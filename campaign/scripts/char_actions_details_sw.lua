-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	registerMenuItem(Interface.getString("menu_addweapon"), "insert", 3);
	updateAbility();
	update();

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "abilities"), "onChildUpdate", updateAbility);
	DB.addHandler(DB.getPath(node, "weaponlist"), "onChildUpdate", updateAbility);
end


function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "abilities"), "onChildUpdate", updateAbility);
	DB.removeHandler(DB.getPath(node, "weaponlist"), "onChildUpdate", updateAbility);
end

function onMenuSelection(selection)
	if selection == 3 then
		addWeapon();
	end
end

function addWeapon()
	local w = weaponlist.createWindow();
	if w then
		w.name.setFocus();
	end
end

local bUpdateLock = false;
function updateAbility()
	if bUpdateLock then
		return;
	end

	bUpdateLock = true;

	for _,v in pairs(weaponlist.getWindows()) do
		v.onDataChanged();
	end

	bUpdateLock = false;
end

function update()
	weaponlist.update();
end

function getEditMode()
	return (parentcontrol.window.actions_iedit.getValue() == 1);
end