-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	TypeChanged();
	onLockChanged();
	onIDChanged();
end

function TypeChanged()
	local sType = DB.getValue(getDatabaseNode(), "npctype", "");
	
	if sType == "Trap" then
		-- tabs.setTab(1, "main_trap", "tab_main");
	elseif sType == "Vehicle" then
		tabs.setTab(1, "main_vehicle", "tab_main");
	else
		tabs.setTab(1, "main_creature", "tab_main");
	end
end

function onLockChanged()
	StateChanged();
end

-- ===================================================================================================================
-- Modified
-- ===================================================================================================================
function StateChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	-- if main_trap.subwindow then
		-- main_trap.subwindow.update();
	-- end
	if main_vehicle.subwindow then
		main_vehicle.subwindow.update();
	end
	if main_creature.subwindow then
		main_creature.subwindow.update();
	end
	-- if spells.subwindow then
		-- spells.subwindow.update();
	-- end

	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	
	npctype.setReadOnly(bReadOnly);
	text.setReadOnly(bReadOnly);
end

-- ===================================================================================================================
-- Modified
-- ===================================================================================================================
function onIDChanged()
	if Session.IsHost then
		-- if main_trap.subwindow then
			-- main_trap.subwindow.update();
		-- end
		if main_vehicle.subwindow then
			main_vehicle.subwindow.update();
		end
		if main_creature.subwindow then
			main_creature.subwindow.update();
		end
	else
		local bID = LibraryData.getIDState("npc", getDatabaseNode(), true);
		tabs.setVisibility(bID);
		npctype.setVisible(bID);
	end
end