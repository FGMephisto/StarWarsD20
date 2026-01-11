-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	self.onStateChanged();
end

function onLockModeChanged()
	self.onStateChanged();
end
function onIDModeChanged()
	self.onStateChanged();
end

function onStateChanged()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = RecordDataManager.getIDState("item", nodeRecord);

	local sType = type.getValue();
	local bWeapon = (sType == "Weapon");
	local bArmor = (sType == "Armor");
	
	local tTypeFields = { "type", "subtype", };
	WindowManager.callSafeControlsUpdate(self, tTypeFields, bReadOnly, not bID);
	divider2.setVisible(WindowManager.getAnyControlVisible(self, tTypeFields));

	local tBasicFields = { "cost", "weight", };
	WindowManager.callSafeControlsUpdate(self, tBasicFields, bReadOnly, not bID);
	divider3.setVisible(WindowManager.getAnyControlVisible(self, tBasicFields));
	
	if bID and bWeapon then
		type_stats.setValue("item_main_weapon", nodeRecord);
	elseif bID and bArmor then
		type_stats.setValue("item_main_armor", nodeRecord);
	else
		type_stats.setValue("", "");
	end
	type_stats.setVisible(not type_stats.isEmpty());
	divider4.setVisible(WindowManager.getAnyControlVisible(self, { "type_stats", }));

	local tMagicFields = { "aura", "cl", "prerequisites", };
	WindowManager.callSafeControlsUpdate(self, tMagicFields, bReadOnly, not bID);
	divider5.setVisible(WindowManager.getAnyControlVisible(self, tMagicFields));
	
	WindowManager.callSafeControlsUpdate(self, { "description", }, bReadOnly, not bID);

	WindowManager.callSafeControlUpdate(self, "sub_pack", bReadOnly, bID);
end

-- Added
function onClose()
	self.onStateChanged()

	local nodeRecord = getDatabaseNode()
	local bWeapon = ItemManager.isWeapon(nodeRecord)
	local bArmor = ItemManager.isArmor(nodeRecord)

	if not bArmor then
		DB.deleteChild(nodeRecord, "dr")
		DB.deleteChild(nodeRecord, "maxstatbonus")
		DB.deleteChild(nodeRecord, "checkpenalty")
		DB.deleteChild(nodeRecord, "speed30")
		DB.deleteChild(nodeRecord, "speed20")
	end

	if not bWeapon then
		DB.deleteChild(nodeRecord, "damage")
		DB.deleteChild(nodeRecord, "damagetype")
		DB.deleteChild(nodeRecord, "critical")
		DB.deleteChild(nodeRecord, "range")
		DB.deleteChild(nodeRecord, "stundc")
		DB.deleteChild(nodeRecord, "firingmodes")
		DB.deleteChild(nodeRecord, "size")
	end
	
	-- ToDo Clean up Vehicles fields
end