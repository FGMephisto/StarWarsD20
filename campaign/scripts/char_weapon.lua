-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars D20 (Parent Weapon script)
--

function onInit()
	registerMenuItem(Interface.getString("wpn_menu_action_add") or "Add Action", "insert", 5);
	registerMenuItem(Interface.getString("wpn_menu_action_add_melee") or "Add Melee Action", "char_weapon_melee", 5, 2);
	registerMenuItem(Interface.getString("wpn_menu_action_add_ranged") or "Add Ranged Action", "char_weapon_ranged", 5, 4);
	registerMenuItem(Interface.getString("wpn_menu_action_add_throwing") or "Add Thrown Action", "char_weapon_thrown", 5, 6);

	self.onLinkChanged();
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));

	if minisheet then
		carried.setVisible(false);
	end

	local nodeWeapon = getDatabaseNode();
	DB.addHandler(DB.getPath(nodeWeapon, "shortcut"), "onUpdate", self.onLinkChanged);

	if action_list then
		action_list.onFilter = self.onFilterAction;
		action_list.applyFilter();
	end
end

function onTypeChanged()
	if action_list then
		action_list.applyFilter();
	end
end

function onFilterAction(w)
	if not type then
		return true;
	end
	local nType = type.getValue();
	-- If state is 3 (All), show all subrows
	if nType == 3 then
		return true;
	end
	local nActionType = DB.getValue(w.getDatabaseNode(), "atktype", 0);
	return (nActionType == nType);
end

function onClose()
	local nodeWeapon = getDatabaseNode();
	DB.removeHandler(DB.getPath(nodeWeapon, "shortcut"), "onUpdate", self.onLinkChanged);
end

function onLockModeChanged(bReadOnly)
	if minisheet then
		bReadOnly = true;
	end
	local tFields = { "name", "idelete", };
	WindowManager.callSafeControlsSetLockMode(self, tFields, bReadOnly);
	
	if not minisheet then
		local sMode = DB.getValue(WindowManager.getTopWindow(self).getDatabaseNode(), "spellmode", "");
		WindowManager.callSafeControlsSetVisible(self, { "carried", }, not bReadOnly or (sMode == "preparation"));
	end
end

function onModeChanged()
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
end

local _sClass = "";
local _sRecord = "";
function onLinkChanged()
	local node = getDatabaseNode();
	local sClass, sRecord = DB.getValue(node, "shortcut", "", "");
	if sClass ~= _sClass or sRecord ~= _sRecord then
		_sClass = sClass;
		_sRecord = sRecord;
		
		local sInvList = DB.getPath(DB.getChild(node, "..."), "inventorylist") .. ".";
		if sRecord:sub(1, #sInvList) == sInvList then
			carried.setLink(DB.findNode(DB.getPath(sRecord, "carried")));
		end
	end
end

function onMenuSelection(selection, subselection)
	if selection == 5 then
		local nodeWeapon = getDatabaseNode();
		if subselection == 2 then
			CharManager.addWeaponAction(nodeWeapon, 0, "Melee Attack");
		elseif subselection == 4 then
			CharManager.addWeaponAction(nodeWeapon, 1, "Ranged Attack");
		elseif subselection == 6 then
			CharManager.addWeaponAction(nodeWeapon, 2, "Thrown Attack");
		end
		return true;
	end
end
