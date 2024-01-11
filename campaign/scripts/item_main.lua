-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
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
	
	local bSection1 = false;
	if Session.IsHost then
		if WindowManager.callSafeControlUpdate(self, "nonid_name", bReadOnly) then bSection1 = true; end;
	else
		WindowManager.callSafeControlUpdate(self, "nonid_name", bReadOnly, true);
	end
	if (Session.IsHost or not bID) then
		if WindowManager.callSafeControlUpdate(self, "nonidentified", bReadOnly) then bSection1 = true; end;
	else
		WindowManager.callSafeControlUpdate(self, "nonidentified", bReadOnly, true);
	end

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
	if WindowManager.callSafeControlUpdate(self, "aura", bReadOnly, not bID) then bSection5 = true; end
	if WindowManager.callSafeControlUpdate(self, "cl", bReadOnly, not bID) then bSection5 = true; end
	if WindowManager.callSafeControlUpdate(self, "prerequisites", bReadOnly, not bID) then bSection5 = true; end
	
	local bSection6 = bID;
	description.setVisible(bID);
	description.setReadOnly(bReadOnly);
	
	divider.setVisible(bSection1 and bSection2);
	divider2.setVisible((bSection1 or bSection2) and bSection3);
	divider3.setVisible((bSection1 or bSection2 or bSection3) and bSection4);
	divider4.setVisible((bSection1 or bSection2 or bSection3 or bSection4) and bSection5);
	divider5.setVisible((bSection1 or bSection2 or bSection3 or bSection4 or bSection5) and bSection6);

	if Session.IsHost or bID then 
		if ItemManager.isPack(nodeRecord) then
			type_lists.setValue("item_main_subitems", nodeRecord);
		else
			type_lists.setValue("", "");
		end
	else
		type_lists.setValue("", "");
	end
	type_lists.update(bReadOnly);
end
