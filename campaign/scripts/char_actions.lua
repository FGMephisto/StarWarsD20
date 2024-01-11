-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onDisplayChanged()
	if not minisheet then
		for _,v in pairs(actions.subwindow.spellclasslist.getWindows()) do
			v.onDisplayChanged();
		end
	end
end

function onModeChanged()
	if minisheet then
		weaponlist.onModeChanged();
	else
		actions.subwindow.weaponlist.onModeChanged();
	end
	
	self.updateSpellCounters();
end
					
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

