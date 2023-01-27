-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	super.onInit();
	self.onHealthChanged();
end

-- ===================================================================================================================
-- Modified
-- ===================================================================================================================
function onHealthChanged()
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local _,sStatus,sColor = ActorHealthManager.getHealthInfo(rActor);
	
	wounds.setColor(sColor);
	-- nonlethal.setColor(sColor);
	status.setValue(sStatus);
	
	if not self.isPC() then
		idelete.setVisibility(ActorHealthManager.isDyingOrDeadStatus(sStatus));
	end
end

-- ===================================================================================================================
-- Modified
-- ===================================================================================================================
function linkPCFields()
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		name.setLink(DB.createChild(nodeChar, "name", "string"), true);
		senses.setLink(DB.createChild(nodeChar, "senses", "string"), true);

		hp.setLink(DB.createChild(nodeChar, "hp.total", "number"));
		hptemp.setLink(DB.createChild(nodeChar, "hp.temporary", "number"));
		-- nonlethal.setLink(DB.createChild(nodeChar, "hp.nonlethal", "number"));
		wounds.setLink(DB.createChild(nodeChar, "hp.wounds", "number"));

		if DataCommon.isPFRPG() then
			type.addSource(DB.getPath(nodeChar, "alignment"), true);
		else
			alignment.setLink(DB.createChild(nodeChar, "alignment", "string"));
		end
		type.addSource(DB.getPath(nodeChar, "size"), true);
		type.addSource(DB.getPath(nodeChar, "race"));
		
		-- ToDo: Needed/Present?
		grapple.setLink(DB.createChild(nodeChar, "attackbonus.grapple.total", "number"), true);
		
		ac_final.setLink(DB.createChild(nodeChar, "ac.totals.general", "number"), true);
		ac_touch.setLink(DB.createChild(nodeChar, "ac.totals.touch", "number"), true);
		ac_flatfooted.setLink(DB.createChild(nodeChar, "ac.totals.flatfooted", "number"), true);
		-- cmd.setLink(DB.createChild(nodeChar, "ac.totals.cmd", "number"), true);
		
		fortitudesave.setLink(DB.createChild(nodeChar, "saves.fortitude.total", "number"), true);
		reflexsave.setLink(DB.createChild(nodeChar, "saves.reflex.total", "number"), true);
		willsave.setLink(DB.createChild(nodeChar, "saves.will.total", "number"), true);
		
		sr.setLink(DB.createChild(nodeChar, "defenses.sr.total", "number"), true);

		init.setLink(DB.createChild(nodeChar, "initiative.total", "number"), true);
	end
end

-- ===================================================================================================================
-- ToDo: Needed?
-- ===================================================================================================================
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