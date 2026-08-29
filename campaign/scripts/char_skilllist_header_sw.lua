--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
-- File adjusted for Star Wars D20
--

function onInit()
	-- Placeholder
end

function onLockModeChanged(_)
	-- Placeholder
end

-- This function exists only for compatibility reasons to the skilllist item
function setCustom(_)
	-- Placeholder
end

-- This function exists only for compatibility reasons to the skilllist item
function isCustom()
	return false;
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

	local aSkillGroup = nil;
	if DataCommon.skillgroups then
		aSkillGroup = DataCommon.skillgroups[sGroup] or DataCommon.skillgroups["generic"];
	end
	if aSkillGroup then
		groupid.setValue(aSkillGroup.groupid);
	end
end

function updateSortKey()
	local sGroupID = groupid.getValue()
	local sName = label.getValue();

	local sSortKey = sGroupID .. "_1_" .. StringManager.simplify(sName)
	if sortkey then
		sortkey.setValue(sSortKey);
	end
end

function setHeaderData(sGroup)
	if group then
		group.setValue(sGroup);
	end

	if label then
		label.setValue(sGroup:upper());
	end

	self.onDataChanged();
end