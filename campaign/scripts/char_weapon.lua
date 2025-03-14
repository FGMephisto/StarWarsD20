-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	self.onDataChanged();
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));

	DB.addHandler(getDatabaseNode(), "onChildUpdate", onDataChanged);
end
function onClose()
	DB.removeHandler(getDatabaseNode(), "onChildUpdate", onDataChanged);
end

function onLockModeChanged(bReadOnly)
	local tFields = { "type", "name", "attack1", "attack2", "attack3", "attack4", "attacks", "rangeincrement", "maxammo", "idelete", };
	WindowManager.callSafeControlsSetLockMode(self, tFields, bReadOnly);
end

local m_sClass = "";
local m_sRecord = "";
function onLinkChanged()
	local node = getDatabaseNode();
	local sClass, sRecord = DB.getValue(node, "shortcut", "", "");
	if sClass ~= m_sClass or sRecord ~= m_sRecord then
		m_sClass = sClass;
		m_sRecord = sRecord;
		
		local sInvList = DB.getPath(DB.getChild(node, "..."), "inventorylist") .. ".";
		if sRecord:sub(1, #sInvList) == sInvList then
			carried.setLink(DB.findNode(DB.getPath(sRecord, "carried")));
		end
	end
end

function onDataChanged()
	onLinkChanged();
	onDamageChanged();
	
	local bRanged = (type.getValue() == 1);
	label_range.setVisible(bRanged);
	rangeincrement.setVisible(bRanged);
	label_ammo.setVisible(bRanged);
	maxammo.setVisible(bRanged);
	ammocounter.setVisible(bRanged);
end

function onDamageChanged()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = DB.getChild(nodeWeapon, "...")
	local rActor = ActorManager.resolveActor(nodeChar);
	
	local aDamage = {};
	local aDamageNodes = UtilityManager.getNodeSortedChildren(nodeWeapon, "damagelist");
	for _,v in ipairs(aDamageNodes) do
		local aDice = DB.getValue(v, "dice", {});
		local nMod = DB.getValue(v, "bonus", 0);

		local sAbility = DB.getValue(v, "stat", "");
		if sAbility ~= "" then
			local nMult = DB.getValue(v, "statmult", 1);
			local nMax = DB.getValue(v, "statmax", 0);
			local nAbilityBonus = ActorManager35E.getAbilityBonus(rActor, sAbility);
			if nMax > 0 then
				nAbilityBonus = math.min(nAbilityBonus, nMax);
			end
			if nAbilityBonus > 0 and nMult ~= 1 then
				nAbilityBonus = math.floor(nMult * nAbilityBonus);
			end
			nMod = nMod + nAbilityBonus;
		end
		
		if #aDice > 0 or nMod ~= 0 then
			local sDamage = StringManager.convertDiceToString(DB.getValue(v, "dice", {}), nMod);
			local sType = DB.getValue(v, "type", "");
			if sType ~= "" then
				sDamage = sDamage .. " " .. sType;
			end
			table.insert(aDamage, sDamage);
		end
	end

	damageview.setValue(table.concat(aDamage, "\n+ "));
end

function onDamageAction(draginfo)
	local rActor, rDamage = CharManager.getWeaponDamageRollStructures(getDatabaseNode());
	
	ActionDamage.performRoll(draginfo, rActor, rDamage);
	return true;
end
