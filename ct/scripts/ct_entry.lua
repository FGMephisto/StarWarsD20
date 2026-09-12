-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	super.onInit();
	self.onHealthChanged();
end

function onHealthChanged()
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local _,sStatus,sColor = ActorHealthManager.getHealthInfo(rActor);
	
	if wounds then
		wounds.setColor(sColor);
	end
	if nonlethal then
		nonlethal.setColor(sColor);
	end
	if status then
		status.setValue(sStatus);
	end
	
	if not self.isPC() then
		if idelete then
			idelete.setVisible(ActorHealthManager.isDyingOrDeadStatus(sStatus));
		end
	end
end

function linkPCFields()
	super.linkPCFields();

	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		if senses then
			senses.setLink(DB.createChild(nodeChar, "senses", "string"), true);
		end

		if hp then
			hp.setLink(DB.createChild(nodeChar, "hp.total", "number"));
		end
		if hptemp then
			hptemp.setLink(DB.createChild(nodeChar, "hp.temporary", "number"));
		end
		if nonlethal then
			nonlethal.setLink(DB.createChild(nodeChar, "hp.nonlethal", "number"));
		end
		if wounds then
			wounds.setLink(DB.createChild(nodeChar, "hp.wounds", "number"));
		end

		if type then
			if DataCommon.isPFRPG() then
				type.addSource(DB.getPath(nodeChar, "alignment"), true);
			elseif alignment then
				alignment.setLink(DB.createChild(nodeChar, "alignment", "string"));
			end
			type.addSource(DB.getPath(nodeChar, "size"), true);
			type.addSource(DB.getPath(nodeChar, "race"));
		elseif alignment and not DataCommon.isPFRPG() then
			alignment.setLink(DB.createChild(nodeChar, "alignment", "string"));
		end
		
		if grapple then
			grapple.setLink(DB.createChild(nodeChar, "attackbonus.grapple.total", "number"), true);
		end
		
		if ac_final then
			ac_final.setLink(DB.createChild(nodeChar, "ac.totals.general", "number"), true);
		end
		if ac_touch then
			ac_touch.setLink(DB.createChild(nodeChar, "ac.totals.touch", "number"), true);
		end
		if ac_flatfooted then
			ac_flatfooted.setLink(DB.createChild(nodeChar, "ac.totals.flatfooted", "number"), true);
		end
		if cmd then
			cmd.setLink(DB.createChild(nodeChar, "ac.totals.cmd", "number"), true);
		end
		
		if fortitudesave then
			fortitudesave.setLink(DB.createChild(nodeChar, "saves.fortitude.total", "number"), true);
		end
		if reflexsave then
			reflexsave.setLink(DB.createChild(nodeChar, "saves.reflex.total", "number"), true);
		end
		if willsave then
			willsave.setLink(DB.createChild(nodeChar, "saves.will.total", "number"), true);
		end
		
		if sr then
			sr.setLink(DB.createChild(nodeChar, "defenses.sr.total", "number"), true);
		end

		if init then
			init.setLink(DB.createChild(nodeChar, "initiative.total", "number"), true);
		end
	end
end
