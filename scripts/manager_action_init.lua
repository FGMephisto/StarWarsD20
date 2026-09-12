-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYINIT = "applyinit";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInit);

	ActionsManager.registerModHandler("init", modRoll);
	ActionsManager.registerResultHandler("init", onResolve);
end

function notifyApplyInit(rSource, nTotal)
	if not rSource then
		return;
	end
	
	local msgOOB = {
		type = OOB_MSGTYPE_APPLYINIT,
		nTotal = nTotal,
		sSourceNode = ActorManager.getCreatureNodeName(rSource),
	};
	Comm.deliverOOBMessage(msgOOB, "");
end
function handleApplyInit(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	if not rSource then
		return;
	end

	local nTotal = tonumber(msgOOB.nTotal) or 0;
	DB.setValue(ActorManager.getCTNode(rSource), "initresult", "number", nTotal);
end

function performRoll(draginfo, rActor, bSecretRoll)
	local rRoll = getRoll(rActor, bSecretRoll);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end
function getRoll(rActor, bSecretRoll)
	local rRoll = {
		sType = "init",
		sDesc = string.format("[%s]", Interface.getString("action_init_tag")),
		aDice = DiceRollManager.getActorDice({ "d20" }, rActor),
		nMod = 0,
		bSecret = bSecretRoll,
	};
	
	ActionInit.resolveRollAbility(rActor, rRoll);
	if not StringManager.contains({ "", "dexterity" }, (rRoll.sAbility or "")) then
		local sAbilityEffect = DataCommon.ability_ltos[sAbility];
		if sAbilityEffect then
			rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, string.format("[MOD:%s]", sAbilityEffect));
		end
	end
	
	return rRoll;
end

function modRoll(rSource, rTarget, rRoll)
	ActionInit.applyEffectsToRollMod(rSource, rTarget, rRoll);
end
function applyEffectsToRollMod(rSource, rTarget, rRoll)
	ActionInit.resolveRollAbility(rSource, rRoll);
	ActionInit.applyAbilityEffectsToRollMod(rSource, rTarget, rRoll);
	ActionInit.applyStandardEffectsToRollMod(rSource, rTarget, rRoll);
end
function applyAbilityEffectsToRollMod(rSource, _, rRoll)
	local nAbilityMod, nAbilityCount = ActorManagerD20.getAbilityEffectsBonus(rSource, rRoll.sAbility);
	ActionCore.applyModRollEffect(rRoll, nil, nAbilityMod, nAbilityCount);
end
function applyStandardEffectsToRollMod(rSource, _, rRoll)
	local tInitDice, nInitMod, nInitCount = EffectManager.getBonusDiceMod(rSource, "INIT");
	ActionCore.applyModRollEffect(rRoll, tInitDice, nInitMod, nInitCount);

	if EffectManager.hasCondition(rSource, "Deafened") then
		ActionCore.applyModRollEffect(rRoll, nil, -4, 1);
	end
end

function onResolve(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Comm.deliverChatMessage(rMessage);
	
	ActionInit.notifyApplyInit(rSource, ActionsManager.total(rRoll));
	ActionInit.applyHRFFOption(rSource);
end
function applyHRFFOption(rActor, nInit)
	if not rActor then
		return;
	end

	if not OptionsManager.isOption("HRFF", "on") then
		return;
	end
	local nCurrent = DB.getValue("combattracker.round", 0);
	if nCurrent > 1 then
		return;
	end
	if ActorManager35E.hasRollSpecialAbility(rActor, "Uncanny Dodge") or ActorManager35E.hasRollSpecialAbility(rActor, "Improved Uncanny Dodge") then
		return;
	end

	local nInit = DB.getValue(ActorManager.getCTNode(rActor), "initresult", 0);
	EffectManager.addEffectByTable(rActor, { sName = "Flat-Footed", nDuration = 1, sExpire = "start", nInit = nInit, bSkipAnnounce = true, });
end

--
--	OTHER
--

function resolveRollAbility(rActor, rRoll)
	if not rActor or not rRoll or ((rRoll.sAbility or "") ~= "") then
		return;
	end

	if ActorManager.isPC(rActor) then
		rRoll.sAbility = DB.getValue(ActorManager.getCreatureNode(rActor), "initiative.ability", "");
	else
		rRoll.sAbility = "dexterity";
	end
end

-- Used in combat manager script to get initiative adjustments for automatic initiative
-- Returns effect existence, effect dice, effect mod, effect advantage, effect disadvantage
function getEffectAdjustments(rActor)
	local rRoll = {
		sType = "init",
		bEffects = false,
		tEffectDice = {},
		nEffectMod = 0,
	};
	ActionInit.applyEffectsToRollMod(rActor, nil, rRoll);
	return rRoll;
end
