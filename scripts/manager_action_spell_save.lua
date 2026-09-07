-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYSAVEVS = "applysavevs";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYSAVEVS, handleApplySaveVs);

	ActionsManager.registerTargetingHandler("spellsave", ActionCore.onTargeting);

	ActionsManager.registerModHandler("castsave", modSaveVs);
	ActionsManager.registerModHandler("spellsave", modSaveVs);
	
	ActionsManager.registerResultHandler("castsave", onCastSaveVs);
	ActionsManager.registerResultHandler("spellsave", onSpellSaveVs);
end

function notifyApplySaveVs(rSource, rTarget, rRoll)
	local msgOOB = UtilityManager.encodeRollToOOB(rRoll);
	msgOOB.type = ActionSpellSave.OOB_MSGTYPE_APPLYSAVEVS;
	msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);
	msgOOB.sTargetNode = ActorManager.getCreatureNodeName(rTarget);
	Comm.deliverOOBMessage(msgOOB, "");
end
function handleApplySaveVs(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);
	local rSaveVsRoll = UtilityManager.decodeRollFromOOB(msgOOB);
	ActionSpellSave.performSaveVsRoll(rSource, rTarget, rSaveVsRoll);
end
function performSaveVsRoll(rSource, rTarget, rSaveVsRoll)
	if not rSaveVsRoll then
		return;
	end
	local sSaveShort, sSaveDC = (rSaveVsRoll.sDesc or ""):match("%[(%w+) DC (%d+)%]");
	if not sSaveShort then
		return;
	end
	local sSave = DataCommon.save_stol[sSaveShort];
	if not sSave then
		return;
	end

	local rRoll = ActionSave.getRoll(rTarget, sSave);
	rRoll.bVsSave = true;
	rRoll.sSaveDesc = rSaveVsRoll.sDesc;
	rRoll.bSecret = rSaveVsRoll.bSecret;
	rRoll.nTarget = rSaveVsRoll.nMod; 
	rRoll.bRemoveOnMiss = rSaveVsRoll.bRemoveOnMiss;
	rRoll.tActionTags = rSaveVsRoll.tActionTags;

	-- Legacy (2026-08)
	rRoll.sSource = ActorManager.getCTNodeName(rSource);

	ActionsManager.performAction(draginfo, rTarget, rRoll);
end

function getSaveVsRoll(rActor, rAction)
	local rRoll = {
		sType = "spellsave",
		sDesc = ActionCore.encodeActionText(rAction, "action_savevs_tag"),
		aDice = {},
		nMod = (rAction.savemod or 0),
	};

	if rAction.save == "fortitude" then
		rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, string.format("[FORT DC %d]", rAction.savemod));
	elseif rAction.save == "reflex" then
		rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, string.format("[REF DC %d]", rAction.savemod));
	elseif rAction.save == "will" then
		rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, string.format("[WILL DC %d]", rAction.savemod));
	end

	if rAction.dcstat then
		local sAbilityEffect = DataCommon.ability_ltos[rAction.dcstat];
		if sAbilityEffect then
			rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, string.format("[MOD:%s]", sAbilityEffect));
		end
	end
	if rAction.onmissdamage == "half" then
		rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, "[HALF ON SAVE]");
	end

	local nDCEffectMod = EffectManager.getBonusMod(rActor, "DC", { tActionTags = rAction.tActionTags, });
	if nDCEffectMod ~= 0 then
		rRoll.nMod = rRoll.nMod + nDCEffectMod;
		rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, EffectManager.buildEffectOutput(nDCEffectMod));
	end

	rRoll.tActionTags = rAction.tActionTags;

	return rRoll;
end

function modSaveVs(rSource, rTarget, rRoll)
	if rSource then
		local sActionStat = nil;
		local sModStat = string.match(rRoll.sDesc, "%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		end
		if sActionStat then
			local nBonusStat, nBonusEffects = ActorManagerD20.getAbilityEffectsBonus(rSource, sActionStat);
			if nBonusEffects > 0 then
				rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, EffectManager.buildEffectOutput(nBonusStat));
				rRoll.nMod = rRoll.nMod + nBonusStat;
			end
		end
	end
end

function onCastSaveVs(rSource, rTarget, rRoll)
	if rTarget then
		local sSaveShort, sSaveDC = string.match(rRoll.sDesc, "%[(%w+) DC (%d+)%]")
		if sSaveShort then
			local sSave = DataCommon.save_stol[sSaveShort];
			if sSave then
				ActionSpellSave.notifyApplySaveVs(rSource, rTarget, rRoll);
				return true;
			end
		end
	end

	return false;
end
function onSpellSaveVs(rSource, rTarget, rRoll)
	if ActionSpellSave.onCastSaveVs(rSource, rTarget, rRoll) then
		return;
	end

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Comm.deliverChatMessage(rMessage);
end
