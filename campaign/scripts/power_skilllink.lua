-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	updateSkillLink();
	local nodePower = window.getDatabaseNode();
	if nodePower then
		DB.addHandler(DB.getPath(nodePower, "name"), "onUpdate", updateSkillLink);
		DB.addHandler(DB.getPath(nodePower, "skillpath"), "onUpdate", updateSkillLink);
	end
end

function onClose()
	local nodePower = window.getDatabaseNode();
	if nodePower then
		DB.removeHandler(DB.getPath(nodePower, "name"), "onUpdate", updateSkillLink);
		DB.removeHandler(DB.getPath(nodePower, "skillpath"), "onUpdate", updateSkillLink);
	end
end

function getPowerName()
	local nodePower = window.getDatabaseNode();
	if nodePower then
		local sName = DB.getValue(nodePower, "name", "");
		if sName ~= "" then
			return sName;
		end
	end
	if window.name and window.name.getValue then
		local sName = window.name.getValue();
		if sName ~= "" then
			return sName;
		end
	end
	if window.header and window.header.subwindow and window.header.subwindow.name then
		return window.header.subwindow.name.getValue();
	end
	return "";
end

function getSkillDescNode()
	local sPowerName = getPowerName();
	local sStripName = StringManager.strip(sPowerName);
	if sStripName == "" then
		return nil;
	end

	local nodePower = window.getDatabaseNode();
	if nodePower then
		local sSkillPath = DB.getValue(nodePower, "skillpath", "");
		if sSkillPath ~= "" then
			local nodeSkill = DB.findNode(sSkillPath);
			if nodeSkill then
				local sClass, sRecord = DB.getValue(nodeSkill, "shortcut", "", "");
				if sRecord ~= "" and sClass ~= "spelldesc" and sClass ~= "spelldesc2" then
					local nodeRef = DB.findNode(sRecord);
					if nodeRef then
						return nodeRef, (sClass ~= "" and sClass or "referenceskill");
					end
				end
			end
		end
	end

	local aMappings = LibraryData.getMappings("skill");
	for _, vMapping in ipairs(aMappings) do
		for _, vNode in ipairs(DB.getChildrenGlobal(vMapping)) do
			if StringManager.strip(DB.getValue(vNode, "name", "")) == sStripName then
				return vNode, "referenceskill";
			end
		end
	end

	if nodePower then
		local sSkillPath = DB.getValue(nodePower, "skillpath", "");
		if sSkillPath ~= "" then
			local nodeSkill = DB.findNode(sSkillPath);
			if nodeSkill then
				return nodeSkill, "referenceskill";
			end
		end
	end

	return nil;
end

function updateSkillLink()
	local vNode, sClass = getSkillDescNode();
	if vNode then
		sClass = sClass or "referenceskill";
		setValue(sClass, DB.getPath(vNode));
	end
end

function onClickDown(button, x, y)
	updateSkillLink();
end

function onDragStart(button, x, y, draginfo)
	updateSkillLink();
	local sClass, sRecord = getValue();
	if sRecord ~= "" then
		draginfo.setType("shortcut");
		draginfo.setIcon(Interface.getLinkIcon(sClass));
		draginfo.setShortcutData(sClass, sRecord);
		draginfo.setDescription(getPowerName());
		return true;
	end
	return false;
end
