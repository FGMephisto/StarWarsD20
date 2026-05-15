-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

local _bInitialized = false;

function onInit() -- Adjusted
	local nodeChar = window.getDatabaseNode();
	DB.addHandler(getDatabaseNode(), "onChildAdded", self.onDataChanged);
	DB.addHandler(getDatabaseNode(), "onChildDeleted", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "skilllist.*.group"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "skilllist.*.name"), "onUpdate", self.onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "skilllist.*.name_focus"), "onUpdate", self.onDataChanged);

	self.constructDefaultSkills();
	_bInitialized = true;
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
			if not t.sublabeling then
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
			local aSkillGroup = DataCommon.skillgroups[StringManager.simplify(t.group)] or DataCommon.skillgroups["generic"];
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