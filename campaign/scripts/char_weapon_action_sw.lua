-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars D20 (Child Action script)
--

function onInit()
	local nodeAction = getDatabaseNode();
	local nodeWeapon = nodeAction.getParent().getParent();
	local nodeChar = DB.getChild(nodeWeapon, "...");

	DB.addHandler(nodeAction, "onChildUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "name"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "properties"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "firingmodes"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "rangeincrement"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "maxammo"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "abilities.*.bonus"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "attackbonus.base"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "attackbonus.*"), "onChildUpdate", self.onDataChanged);

	self.updateDisplay();
	self.updateFireModeControl();
	self.onDataChanged();
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
end

function onClose()
	local nodeAction = getDatabaseNode();
	local nodeWeapon = nodeAction.getParent().getParent();
	local nodeChar = DB.getChild(nodeWeapon, "...");

	DB.removeHandler(nodeAction, "onChildUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "name"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "properties"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "firingmodes"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "rangeincrement"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "maxammo"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "abilities.*.bonus"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "attackbonus.base"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "attackbonus.*"), "onChildUpdate", self.onDataChanged);
end

function onLockModeChanged(bReadOnly)
	WindowManager.callSafeControlsSetLockMode(self, { "name", "idelete" }, bReadOnly);
	
	local nodeAction = getDatabaseNode();
	local nMaxAmmo = DB.getValue(nodeAction, "maxammo", 0);
	local bShowAmmo = not bReadOnly or (nMaxAmmo > 0);
	local nAtkType = DB.getValue(nodeAction, "atktype", 0);
	if nAtkType == 0 then
		bShowAmmo = false;
	end
	WindowManager.callSafeControlsSetVisible(self, { "label_ammo", "maxammo", "ammocounter" }, bShowAmmo);
end

function onModeChanged()
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
end

function onDataChanged()
	self.updateDisplay();
	self.updateFireModeControl();
	self.onAttackChanged();
	self.onDamageChanged();
end

function updateDisplay()
	local nodeAction = getDatabaseNode();
	local nAtkType = DB.getValue(nodeAction, "atktype", 0);
	local bRanged = (nAtkType == 1 or nAtkType == 2);
	local nMaxAmmo = DB.getValue(nodeAction, "maxammo", 0);
	if nMaxAmmo == 0 then
		local nodeWeapon = nodeAction.getParent().getParent();
		nMaxAmmo = DB.getValue(nodeWeapon, "maxammo", 0);
	end
	local bReadOnly = WindowManager.getWindowReadOnlyState(self);

	WindowManager.callSafeControlsSetVisible(self, { "firemode" }, bRanged);
	WindowManager.callSafeControlsSetVisible(self, { "label_ammo", "maxammo", "ammocounter" }, (bRanged or nMaxAmmo > 0) and (not bReadOnly or nMaxAmmo > 0));
end

function getAvailableFiringModes(nodeAction)
	local sModes = StringManager.trim(DB.getValue(nodeAction, "firingmodes", ""):lower());
	local nodeWeapon = nodeAction.getParent().getParent();
	if sModes == "" then
		sModes = StringManager.trim(DB.getValue(nodeWeapon, "firingmodes", ""):lower());
		if sModes == "" then
			local _, sRecord = DB.getValue(nodeWeapon, "shortcut", "", "");
			if sRecord ~= "" then
				local nodeItem = DB.findNode(sRecord);
				if nodeItem then
					sModes = StringManager.trim(DB.getValue(nodeItem, "firingmodes", ""):lower());
					if sModes == "" then
						sModes = StringManager.trim(DB.getValue(nodeItem, "properties", ""):lower());
					end
				end
			end
		end
		if sModes == "" then
			sModes = StringManager.trim(DB.getValue(nodeAction, "properties", ""):lower());
			if sModes == "" then
				sModes = StringManager.trim(DB.getValue(nodeWeapon, "properties", ""):lower());
			end
		end
	end

	local tModes = {};
	table.insert(tModes, { sValue = "", sLabel = Interface.getString("char_menu_firemode_single") or "Single" });
	
	local bHasMultifire = (sModes == "m" or sModes:find("m/") or sModes:find("/m") or sModes:find("multifire") or sModes:find("%f[%a]m%f[%A]"));
	local bHasMultishot = sModes:find("multishot") ~= nil;
	local bHasAutofire = (sModes == "a" or sModes:find("a/") or sModes:find("/a") or sModes:find("autofire") or sModes:find("%f[%a]a%f[%A]"));

	if bHasMultifire then
		table.insert(tModes, { sValue = "multifire", sLabel = Interface.getString("char_menu_firemode_multifire") or "Multifire (-4)" });
	end
	if bHasMultishot then
		table.insert(tModes, { sValue = "multishot", sLabel = Interface.getString("char_menu_firemode_multishot") or "Multishot (-4)" });
	end
	if bHasAutofire then
		table.insert(tModes, { sValue = "autofire", sLabel = Interface.getString("char_menu_firemode_autofire") or "Autofire (-6)" });
	end
	
	return tModes;
end

function updateFireModeControl()
	local nodeAction = getDatabaseNode();
	if not nodeAction then return; end
	if firemode then
		local tModes = self.getAvailableFiringModes(nodeAction);
		local tLabels = {};
		local tValues = {};
		for _, vMode in ipairs(tModes) do
			if vMode.sValue ~= "" then
				local sShort = "S";
				if vMode.sValue == "multifire" then sShort = "M";
				elseif vMode.sValue == "autofire" then sShort = "A";
				elseif vMode.sValue == "multishot" then sShort = "MS";
				end
				table.insert(tLabels, sShort);
				table.insert(tValues, vMode.sValue);
			end
		end
		
		local sDefaultLabel = "S";
		local sCurrent = DB.getValue(nodeAction, "firemode", "");
		local bValid = false;
		if sCurrent == "" or sCurrent == "single" then
			bValid = true;
			sCurrent = "";
		else
			for _, vVal in ipairs(tValues) do
				if sCurrent == vVal then
					bValid = true;
					break;
				end
			end
		end
		if not bValid then
			DB.setValue(nodeAction, "firemode", "string", "");
			sCurrent = "";
		end

		firemode.initialize(table.concat(tLabels, "|"), table.concat(tValues, "|"), sDefaultLabel, sCurrent);
		firemode.setReadOnly(#tModes <= 1);
		self.updateFireModeTooltip();
	end
end

function updateFireModeTooltip()
	if firemode then
		local sCurrent = DB.getValue(getDatabaseNode(), "firemode", ""):lower();
		local sTip = Interface.getString("char_menu_firemode_single") or "Single";
		if sCurrent == "multifire" then
			sTip = Interface.getString("char_menu_firemode_multifire") or "Multifire (-4)";
		elseif sCurrent == "autofire" then
			sTip = Interface.getString("char_menu_firemode_autofire") or "Autofire (-6)";
		elseif sCurrent == "multishot" then
			sTip = Interface.getString("char_menu_firemode_multishot") or "Multishot (-4)";
		end
		firemode.setTooltipText(string.format("%s: %s", Interface.getString("char_menu_firemode") or "Fire Mode", sTip));
	end
end

function getFireModeInfo(nodeAction)
	local sFireMode = DB.getValue(nodeAction, "firemode", ""):lower();
	local nPenalty = 0;
	local sTag = nil;
	local nAmmoCost = 1;

	local tModes = self.getAvailableFiringModes(nodeAction);
	local bHasMultifire, bHasMultishot, bHasAutofire = false, false, false;
	for _, v in ipairs(tModes) do
		if v.sValue == "multifire" then bHasMultifire = true; end
		if v.sValue == "multishot" then bHasMultishot = true; end
		if v.sValue == "autofire" then bHasAutofire = true; end
	end

	if (sFireMode == "multifire") and bHasMultifire then
		nPenalty = -4;
		sTag = "[Multifire]";
		nAmmoCost = 2;
	elseif (sFireMode == "multishot") and bHasMultishot then
		nPenalty = -2;
		sTag = "[MultiShot]";
		nAmmoCost = 2;
	elseif (sFireMode == "autofire") and bHasAutofire then
		nPenalty = -6;
		sTag = "[Autofire]";
		nAmmoCost = 10;
	else
		sFireMode = "single";
		nAmmoCost = 1;
	end

	return sFireMode, nPenalty, sTag, nAmmoCost;
end

function calcAttackBonus(n)
	local nodeAction = getDatabaseNode();
	local nodeWeapon = nodeAction.getParent().getParent();
	local nodeChar = DB.getChild(nodeWeapon, "...");
	local rActor, rAttack = CharManager.getWeaponAttackRollStructures(nodeWeapon, nodeAction);

	local nBonus = DB.getValue(nodeChar, "attackbonus.base", 0);
	nBonus = nBonus + ActorManager35E.getAbilityBonus(rActor, rAttack.stat);
	if rAttack.range == "R" then
		nBonus = nBonus + DB.getValue(nodeChar, "attackbonus.ranged.size", 0);
		nBonus = nBonus + DB.getValue(nodeChar, "attackbonus.ranged.misc", 0);
		nBonus = nBonus + DB.getValue(nodeChar, "attackbonus.ranged.temporary", 0);
	else
		nBonus = nBonus + DB.getValue(nodeChar, "attackbonus.melee.size", 0);
		nBonus = nBonus + DB.getValue(nodeChar, "attackbonus.melee.misc", 0);
		nBonus = nBonus + DB.getValue(nodeChar, "attackbonus.melee.temporary", 0);
	end
	nBonus = nBonus + DB.getValue(nodeAction, "bonus", 0);
	nBonus = nBonus + DB.getValue(nodeAction, "attack" .. (n or 1) .. "modifier", 0);
	nBonus = nBonus + (((n or 1) - 1) * -5);

	return nBonus;
end

function getActionAttackBonuses(nodeAction)
	local nodeWeapon = nodeAction.getParent().getParent();
	local nodeChar = DB.getChild(nodeWeapon, "...");
	local nBAB = DB.getValue(nodeChar, "attackbonus.base", 0);
	local nDefaultAttacks = math.max(math.min(math.floor((nBAB - 1) / 5) + 1, 4), 1);
	local nAttacks = DB.getValue(nodeAction, "attacks", 0);
	if nAttacks <= 0 then
		nAttacks = nDefaultAttacks;
	end

	local nAtkType = DB.getValue(nodeAction, "atktype", 0);
	local bRanged = (nAtkType == 1 or nAtkType == 2);
	local sFireMode, nModeMod, sModeTag, nAmmoCost = self.getFireModeInfo(nodeAction);
	local tBonuses = {};

	if bRanged and sFireMode == "autofire" then
		table.insert(tBonuses, self.calcAttackBonus(1) + nModeMod);
		table.insert(tBonuses, self.calcAttackBonus(1) + nModeMod);
		table.insert(tBonuses, self.calcAttackBonus(1) + nModeMod);
		for i = 2, nAttacks do
			table.insert(tBonuses, self.calcAttackBonus(i) + nModeMod);
		end
	elseif bRanged and (sFireMode == "multifire" or sFireMode == "multishot") then
		table.insert(tBonuses, self.calcAttackBonus(1) + nModeMod);
		table.insert(tBonuses, self.calcAttackBonus(1) + nModeMod);
		for i = 2, nAttacks do
			table.insert(tBonuses, self.calcAttackBonus(i) + nModeMod);
		end
	else
		for i = 1, nAttacks do
			table.insert(tBonuses, self.calcAttackBonus(i));
		end
	end

	return tBonuses, sFireMode, sModeTag, nAmmoCost;
end

function onAttackChanged()
	local nodeAction = getDatabaseNode();
	local tBonuses, sFireMode, sModeTag, nAmmoCost = self.getActionAttackBonuses(nodeAction);

	local nViewOffset = 1;
	local nViewSpacing = 2;
	local nViewFieldWidth = 30;

	local tAttack = {};
	for i = 1, 8 do
		local cAttack = self["attackview" .. i];
		if cAttack then
			if i <= #tBonuses then
				cAttack.setValue(tBonuses[i]);
				cAttack.setVisible(true);
				table.insert(tAttack, string.format("%+d", tBonuses[i]));
			else
				cAttack.setValue(0);
				cAttack.setVisible(false);
			end
		end
	end

	if attackview then
		attackview.setAnchoredWidth(nViewOffset + ((nViewFieldWidth + nViewSpacing) * #tBonuses));
	end
	if button_attack then
		local sAttack = table.concat(tAttack, "/");
		button_attack.setTooltipText(string.format("%s: %s", Interface.getString("action_attack_tag") or "Attack", sAttack));
	end
end

function onDamageChanged()
	local nodeAction = getDatabaseNode();
	local nodeWeapon = nodeAction.getParent().getParent();
	local rActor, rDamage = CharManager.getWeaponDamageRollStructures(nodeWeapon, nodeAction);

	local tDamage = {};
	for _, v in ipairs(rDamage.clauses) do
		local sDmg = StringManager.convertDiceToString(v.dice, v.modifier);
		if (v.dmgtype or "") ~= "" then
			sDmg = sDmg .. " " .. v.dmgtype;
		end
		table.insert(tDamage, sDmg);
	end

	local sDamageStr = table.concat(tDamage, " + ");
	if button_damage then
		button_damage.setTooltipText(string.format("%s: %s", Interface.getString("action_damage_tag") or "Damage", sDamageStr));
	end
	if damageview then
		damageview.setValue(sDamageStr);
	end
end

function deductAmmo(nCost)
	local nodeAction = getDatabaseNode();
	local nMax = DB.getValue(nodeAction, "maxammo", 0);
	if nMax > 0 and nCost > 0 then
		local nCurrent = DB.getValue(nodeAction, "ammo", 0);
		local nNew = math.min(nCurrent + nCost, nMax);
		DB.setValue(nodeAction, "ammo", "number", nNew);
	end
end

function onFullAttackAction(draginfo)
	local nodeAction = getDatabaseNode();
	local nodeWeapon = nodeAction.getParent().getParent();
	local rActor, rAttack = CharManager.getWeaponAttackRollStructures(nodeWeapon, nodeAction);

	local tBonuses, sFireMode, sModeTag, nAmmoCost = self.getActionAttackBonuses(nodeAction);
	local bRanged = (rAttack.range == "R");

	local rRolls = {};
	for i = 1, #tBonuses do
		rAttack.modifier = tBonuses[i];
		rAttack.order = i;
		local rRoll = ActionAttack.getRoll(rActor, rAttack);
		if bRanged and sModeTag and not string.match(rRoll.sDesc, "%[" .. sFireMode .. "%]", 1, true) then
			rRoll.sDesc = rRoll.sDesc .. " " .. sModeTag;
		end
		table.insert(rRolls, rRoll);
	end
	if not OptionsManager.isOption("RMMT", "off") and (#rRolls > 1) then
		for _,v in ipairs(rRolls) do
			v.sDesc = v.sDesc .. " [FULL]";
		end
	end
	
	if bRanged then
		self.deductAmmo(nAmmoCost * #rRolls);
	end

	ActionsManager.performMultiAction(draginfo, rActor, "attack", rRolls);
	return true;
end

function onSingleAttackAction(n, draginfo)
	local nodeAction = getDatabaseNode();
	local nodeWeapon = nodeAction.getParent().getParent();
	local rActor, rAttack = CharManager.getWeaponAttackRollStructures(nodeWeapon, nodeAction);

	local tBonuses, sFireMode, sModeTag, nAmmoCost = self.getActionAttackBonuses(nodeAction);
	local bRanged = (rAttack.range == "R");

	rAttack.order = n or 1;
	rAttack.modifier = tBonuses[n or 1] or self.calcAttackBonus(n or 1);
	
	local rRoll = ActionAttack.getRoll(rActor, rAttack);
	if bRanged and sModeTag and not string.match(rRoll.sDesc, "%[" .. sFireMode .. "%]", 1, true) then
		rRoll.sDesc = rRoll.sDesc .. " " .. sModeTag;
	end

	if bRanged then
		self.deductAmmo(nAmmoCost);
	end

	ActionAttack.performRoll(draginfo, rActor, rAttack);
	return true;
end

function onDamageAction(draginfo)
	local nodeAction = getDatabaseNode();
	local nodeWeapon = nodeAction.getParent().getParent();
	local rActor, rDamage = CharManager.getWeaponDamageRollStructures(nodeWeapon, nodeAction);
	
	ActionDamageD20.performRoll(draginfo, rActor, rDamage);
	return true;
end
