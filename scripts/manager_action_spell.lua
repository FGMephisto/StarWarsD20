-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ActionsManager.registerTargetingHandler("cast", ActionCore.onTargeting);
	ActionsManager.registerTargetingHandler("clc", ActionCore.onTargeting);

	ActionsManager.registerModHandler("clc", modCLC);
	ActionsManager.registerModHandler("concentration", modConcentration);
	
	ActionsManager.registerResultHandler("cast", onSpellCast);
	ActionsManager.registerResultHandler("castclc", onCastCLC);
	ActionsManager.registerResultHandler("clc", onCLC);
	ActionsManager.registerResultHandler("spellfailure", onSpellFailure);
end

function getSpellCastRoll(rActor, rAction)
	local rRoll = {
		sType = "cast",
		sDesc = ActionCore.encodeActionText(rAction, "action_cast_tag"),
		aDice = {},
		nMod = 0,
		sActionPath = DB.getPath(rAction.nodeAction),
		tActionTags = rAction.tActionTags,
	};
	return rRoll;
end
function getCLCRoll(rActor, rAction)
	local rRoll = {};
	rRoll.sType = "clc";
	rRoll.aDice = DiceRollManager.getActorDice({ "d20" }, rActor);
	rRoll.nMod = rAction.clc or 0;
	
	rRoll.sDesc = "[CL CHECK";
	if rAction.order and rAction.order > 1 then
		rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
	end
	rRoll.sDesc = rRoll.sDesc .. "] " .. StringManager.capitalizeAll(rAction.label);
	if rAction.sr == "no" then
		rRoll.sDesc = rRoll.sDesc .. " [SR NOT ALLOWED]";
	end
	rRoll.tActionTags = rAction.tActionTags;
	
	return rRoll;
end
function performSpellFailureRoll(rActor, nTarget)
	local rRoll = {
		sType = "spellfailure",
		sDesc = "[SPELL FAILURE CHECK]",
		aDice = { "d100" },
		nTarget = nTarget,
	};
	ActionsManager.actionDirect(rActor, rRoll.sType, { rRoll });
end

function modCLC(rSource, rTarget, rRoll)
	if rSource then
		local aAddDice = {};
		local nAddMod = 0;
		
		-- Get CLC modifier effects
		local tCLCDice, nCLCMod, nCLCCount = EffectManager.getBonusDiceMod(rSource, "CLC", { rTarget = rTarget, tActionTags = rRoll.tActionTags, });
		if nCLCCount > 0 then
			bEffects = true;
			for _,v in ipairs(tCLCDice) do
				table.insert(aAddDice, v);
			end
			nAddMod = nAddMod + nCLCMod;
		end
		
		-- Get negative levels
		local nNegLevelMod, nNegLevelCount = EffectManager.getBonusMod(rSource, "NLVL");
		if nNegLevelCount > 0 then
			bEffects = true;
			nAddMod = nAddMod - nNegLevelMod;
		end

		if bEffects then
			rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, EffectManager.buildEffectDiceModOutput(aAddDice, nAddMod));
			DiceRollManager.addRollEffectDiceMod(rSource, rRoll, aAddDice, nAddMod);
		end
	end
end
function modConcentration(rSource, rTarget, rRoll)
	if rSource then
		local sActionStat = nil;
		local sModStat = string.match(rRoll.sDesc, "%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		end

		local nBonusStat, nBonusEffects = ActorManagerD20.getAbilityEffectsBonus(rSource, sActionStat);
		if nBonusEffects > 0 then
			rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, EffectManager.buildEffectOutput(nBonusStat));
			rRoll.nMod = rRoll.nMod + nBonusStat;
		end
	end
end

function onSpellCast(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll, { sIcon = "action_cast", rTarget = rTarget, });
	Comm.deliverChatMessage(rMessage);

	ActionSpell.handleSpellFailure(rSource, rTarget, rRoll);
end
function handleSpellFailure(rSource, rTarget, rRoll)
	local nodeAction = DB.findNode(rRoll.sActionPath);
	local nodeSpell = DB.getChild(nodeAction, "...");
	local rActor = ActorManager.resolveActor(DB.getChild(nodeSpell, "......."));
	handleSpellFailureConditions(rActor, nodeSpell);
	handleSpellFailureComponents(rActor, nodeSpell);
end
function handleSpellFailureConditions(rActor, nodeSpell)
	if not rActor or not nodeSpell then
		return;
	end

	local tComponents = StringManager.splitByPattern( DB.getValue(nodeSpell, "components", ""):lower(), ",", true);

	if EffectManager.hasCondition(rActor, "Silenced") and StringManager.contains(tComponents, "v") then
		ChatManager.sendMessage(Interface.getString("cast_message_verbalwhilesilenced"), { sIcon = "action_error", rActor = rActor, });
		return;
	end

	local sConcCond;
	if EffectManager.hasCondition(rActor, "Pinned") then
		if StringManager.contains(tComponents, "s") then
			ChatManager.sendMessage(Interface.getString("cast_message_somaticwhilepinned"), { sIcon = "action_error", rActor = rActor, });
			return;
		end
		sConcCond = "Pinned";
	end
	if not sConcCond and EffectManager.hasCondition(rActor, "Entangled") then
		sConcCond = "Entangled";
	end
	if not sConcCond and EffectManager.hasCondition(rActor, "Grappled") then
		sConcCond = "Grappled";
	end
	if sConcCond then
		local sMsg = string.format(Interface.getString("cast_message_needconcentrationcheck"), sConcCond);
		ChatManager.sendMessage(sMsg, { sIcon = "action_warning", rActor = rActor, });
	end
