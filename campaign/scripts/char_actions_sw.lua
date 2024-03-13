-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function onDisplayChanged()
	if not minisheet then
		for _,v in pairs(actions.subwindow.spellclasslist.getWindows()) do
			v.onDisplayChanged();
		end
	end
end

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function onModeChanged()
	if minisheet then
		weaponlist.onModeChanged();
	else
		actions.subwindow.weaponlist.onModeChanged();
	end
	
	self.updateSpellCounters();
end

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function onEditModeChanged()
	local bEditMode = WindowManager.getEditMode(self, "actions_iedit");
	
	label_mode.setVisible(not bEditMode);
	spellmode.setVisible(not bEditMode);
	label_display.setVisible(not bEditMode);
	spelldisplaymode.setVisible(not bEditMode);
	if bEditMode then
		DB.setValue(getDatabaseNode(), "spellmode", "string", "standard");
	end
end

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function updateSpellCounters()
	if minisheet then
		for _,v in pairs(spellclasslist.getWindows()) do
			v.onSpellCounterUpdate();
		end
	else
		for _,v in pairs(actions.subwindow.spellclasslist.getWindows()) do
			v.onSpellCounterUpdate();
		end
	end
end