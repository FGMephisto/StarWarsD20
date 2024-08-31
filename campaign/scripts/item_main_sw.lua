-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	self.update();
end
function VisDataCleared()
	self.update();
end
function InvisDataAdded()
	self.update();
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = LibraryData.getIDState("item", nodeRecord);
	
	local sType = type.getValue();
	local bWeapon = (sType == "Weapon");
	local bArmor = (sType == "Armor");
	
	sub_nonid.update(bReadOnly, bID);

	local bSection2 = false;
	if WindowManager.callSafeControlUpdate(self, "type", bReadOnly, not bID) then bSection2 = true; end
	if WindowManager.callSafeControlUpdate(self, "subtype", bReadOnly, not bID) then bSection2 = true; end
	
	local bSection3 = false;
	if WindowManager.callSafeControlUpdate(self, "cost", bReadOnly, not bID) then bSection3 = true; end
	if WindowManager.callSafeControlUpdate(self, "weight", bReadOnly, not bID) then bSection3 = true; end
	
	local bSection4 = true;
	if Session.IsHost or bID then 
		if bWeapon then
			type_stats.setValue("item_main_weapon", nodeRecord);
		elseif bArmor then
			type_stats.setValue("item_main_armor", nodeRecord);
		else
			type_stats.setValue("", "");
			bSection4 = false;
		end
	else
		type_stats.setValue("", "");
		bSection4 = false;
	end
	type_stats.update(bReadOnly, bID);

	local bSection5 = false;
	-- if WindowManager.callSafeControlUpdate(self, "aura", bReadOnly, not bID) then bSection5 = true; end
	-- if WindowManager.callSafeControlUpdate(self, "cl", bReadOnly, not bID) then bSection5 = true; end
	if WindowManager.callSafeControlUpdate(self, "prerequisites", bReadOnly, not bID) then bSection5 = true; end
	
	local bSection6 = bID;
	description.setVisible(bID);
	description.setReadOnly(bReadOnly);
	
	divider2.setVisible(bSection2 and bSection3);
	divider3.setVisible((bSection2 or bSection3) and bSection4);
	divider4.setVisible((bSection2 or bSection3 or bSection4) and bSection5);
	divider5.setVisible((bSection2 or bSection3 or bSection4 or bSection5) and bSection6);

	sub_pack.update(bReadOnly, bID);
end

-- Added
function onClose()
	self.update()

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