end
function handleSpellFailureComponents(rActor, nodeSpell)
	if not rActor or not nodeSpell then
		return;
	end

	local sComponents = DB.getValue(nodeSpell, "components", "");
	local tComponents = StringManager.splitByPattern(sComponents:lower(), ",", true);

	if StringManager.contains(tComponents, "v") then
		handleSpellFailureVerbal(rActor, nodeSpell);
	end
	if StringManager.contains(tComponents, "s") then
		handleSpellFailureSomatic(rActor, nodeSpell);
	end
end
function handleSpellFailureVerbal(rActor, nodeSpell)
	local nVerbalSpellFailureChance = 0;
	if EffectManager.hasCondition(rActor, "Deafened") then
		nVerbalSpellFailureChance = 20;
		ChatManager.Message(Interface.getString("cast_message_verbalwhiledeafened"), true, rActor);
	end

	if nVerbalSpellFailureChance > 0 then
		if OptionsManager.isOption("AUTO_SPELL_FAILURE", "auto") then
			ActionSpell.performSpellFailureRoll(rActor, nVerbalSpellFailureChance);
		elseif OptionsManager.isOption("AUTO_SPELL_FAILURE", "prompt") then
			local sMsg = string.format(Interface.getString("cast_message_verbal_prompt"), nVerbalSpellFailureChance);
			ChatManager.sendMessage(sMsg, { sIcon = "action_warning", rActor = rActor, });
		end
	end
end
function handleSpellFailureSomatic(rActor, nodeSpell)
	if EffectManager.hasCondition(rActor, "NSF") then
		return;
	end

	local nSomaticSpellFailureChance = 0;
	if ActorManager.isPC(rActor) then
		local nodeActor = ActorManager.getCreatureNode(rActor);
		if DB.getValue(nodeActor, "encumbrance.spellfailureactive", 0) == 1 then
			nSomaticSpellFailureChance = DB.getValue(nodeActor, "encumbrance.spellfailure", 0);
		end
	end
	nSomaticSpellFailureChance = nSomaticSpellFailureChance + EffectManager.getBonusMod(rActor, "SF");

	if nSomaticSpellFailureChance > 0 then
		if OptionsManager.isOption("AUTO_SPELL_FAILURE", "auto") then
			ActionSpell.performSpellFailureRoll(rActor, nSomaticSpellFailureChance);
		elseif OptionsManager.isOption("AUTO_SPELL_FAILURE", "prompt") then
			local sMsg = string.format(Interface.getString("cast_message_somatic_prompt"), nSomaticSpellFailureChance);
			ChatManager.sendMessage(sMsg, { sIcon = "action_warning", rActor = rActor, });
		end
	end
end

function onCastCLC(rSource, rTarget, rRoll)
	if rTarget then
		local nSR = ActorManager35E.getSpellDefense(rSource, rTarget);
		nSR = nSR + EffectManager.getBonusMod(rTarget, "SR", { rTarget = rSource, tActionTags = rRoll.tActionTags, });

		if nSR > 0 then
			if not string.match(rRoll.sDesc, "%[SR NOT ALLOWED%]") then
				local rRoll = { 
					sType = "clc", 
					sDesc = rRoll.sDesc, 
					aDice = DiceRollManager.getActorDice({ "d20" }, rSource),
					nMod = rRoll.nMod, 
					bRemoveOnMiss = rRoll.bRemoveOnMiss,
					tActionTags = rRoll.tActionTags,
				};
				ActionsManager.actionDirect(rSource, "clc", { rRoll }, { { rTarget } });
				return true;
			end
		end
	end
end
function onCLC(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll, { rTarget = rTarget, });

	local nTotal = ActionsManager.total(rRoll);
	local bSRAllowed = not string.match(rRoll.sDesc, "%[SR NOT ALLOWED%]");
	
	if rTarget then
		if bSRAllowed then
			local nSR = ActorManager35E.getSpellDefense(rSource, rTarget) + EffectManager.getBonusMod(rTarget, "SR", { rTarget = rSource, tActionTags = rRoll.tActionTags, });
			if nSR > 0 then
				if nTotal >= nSR then
					rMessage.text = StringManager.appendLine(rMessage.text, "[SUCCESS]");
				else
					rMessage.text = StringManager.appendLine(rMessage.text, "[FAILURE]");
					if rSource then
						local bRemoveTarget = false;
						if OptionsManager.isOption("RMMT", "on") then
							bRemoveTarget = true;
						elseif rRoll.bRemoveOnMiss then
							bRemoveTarget = true;
						end
						
						if bRemoveTarget then
							TargetingManager.removeTarget(ActorManager.getCTNodeName(rSource), ActorManager.getCTNodeName(rTarget));
						end
					end
				end
			else
				rMessage.text = StringManager.appendLine(rMessage.text, "[TARGET HAS NO SR]");
			end
		end
	end
	
	Comm.deliverChatMessage(rMessage);
end
function onSpellFailure(rSource, _, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	if rRoll.nTarget then
		rMessage.text = StringManager.append(rMessage.text, string.format("[%d%%]", rRoll.nTarget), " ");
		if rRoll.nTotal > rRoll.nTarget then
			rMessage.icon = "action_save_success";
			rMessage.text = StringManager.appendLine(rMessage.text, "[SUCCESS]");
		else
			rMessage.icon = "action_save_failure";
			rMessage.text = StringManager.appendLine(rMessage.text, "[FAILURE]");
		end
	end
	Comm.deliverChatMessage(rMessage);
end
