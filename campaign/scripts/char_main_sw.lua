-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

-- ===================================================================================================================
-- Modified
-- ===================================================================================================================
function onInit()
	onLevelChanged();
	DB.addHandler(DB.getPath(getDatabaseNode(), "classes"), "onChildUpdate", onLevelChanged);
end

function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "classes"), "onChildUpdate", onLevelChanged);
end

function onLevelChanged()
	CharManager.calcLevel(getDatabaseNode());
end

-- ===================================================================================================================
-- Modified
-- ===================================================================================================================
function onSystemChanged()
	-- local bPFMode = DataCommon.isPFRPG();
	
	-- cmd.setVisible(bPFMode);
	-- label_cmd.setVisible(bPFMode);
	
	-- if label_grapple then
		-- if bPFMode then
			-- label_grapple.setValue(Interface.getString("cmb"));
		-- elseif minisheet then
			-- label_grapple.setValue(Interface.getString("grp"));
		-- else
			-- label_grapple.setValue(Interface.getString("grapple"));
		-- end
	-- end
	
	-- spot.setVisible(not bPFMode);
	-- label_spot.setVisible(not bPFMode);
	-- listen.setVisible(not bPFMode);
	-- label_listen.setVisible(not bPFMode);
	-- search.setVisible(not bPFMode);
	-- label_search.setVisible(not bPFMode);

	-- perception.setVisible(bPFMode);
	-- label_perception.setVisible(bPFMode);
end

-- ===================================================================================================================
-- Modified
-- ===================================================================================================================
function onHealthChanged()
	local sColor = ActorManager35E.getPCSheetWoundColor(getDatabaseNode());
	wounds.setColor(sColor);
end

function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		if StringManager.contains({"referenceclass", "referencerace"}, sClass) then
			CharManager.addInfoDB(getDatabaseNode(), sClass, sRecord);
			return true;
		end
	end
end