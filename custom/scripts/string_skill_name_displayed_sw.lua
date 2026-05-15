--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
-- File adjusted for HM3.5
--

function onInit()
	if super and super.onInit then
		super.onInit();
	end

	local node = window.getDatabaseNode();
	DB.addHandler(DB.getPath(node, "label"), "onUpdate", onNameChanged);
	DB.addHandler(DB.getPath(node, "sublabel"), "onUpdate", onNameChanged);
	onNameChanged();
end

function onClose()
	if super and super.onClose then
		super.onClose();
	end

	local node = window.getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "label"), "onUpdate", onNameChanged);
	DB.removeHandler(DB.getPath(node, "sublabel"), "onUpdate", onNameChanged);
end

function onNameChanged()
	local node = window.getDatabaseNode();
	local sName = DB.getValue(node, "label", "");
	local sFocus = DB.getValue(node, "sublabel", "");

	local sDisplay = sName;
	if sFocus ~= "" then
		sDisplay = sDisplay .. " - " .. sFocus;
	end

	setValue(sDisplay);
end
