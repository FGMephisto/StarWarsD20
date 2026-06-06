--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
-- File adjusted for Star Wars D20
--

local aGroups = {};
local sHeaderClass = "charsheet_skilllist_header";
local _bUpdating = false;

function onInit()
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "skillgroup"), "onChildAdded", self.onGroupListChanged);
	DB.addHandler(DB.getPath(node, "skillgroup"), "onChildDeleted", self.onGroupListChanged);
	DB.addHandler(DB.getPath(node, "skillgroup.*.name"), "onUpdate", self.onGroupNameChanged);
	DB.addHandler(DB.getPath(node, "skilllist"), "onChildAdded", self.onSkillListChanged);
	DB.addHandler(DB.getPath(node, "skilllist"), "onChildDeleted", self.onSkillListChanged);
	DB.addHandler(DB.getPath(node, "skilllist.*.group"), "onUpdate", self.onSkillGroupChanged);

	if list.classheader then
		if type(list.classheader) == "table" then
			sHeaderClass = list.classheader[1];
		else
			sHeaderClass = list.classheader;
		end
	end

	self.updateSkillGroups();
	self.onModeChanged();
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "skillgroup"), "onChildAdded", self.onGroupListChanged);
	DB.removeHandler(DB.getPath(node, "skillgroup"), "onChildDeleted", self.onGroupListChanged);
	DB.removeHandler(DB.getPath(node, "skillgroup.*.name"), "onUpdate", self.onGroupNameChanged);
	DB.removeHandler(DB.getPath(node, "skilllist"), "onChildAdded", self.onSkillListChanged);
	DB.removeHandler(DB.getPath(node, "skilllist"), "onChildDeleted", self.onSkillListChanged);
	DB.removeHandler(DB.getPath(node, "skilllist.*.group"), "onUpdate", self.onSkillGroupChanged);
end

function onLockModeChanged()
	local bReadOnly = WindowManager.getWindowReadOnlyState(self);
	WindowManager.callSafeControlsSetLockMode(self, { "idelete_header" }, bReadOnly);
end

function onModeChanged()
	self.rebuildGroups();
end

function onGroupListChanged()
	self.updateSkillGroups();
end

function onGroupTypeChanged()
	self.updateSkillGroups();
end

function onGroupNameChanged(nodeGroupName)
	if _bUpdating then return end
	_bUpdating = true;

	local nodeParent = DB.getParent(nodeGroupName);
	local sNode = DB.getPath(nodeParent);

	local nodeGroup = nil;
	local sOldValue = "";
	for sGroup, vGroup in pairs(aGroups) do
		if vGroup.nodename == sNode then
			nodeGroup = vGroup.node;
			sOldValue = sGroup;
			break;
		end
	end
	if not nodeGroup then
		_bUpdating = false;
		return;
	end

	local sNewValue = DB.getValue(nodeParent, "name", "");
	for _,v in pairs(list.getWindows()) do
		if v.group.getValue() == sOldValue then
			v.group.setValue(sNewValue);
		end
	end

	_bUpdating = false;

	self.updateSkillGroups();
end

function onSkillListChanged()
	self.updateSkillGroups();
end

function onSkillGroupChanged()
	self.updateSkillGroups();
end

function addSkill()
	return list.createWindow(nil, true);
end

function addGroupSkill(sGroup, nGroupID)
	local w = list.createWindow(nil, true);
	w.groupid.setValue(nGroupID);
	w.group.setValue(sGroup);
	return w;
end

function updateSkillGroups()
	local node = getDatabaseNode();
	if not node or _bUpdating then return end
	_bUpdating = true;

	self.rebuildGroups();

	-- Determine all the groups accounted for by current items
	local aSkillGroups = {};
	for _, nodeList in ipairs(DB.getChildList(node, "skilllist")) do
		local sGroup = DB.getValue(nodeList, "group", "");
		if sGroup ~= "" then
			aSkillGroups[sGroup] = true;
		end
	end

	-- Remove the groups that already exist, and delete those with no skills
	for sGroup, vGroup in pairs(aGroups) do
		if aSkillGroups[sGroup] then
			aSkillGroups[sGroup] = nil;
		else
			vGroup.node.delete();
		end
	end

	-- For the remaining groups, that aren't named
	for k,_ in pairs(aSkillGroups) do
		if not aGroups[k] then
			local nodeGroups = DB.createChild(node, "skillgroup");
			local nodeNewGroup = DB.createChild(nodeGroups);
			DB.setValue(nodeNewGroup, "name", "string", k);
		end
	end

	self.rebuildGroups();
	_bUpdating = false;
	self.updateHeaders();
end

function updateHeaders()
	local node = getDatabaseNode();
	if not node or _bUpdating then return end
	_bUpdating = true;

	-- Close all category headings
	for _,v in pairs(list.getWindows()) do
		if v.getClass() == sHeaderClass then
			v.close();
		end
	end

	-- Create new category headings
	local aCategoryWindows = {};
	local aGroupShown = {};
	for _, nodeList in ipairs(DB.getChildList(node, "skilllist")) do
		local sGroup = DB.getValue(nodeList, "group", "");

		if not aCategoryWindows[sGroup] then
			local wh = list.createWindowWithClass(sHeaderClass);
			if wh then
				wh.setHeaderData(sGroup);
			end
			aCategoryWindows[sGroup] = wh;
			aGroupShown[sGroup] = true;
		end
	end

	-- Create empty category headings
	for k, v in pairs(aGroups) do
		if not aGroupShown[k] then
			local wh = list.createWindowWithClass(sHeaderClass);
			if wh then
				wh.setHeaderData(k);
			end
		end
	end

	_bUpdating = false;

	list.applySort();
end

--------------------------
-- GROUP DISPLAY
--------------------------

function rebuildGroups()
	aGroups = {};

	local nodeChar = getDatabaseNode();

	for _, v in ipairs(DB.getChildList(nodeChar, "skillgroup")) do
		local sGroup = DB.getValue(v, "name", "");
		local rGroup = {};
		rGroup.node = v;
		rGroup.nodename = DB.getPath(v);
		if sGroup == "" then
			rGroup.grouptype = "";
		else
			rGroup.grouptype = "header";
		end

		aGroups[sGroup] = rGroup;
	end
end