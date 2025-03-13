-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
end

function onLockModeChanged(bReadOnly)
	local tFields = { "spellclass_iadd", "weapon_iadd", };
	WindowManager.callSafeControlsSetVisible(self, tFields, not bReadOnly);

	if UtilityManager.getTopWindow(self).getClass() == "charsheetmini" then
		return;
	end

	local tFieldsPlay = { "label_mode", "spellmode", "label_display", "spelldisplaymode", };
	WindowManager.callSafeControlsSetVisible(self, tFieldsPlay, bReadOnly);
	if not bReadOnly then
		DB.setValue(getDatabaseNode(), "spellmode", "string", "standard");
	end
end

function onDisplayChanged()
	if not minisheet then
		if actions and actions.subwindow then
			for _,v in pairs(actions.subwindow.spellclasslist.getWindows()) do
				v.onDisplayChanged();
			end
		end
	end
end

function onModeChanged()
	if minisheet then
		weaponlist.onModeChanged();
	else
		if actions and actions.subwindow then
			actions.subwindow.weaponlist.onModeChanged();
		end
	end
	
	self.updateSpellCounters();
end
					
function updateSpellCounters()
	if minisheet then
		for _,v in pairs(spellclasslist.getWindows()) do
			v.onSpellCounterUpdate();
		end
	else
		if actions and actions.subwindow then
			for _,v in pairs(actions.subwindow.spellclasslist.getWindows()) do
				v.onSpellCounterUpdate();
			end
		end
	end
end

