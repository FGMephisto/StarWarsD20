--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E (Merged from char_skill.lua and char_skilllist_item_sw.lua)
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

	self.onCheckPenaltyChange();
	self.onStatUpdate();

	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
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

function onLockModeChanged(bReadOnly)
	local tFields = { "state", "sublabel", "ranks", "statname", "misc", };
	WindowManager.callSafeControlsSetLockMode(self, tFields, bReadOnly);
	if self.isCustom() then
		label.setReadOnly(bReadOnly);
	end

	local bAllowDelete = self.isCustom();
	if not bAllowDelete then
		local sLabel = label.getValue();
		local rSkill = DataCommon.skilldata[sLabel];
		if rSkill and rSkill.sublabeling then
			bAllowDelete = true;
		end
	end
	
	if bAllowDelete then
		idelete_spacer.setVisible(false);
		idelete.setVisible(not bReadOnly);
	else
		idelete_spacer.setVisible(not bReadOnly);
		idelete.setVisible(false);
	end
end

-- This function is called to set the entry to non-custom or custom.
-- Custom entries have configurable stats and editable labels.
local _bCustom = true;

function setCustom(state)
	_bCustom = state;
	
	if _bCustom then
		label.setEnabled(true);
		label.setLine(true);
	else
		label.setEnabled(false);
		label.setLine(false);
	end
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
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
	local sSubLabel = "";
	if sublabel then
		sSubLabel = sublabel.getValue();
	end

	local sSortKey = sGroupID .. "_2_" .. StringManager.simplify(sName) .. StringManager.simplify(sSubLabel)
	if sortkey then
		sortkey.setValue(sSortKey);
	end
end

--------------------------
-- SW-ONLY FUNCTIONS
--------------------------

function updateWindow()
	local sLabel = label.getValue();
	local t = DataCommon.skilldata[sLabel];
	if t then
		self.setCustom(false);
		
		if t.sublabeling then
			sublabel.setVisible(true);
		end

		if t.armorcheckmultiplier then
			armorcheckmultiplier.setValue(t.armorcheckmultiplier);
		else
			armorcheckmultiplier.setValue(0);
		end
	else
		self.setCustom(true);
	end
end

function onSystemChanged(bPFMode)
	total.onSourceUpdate();
end

function onCheckPenaltyChange()
	if armorcheckmultiplier.getValue() ~= 0 then
		armorwidget.setIcon("char_armorcheck");
	else
		armorwidget.setIcon(nil);
	end
end

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