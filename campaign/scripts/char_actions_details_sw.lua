-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function onInit()
	registerMenuItem(Interface.getString("menu_addweapon"), "insert", 3);
	registerMenuItem(Interface.getString("menu_addspellclass"), "insert", 5);
	
	self.updateAbility();

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "abilities"), "onChildUpdate", updateAbility);
	DB.addHandler(DB.getPath(node, "weaponlist"), "onChildUpdate", updateAbility);
	DB.addHandler(DB.getPath(node, "spellset"), "onChildUpdate", updateAbility);
end

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "abilities"), "onChildUpdate", updateAbility);
	DB.removeHandler(DB.getPath(node, "weaponlist"), "onChildUpdate", updateAbility);
	DB.removeHandler(DB.getPath(node, "spellset"), "onChildUpdate", updateAbility);
end

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function onMenuSelection(selection)
	if selection == 3 then
		self.addWeapon();
	elseif selection == 5 then
		self.addSpellClass();
	end
end

function addSpellClass()
	local w = spellclasslist.createWindow();
	if w then
		w.activatedetail.setValue(1);
		w.label.setFocus();
		DB.setValue(getDatabaseNode(), "spellmode", "string", "standard");
	end
end

function addWeapon()
	local w = weaponlist.createWindow();
	if w then
		w.name.setFocus();
	end
end

local bUpdateLock = false;

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function updateAbility()
	if bUpdateLock then
		return;
	end

	bUpdateLock = true;

	for _,v in pairs(weaponlist.getWindows()) do
		v.onDataChanged();
	end
	for _,v in pairs(spellclasslist.getWindows()) do
		v.onStatUpdate();
	end

	bUpdateLock = false;
end