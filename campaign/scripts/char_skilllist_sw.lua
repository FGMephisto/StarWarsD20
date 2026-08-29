-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars D20
--

local _bInitialized = false;

function onInit() -- Adjusted
	local nodeChar = window.getDatabaseNode();
	DB.addHandler(getDatabaseNode(), "onChildAdded", self.onDataChanged);
	DB.addHandler(getDatabaseNode(), "onChildDeleted", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "skilllist.*.group"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "skilllist.*.name"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "skilllist.*.name_focus"), "onUpdate", self.onDataChanged);

	registerMenuItem(Interface.getString("char_menu_addforceskills"), "insert", 4);

	self.constructDefaultSkills();
	_bInitialized = true;
end

function onMenuSelection(selection, subselection)
	if selection == 4 then
		self.addForceSkills();
	end
end

function onClose() -- Added
	local nodeChar = window.getDatabaseNode();
	DB.removeHandler(getDatabaseNode(), "onChildAdded", self.onDataChanged);
	DB.removeHandler(getDatabaseNode(), "onChildDeleted", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "skilllist.*.group"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "skilllist.*.name"), "onUpdate", self.onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "skilllist.*.name_focus"), "onUpdate", self.onDataChanged);
end

function onChildWindowCreated(w)
	if _bInitialized then
		w.setCustom(true);
	end
end

-- Create default skill selection
function constructDefaultSkills() -- Adjusted
	-- Collect existing entries
	local entrymap = {};

	for _,w in pairs(getWindows()) do
		local sLabel = w.label.getValue();

		if DataCommon.skilldata[sLabel] then
			if not entrymap[sLabel] then
				entrymap[sLabel] = { w };
			else
				table.insert(entrymap[sLabel], w);
			end
		else
			w.setCustom(true);
		end
		if w.onDataChanged then
			w.onDataChanged();
		end
	end

	-- Set properties and create missing entries for all known skills
	for k, t in pairs(DataCommon.skilldata) do
		local matches = entrymap[k];
		local w

		-- Set data for new list entries
		if not matches then
			if not t.sublabeling and t.group ~= "force" then
				w = createWindow();
				if w then
					w.label.setValue(k);
					w.statname.setValue(t.stat or "")

					matches = { w };
				end
			end
		else
			w = matches[1]  -- use the first matching window
		end

		-- Update data for all list entries
		if w then
			w.group.setValue(StringManager.titleCase(t.group))

			-- Get groupid from skillgroups
			local aSkillGroup = nil;
			if DataCommon.skillgroups then
				aSkillGroup = DataCommon.skillgroups[StringManager.simplify(t.group)] or DataCommon.skillgroups["generic"];
			end
			if aSkillGroup then
				w.groupid.setValue(aSkillGroup.groupid)
			end
		end

		-- Update properties for all list entries
		local bCustom = false;
		for _, match in pairs(matches or {}) do
			match.setCustom(bCustom);
			if match.onDataChanged then
				match.onDataChanged();
			end
			bCustom = true;
		end
	end
end

function onDataChanged()
	self.applySort();
end

--------------------------
-- SW-ONLY FUNCTIONS
--------------------------

function onSkillDataUpdate()
	CharManager.updateSkillPoints(window.getDatabaseNode());
end

function addForceSkills()
	local nodeChar = window.getDatabaseNode();
	if not nodeChar then
		return;
	end

	-- Map existing skills (normalized lower-case trimmed name)
	local aExisting = {};
	for _, w in pairs(getWindows()) do
		if w.label then
			local sLabel = w.label.getValue();
			if type(sLabel) == "string" then
				local sTrimmed = StringManager.trim(sLabel):lower();
				if sTrimmed ~= "" then
					aExisting[sTrimmed] = true;
				end
			end
		end
	end

	-- Also check database child nodes directly to ensure no un-instantiated / unlinked nodes exist
	for _, nodeSkill in pairs(DB.getChildren(nodeChar, "skilllist")) do
		local sName = DB.getValue(nodeSkill, "label", "");
		if sName == "" then
			sName = DB.getValue(nodeSkill, "name", "");
		end
		if type(sName) == "string" then
			local sTrimmed = StringManager.trim(sName):lower();
			if sTrimmed ~= "" then
				aExisting[sTrimmed] = true;
			end
		end
	end

	local bAddedAny = false;
	local aSkillGroup = nil;
	if DataCommon.skillgroups then
		aSkillGroup = DataCommon.skillgroups["force"] or DataCommon.skillgroups["generic"];
	end
	local sGroupId = aSkillGroup and aSkillGroup.groupid or "40";

	-- Sort skill names alphabetically for predictable creation order
	local aForceSkillNames = {};
	if DataCommon.forceskills then
		for sSkillName, _ in pairs(DataCommon.forceskills) do
			table.insert(aForceSkillNames, sSkillName);
		end
	end
	table.sort(aForceSkillNames);

	for _, sSkillName in ipairs(aForceSkillNames) do
		local sNormalized = StringManager.trim(sSkillName):lower();
		if not aExisting[sNormalized] then
			local rSkill = DataCommon.forceskills[sSkillName];
			local w = createWindow();
			if w then
				w.label.setValue(sSkillName);
				w.statname.setValue(rSkill.stat or "");
				w.group.setValue(StringManager.titleCase(rSkill.group or "Force"));
				w.groupid.setValue(sGroupId);
				if rSkill.trainedonly and w.state then
					w.state.setValue(rSkill.trainedonly);
				end
				if w.updateWindow then
					w.updateWindow();
				end
				if w.onDataChanged then
					w.onDataChanged();
				end
				aExisting[sNormalized] = true;
				bAddedAny = true;
			end
		end
	end

	if bAddedAny then
		self.applySort();
		if window.updateSkillGroups then
			window.updateSkillGroups();
		end
	end
end

function addNewInstance(sLabel)
	local rSkill = DataCommon.skilldata[sLabel];
	if rSkill and rSkill.sublabeling then
		local w = createWindow();
		w.label.setValue(sLabel);
		w.statname.setValue(rSkill.stat);
		w.updateWindow();
		w.sublabel.setFocus();
	end
end

function addSkillReference(nodeSource)
	if not nodeSource then
		return;
	end

	local sName = StringManager.trim(DB.getValue(nodeSource, "name", ""));
	if sName == "" then
		return;
	end

	local wSkill = nil;
	for _, w in pairs(getWindows()) do
		if StringManager.trim(w.label.getValue()) == sName then
			wSkill = w;
			break;
		end
	end

	if not wSkill then
		wSkill = createWindow();
		wSkill.label.setValue(sName);
		
		local sAbility = DB.getValue(nodeSource, "ability", "");
		sAbility = DataCommon.ability_stol[sAbility:upper()] or sAbility:lower();
		wSkill.statname.setValue(sAbility);
		
		local sGroup = DB.getValue(nodeSource, "group", "");
		wSkill.group.setValue(StringManager.titleCase(sGroup));
		
		local nTrained = DB.getValue(nodeSource, "trained", 0);
		wSkill.state.setValue(nTrained);
		
		wSkill.updateWindow();
	end
end