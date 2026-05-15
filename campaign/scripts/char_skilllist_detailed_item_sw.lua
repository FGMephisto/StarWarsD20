--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	local nodeSkill = getDatabaseNode();
	local nodeChar = DB.getChild(nodeSkill, "...");
	DB.addHandler(DB.getPath(nodeSkill, "label"), "onUpdate", onDataChanged);
	DB.addHandler(DB.getPath(nodeSkill, "sublabel"), "onUpdate", onDataChanged);
	DB.addHandler(DB.getPath(nodeSkill, "group"), "onUpdate", onDataChanged);
	DB.addHandler(DB.getPath(nodeSkill, "statname"), "onUpdate", onStatUpdate);
	if nodeChar then
		DB.addHandler(DB.getPath(nodeChar, "abilities.*.bonus"), "onUpdate", onAbilityBonusChanged);
	end

	self.setCustom(self.isCustom());
	self.onStatUpdate();
	self.onDataChanged();
end

function onClose()
	local nodeSkill = getDatabaseNode();
	local nodeChar = DB.getChild(nodeSkill, "...");
	DB.removeHandler(DB.getPath(nodeSkill, "label"), "onUpdate", onDataChanged);
	DB.removeHandler(DB.getPath(nodeSkill, "sublabel"), "onUpdate", onDataChanged);
	DB.removeHandler(DB.getPath(nodeSkill, "group"), "onUpdate", onDataChanged);
	DB.removeHandler(DB.getPath(nodeSkill, "statname"), "onUpdate", onStatUpdate);
	if nodeChar then
		DB.removeHandler(DB.getPath(nodeChar, "abilities.*.bonus"), "onUpdate", onAbilityBonusChanged);
	end
end

function onDataChanged()
	self.updateGroupID();
	self.updateSortKey();
end

function updateGroupID()
	local sGroup = group.getValue();

	if sGroup == "" then
		sGroup = "generic"; -- Default fallback
	else
		sGroup = StringManager.simplify(sGroup)
	end

	local aSkillGroup = DataCommon.skillgroups[sGroup]
	                 or DataCommon.skillgroups["generic"];
	if aSkillGroup then
		groupid.setValue(aSkillGroup.groupid);
	end
end

function updateSortKey()
	local sGroupID = groupid.getValue();
	local sName = label.getValue();
	local sNameFocus = sublabel and sublabel.getValue() or "";

	local sSortKey = sGroupID .. "_2_" .. StringManager.simplify(sName) .. StringManager.simplify(sNameFocus)
	if sortkey then
		sortkey.setValue(sSortKey);
	end
end

-- This function is called to set the entry to non-custom or custom.
-- Custom entries have configurable stats and editable labels.
local _bCustom = true;

function setCustom(state)
	_bCustom = state;

	idelete.setVisible(_bCustom);
	iadd.setVisible(not _bCustom);
end

function isCustom()
	return _bCustom;
end

function openSkillLink()
	local nodeSkill = RecordManager.findRecordByStringI("skill", "label", label.getValue());
	if nodeSkill then
		Interface.openWindow(LibraryData.getRecordDisplayClass("skill"), nodeSkill);
	else
		Interface.openWindow("ref_ability", getDatabaseNode());
	end
end

function action(draginfo)
	local nodeSkill = getDatabaseNode();
	local nodeChar = DB.getChild(nodeSkill, "...");
	local rActor = ActorManager.resolveActor(nodeChar);
	ActionSkill.performRoll(draginfo, rActor, nodeSkill);
	return true;
end

function copySkill()
	local nodeChar = getDatabaseNode();
	local nodeParent = DB.getParent(nodeChar);
	local nodeNew = DB.createChild(nodeParent);

	if nodeNew then
		DB.copyNode(nodeChar, nodeNew);
		if sublabel then DB.setValue(nodeNew, "sublabel", "string", "New") end
	end
end

--------------------------
-- SW-ONLY FUNCTIONS
--------------------------

function onAbilityBonusChanged()
	self.onStatUpdate();
end

function onStatUpdate()
	local sStatName = statname.getValue();
	if not sStatName or sStatName == "" then
		stat.setValue(0);
		return;
	end
	local nodeChar = DB.getChild(getDatabaseNode(), "...");
	if nodeChar then
		stat.setValue(DB.getValue(nodeChar, "abilities." .. sStatName:lower() .. ".bonus", 0));
	else
		stat.setValue(0);
	end
end