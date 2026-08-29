-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars D20
--

local FORCE_POWERS_LABEL = "Force Powers";

function onInit()
	self.updateAbility();

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "abilities"), "onChildUpdate", updateAbility);
	DB.addHandler(DB.getPath(node, "weaponlist"), "onChildUpdate", updateAbility);
	DB.addHandler(DB.getPath(node, "spellset"), "onChildUpdate", updateAbility);

	-- Monitor skill group changes for force power sync
	DB.addHandler(DB.getPath(node, "skilllist.*.group"), "onUpdate", self.onForceSkillChanged);
	DB.addHandler(DB.getPath(node, "skilllist"), "onChildAdded", self.onForceSkillChanged);
	DB.addHandler(DB.getPath(node, "skilllist"), "onChildDeleted", self.onForceSkillChanged);

	self.syncForcePowers();
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "abilities"), "onChildUpdate", updateAbility);
	DB.removeHandler(DB.getPath(node, "weaponlist"), "onChildUpdate", updateAbility);
	DB.removeHandler(DB.getPath(node, "spellset"), "onChildUpdate", updateAbility);

	DB.removeHandler(DB.getPath(node, "skilllist.*.group"), "onUpdate", self.onForceSkillChanged);
	DB.removeHandler(DB.getPath(node, "skilllist"), "onChildAdded", self.onForceSkillChanged);
	DB.removeHandler(DB.getPath(node, "skilllist"), "onChildDeleted", self.onForceSkillChanged);
end

function onLockModeChanged()
	weaponlist.applyFilter();
end

function addWeapon()
	local w = weaponlist.createWindow();
	if w then
		local nodeWeapon = w.getDatabaseNode();
		if nodeWeapon and #DB.getChildList(nodeWeapon, "actionlist") == 0 then
			CharManager.addWeaponAction(nodeWeapon, 0, "Melee Attack");
		end
		w.name.setFocus();
	end
end

local bUpdateLock = false;
function updateAbility()
	if bUpdateLock then
		return;
	end
	bUpdateLock = true;
	for _,v in pairs(weaponlist.getWindows()) do
		if v.onDataChanged then
			v.onDataChanged();
		end
	end
	for _,v in pairs(spellclasslist.getWindows()) do
		if v.onStatUpdate then
			v.onStatUpdate();
		end
	end
	bUpdateLock = false;
end

--------------------------
-- FORCE POWER SYNC
--------------------------

function onForceSkillChanged()
	self.syncForcePowers();
end

-- Collect all skills whose group contains "force" (case-insensitive)
function getForceSkills()
	local nodeChar = getDatabaseNode();
	local aForceSkills = {};
	for _, nodeSkill in ipairs(DB.getChildList(nodeChar, "skilllist")) do
		local sGroup = DB.getValue(nodeSkill, "group", ""):lower();
		if sGroup:match("force") then
			table.insert(aForceSkills, nodeSkill);
		end
	end
	return aForceSkills;
end

-- Find or create the "Force Powers" spell class node
function getOrCreateForceSpellClass(nodeChar)
	local nodeSpellSet = DB.createChild(nodeChar, "spellset");
	for _, nodeClass in ipairs(DB.getChildList(nodeSpellSet)) do
		if DB.getValue(nodeClass, "label", "") == FORCE_POWERS_LABEL then
			return nodeClass;
		end
	end
	-- Create new spell class
	local nodeNew = DB.createChild(nodeSpellSet);
	DB.setValue(nodeNew, "label", "string", FORCE_POWERS_LABEL);
	DB.setValue(nodeNew, "castertype", "string", "points");
	return nodeNew;
end

-- Find the "Force Powers" spell class node (without creating)
function findForceSpellClass(nodeChar)
	for _, nodeClass in ipairs(DB.getChildList(nodeChar, "spellset")) do
		if DB.getValue(nodeClass, "label", "") == FORCE_POWERS_LABEL then
			return nodeClass;
		end
	end
	return nil;
end

-- Main sync function
function syncForcePowers()
	local nodeChar = getDatabaseNode();
	local aForceSkills = self.getForceSkills();

	if #aForceSkills == 0 then
		-- No force skills: delete the Force Powers spell class and hide the list
		local nodeForceClass = self.findForceSpellClass(nodeChar);
		if nodeForceClass then
			DB.deleteNode(nodeForceClass);
		end
		spellclasslist.setVisible(false);
		return;
	end

	-- Force skills exist: get or create the spell class
	local nodeForceClass = self.getOrCreateForceSpellClass(nodeChar);
	local nodeSpells = DB.createChild(nodeForceClass, "spells");

	-- Build lookup of existing power entries by skillpath
	local aExistingPowers = {};
	for _, nodePower in ipairs(DB.getChildList(nodeSpells)) do
		local sSkillPath = DB.getValue(nodePower, "skillpath", "");
		if sSkillPath ~= "" then
			aExistingPowers[sSkillPath] = nodePower;
		end
	end

	-- Build lookup of force skill paths
	local aForceSkillPaths = {};
	for _, nodeSkill in ipairs(aForceSkills) do
		local sPath = DB.getPath(nodeSkill);
		aForceSkillPaths[sPath] = nodeSkill;

		-- Create power entry if it doesn't exist
		if not aExistingPowers[sPath] then
			local nodePower = DB.createChild(nodeSpells);
			DB.setValue(nodePower, "name", "string", DB.getValue(nodeSkill, "label", ""));
			DB.setValue(nodePower, "skillpath", "string", sPath);
		end
	end

	-- Remove orphaned power entries (skillpath no longer points to a force skill)
	for sPath, nodePower in pairs(aExistingPowers) do
		if not aForceSkillPaths[sPath] then
			DB.deleteNode(nodePower);
		end
	end

	-- Also remove any power entries without a skillpath (manually added orphans)
	for _, nodePower in ipairs(DB.getChildList(nodeSpells)) do
		local sSkillPath = DB.getValue(nodePower, "skillpath", "");
		if sSkillPath == "" then
			DB.deleteNode(nodePower);
		end
	end

	spellclasslist.setVisible(true);
end
