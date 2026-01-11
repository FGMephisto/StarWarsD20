-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

OOB_MSGTYPE_APPLYATK = "applyatk";
OOB_MSGTYPE_APPLYHRFC = "applyhrfc";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYATK, handleApplyAttack);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYHRFC, handleApplyHRFC);

	ActionsManager.registerTargetingHandler("attack", onTargeting);

	ActionsManager.registerModHandler("attack", modAttack);
	ActionsManager.registerModHandler("grapple", modAttack);
	
	ActionsManager.registerResultHandler("attack", onAttack);
	ActionsManager.registerResultHandler("critconfirm", onAttack);
	ActionsManager.registerResultHandler("misschance", onMissChance);
	ActionsManager.registerResultHandler("grapple", onGrapple);
end

function handleApplyAttack(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);
	
	local rRoll = UtilityManager.decodeRollFromOOB(msgOOB);
	ActionAttack.applyAttack(rSource, rTarget, rRoll);
end
function notifyApplyAttack(rSource, rTarget, rRoll)
	if not rTarget then
		return;
	end

	rRoll.sResults = table.concat(rRoll.aMessages, " ");
	
	local msgOOB = UtilityManager.encodeRollToOOB(rRoll);
	msgOOB.type = ActionAttack.OOB_MSGTYPE_APPLYATK;
	msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);
	msgOOB.sTargetNode = ActorManager.getCreatureNodeName(rTarget);

	Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyHRFC(msgOOB)
	TableManager.processTableRoll("", msgOOB.sTable);
end

function notifyApplyHRFC(sTable)
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYHRFC;
	
	msgOOB.sTable = sTable;

	Comm.deliverOOBMessage(msgOOB, "");
end

function onTargeting(rSource, aTargeting, rRolls)
	if OptionsManager.isOption("RMMT", "multi") then
		local aTargets = {};
		for _,vTargetGroup in ipairs(aTargeting) do
			for _,vTarget in ipairs(vTargetGroup) do
				table.insert(aTargets, vTarget);
			end
		end
		if #aTargets > 1 then
			for _,vRoll in ipairs(rRolls) do
				if not string.match(vRoll.sDesc, "%[FULL%]") then
					vRoll.bRemoveOnMiss = true;
				end
			end
		end
	end
	return aTargeting;
end

function performPartySheetVsRoll(draginfo, rActor, rAction)
	local rRoll = ActionAttack.getRoll(nil, rAction);
	
	if DB.getValue("partysheet.hiderollresults", 0) == 1 then
		rRoll.bSecret = true;
		rRoll.bTower = true;
	end
	
	ActionsManager.actionDirect(nil, "attack", { rRoll }, { { rActor } });
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = ActionAttack.getRoll(rActor, rAction);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction)
	local rRoll = {};
	if rAction.cm then
		rRoll.sType = "grapple";
	else
		rRoll.sType = "attack";
	end
	rRoll.aDice = DiceRollManager.getActorDice({ "d20" }, rActor);
	rRoll.nMod = rAction.modifier or 0;
	
	if rAction.cm then
		rRoll.sDesc = ActionCore.encodeActionText(rAction, "action_cm_tag");
	else
		rRoll.sDesc = ActionAttackCore.encodeActionText(rAction);
	end
	rRoll.sRange = rAction.range;
	
	-- Add ability modifiers
	if rAction.stat then
		if (rAction.range == "M" and rAction.stat ~= "strength") or (rAction.range == "R" and rAction.stat ~= "dexterity") then
			local sAbilityEffect = DataCommon.ability_ltos[rAction.stat];
			if sAbilityEffect then
				rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
			end
		end
	end
	
	-- Add other modifiers
	if rAction.crit and rAction.crit < 20 then
		rRoll.sDesc = rRoll.sDesc .. " [CRIT " .. rAction.crit .. "]";
	end
	if rAction.touch then
		rRoll.sDesc = rRoll.sDesc .. " [TOUCH]";
	end
	
	-- Legacy
	rRoll.range = rAction.range;

	return rRoll;
end

