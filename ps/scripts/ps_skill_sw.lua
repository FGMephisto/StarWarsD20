-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function onInit()
	OptionsManager.registerCallback("REVL", update);

	if not Session.IsHost then
		list.setAnchor("bottom", "", "bottom", "absolute", -25);
	end
	
	-- onSystemChanged();
end

-- ===================================================================================================================
-- ===================================================================================================================
function onClose()
	OptionsManager.unregisterCallback("REVL", update);
end

-- ===================================================================================================================
-- ===================================================================================================================
function update()
	hiderollresults.setVisible(OptionsManager.isOption("REVL", "on"));
end

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function onSystemChanged()
	-- local bPFMode = DataCommon.isPFRPG();
	
	-- spotlabel.setVisible(not bPFMode);
	-- listenlabel.setVisible(not bPFMode);
	-- searchlabel.setVisible(not bPFMode);
	-- perceptionlabel.setVisible(bPFMode);
	-- smlabel.setVisible(bPFMode);
	
	-- gatherinfolabel.setVisible(not bPFMode);
	
	-- acrobaticslabel.setVisible(bPFMode);
	-- heallabel.setVisible(bPFMode);
	-- jumplabel.setVisible(not bPFMode);
	
	-- hidelabel.setVisible(not bPFMode);
	-- movesilentlabel.setVisible(not bPFMode);
	-- stealthlabel.setVisible(bPFMode);
end