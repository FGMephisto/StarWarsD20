-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	-- Show active section, if combatant is active
	self.onActiveChanged();

	-- Acquire token reference, if any
	self.linkToken();
	
	-- Set up the PC links
	self.onLinkChanged();
	self.onFactionChanged();
	self.onHealthChanged();
	
	-- Register the deletion menu item for the host
	registerMenuItem(Interface.getString("list_menu_deleteitem"), "delete", 6);
	registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);
end

function onMenuSelection(selection, subselection)
	if selection == 6 and subselection == 7 then
		self.delete();
	end
end
function onLinkChanged()
	-- If a PC, then set up the links to the char sheet
	if self.isPC() then
		self.linkPCFields();
		name.setLine(false);
	end
	self.onIDChanged();
end
function onIDChanged()
	local nodeRecord = getDatabaseNode();
	local sClass = link.getValue();
	local sRecordType = LibraryData.getRecordTypeFromDisplayClass(sClass);
	local bID = LibraryData.getIDState(sRecordType, nodeRecord, true);
	
	name.setVisible(bID);
	nonid_name.setVisible(not bID);

	isidentified.setVisible(LibraryData.getIDMode(sRecordType));
end
function onFactionChanged()
	-- Update the entry frame
	self.updateDisplay();

	-- If not a friend, then show visibility toggle
	if friendfoe.getStringValue() == "friend" then
		tokenvis.setVisible(false);
	else
		tokenvis.setVisible(true);
	end
end
function onHealthChanged()
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local _,sStatus,sColor = ActorHealthManager.getHealthInfo(rActor);
	
	wounds.setColor(sColor);
	nonlethal.setColor(sColor);
	status.setValue(sStatus);
	
	if not self.isPC() then
		idelete.setVisibility(ActorHealthManager.isDyingOrDeadStatus(sStatus));
	end
end
function onVisibilityChanged()
	TokenManager.updateVisibility(getDatabaseNode());
	windowlist.onVisibilityToggle();
end
function onActiveChanged()
	self.onSectionChanged("active");
end

function updateDisplay()
	local sFaction = friendfoe.getStringValue();

	if DB.getValue(getDatabaseNode(), "active", 0) == 1 then
		name.setFont("sheetlabel");
		nonid_name.setFont("sheetlabel");
		
		active_spacer_top.setVisible(true);
		active_spacer_bottom.setVisible(true);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend_active");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral_active");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe_active");
		else
			setFrame("ctentrybox_active");
		end
	else
		name.setFont("sheettext");
		nonid_name.setFont("sheettext");
		
		active_spacer_top.setVisible(false);
		active_spacer_bottom.setVisible(false);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe");
		else
			setFrame("ctentrybox");
		end
	end
end

function linkToken()
	local imageinstance = token.populateFromImageNode(tokenrefnode.getValue(), tokenrefid.getValue());
	if imageinstance then
		TokenManager.linkToken(getDatabaseNode(), imageinstance);
	end
end

function delete()
	local node = getDatabaseNode();
	if not node then
		close();
		return;
	end
	
	-- Clear any effects first, so that saves aren't triggered when initiative advanced
	DB.deleteChildren(node, "effects");

	-- Clear NPC wounds, so that stabilization rolls aren't triggered when initiative advanced
	if not self.isPC() then
		DB.setValue(node, "wounds", "number", 0);
	end

	-- Move to the next actor, if this CT entry is active
	if self.isActive() then
		CombatManager.nextActor();
	end

	-- Delete the database node and close the window
	local cList = windowlist;
	node.delete();

	-- Update list information
	cList.onVisibilityToggle();
end

function linkPCFields()
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		name.setLink(nodeChar.createChild("name", "string"), true);
		senses.setLink(nodeChar.createChild("senses", "string"), true);

		hp.setLink(nodeChar.createChild("hp.total", "number"));
		hptemp.setLink(nodeChar.createChild("hp.temporary", "number"));
		nonlethal.setLink(nodeChar.createChild("hp.nonlethal", "number"));
		wounds.setLink(nodeChar.createChild("hp.wounds", "number"));

		if DataCommon.isPFRPG() then
			type.addSource(DB.getPath(nodeChar, "alignment"), true);
		else
			alignment.setLink(nodeChar.createChild("alignment", "string"));
		end
		type.addSource(DB.getPath(nodeChar, "size"), true);
		type.addSource(DB.getPath(nodeChar, "race"));
		
		grapple.setLink(nodeChar.createChild("attackbonus.grapple.total", "number"), true);
		
		ac_final.setLink(nodeChar.createChild("ac.totals.general", "number"), true);
		ac_touch.setLink(nodeChar.createChild("ac.totals.touch", "number"), true);
		ac_flatfooted.setLink(nodeChar.createChild("ac.totals.flatfooted", "number"), true);
		cmd.setLink(nodeChar.createChild("ac.totals.cmd", "number"), true);
		
		fortitudesave.setLink(nodeChar.createChild("saves.fortitude.total", "number"), true);
		reflexsave.setLink(nodeChar.createChild("saves.reflex.total", "number"), true);
		willsave.setLink(nodeChar.createChild("saves.will.total", "number"), true);
		
		sr.setLink(nodeChar.createChild("defenses.sr.total", "number"), true);

		init.setLink(nodeChar.createChild("initiative.total", "number"), true);
	end
end

--
--	HELPERS
--

function isRecordType(s)
	local sClass = link.getValue();
	local sRecordType = LibraryData.getRecordTypeFromDisplayClass(sClass);
	return (sRecordType == s);
end
function isPC()
	return self.isRecordType("charsheet");
end
function isActive()
	return (active.getValue() == 1);
end

--
--	SECTION HANDLING
--

function getSectionToggle(sKey)
	local bResult = false;

	local sButtonName = "button_section_" .. sKey;
	local cButton = self[sButtonName];
	if cButton then
		bResult = (cButton.getValue() == 1);
		if (sKey == "active") and self.isActive() and not self.isPC() then
			bResult = true;
		end
	end

	return bResult;
end
function onSectionChanged(sKey)
	local sSectionName = "sub_" .. sKey;

	local cSection = self[sSectionName];
	if cSection then
		local bShow = self.getSectionToggle(sKey);

		if bShow then
			local sSectionClass = "ct_section_" .. sKey;
			if sKey == "active" then
				if self.isRecordType("npc") then
					sSectionClass = sSectionClass .. "_npc";
				end
			end
			cSection.setValue(sSectionClass, getDatabaseNode());
		else
			cSection.setValue("", "");
		end
		cSection.setVisible(bShow);
	end

	local sSummaryName = "summary_" .. sKey;
	local cSummary = self[sSummaryName];
	if cSummary then
		cSummary.onToggle();
	end
end

--
--	DEPRECATED
--

function setTargetingVisible()
	self.onSectionChanged("targets");
end
function setActiveVisible()
	self.onSectionChanged("active");
end
function setDefensiveVisible()
	self.onSectionChanged("defense");
end
function setAttributesVisible()
	self.onSectionChanged("attributes");
end
function setSpacingVisible(v)
	self.onSectionChanged("spacing");
end
function setEffectsVisible(v)
	self.onSectionChanged("effects");
end
