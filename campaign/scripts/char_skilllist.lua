-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	self.constructDefaultSkills();
	CharManager.updateSkillPoints(window.getDatabaseNode());

	local nodeChar = DB.getParent(getDatabaseNode());
	DB.addHandler(DB.getPath(nodeChar, "abilities"), "onChildUpdate", onStatUpdate);
	
	DB.addHandler(DB.getPath(nodeChar, "skilllist"), "onChildAdded", onSkillDataUpdate);
	DB.addHandler(DB.getPath(nodeChar, "skilllist"), "onChildDeleted", onSkillDataUpdate);
end
function onClose()
	local nodeChar = DB.getParent(getDatabaseNode());
	DB.removeHandler(DB.getPath(nodeChar, "abilities"), "onChildUpdate", onStatUpdate);
	
	DB.removeHandler(DB.getPath(nodeChar, "skilllist"), "onChildAdded", onSkillDataUpdate);
	DB.removeHandler(DB.getPath(nodeChar, "skilllist"), "onChildDeleted", onSkillDataUpdate);
end

function onSkillDataUpdate()
	CharManager.updateSkillPoints(window.getDatabaseNode());
end

function onStatUpdate()
	for _,w in pairs(getWindows()) do
		w.onStatUpdate();
	end
end

function addEntry(bFocus)
	local w = createWindow(nil, true);
	w.setCustom(true);
	return w;
end

-- Create default skill selection
function constructDefaultSkills()
	local aSystemSkills = DataCommon.skilldata;
	
	-- Create missing entries for all known skills
	local entrymap = {};
	for _,w in pairs(getWindows()) do
		local sLabel = w.label.getValue();
	
		local t = aSystemSkills[sLabel];
		if t and not t.sublabeling then
			if not entrymap[sLabel] then
				entrymap[sLabel] = { w };
			else
				table.insert(entrymap[sLabel], w);
			end
		end
	end

	-- Set properties and create missing entries for all known skills
	for k, t in pairs(DataCommon.skilldata) do
		if not t.sublabeling then
			local matches = entrymap[k];
			
			if not matches then
				local w = createWindow();
				if w then
					w.label.setValue(k);
					if t.stat then
						w.statname.setValue(t.stat);
					else
						w.statname.setValue("");
					end
					if t.trainedonly then
						w.showonminisheet.setValue(0);
					end
					matches = { w };
				end
			end
		end
	end

	-- Set properties for all skills
	for _,w in pairs(getWindows()) do
		w.updateWindow();
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
