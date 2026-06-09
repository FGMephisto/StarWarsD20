--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
-- File adjusted for HM3.5
--

function onInit()
	if super and super.onInit then
		super.onInit();
	end

	local nodeSpell = window.getDatabaseNode();
	if not nodeSpell then
		return;
	end

	local sPath = DB.getPath(nodeSpell);
	local sCharPath = sPath:match("^([^.]*%.id%-%d+)");
	local nodeChar = nil;
	if sCharPath then
		nodeChar = DB.findNode(sCharPath);
	end

	DB.addHandler(DB.getPath(nodeSpell, "misc"), "onUpdate", onSourceUpdate);
	DB.addHandler(DB.getPath(nodeSpell, "skillpath"), "onUpdate", onSourceUpdate);

	if nodeChar then
		DB.addHandler(DB.getPath(nodeChar, "skilllist.*.total"), "onUpdate", onSourceUpdate);
		DB.addHandler(DB.getPath(nodeChar, "skilllist.*.name"), "onUpdate", onSourceUpdate);
	end

	self.onSourceUpdate();
end

function onClose()
	if super and super.onClose then
		super.onClose();
	end

	local nodeSpell = window.getDatabaseNode();
	if not nodeSpell then
		return;
	end

	local sPath = DB.getPath(nodeSpell);
	local sCharPath = sPath:match("^([^.]*%.id%-%d+)");
	local nodeChar = nil;
	if sCharPath then
		nodeChar = DB.findNode(sCharPath);
	end

	DB.removeHandler(DB.getPath(nodeSpell, "misc"), "onUpdate", onSourceUpdate);
	DB.removeHandler(DB.getPath(nodeSpell, "skillpath"), "onUpdate", onSourceUpdate);

	if nodeChar then
		DB.removeHandler(DB.getPath(nodeChar, "skilllist.*.total"), "onUpdate", onSourceUpdate);
		DB.removeHandler(DB.getPath(nodeChar, "skilllist.*.name"), "onUpdate", onSourceUpdate);
	end
end

function onSourceUpdate()
	if super and super.onSourceUpdate then
		super.onSourceUpdate();
	end

	local nodeSpell = window.getDatabaseNode();
	if not nodeSpell then
		return;
	end

	local nSkillTotal = 0;
	local sSkillPath = DB.getValue(nodeSpell, "skillpath", "");
	if sSkillPath ~= "" then
		local nodeSkill = DB.findNode(sSkillPath);
		if nodeSkill then
			nSkillTotal = DB.getValue(nodeSkill, "total", 0);
		end
	else
		local sSchool = DB.getValue(nodeSpell, "school", "");
		if type(sSchool) ~= "string" then sSchool = tostring(sSchool) end
		local sSchoolTrimmedLower = (sSchool:match("^%s*(.-)%s*$") or ""):lower();

		local sPath = DB.getPath(nodeSpell);
		local sCharPath = sPath:match("^([^.]*%.id%-%d+)");
		local nodeChar = nil;
		if sCharPath then
			nodeChar = DB.findNode(sCharPath);
		end

		if nodeChar and sSchoolTrimmedLower ~= "" then
			for _, vSkillNode in pairs(DB.getChildren(nodeChar, "skilllist")) do
				local sSkillName = DB.getValue(vSkillNode, "name", "");
				if type(sSkillName) ~= "string" then sSkillName = tostring(sSkillName) end
				local sSkillTrimmedLower = (sSkillName:match("^%s*(.-)%s*$") or ""):lower();

				if sSkillTrimmedLower == sSchoolTrimmedLower then
					nSkillTotal = DB.getValue(vSkillNode, "total", 0);
					break;
				end
			end
		end
	end

	local nDevelopment = DB.getValue(nodeSpell, "misc", 0);
	local nValue = nSkillTotal + nDevelopment;

	if DB.getValue(nodeSpell, "total") ~= nValue then
		DB.setValue(nodeSpell, "total", "number", nValue);
	end
end

function onDragStart(_, _, _, draginfo)
	return window.action(draginfo);
end