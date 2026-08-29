-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars D20
--

	
function onInit()
	self.setInitialized();

	local nodeChar = DB.getChild(getDatabaseNode(), "...");
	if nodeChar then
		if DB.getChild(nodeChar, "hptemp") or not DB.getChild(nodeChar, "hp.temporary") then
			points.setLink(DB.createChild(nodeChar, "hptemp", "number"));
		else
			points.setLink(DB.createChild(nodeChar, "hp.temporary", "number"));
		end
	end

	self.onCasterTypeChanged();
	self.onDisplayChanged();

	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
end

function onLockModeChanged(bReadOnly)
	local tFields = { "castertype", "label", "points", "idelete", };
	WindowManager.callSafeControlsSetLockMode(self, tFields, bReadOnly);
end

local _bShow = true;
function setFilter(bValue)
	_bShow = bValue;
end
function getFilter()
	return _bShow;
end
local _bInitialized = false;
function isInitialized()
	return _bInitialized;
end
function setInitialized()
	_bInitialized = true;
end

function registerMenuItems()
	resetMenuItems();
	
	if DB.getValue(getDatabaseNode(), "castertype", "") == "" then
		registerMenuItem(Interface.getString("menu_resetspells"), "pointer_circle", 3);
	end
end

local bStatUpdateLock = false;
function onStatUpdate()
	if bStatUpdateLock then
		return;
	end
	bStatUpdateLock = true;

	for _, v in pairs(spells.getWindows()) do
		if v.header.subwindow and v.header.subwindow.actionsmini then
			for _,v2 in pairs(v.header.subwindow.actionsmini.getWindows()) do
				v2.onDataChanged();
			end
		end
		if v.actions then
			for _,v2 in pairs(v.actions.getWindows()) do
				v2.onDataChanged();
			end
		end
	end

	bStatUpdateLock = false;
end

function onMenuSelection(selection, subselection)
	if selection == 3 then
		local nodeCaster = DB.getChild(getDatabaseNode(), "...");
		SpellManager.resetPrepared(nodeCaster);
	end
end

-- Detail toggle is unused in this layout

function getSheetMode()
	if minisheet then
		return "combat";
	end
	
	return DB.getValue(getDatabaseNode(), "...spellmode", "");
end

function onCasterTypeChanged()
	local bShowPP = (DB.getValue(getDatabaseNode(), "castertype", "") == "points");
	points.setVisible(bShowPP);
	label_points.setVisible(bShowPP);
	
	self.registerMenuItems();
end

function onDisplayChanged()
	if minisheet then
		return;
	end
	
	for _,vSpell in pairs(spells.getWindows()) do
		vSpell.onDisplayChanged();
	end
end

function onSpellCounterUpdate()
	if not self.isInitialized() then
		return;
	end
	
	SpellManager.updateSpellClassCounts(getDatabaseNode());

	self.updateSpellView();
	
	self.performFilter();
end

function updateSpellView()
	local nodeSpellClass = getDatabaseNode();

	local bClassShow = false;
	local sSheetMode = self.getSheetMode();
	local bCombatMode = (sSheetMode == "combat");
	local sCasterType = DB.getValue(nodeSpellClass, "castertype", "");

	local bSpellShow, nodeSpell, nPointCost;

	local nPP = DB.getValue(nodeSpellClass, "points", 0);
	local nPPUsed = DB.getValue(nodeSpellClass, "pointsused", 0);
	
	for _, vSpell in pairs(spells.getWindows()) do
		nodeSpell = vSpell.getDatabaseNode();
		
		if sCasterType == "points" then
			nPointCost = DB.getValue(nodeSpell, "cost", 0);
			if bCombatMode then
				bSpellShow = (nPointCost <= (nPP - nPPUsed));
			else
				bSpellShow = true;
			end
		else
			bSpellShow = true;
		end
		
		vSpell.setFilter(bSpellShow);
		bClassShow = bClassShow or bSpellShow;

		if vSpell.header.subwindow then
			if sCasterType == "points" then
				if vSpell.header.subwindow.usepower then
					vSpell.header.subwindow.usepower.setVisible(true);
					vSpell.header.subwindow.usepower.setTooltipText(Interface.getString("power_tooltip_use"));
				end
				if vSpell.header.subwindow.cost then
					vSpell.header.subwindow.cost.setVisible(true);
				end
				if vSpell.header.subwindow.counter then
					vSpell.header.subwindow.counter.setVisible(false);
				end
				if vSpell.header.subwindow.usespacer then
					vSpell.header.subwindow.usespacer.setVisible(false);
				end
			else
				if vSpell.header.subwindow.usepower then
					vSpell.header.subwindow.usepower.setVisible(true);
					vSpell.header.subwindow.usepower.setTooltipText(Interface.getString("spell_tooltip_castspell"));
				end
				if vSpell.header.subwindow.cost then
					vSpell.header.subwindow.cost.setVisible(false);
				end
				if vSpell.header.subwindow.counter then
					vSpell.header.subwindow.counter.setVisible(false);
				end
				if vSpell.header.subwindow.usespacer then
					vSpell.header.subwindow.usespacer.setVisible(false);
				end
			end
		end
	end
	
	if bCombatMode then
		self.setFilter(bClassShow);
	else
		self.setFilter(true);
	end
end

function performFilter()
	spells.applyFilter();
	windowlist.applyFilter();
end

function showSpellsForLevel(nLevel)
	-- No levels exist in this ruleset, spells are listed in a flat list
end