function performGrappleRoll(draginfo, rActor, rAction)
	local rRoll = ActionAttack.getGrappleRoll(rActor, rAction);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getGrappleRoll(rActor, rAction)
	local rRoll = {};
	rRoll.sType = "grapple";
	rRoll.aDice = DiceRollManager.getActorDice({ "d20" }, rActor);
	rRoll.nMod = rAction.modifier or 0;
	
	if DataCommon.isPFRPG() then
		rRoll.sDesc = ActionCore.encodeActionText(rAction, "action_cm_tag");
	else
		rRoll.sDesc = ActionCore.encodeActionText(rAction, "action_grapple_tag");
	end
	
	-- Add ability modifiers
	if rAction.stat then
		if rAction.stat ~= "strength" then
			local sAbilityEffect = DataCommon.ability_ltos[rAction.stat];
			if sAbilityEffect then
				rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
			end
		end
	end
	
	return rRoll;
end

function modAttack(rSource, rTarget, rRoll) -- Adjusted
	ActionAttack.clearCritState(rSource);
	
	ActionAttackCore.decodeRollData(rRoll);

	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	
	-- Check for opportunity attack
	local bOpportunity = ModifierManager.getKey("ATT_OPP") or Input.isShiftPressed();

	-- Check defense modifiers
	local bTouch = ModifierManager.getKey("ATT_TCH");
	local bFlatFooted = ModifierManager.getKey("ATT_FF");
	local bCover = ModifierManager.getKey("DEF_COVER");
	local bPartialCover = ModifierManager.getKey("DEF_PCOVER");
	local bSuperiorCover = ModifierManager.getKey("DEF_SCOVER");
	local bConceal = ModifierManager.getKey("DEF_CONC");
	local bTotalConceal = ModifierManager.getKey("DEF_TCONC");

	local bMinimumCover = ModifierManager.getKey("DEF_MCOVER");
	local bTotalDefense = ModifierManager.getKey("DEF_TDEF");
	local bDodging = ModifierManager.getKey("DEF_DOD");
	local bKneeling = ModifierManager.getKey("DEF_KNE");
	local bProne = ModifierManager.getKey("DEF_PRO");
	local bRunning = ModifierManager.getKey("DEF_RUN");
	local bPinned = ModifierManager.getKey("DEF_PIN");
	local bMinimumConceal = ModifierManager.getKey("DEF_MCONC");
	local bPartialConceal = ModifierManager.getKey("DEF_PCONC");
	local bSuperiosConceal = ModifierManager.getKey("DEF_SCONC");

	-- Check attack modifiers
	local bMultifire = ModifierManager.getKey("ATT_MFI");
	local bAutofire = ModifierManager.getKey("ATT_AFI");
	local bMultiShot = ModifierManager.getKey("ATT_MSO");
	local bRapidShot = ModifierManager.getKey("ATT_RSO");
	local bPointBlank = ModifierManager.getKey("ATT_PBL");
	local bFireintoMelee = ModifierManager.getKey("ATT_ITM");
	local bFlanking = ModifierManager.getKey("ATT_FLA");
	local bHigherGround = ModifierManager.getKey("ATT_HGR");	
	local bAProne = ModifierManager.getKey("ATT_PRO");
	local bAConceal = ModifierManager.getKey("ATT_CONC");	

	-- Add attack modifiers and adjust attack roll string
	if bOpportunity then
		table.insert(aAddDesc, "[OPPORTUNITY]");
	end

	if bMultifire then
		table.insert(aAddDesc, "[Multifire]");
		nAddMod = nAddMod - 4;
	end
	if bAutofire then
		table.insert(aAddDesc, "[Autofire]");
		nAddMod = nAddMod - 6;
	end
	if bMultiShot then
		table.insert(aAddDesc, "[MultiShot]");
		nAddMod = nAddMod + 2;
	end
	if bRapidShot then
		table.insert(aAddDesc, "[Rapid Shot]");
		nAddMod = nAddMod - 2;
	end
	if bPointBlank then
		table.insert(aAddDesc, "[Point Blank]");
		nAddMod = nAddMod + 1;
	end
	if bFireintoMelee then
		table.insert(aAddDesc, "[Fire into Melee]");
		nAddMod = nAddMod - 4;
	end
	if bFlanking then
		table.insert(aAddDesc, "[Flanking]");
		nAddMod = nAddMod + 2;
	end
	if bHigherGround then
		table.insert(aAddDesc, "[Higher Ground]");
		nAddMod = nAddMod + 1;
	end	
	if bAProne then
		table.insert(aAddDesc, "[Attacker prone]");
		nAddMod = nAddMod - 4;
	end
	if bAConceal then
		table.insert(aAddDesc, "[Attacker Concealed]");
		nAddMod = nAddMod + 2;
	end	

	-- Add defense modifiers and adjust attack roll string
	if bTouch then
		if not string.match(rRoll.sDesc, "%[TOUCH%]") then
			table.insert(aAddDesc, "[TOUCH]");
		end
	end
	if bFlatFooted then
		table.insert(aAddDesc, "[FF]");
	end
	if bSuperiorCover then
		table.insert(aAddDesc, "[COVER -10]");
	elseif bCover then
		table.insert(aAddDesc, "[COVER -7]");
	elseif bPartialCover then
		table.insert(aAddDesc, "[COVER -4]");
	elseif bMinimumCover then
		table.insert(aAddDesc, "[COVER -2]");		
	end
	if bConceal then
		table.insert(aAddDesc, "[CONCEAL]");
	end
	if bTotalConceal then
		table.insert(aAddDesc, "[TOTAL CONC]");
	end
	if bTotalDefense then
		table.insert(aAddDesc, "[Total Defense]");
		nAddMod = nAddMod - 4;
	end
	if bDodging then
		table.insert(aAddDesc, "[Dodging]");
		nAddMod = nAddMod - 1;
	end
	if bKneeling then
		table.insert(aAddDesc, "[Defender kneeling]");
		nAddMod = nAddMod + 2;
	end
	if bProne then
		table.insert(aAddDesc, "[Defender prone]");
		nAddMod = nAddMod + 4;
	end
	if bRunning then
		table.insert(aAddDesc, "[Defender running]");
		nAddMod = nAddMod - 2;
	end
	if bPinned then
		table.insert(aAddDesc, "[Defender pinned]");
		nAddMod = nAddMod + 4;
	end

	if rSource then
		-- Determine ability used
		local sActionStat = nil;
		local sModStat = string.match(rRoll.sDesc, "%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		end
		if not sActionStat then
			if rRoll.sRange == "M" then
				sActionStat = "strength";
			elseif rRoll.sRange == "R" then
				sActionStat = "dexterity";
			end
		end

		-- Build attack filter
		local aAttackFilter = {};
		if rRoll.sRange == "M" then
			table.insert(aAttackFilter, "melee");
		elseif rRoll.sRange == "R" then
			table.insert(aAttackFilter, "ranged");
		end
		if bOpportunity then
			table.insert(aAttackFilter, "opportunity");
		end
		
		-- Get attack effect modifiers
		local bEffects = false;
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManager35E.getEffectsBonus(rSource, {"ATK"}, false, aAttackFilter, rTarget);
		if (nEffectCount > 0) then
			bEffects = true;
		end
		if rRoll.sType == "grapple" then
			local aPFDice, nPFMod, nPFCount = EffectManager35E.getEffectsBonus(rSource, {"CMB"}, false, aAttackFilter, rTarget);
			if nPFCount > 0 then
				bEffects = true;
				for _,v in ipairs(aPFDice) do
					table.insert(aAddDice, v);
				end
				nAddMod = nAddMod + nPFMod;
			end
		end
		
		-- Get condition modifiers
		if EffectManager35E.hasEffect(rSource, "Invisible") then
			bEffects = true;
			nAddMod = nAddMod + 2;
			table.insert(aAddDesc, "[CA]");
		elseif EffectManager35E.hasEffect(rSource, "CA") then
			bEffects = true;
			table.insert(aAddDesc, "[CA]");
		end
		if EffectManager35E.hasEffect(rSource, "Blinded") then
			bEffects = true;
			table.insert(aAddDesc, "[BLINDED]");
		end
		if not DataCommon.isPFRPG() then
			if EffectManager35E.hasEffect(rSource, "Incorporeal") and (rRoll.sRange == "M") and not string.match(string.lower(rRoll.sDesc), "incorporeal touch") then
				bEffects = true;
				table.insert(aAddDesc, "[INCORPOREAL]");
			end
		end
		if EffectManager35E.hasEffectCondition(rSource, "Dazzled") then
			bEffects = true;
			nAddMod = nAddMod - 1;
		end
		if EffectManager35E.hasEffectCondition(rSource, "Slowed") then
			bEffects = true;
			nAddMod = nAddMod - 1;
		end
		if EffectManager35E.hasEffectCondition(rSource, "Entangled") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end
		if rRoll.sType == "attack" and 
				(EffectManager35E.hasEffectCondition(rSource, "Pinned") or
				EffectManager35E.hasEffectCondition(rSource, "Grappled")) then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end
		if EffectManager35E.hasEffectCondition(rSource, "Frightened") or 
				EffectManager35E.hasEffectCondition(rSource, "Panicked") or
				EffectManager35E.hasEffectCondition(rSource, "Shaken") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end
		if EffectManager35E.hasEffectCondition(rSource, "Sickened") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end

		-- Get other effect modifiers
		if EffectManager35E.hasEffectCondition(rSource, "Squeezing") then
			bEffects = true;
			nAddMod = nAddMod - 4;
		end
		if EffectManager.hasCondition(rSource, "Prone") then
			if rRoll.sRange == "M" then
				bEffects = true;
				nAddMod = nAddMod - 4;
			end
		end
		
		-- Get ability modifiers
		local nBonusStat, nBonusEffects = ActorManager35E.getAbilityEffectsBonus(rSource, sActionStat);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end
		
		-- Get negative levels
		local nNegLevelMod, nNegLevelCount = EffectManager35E.getEffectsBonus(rSource, {"NLVL"}, true);
		if nNegLevelCount > 0 then
			bEffects = true;
			nAddMod = nAddMod - nNegLevelMod;
		end

		-- If effects, then add them
		if bEffects then
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			table.insert(aAddDesc, EffectManager.buildEffectOutput(sMod));
		end
	end
	
	if bSuperiorCover then
		nAddMod = nAddMod - 10;
	elseif bCover then
		nAddMod = nAddMod - 7;
	elseif bPartialCover then
		nAddMod = nAddMod - 4;
	elseif bMinimumCover then
		nAddMod = nAddMod - 2;
	end
	
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end
	for _,vDie in ipairs(aAddDice) do
		if vDie:sub(1,1) == "-" then
			table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
		else
			table.insert(rRoll.aDice, "p" .. vDie:sub(2));
		end
	end
	rRoll.nMod = rRoll.nMod + nAddMod;
end

function onAttack(rSource, rTarget, rRoll)
	ActionAttackCore.decodeRollData(rRoll);
	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	local bIsSourcePC = ActorManager.isPC(rSource);
	local bAllowCC = OptionsManager.isOption("HRCC", "on") or (not bIsSourcePC and OptionsManager.isOption("HRCC", "npc"));
	
	if ActionCore.isActionText(rRoll.sDesc, "action_cm_tag") then
		rRoll.sType = "grapple";
	end
	
	rRoll.nTotal = ActionsManager.total(rRoll);
	rRoll.aMessages = {};
	
	-- If we have a target, then calculate the defense we need to exceed
	if rRoll.sType == "critconfirm" then
		local sDefenseVal = rRoll.sDesc:match(" %[AC (%d+)%]");
		if sDefenseVal then
			rRoll.nDefenseVal = tonumber(sDefenseVal);
		end
		rRoll.nMissChance = tonumber(rRoll.sDesc:match("%[MISS CHANCE (%d+)%%%]")) or 0;
		rMessage.text = rMessage.text:gsub(" %[AC %d+%]", "");
		rMessage.text = rMessage.text:gsub(" %[MISS CHANCE %d+%%%]", "");
	else
		rRoll.nDefenseVal, rRoll.nAtkEffectsBonus, rRoll.nDefEffectsBonus, rRoll.nMissChance = ActorManager35E.getDefenseValue(rSource, rTarget, rRoll);
		if rRoll.nAtkEffectsBonus ~= 0 then
			rRoll.nTotal = rRoll.nTotal + rRoll.nAtkEffectsBonus;
			table.insert(rRoll.aMessages, EffectManager.buildEffectOutput(rRoll.nAtkEffectsBonus));
		end
		if rRoll.nDefEffectsBonus ~= 0 then
			rRoll.nDefenseVal = rRoll.nDefenseVal + rRoll.nDefEffectsBonus;
			table.insert(rRoll.aMessages, string.format("[%s %+d]", Interface.getString("effects_def_tag"), rRoll.nDefEffectsBonus));
		end
	end

	-- Get the crit threshold
	rRoll.nCrit = 20;	
	local sAltCritRange = string.match(rRoll.sDesc, "%[CRIT (%d+)%]");
	if sAltCritRange then
		rRoll.nCrit = tonumber(sAltCritRange) or 20;
		if (rRoll.nCrit <= 1) or (rRoll.nCrit > 20) then
			rRoll.nCrit = 20;
		end
	end
	
	rRoll.nFirstDie = 0;
	if #(rRoll.aDice) > 0 then
		rRoll.nFirstDie = rRoll.aDice[1].result or 0;
	end
	rRoll.bCritThreat = false;
	if rRoll.nFirstDie >= 20 then
		rRoll.bSpecial = true;
		if rRoll.sType == "critconfirm" then
			rRoll.sResult = "crit";
			table.insert(rRoll.aMessages, "[CRITICAL HIT]");
		elseif rRoll.sType == "attack" then
			if bAllowCC then
				rRoll.sResult = "hit";
				rRoll.bCritThreat = true;
				table.insert(rRoll.aMessages, "[CRITICAL THREAT]");
			else
				rRoll.sResult = "crit";
				table.insert(rRoll.aMessages, "[CRITICAL HIT]");
			end
		else
			rRoll.sResult = "hit";
			table.insert(rRoll.aMessages, "[HIT]");
		end
	elseif rRoll.nFirstDie == 1 then
		if rRoll.sType == "critconfirm" then
			table.insert(rRoll.aMessages, "[HIT]");
			table.insert(rRoll.aMessages, "[CRIT NOT CONFIRMED]");
			rRoll.sResult = "miss";
		else
			table.insert(rRoll.aMessages, "[AUTOMATIC MISS]");
			rRoll.sResult = "fumble";
		end
	elseif rRoll.nDefenseVal then
		if rRoll.nTotal >= rRoll.nDefenseVal then
			if rRoll.sType == "critconfirm" then
				rRoll.sResult = "crit";
				table.insert(rRoll.aMessages, "[CRITICAL HIT]");
			elseif rRoll.sType == "attack" and rRoll.nFirstDie >= rRoll.nCrit then
				if bAllowCC then
					rRoll.sResult = "hit";
					rRoll.bCritThreat = true;
					table.insert(rRoll.aMessages, "[CRITICAL THREAT]");
				else
					rRoll.sResult = "crit";
					table.insert(rRoll.aMessages, "[CRITICAL HIT]");
				end
			else
				rRoll.sResult = "hit";
				table.insert(rRoll.aMessages, "[HIT]");
			end
		else
			rRoll.sResult = "miss";
			if rRoll.sType == "critconfirm" then
				table.insert(rRoll.aMessages, "[HIT]");
				table.insert(rRoll.aMessages, "[CRIT NOT CONFIRMED]");
			else
				table.insert(rRoll.aMessages, "[MISS]");
			end
		end
	elseif rRoll.sType == "critconfirm" then
		rRoll.sResult = "crit";
		table.insert(rRoll.aMessages, "[CHECK FOR CRITICAL]");
	elseif rRoll.sType == "attack" and rRoll.nFirstDie >= rRoll.nCrit then
		if bAllowCC then
			rRoll.sResult = "hit";
			rRoll.bCritThreat = true;
		else
			rRoll.sResult = "crit";
		end
		table.insert(rRoll.aMessages, "[CHECK FOR CRITICAL]");
	end
	
	if ((rRoll.sType == "critconfirm") or not rRoll.bCritThreat) and (rRoll.nMissChance > 0) then
		table.insert(rRoll.aMessages, "[MISS CHANCE " .. rRoll.nMissChance .. "%]");
	end

	ActionAttack.onPreAttackResolve(rSource, rTarget, rRoll, rMessage);
	ActionAttack.onAttackResolve(rSource, rTarget, rRoll, rMessage);
	ActionAttack.onPostAttackResolve(rSource, rTarget, rRoll, rMessage);

	GameManager.callEventFunctions("onAttackPostResolve", rSource, rTarget, rRoll);
end

function onPreAttackResolve(rSource, rTarget, rRoll, rMessage)
	-- Do nothing; location to override
end
function onAttackResolve(rSource, rTarget, rRoll, rMessage)
	Comm.deliverChatMessage(rMessage);

	if rRoll.sResult == "crit" then
		ActionAttack.setCritState(rSource, rTarget);
	end
	
	local bRollMissChance = false;
	if rRoll.sType == "critconfirm" then
		bRollMissChance = true;
	else
		if rRoll.bCritThreat then
			local rCritConfirmRoll = {
				sType = "critconfirm",
				aDice = DiceRollManager.getActorDice({ "d20" }, rActor),
				bTower = rRoll.bTower,
				bSecret = rRoll.bSecret,
			};
				
			local tCCDice, nCCMod, nCCEffects = EffectManager35E.getEffectsBonus(rSource, {"CC"}, false, nil, rTarget);
			if (nCCEffects > 0) then
				local sMod = StringManager.convertDiceToString(tCCDice, nCCMod, true);
				rCritConfirmRoll.sDesc = string.format("%s [CONFIRM %s]", rRoll.sDesc, sMod);
			else
				rCritConfirmRoll.sDesc = rRoll.sDesc .. " [CONFIRM]";
			end

			for _,vDie in ipairs(tCCDice) do
				if vDie:sub(1,1) == "-" then
					table.insert(rCritConfirmRoll.aDice, "-p" .. vDie:sub(3));
				else
					table.insert(rCritConfirmRoll.aDice, "p" .. vDie:sub(2));
				end
			end
			rCritConfirmRoll.nMod = rRoll.nMod + nCCMod;

			if rRoll.nMissChance > 0 then
				rCritConfirmRoll.sDesc = rCritConfirmRoll.sDesc .. " [MISS CHANCE " .. rRoll.nMissChance .. "%]";
			end
			if rRoll.nDefenseVal then
				rCritConfirmRoll.sDesc = rCritConfirmRoll.sDesc .. " [AC " .. rRoll.nDefenseVal .. "]";
			end
			if (rRoll.nAtkEffectsBonus or 0) ~= 0 then
				rCritConfirmRoll.sDesc = string.format("%s %s", rCritConfirmRoll.sDesc, EffectManager.buildEffectOutput(rRoll.nAtkEffectsBonus));
			end

			ActionsManager.roll(rSource, { rTarget }, rCritConfirmRoll, true);
		elseif (rRoll.sResult ~= "miss") and (rRoll.sResult ~= "fumble") then
			bRollMissChance = true;
		end
	end
	if bRollMissChance and (rRoll.nMissChance > 0) then
		local aMissChanceDice = {};
		local sMissChanceText = rMessage.text:gsub(" %[CRIT %d+%]", ""):gsub(" %[CONFIRM%]", "");
		local rMissChanceRoll = { 
			sType = "misschance", 
			sDesc = sMissChanceText .. " [MISS CHANCE " .. rRoll.nMissChance .. "%]", 
			aDice = DiceRollManager.getActorDice({ "d100" }, rSource), 
			nMod = 0
		};
		ActionsManager.roll(rSource, rTarget, rMissChanceRoll);
	end

	if rTarget then
		ActionAttack.notifyApplyAttack(rSource, rTarget, rRoll);
		
		-- REMOVE TARGET ON MISS OPTION
		if (rRoll.sResult == "miss" or rRoll.sResult == "fumble") and rRoll.sType ~= "critconfirm" and not string.match(rRoll.sDesc, "%[FULL%]") then
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
end
function onPostAttackResolve(rSource, rTarget, rRoll, rMessage)
	-- HANDLE FUMBLE/CRIT HOUSE RULES
	local sOptionHRFC = OptionsManager.getOption("HRFC");
	if rRoll.sResult == "fumble" and ((sOptionHRFC == "both") or (sOptionHRFC == "fumble")) then
		ActionAttack.notifyApplyHRFC("Fumble");
	end
	if rRoll.sResult == "crit" and ((sOptionHRFC == "both") or (sOptionHRFC == "criticalhit")) then
		ActionAttack.notifyApplyHRFC("Critical Hit");
	end
end

function onGrapple(rSource, rTarget, rRoll)
	ActionAttackCore.decodeRollData(rRoll);

	if DataCommon.isPFRPG() then
		ActionAttack.onAttack(rSource, rTarget, rRoll);
	else
		local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
		
		if rTarget then
			rMessage.text = rMessage.text .. " [at " .. ActorManager.getDisplayName(rTarget) .. "]";
		end
		
		if not rSource then
			rMessage.sender = nil;
		end
		Comm.deliverChatMessage(rMessage);
	end
end

function onMissChance(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	local nTotal = ActionsManager.total(rRoll);
	local nMissChance = tonumber(string.match(rMessage.text, "%[MISS CHANCE (%d+)%%%]")) or 0;
	if nTotal <= nMissChance then
		rMessage.text = rMessage.text .. " [MISS]";
		if rTarget then
			rMessage.icon = "roll_attack_miss";
			ActionAttack.clearCritState(rSource, rTarget);
		else
			rMessage.icon = "roll_attack";
		end
	else
		rMessage.text = rMessage.text .. " [HIT]";
		if rTarget then
			rMessage.icon = "roll_attack_hit";
		else
			rMessage.icon = "roll_attack";
		end
	end
	
	Comm.deliverChatMessage(rMessage);
end

function applyAttack(rSource, rTarget, rRoll)
	local msgShort = { font = "msgfont" };
	local msgLong = { font = "msgfont" };
	
	if rRoll.sType == "grapple" then
		msgShort.text = "Combat Man.";
		msgLong.text = "Combat Man.";
	else
		msgShort.text = "Attack";
		msgLong.text = "Attack";
	end
	if rRoll.nOrder then
		msgShort.text = string.format("%s #%d", msgShort.text, rRoll.nOrder);
		msgLong.text = string.format("%s #%d", msgLong.text, rRoll.nOrder);
	end
	if (rRoll.sRange or "") ~= "" then
		msgShort.text = string.format("%s (%s)", msgShort.text, rRoll.sRange);
		msgLong.text = string.format("%s (%s)", msgLong.text, rRoll.sRange);
	end
	if (rRoll.sLabel or "") ~= "" then
		msgShort.text = string.format("%s (%s)", msgShort.text, rRoll.sLabel or "");
		msgLong.text = string.format("%s (%s)", msgLong.text, rRoll.sLabel or "");
	end
	msgLong.text = string.format("%s [%d]", msgLong.text, rRoll.nTotal or 0);

	-- Targeting information
	msgShort.text = string.format("%s ->", msgShort.text);
	msgLong.text = string.format("%s ->", msgLong.text);
	if rTarget then
		local sTargetName = ActorManager.getDisplayName(rTarget);
		msgShort.text = string.format("%s [at %s]", msgShort.text, sTargetName);
		msgLong.text = string.format("%s [at %s]", msgLong.text, sTargetName);
	end

	-- Extra roll information
	msgShort.icon = "roll_attack";
	if (rRoll.sResults or "") ~= "" then
		msgLong.text = string.format("%s %s", msgLong.text, rRoll.sResults);
		if rRoll.sResults:match("%[CRITICAL HIT%]") then
			msgLong.icon = "roll_attack_crit";
		elseif rRoll.sResults:match("HIT%]") then
			msgLong.icon = "roll_attack_hit";
		elseif rRoll.sResults:match("MISS%]") then
			msgLong.icon = "roll_attack_miss";
		else
			msgLong.icon = "roll_attack";
		end
	else
		msgLong.icon = "roll_attack";
	end

	ActionsManager.outputResult(rRoll.bTower, rSource, rTarget, msgLong, msgShort);
end

aCritState = {};

function setCritState(rSource, rTarget)
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT == "" then
		return;
	end
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end
	
	if not aCritState[sSourceCT] then
		aCritState[sSourceCT] = {};
	end
	table.insert(aCritState[sSourceCT], sTargetCT);
end

function clearCritState(rSource, rTarget)
	if rTarget then
		ActionAttack.isCrit(rSource, rTarget);
		return;
	end
	
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT ~= "" then
		aCritState[sSourceCT] = nil;
	end
end

function isCrit(rSource, rTarget)
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT == "" then
		return;
	end
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end

	if not aCritState[sSourceCT] then
		return false;
	end
	
	for k,v in ipairs(aCritState[sSourceCT]) do
		if v == sTargetCT then
			table.remove(aCritState[sSourceCT], k);
			return true;
		end
	end
	
	return false;
end