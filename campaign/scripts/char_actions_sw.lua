-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

-- ===================================================================================================================
-- Modified
-- ===================================================================================================================
function onDisplayChanged()
	-- if not minisheet then
		-- for _,v in pairs(actions.subwindow.spellclasslist.getWindows()) do
			-- v.onDisplayChanged();
		-- end
	-- end
end

-- ===================================================================================================================
-- Modified
-- ===================================================================================================================
function onModeChanged()
	actions.subwindow.weaponlist.onModeChanged();
end

-- ===================================================================================================================
-- Modified
-- ===================================================================================================================
function updateSpellCounters()
	-- if minisheet then
		-- for _,v in pairs(spellclasslist.getWindows()) do
			-- v.onSpellCounterUpdate();
		-- end
	-- else
		-- for _,v in pairs(actions.subwindow.spellclasslist.getWindows()) do
			-- v.onSpellCounterUpdate();
		-- end
	-- end
end