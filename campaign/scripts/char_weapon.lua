-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars D20 (Flat Weapon Record script)
--

function onInit()
	self.onLinkChanged();
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));

	if minisheet then
		carried.setVisible(false);
	end

	local nodeWeapon = getDatabaseNode();
	local nodeChar = DB.getChild(nodeWeapon, "...");
	DB.addHandler(DB.getPath(nodeWeapon, "shortcut"), "onUpdate", self.onLinkChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "type"), "onUpdate", self.onTypeChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "firingmodes"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "properties"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "maxammo"), "onUpdate", self.onTypeChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "rangeincrement"), "onUpdate", self.onTypeChanged);
	DB.addHandler(nodeWeapon, "onChildUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeWeapon, "carried"), "onUpdate", self.onCarriedChanged);
	DB.addHandler(DB.getPath(nodeChar, "abilities.*.bonus"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "attackbonus.base"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "attackbonus.*"), "onChildUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "featlist"), "onChildAdded", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "featlist"), "onChildDeleted", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "featlist.*.name"), "onUpdate", self.onDataChanged);
end

function onClose()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = DB.getChild(nodeWeapon, "...");
	DB.removeHandler(DB.getPath(nodeWeapon, "shortcut"), "onUpdate", self.onLinkChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "type"), "onUpdate", self.onTypeChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "firingmodes"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "properties"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "maxammo"), "onUpdate", self.onTypeChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "rangeincrement"), "onUpdate", self.onTypeChanged);
	DB.removeHandler(nodeWeapon, "onChildUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeWeapon, "carried"), "onUpdate", self.onCarriedChanged);
	DB.removeHandler(DB.getPath(nodeChar, "abilities.*.bonus"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "attackbonus.base"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "attackbonus.*"), "onChildUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "featlist"), "onChildAdded", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "featlist"), "onChildDeleted", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "featlist.*.name"), "onUpdate", self.onDataChanged);
end

function onLockModeChanged(bReadOnly)
	if minisheet then
		bReadOnly = true;
	end
	local tFields = { "type", "name", "idelete", };
	WindowManager.callSafeControlsSetLockMode(self, tFields, bReadOnly);
	
	if not minisheet then
		WindowManager.callSafeControlsSetVisible(self, { "carried", }, true);
	end

	self.onTypeChanged();
	self.onDataChanged();
end

function onCarriedChanged()
	if windowlist and windowlist.applyFilter then
		windowlist.applyFilter();
	end
end

function onModeChanged()
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
end

local _sClass = "";
local _sRecord = "";
function onLinkChanged()
	local node = getDatabaseNode();
	local sClass, sRecord = DB.getValue(node, "shortcut", "", "");
	if sClass ~= _sClass or sRecord ~= _sRecord then
		_sClass = sClass;
		_sRecord = sRecord;
		
		local sInvList = DB.getPath(DB.getChild(node, "..."), "inventorylist") .. ".";
		if sRecord:sub(1, #sInvList) == sInvList then
			carried.setLink(DB.findNode(DB.getPath(sRecord, "carried")));
		end
	end
end

function onTypeChanged()
	local node = getDatabaseNode();
	local nType = DB.getValue(node, "type", 0);
	local bIsRanged = (nType == 1);
	local bHasAmmoCapability = (nType == 1 or nType == 2);
	local bReadOnly = minisheet or WindowManager.getWindowReadOnlyState(self);
	local bHasRange = (DB.getValue(node, "rangeincrement", 0) ~= 0);
	local bHasAmmo = (DB.getValue(node, "maxammo", 0) ~= 0);

	WindowManager.callSafeControlsSetVisible(self, { "label_firemode", "firemode" }, bIsRanged);

	if attackview then
		if bIsRanged then
			attackview.setAnchor("left", "firemode", "right", "absolute", 15);
		else
			attackview.setAnchor("left", "area_details_row2", "left", "absolute", 0);
		end
	end

	local bShowRangedSection = (bHasAmmoCapability and (bHasRange or bHasAmmo or not bReadOnly));
	if bShowRangedSection then
		sub_ranged.setValue("char_weapon_ranged", node);
	else
		sub_ranged.setValue("", "");
	end

	self.updateFireModeControl();
end

function onDataChanged()
	self.onAttackChanged();
	self.onDamageChanged();
	self.updateFireModeControl();
end

function getAvailableFiringModes(nodeWeapon)
	local nodeChar = DB.getChild(nodeWeapon, "...");
	local bRapidShot = CharManager.hasFeat(nodeChar, "Rapid Shot");
	local bMultishot = CharManager.hasFeat(nodeChar, "Multishot");

	local sModes = StringManager.trim(DB.getValue(nodeWeapon, "firingmodes", ""):lower());
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
		sModes = StringManager.trim(DB.getValue(nodeWeapon, "properties", ""):lower());
	end

	local bOnly = (sModes:find("only") ~= nil);
	local bHasMultifire = (sModes:find("m") ~= nil or sModes:find("multifire") ~= nil);
	local bHasAutofire = (sModes:find("a") ~= nil or sModes:find("autofire") ~= nil);

	local tModes = {};

	-- 1. Single / Rapid
	if not bOnly then
		table.insert(tModes, { 
			sValue = "", 
			sLabel = Interface.getString("char_menu_firemode_single") or "Single", 
			sShort = "S" 
		});
		if bRapidShot then
			table.insert(tModes, { 
				sValue = "rapid", 
				sLabel = Interface.getString("char_menu_firemode_rapid") or "Rapid Shot (-2)", 
				sShort = "R" 
			});
		end
	end

	-- 2. Multifire / Multifire+Rapid
	if bHasMultifire then
		local sMLabel = bMultishot and (Interface.getString("char_menu_firemode_multifire_multishot") or "Multifire (-2)")
		                           or (Interface.getString("char_menu_firemode_multifire") or "Multifire (-4)");
		table.insert(tModes, { 
			sValue = "multifire", 
			sLabel = sMLabel, 
			sShort = "M" 
		});
		if bRapidShot then
			local sMRLabel = bMultishot and (Interface.getString("char_menu_firemode_multifire_rapid_multishot") or "Multifire & Rapid Shot (-4)")
			                            or (Interface.getString("char_menu_firemode_multifire_rapid") or "Multifire & Rapid Shot (-6)");
			table.insert(tModes, { 
				sValue = "multifire_rapid", 
				sLabel = sMRLabel, 
				sShort = "M+R" 
			});
		end
	end

	-- 3. Autofire / Autofire+Rapid
	if bHasAutofire then
		local sALabel = bMultishot and (Interface.getString("char_menu_firemode_autofire_multishot") or "Autofire (-4)")
		                           or (Interface.getString("char_menu_firemode_autofire") or "Autofire (-6)");
		table.insert(tModes, { 
			sValue = "autofire", 
			sLabel = sALabel, 
			sShort = "A" 
		});
		if bRapidShot then
			local sARLabel = bMultishot and (Interface.getString("char_menu_firemode_autofire_rapid_multishot") or "Autofire & Rapid Shot (-6)")
			                            or (Interface.getString("char_menu_firemode_autofire_rapid") or "Autofire & Rapid Shot (-8)");
			table.insert(tModes, { 
				sValue = "autofire_rapid", 
				sLabel = sARLabel, 
				sShort = "A+R" 
			});
		end
	end

	if #tModes == 0 then
		table.insert(tModes, { 
			sValue = "", 
			sLabel = Interface.getString("char_menu_firemode_single") or "Single", 
			sShort = "S" 
		});
	end

	return tModes;
end

function updateFireModeControl()
	local nodeWeapon = getDatabaseNode();
	if not nodeWeapon then return; end
	if firemode then
		local tModes = self.getAvailableFiringModes(nodeWeapon);
		local tLabels = {};
		local tValues = {};
		local sDefaultLabel = "S";
		local sDefaultVal = "";

		for i, vMode in ipairs(tModes) do
			if i == 1 then
				sDefaultLabel = vMode.sShort;
				sDefaultVal = vMode.sValue;
			else
				table.insert(tLabels, vMode.sShort);
				table.insert(tValues, vMode.sValue);
			end
		end
		
		local sCurrent = DB.getValue(nodeWeapon, "firemode", "");
		local bValid = false;
		if sCurrent == sDefaultVal then
			bValid = true;
		else
			for _, vVal in ipairs(tValues) do
				if sCurrent == vVal then
					bValid = true;
					break;
				end
			end
		end
		if not bValid then
			DB.setValue(nodeWeapon, "firemode", "string", sDefaultVal);
			sCurrent = sDefaultVal;
		end

		firemode.initialize(table.concat(tLabels, "|"), table.concat(tValues, "|"), sDefaultLabel, sCurrent);
		firemode.setReadOnly(#tModes <= 1);
		self.updateFireModeTooltip();
	end
end

function updateFireModeTooltip()
	if firemode then
		local nodeWeapon = getDatabaseNode();
		local nodeChar = DB.getChild(nodeWeapon, "...");
		local bMultishot = CharManager.hasFeat(nodeChar, "Multishot");
		local sCurrent = DB.getValue(nodeWeapon, "firemode", ""):lower();
		
		local sTip = Interface.getString("char_menu_firemode_single") or "Single";
		if sCurrent == "rapid" then
			sTip = Interface.getString("char_menu_firemode_rapid") or "Rapid Shot (-2)";
		elseif sCurrent == "multifire" then
			sTip = bMultishot and (Interface.getString("char_menu_firemode_multifire_multishot") or "Multifire (-2)")
			                  or (Interface.getString("char_menu_firemode_multifire") or "Multifire (-4)");
		elseif sCurrent == "multifire_rapid" then
			sTip = bMultishot and (Interface.getString("char_menu_firemode_multifire_rapid_multishot") or "Multifire & Rapid Shot (-4)")
			                  or (Interface.getString("char_menu_firemode_multifire_rapid") or "Multifire & Rapid Shot (-6)");
		elseif sCurrent == "autofire" then
			sTip = bMultishot and (Interface.getString("char_menu_firemode_autofire_multishot") or "Autofire (-4)")
			                  or (Interface.getString("char_menu_firemode_autofire") or "Autofire (-6)");
		elseif sCurrent == "autofire_rapid" then
			sTip = bMultishot and (Interface.getString("char_menu_firemode_autofire_rapid_multishot") or "Autofire & Rapid Shot (-6)")
			                  or (Interface.getString("char_menu_firemode_autofire_rapid") or "Autofire & Rapid Shot (-8)");
		end
		firemode.setTooltipText(sTip);
	end
end

function getAttackCount()
	local nodeWeapon = getDatabaseNode();
	local nType = DB.getValue(nodeWeapon, "type", 0);
	if nType == 2 then
		local nodeChar = DB.getChild(nodeWeapon, "...");
		local bITWF = CharManager.hasFeat(nodeChar, "Improved Two-Weapon Fighting");
		return bITWF and 2 or 1;
	end

	local nBaseAttacks = math.max(DB.getValue(nodeWeapon, "attacks", 1), 1);
	local sFireMode = DB.getValue(nodeWeapon, "firemode", "");

	local nAttacks = nBaseAttacks;
	if sFireMode == "rapid" or sFireMode == "multifire" then
		nAttacks = nBaseAttacks + 1;
	elseif sFireMode == "multifire_rapid" or sFireMode == "autofire" then
		nAttacks = nBaseAttacks + 2;
	elseif sFireMode == "autofire_rapid" then
		nAttacks = nBaseAttacks + 3;
	end

	return math.min(math.max(nAttacks, 1), 8);
end

function onAttackChanged()
	local nodeWeapon = getDatabaseNode();
	local nAttacks = self.getAttackCount();
	local nType = DB.getValue(nodeWeapon, "type", 0);
	local tAttack = {};

	local nViewOffset = 1;
	local nViewSpacing = 2;
	local nViewFieldWidth = 30;
	if attackview then
		attackview.setAnchoredWidth(nViewOffset + ((nViewFieldWidth + nViewSpacing) * (nAttacks)));
	end
	for i = 1, 8 do
		local ctrl = self["attackview" .. i];
		if ctrl then
			ctrl.setVisible(nAttacks >= i);
		end
	end
	
	for i = 1, nAttacks do
		local nAtk = self.calcAttackBonus(i);
		local ctrl = self["attackview" .. i];
		if ctrl then
			ctrl.setValue(nAtk);
		end
		local sPrefix = (nType == 2) and " (OH)" or "";
		local sAtk = (i == 1) and string.format("%s%s: %+d", Interface.getString("action_attack_tag"), sPrefix, nAtk) 
		                      or string.format("%s%s #%d: %+d", Interface.getString("action_attack_tag"), sPrefix, i, nAtk);
		table.insert(tAttack, sAtk);
	end

	local nDC = self.getStunDC();
	if button_stun then
		if nDC > 0 then
			button_stun.setVisible(true);
			button_stun.setTooltipText(string.format("%s: DC %d", Interface.getString("char_tooltip_actionstun") or "Fortitude Attack (Stun)", nDC));
		else
			button_stun.setVisible(false);
		end
	end

	button_attack.setTooltipText(table.concat(tAttack, "\r"));
end

function getStunDC()
	local nodeWeapon = getDatabaseNode();
	local nDC = tonumber(DB.getValue(nodeWeapon, "stundc", "")) or 0;
	local sProps = DB.getValue(nodeWeapon, "properties", ""):lower();
	local bHasStunProp = sProps:match("stun");
	
	if nDC == 0 or not bHasStunProp then
		local _, sRecord = DB.getValue(nodeWeapon, "shortcut", "", "");
		if sRecord ~= "" then
			local nodeItem = DB.findNode(sRecord);
			if nodeItem then
				if nDC == 0 then
					nDC = tonumber(DB.getValue(nodeItem, "stundc", "")) or 0;
				end
				local sItemProps = DB.getValue(nodeItem, "properties", ""):lower();
				local sItemDmgType = DB.getValue(nodeItem, "damagetype", ""):lower();
				if sItemProps:match("stun") or sItemDmgType:match("stun") then
					bHasStunProp = true;
				end
			end
		end
	end
	
	if nDC > 0 then
		return nDC;
	elseif bHasStunProp then
		return 15;
	end
	return 0;
end

function onDamageChanged()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = DB.getChild(nodeWeapon, "...")
	local rActor = ActorManager.resolveActor(nodeChar);
	local sFireMode = DB.getValue(nodeWeapon, "firemode", ""):lower();
	local bMultifire = (sFireMode == "multifire" or sFireMode == "multifire_rapid");
	
	local tDamage = {};
	local aDmgNodes = UtilityManager.getNodeSortedChildren(nodeWeapon, "damagelist");
	for i, v in ipairs(aDmgNodes) do
		local aDice = DB.getValue(v, "dice", {});
		local nMod = DB.getValue(v, "bonus", 0);
		local sStat = DB.getValue(v, "stat", "");
		local nStatMult = DB.getValue(v, "statmult", 1);
		local nStatMax = DB.getValue(v, "statmax", 0);
		
		if sStat ~= "" then
			local nStatBonus = ActorManager35E.getAbilityBonus(rActor, sStat);
			if nStatBonus > 0 then
				local nEffMult = nStatMult;
				local nType = DB.getValue(nodeWeapon, "type", 0);
				if nType == 2 and sStat == "strength" then
					nEffMult = 0.5;
				end
				nStatBonus = math.floor(nStatBonus * nEffMult);
				if nStatMax > 0 then
					nStatBonus = math.min(nStatBonus, nStatMax);
				end
			end
			nMod = nMod + nStatBonus;
		end
		
		local sDmg = StringManager.convertDiceToString(aDice, nMod);
		if sDmg ~= "" then
			local sType = DB.getValue(v, "type", "");
			if sType ~= "" then
				sDmg = sDmg .. " " .. sType;
			end
			table.insert(tDamage, sDmg);
		end
	end

	if bMultifire and (#tDamage > 0) then
		tDamage[1] = "[+1 DIE] " .. tDamage[1];
	end

	local sDamage = table.concat(tDamage, " + ");
	button_damage.setTooltipText(string.format("%s: %s", Interface.getString("action_damage_tag"), sDamage));
	damageview.setValue(sDamage);
end

function onFortitudeAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local rActor, rAttack = CharManager.getWeaponAttackRollStructures(nodeWeapon);
	rAttack.order = 1;
	rAttack.modifier = self.calcAttackBonus(1);
	rAttack.stun = true;
	
	local nDC = self.getStunDC();
	if nDC == 0 then
		nDC = 15;
	end
	rAttack.stundc = nDC;
	
	local rRoll = ActionAttack.getRoll(rActor, rAttack);
	rRoll.sDesc = rRoll.sDesc .. string.format(" [STUN] [FORT DC %d]", nDC);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
	return true;
end

function onFullAttackAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local rActor, rAttack = CharManager.getWeaponAttackRollStructures(nodeWeapon);
	local nType = DB.getValue(nodeWeapon, "type", 0);
	
	local rRolls = {};
	local nAttacks = self.getAttackCount();
	for i = 1, nAttacks do
		rAttack.modifier = self.calcAttackBonus(i);
		rAttack.order = i;
		local rSingleRoll = ActionAttack.getRoll(rActor, rAttack);
		if nType == 2 then
			rSingleRoll.sDesc = rSingleRoll.sDesc .. " [OFF-HAND]";
		end
		table.insert(rRolls, rSingleRoll);
	end
	if not OptionsManager.isOption("RMMT", "off") and (#rRolls > 1) then
		for _,v in ipairs(rRolls) do
			v.sDesc = v.sDesc .. " [FULL]";
		end
	end
	
	ActionsManager.performMultiAction(draginfo, rActor, "attack", rRolls);
	return true;
end

function onSingleAttackAction(n, draginfo)
	local nodeWeapon = getDatabaseNode();
	local rActor, rAttack = CharManager.getWeaponAttackRollStructures(nodeWeapon);
	local nType = DB.getValue(nodeWeapon, "type", 0);
	rAttack.order = n or 1;
	rAttack.modifier = self.calcAttackBonus(n or 1);
	
	local rRoll = ActionAttack.getRoll(rActor, rAttack);
	if nType == 2 then
		rRoll.sDesc = rRoll.sDesc .. " [OFF-HAND]";
	end
	ActionsManager.performAction(draginfo, rActor, rRoll);
	return true;
end

function onDamageAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local rActor, rDamage = CharManager.getWeaponDamageRollStructures(nodeWeapon);
	local sFireMode = DB.getValue(nodeWeapon, "firemode", ""):lower();
	local bMultifire = (sFireMode == "multifire" or sFireMode == "multifire_rapid");
	
	if bMultifire and rDamage and rDamage.clauses and (#rDamage.clauses > 0) then
		local aDice = rDamage.clauses[1].dice;
		if aDice and #aDice > 0 then
			table.insert(aDice, aDice[1]);
		end
	end

	ActionDamageD20.performRoll(draginfo, rActor, rDamage);
	return true;
end

function calcAttackBonus(n)
	local nodeWeapon = getDatabaseNode();
	local nodeChar = DB.getChild(nodeWeapon, "...");
	local rActor, rAttack = CharManager.getWeaponAttackRollStructures(nodeWeapon);

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
	nBonus = nBonus + DB.getValue(nodeWeapon, "bonus", 0);
	
	local sFireMode = DB.getValue(nodeWeapon, "firemode", "");
	local bMultishot = CharManager.hasFeat(nodeChar, "Multishot");

	local nModePenalty = 0;
	local nExtraTopAttacks = 0;

	if sFireMode == "rapid" then
		nModePenalty = -2;
		nExtraTopAttacks = 1;
	elseif sFireMode == "multifire" then
		nModePenalty = bMultishot and -2 or -4;
		nExtraTopAttacks = 1;
	elseif sFireMode == "multifire_rapid" then
		nModePenalty = bMultishot and -4 or -6;
		nExtraTopAttacks = 2;
	elseif sFireMode == "autofire" then
		nModePenalty = bMultishot and -4 or -6;
		nExtraTopAttacks = 2;
	elseif sFireMode == "autofire_rapid" then
		nModePenalty = bMultishot and -6 or -8;
		nExtraTopAttacks = 3;
	end

	nBonus = nBonus + nModePenalty;

	local nType = DB.getValue(nodeWeapon, "type", 0);
	if nType == 2 then
		local bTWF = CharManager.hasFeat(nodeChar, "Two-Weapon Fighting") or CharManager.hasFeat(nodeChar, "Multiweapon Fighting");
		local bAmbi = CharManager.hasFeat(nodeChar, "Ambidexterity");
		local sProps = DB.getValue(nodeWeapon, "properties", ""):lower();
		local bLight = sProps:match("light") or sProps:match("small");
		
		local nTWFPenalty = -10;
		if bTWF and bAmbi then
			nTWFPenalty = bLight and -2 or -4;
		elseif bTWF then
			nTWFPenalty = bLight and -4 or -8;
		elseif bAmbi then
			nTWFPenalty = -6;
		else
			nTWFPenalty = bLight and -8 or -10;
		end
		nBonus = nBonus + nTWFPenalty;
	end

	local nIterativeStep = 1;
	if (n or 1) > (1 + nExtraTopAttacks) then
		nIterativeStep = (n or 1) - nExtraTopAttacks;
	end

	nBonus = nBonus + DB.getValue(nodeWeapon, "attack" .. nIterativeStep .. "modifier", 0);
	nBonus = nBonus + ((nIterativeStep - 1) * -5);

	return nBonus;
end
