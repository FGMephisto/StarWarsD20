-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
	self.updateAbility();

	local node = getDatabaseNode();
	for _,v in pairs(DataCommon.abilities) do
		DB.addHandler(DB.getPath(node, v), "onUpdate", updateAbility);
	end

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "spellset"), "onChildUpdate", updateAbility);

	if spellmode then
		local sMode = DB.getValue(node, "spellmode", "");
		spellmode.setStringValue(sMode);
	end
end
function onClose()
	local node = getDatabaseNode();
	for _,v in pairs(DataCommon.abilities) do
		DB.removeHandler(DB.getPath(node, v), "onUpdate", updateAbility);
	end

	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "spellset"), "onChildUpdate", updateAbility);
end

function onLockModeChanged(bReadOnly)
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	WindowManager.callSafeControlsSetVisible(self, { "spell_iadd", "spellclass_iadd" }, not bReadOnly);
end

function updateAbility()
	for _,v in pairs(spellclasslist.getWindows()) do
		v.onStatUpdate();
	end
end
function onModeChanged()
	local sMode = "";
	if spellmode then
		sMode = spellmode.getStringValue();
	end
	DB.setValue(getDatabaseNode(), "spellmode", "string", sMode);
	for _,vClass in pairs(spellclasslist.getWindows()) do
		vClass.onSpellCounterUpdate();
		vClass.onDisplayChanged();
	end
end

function getOrCreateForceClass()
	local nodeNPC = getDatabaseNode();
	local nodeSpellSet = DB.createChild(nodeNPC, "spellset");
	local aClasses = DB.getChildList(nodeSpellSet);
	if #aClasses > 0 then
		return aClasses[1];
	end
	
	local nodeClass = DB.createChild(nodeSpellSet);
	DB.setValue(nodeClass, "label", "string", Interface.getString("spell_header_forcepowers") or "Force Powers");
	DB.setValue(nodeClass, "castertype", "string", "points");
	return nodeClass;
end

function addPower()
	local nodeClass = self.getOrCreateForceClass();
	if not nodeClass then return; end
	
	local nodeSpells = DB.createChild(nodeClass, "spells");
	local nodePower = DB.createChild(nodeSpells);

	for _, vWin in pairs(spellclasslist.getWindows()) do
		if vWin.getDatabaseNode() == nodeClass then
			for _, vSpell in pairs(vWin.spells.getWindows()) do
				if vSpell.getDatabaseNode() == nodePower then
					if vSpell.name then
						vSpell.name.setFocus();
					end
					return;
				end
			end
		end
	end
end

function addSpellClass()
	self.addPower();
end

function onSpellDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		if sClass == "spelldesc" or sClass == "spelldesc2" or sClass == "power" or sClass == "reference_spell" then
			local nodeSource = draginfo.getDatabaseNode();
			if nodeSource then
				local nodeClass = self.getOrCreateForceClass();
				if nodeClass then
					local nodeSpells = DB.createChild(nodeClass, "spells");
					local nodeNew = DB.createChild(nodeSpells);
					DB.copyNode(nodeSource, nodeNew);
					return true;
				end
			end
		end
	end
end