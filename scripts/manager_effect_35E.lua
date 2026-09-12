-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	EffectManager.registerStandardDescriptorGroups();
	EffectManagerD20.registerStandardConditionals();
	
	GameManager.setFunction("onActorStartTurn", EffectManager35E.onActorStartTurn);
	GameManager.setFunction("onActorEndTurn", EffectManager35E.onActorEndTurn);
end

--
--	EFFECT MANAGER OVERRIDES
--

function onActorStartTurn(rActor)
	EffectManager.applyTurnChangeEffect(rActor, "FHEAL", ActionHealthD20.applyOngoingHealthAdjustment);
	EffectManager.applyTurnChangeEffect(rActor, "REGEN", ActionHealthD20.applyOngoingHealthAdjustment);
	EffectManager.applyTurnChangeEffect(rActor, "TEMPO", ActionHealthD20.applyOngoingHealthAdjustment);
	EffectManager.applyTurnChangeEffect(rActor, "DMGO", ActionHealthD20.applyOngoingHealthAdjustment);
	EffectManager.applyTurnChangeEffect(rActor, "SAVEO", EffectManager35E.applySave);
end
function onActorEndTurn(rActor)
	EffectManager.applyTurnChangeEffect(rActor, "REGENE", ActionHealthD20.applyOngoingHealthAdjustment);
	EffectManager.applyTurnChangeEffect(rActor, "TEMPOE", ActionHealthD20.applyOngoingHealthAdjustment);
	EffectManager.applyTurnChangeEffect(rActor, "DMGOE", ActionHealthD20.applyOngoingHealthAdjustment);
	EffectManager.applyTurnChangeEffect(rActor, "SAVEOE", EffectManager35E.applySave);
end
function applySave(rActor, tCompData)
	if not rActor or not tCompData then
		return;
	end
	if (tCompData.mod or 0) == 0 then
		return;
	end

	local sSave = tCompData.sRemainder:match("^%w+");
	if (sSave or "") == "" then
		return;
	end
	sSave = DataCommon.save_stol[sSave:upper()] or sSave:lower();
	if not DataCommon.save_ltos[sSave] then
		return;
	end

	local bHalfOnSave = StringManager.contains(tCompData.remainder, "half");
	local bExpireNone = StringManager.contains(tCompData.remainder, "expirenone");
	local bExpireAny = StringManager.contains(tCompData.remainder, "expireany");

	local tSaveDesc = {};
	table.insert(tSaveDesc, ActionCore.encodeActionText({ label = Interface.getString("effect_special_SAVE"), }, "action_savevs_tag"));
	if bHalfOnSave then
		table.insert(tSaveDesc, "[HALF ON SAVE]");
	end

	local rRoll = ActionSave.getRoll(rActor, sSave);
	rRoll.sSaveDesc = table.concat(tSaveDesc, " ");
	rRoll.nTarget = tCompData.mod;
	rRoll.sEffectRecord = DB.getPath(tCompData.node);
	if bExpireAny then
		rRoll.sEffectExpire = "any";
	elseif bExpireNone then
		rRoll.sEffectExpire = "none";
	else
		rRoll.sEffectExpire = "success";
	end
	rRoll.tActionTags = {};
	for _,sComp in ipairs(EffectManager.parseEffect(EffectVarManager.getEffectVarFromNode(tCompData.node, "sName", ""))) do
		local sLower = sComp:lower();
		if ActionCore.isCondition(sLower) then
			table.insert(rRoll.tActionTags, sLower);
		end
	end

	local rSource = EffectManager.getSourceActor(tCompData.node) or rActor;

	-- Legacy (2026-08)
	rRoll.sSource = ActorManager.getCTNodeName(rSource);

	ActionsManager.actionDirect(rActor, rRoll.sType, { rRoll }, { { rSource } });
end
