-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYATK = "applyatk";
OOB_MSGTYPE_APPLYHRFC = "applyhrfc";
OOB_MSGTYPE_APPLYAOO = "applyaoo";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYATK, handleApplyAttack);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYHRFC, handleApplyHRFC);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYAOO, handleApplyAoO);

	ActionsManager.registerTargetingHandler("attack", onTargeting);

	ActionsManager.registerModHandler("attack", modAttack);
	ActionsManager.registerModHandler("grapple", modAttack);
	
	ActionsManager.registerResultHandler("attack", onAttack);
	ActionsManager.registerResultHandler("critconfirm", onAttack);
	ActionsManager.registerResultHandler("misschance", onMissChance);
	ActionsManager.registerResultHandler("grapple", onGrapple);
end

function notifyApplyAttack(rSource, rTarget, rRoll)
	if not rTarget then
		return;
	end

	rRoll.sResults = table.concat(rRoll.aMessages, "\r");
	
	local msgOOB = UtilityManager.encodeRollToOOB(rRoll);
	msgOOB.type = ActionAttack.OOB_MSGTYPE_APPLYATK;
	msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);
	msgOOB.sTargetNode = ActorManager.getCreatureNodeName(rTarget);

	Comm.deliverOOBMessage(msgOOB, "");
end
function handleApplyAttack(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);
	
	local rRoll = UtilityManager.decodeRollFromOOB(msgOOB);
	ActionAttack.applyAttack(rSource, rTarget, rRoll);
end

function notifyApplyHRFC(sTable)
	local msgOOB = {
		type = OOB_MSGTYPE_APPLYHRFC,
		sTable = sTable,
	};
	Comm.deliverOOBMessage(msgOOB, "");
end
function handleApplyHRFC(msgOOB)
	TableManager.processTableRoll("", msgOOB.sTable);
end

function notifyApplyAoO(rActor)
	local msgOOB = {
		type = OOB_MSGTYPE_APPLYAOO,
		sSourceNode = ActorManager.getCreatureNodeName(rActor),
	};
	Comm.deliverOOBMessage(msgOOB, "");
end
function handleApplyAoO(msgOOB)
	local rActor = ActorManager.resolveActor(msgOOB.sSourceNode);
	local nodeCT = ActorManager.getCTNode(rActor);
	if not nodeCT then
		return;
	end

	DB.setValue(nodeCT, "aoo", "number", DB.getValue(nodeCT, "aoo", 0) + 1);

	local tMsgData = {
		rActor = rActor,
		bSecret = Session.IsHost and OptionsManager.isOption("REVL", "off"),
	};
	local nAOO = DB.getValue(nodeCT, "aoo", 0);
	local nMaxAOO = DB.getValue(nodeCT, "aoomax", 0);
	if nAOO == nMaxAOO then
		ChatManager.sendMessage(Interface.getString("attack_message_aoo_used"), tMsgData);
	elseif nAOO > nMaxAOO then
		tMsgData.sIcon = "action_warning";
		ChatManager.sendMessage(Interface.getString("attack_message_aoo_exceeded"), tMsgData);
	end
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
		rRoll.nCrit = rAction.crit;
	end
	if rAction.touch then
		rRoll.sDesc = rRoll.sDesc .. " [TOUCH]";
	end
	if rAction.ghosttouch then
		rRoll.sDesc = rRoll.sDesc .. " [GHOST TOUCH]";
	end

	rRoll.bWeapon = rAction.bWeapon;
	rRoll.bSpell = rAction.bSpell;

	rRoll.tActionTags = rAction.tActionTags;

	-- Legacy
	rRoll.range = rAction.range;

	rRoll.rangeincrement = rAction.rangeincrement;
	rRoll.thrown = rAction.thrown;
	rRoll.stundc = rAction.stundc;
	rRoll.stun = rAction.stun;
	rRoll.nodeWeapon = rAction.nodeWeapon;

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

function isAlly(rActor1, rActor2)
	if not rActor1 or not rActor2 then
		return false;
	end
	if ActorManager.isEqual(rActor1, rActor2) then
		return false;
	end
	local sFaction1 = ActorManager.getFaction(rActor1);
	local sFaction2 = ActorManager.getFaction(rActor2);
	if (sFaction1 == "") or (sFaction2 == "") then
		if ActorManager.isPC(rActor1) and ActorManager.isPC(rActor2) then
			return true;
		end
		return false;
	end
	return (sFaction1 == sFaction2);
end

function isCombatantActive(rActor)
	if not rActor then
		return false;
	end
	if ActorHealthManager and ActorHealthManager.isDyingOrDead(rActor) then
		return false;
	end
	if EffectManager.hasCondition(rActor, "Unconscious") or
	   EffectManager.hasCondition(rActor, "Paralyzed") or
	   EffectManager.hasCondition(rActor, "Helpless") or
	   EffectManager.hasCondition(rActor, "Petrified") or
	   EffectManager.hasCondition(rActor, "Dead") then
		return false;
	end
	return true;
end

function getMeleeDistanceThreshold(rActor)
	local nThreshold = 3;
	local nodeCT = ActorManager.getCTNode(rActor);
	if nodeCT then
		local sSpaceReach = DB.getValue(nodeCT, "spacereach", ""):lower();
		if sSpaceReach:match("ft") then
			return 8;
		end
		local sReach = sSpaceReach:match("/%s*(%d+)");
		if sReach then
			local nR = tonumber(sReach);
			if nR then
				return nR * 1.5;
			end
		end
	end
	return nThreshold;
end

function isTargetEngagedInMelee(rSource, rTarget)
	if not rSource or not rTarget then
		return false;
	end
	local tokenTarget = ActorManager.getToken(rTarget);
	if not tokenTarget then
		return false;
	end

	local aCombatants = CombatManager.getCombatantNodes();
	for _, nodeCT in pairs(aCombatants) do
		local rCombatant = ActorManager.resolveActor(nodeCT);
		if rCombatant and not ActorManager.isEqual(rCombatant, rTarget) and not ActorManager.isEqual(rCombatant, rSource) then
			if isAlly(rSource, rCombatant) and isCombatantActive(rCombatant) then
				local nDist = ActorManager.getDistanceBetween(rCombatant, rTarget);
				if nDist then
					local nThreshold = getMeleeDistanceThreshold(rCombatant);
					if nDist <= nThreshold then
						return true;
					end
				end
			end
		end
	end
	return false;
end

function modAttack(rSource, rTarget, rRoll)
	ActionAttackCore.clearCritState(rSource);
	
	ActionAttackCore.decodeRollData(rRoll);

	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	local bEffects = false;
	
	-- Check for opportunity attack
	rRoll.bOpportunity = ModifierManager.getKey("ATT_OPP") or Input.isShiftPressed();

	-- Check defense modifiers
	local bTouch = ModifierManager.getKey("ATT_TCH");
	local bFlatFooted = ModifierManager.getKey("ATT_FF");
	local bCA = ModifierManager.getKey("ATT_CA");
	local bCover = ModifierManager.getKey("DEF_COVER");
	local bPartialCover = ModifierManager.getKey("DEF_PCOVER");
	local bSuperiorCover = ModifierManager.getKey("DEF_SCOVER");
	local bConceal = ModifierManager.getKey("DEF_CONC");
	local bTotalConceal = ModifierManager.getKey("DEF_TCONC");
	
	local bUncannyDodge = ActorManager35E.hasRollSpecialAbility(rTarget, "Uncanny Dodge");
	if bFlatFooted and bUncannyDodge then
		bFlatFooted = false;
	end

	local bMinimumCover = ModifierManager.getKey("DEF_MCOVER");
	local bTotalDefense = ModifierManager.getKey("DEF_TDEF");
	local bDodging = ModifierManager.getKey("DEF_DODGE") or ModifierManager.getKey("DEF_DOD");
	local bKneeling = ModifierManager.getKey("DEF_KNEELING") or ModifierManager.getKey("DEF_KNE");
	local bProne = ModifierManager.getKey("DEF_PRONE") or ModifierManager.getKey("DEF_PRO");
	local bRunning = ModifierManager.getKey("DEF_RUN");
	local bPinned = ModifierManager.getKey("DEF_PINNED") or ModifierManager.getKey("DEF_PIN");
	local bMinimumConceal = ModifierManager.getKey("DEF_MCONC");
	local bPartialConceal = ModifierManager.getKey("DEF_PCONC");
	local bSuperiosConceal = ModifierManager.getKey("DEF_SCONC");

	-- Check attack modifiers
	local bMultifire = ModifierManager.getKey("ATT_MULTIFIRE") or ModifierManager.getKey("ATT_MFI");
	local bAutofire = ModifierManager.getKey("ATT_AUTOFIRE") or ModifierManager.getKey("ATT_AFI");
	local bMultiShot = ModifierManager.getKey("ATT_MULTISHOT") or ModifierManager.getKey("ATT_MSO");
	local bRapidShot = ModifierManager.getKey("ATT_RAPIDSHOT") or ModifierManager.getKey("ATT_RSO");
	local bPointBlank = ModifierManager.getKey("ATT_PBLANK") or ModifierManager.getKey("ATT_PBL");
	local bFireintoMelee = ModifierManager.getKey("ATT_ITMELEE") or ModifierManager.getKey("ATT_ITM");
	local bFlanking = ModifierManager.getKey("ATT_FLANK") or ModifierManager.getKey("ATT_FLA");
	local bHigherGround = ModifierManager.getKey("ATT_HGROUND") or ModifierManager.getKey("ATT_HGR");	
	local bAProne = ModifierManager.getKey("ATT_PRONE") or ModifierManager.getKey("ATT_PRO");
	local bAConceal = ModifierManager.getKey("ATT_CONC");	

	-- Add attack modifiers and adjust attack roll string
	if rRoll.bOpportunity then
		table.insert(aAddDesc, "[OPPORTUNITY]");
	end
	if bTouch and not rRoll.sDesc:match("%[TOUCH%]") then
		table.insert(aAddDesc, "[TOUCH]");
	end

	if bMultifire and not string.match(rRoll.sDesc, "%[Multifire%]") then
		table.insert(aAddDesc, "[Multifire]");
		nAddMod = nAddMod - 4;
	end
	if bAutofire and not string.match(rRoll.sDesc, "%[Autofire%]") then
		table.insert(aAddDesc, "[Autofire]");
		nAddMod = nAddMod - 6;
	end
	if bMultiShot and not string.match(rRoll.sDesc, "%[MultiShot%]") then
		table.insert(aAddDesc, "[MultiShot]");
		nAddMod = nAddMod - 4;
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

	-- Automatic Range & Melee Detection
	if rSource and rTarget and (rRoll.sRange == "R") then
		local nDistance = ActorManager.getDistanceBetween(rSource, rTarget);

		-- Automatic Range Increments & Point Blank
		if nDistance and OptionsManager.isOption("AUTORANGE", "on") then
			-- 1. Point Blank Shot (+1 within 10m / 30ft)
			local nPBMax = (getMeleeDistanceThreshold(rSource) > 3) and 30 or 10;
			if (nDistance <= nPBMax) and not bPointBlank and not rRoll.sDesc:match("%[Point Blank%]") then
				if ActorManager35E.hasRollFeat(rSource, "Point Blank Shot") or EffectManager.hasText(rSource, "PBLANK") then
					bPointBlank = true;
					table.insert(aAddDesc, "[Point Blank]");
					nAddMod = nAddMod + 1;
				end
			end

			-- 2. Range Increments & Out of Range
			local sUnit = (getMeleeDistanceThreshold(rSource) > 3) and "ft" or "m";
			local sDistStr = string.format("%d%s", math.floor(nDistance), sUnit);

			local nRangeInc = tonumber(rRoll.rangeincrement) or 0;
			if (nRangeInc == 0) and rRoll.nodeWeapon then
				nRangeInc = tonumber(DB.getValue(rRoll.nodeWeapon, "rangeincrement", 0)) or 0;
			end
			if (nRangeInc == 0) and rSource then
				local nodeSource = ActorManager.getCreatureNode(rSource);
				if nodeSource and rRoll.sLabel then
					for _, nodeWpn in ipairs(DB.getChildList(nodeSource, "weaponlist")) do
						if DB.getValue(nodeWpn, "name", "") == rRoll.sLabel then
							nRangeInc = tonumber(DB.getValue(nodeWpn, "rangeincrement", 0)) or 0;
							if nRangeInc > 0 then break; end
						end
					end
				end
			end

			local bStun = rRoll.stun or (rRoll.sDesc and rRoll.sDesc:match("%[STUN%]"));
			local nMaxStunDist = 6;

			if bStun and ((nDistance - 0.05) > nMaxStunDist) then
				rRoll.bOutOfRange = true;
				table.insert(aAddDesc, string.format("[OUT OF RANGE (STUN %s)]", sDistStr));
			elseif nRangeInc > 0 then
				local bThrown = rRoll.thrown or (rRoll.sDesc and rRoll.sDesc:lower():match("thrown"));
				local nMaxInc = bThrown and 5 or 10;
				local nInc = math.floor((nDistance - 0.01) / nRangeInc);
				if nInc >= nMaxInc then
					rRoll.bOutOfRange = true;
					table.insert(aAddDesc, string.format("[OUT OF RANGE (%s)]", sDistStr));
				else
					if nInc > 0 then
						local nRangePenalty = nInc * -2;
						nAddMod = nAddMod + nRangePenalty;
					end
					table.insert(aAddDesc, string.format("[RANGE: %s]", sDistStr));
				end
			else
				table.insert(aAddDesc, string.format("[RANGE: %s]", sDistStr));
			end
		end

		-- Automatic Firing into Melee
		if OptionsManager.isOption("AUTOFIRINGINTOMELEE", "on") and not bFireintoMelee and not rRoll.sDesc:match("%[Fire into Melee%]") then
			if isTargetEngagedInMelee(rSource, rTarget) then
				if ActorManager35E.hasRollFeat(rSource, "Precise Shot") or EffectManager.hasText(rSource, "PRECISE") then
					table.insert(aAddDesc, "[PRECISE SHOT]");
				else
					bFireintoMelee = true;
					table.insert(aAddDesc, "[Fire into Melee]");
					nAddMod = nAddMod - 4;
				end
			end
		end
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
		local tAttackFilter = ActionCore.buildEffectFilter(rRoll);
		
		-- Get attack effect modifiers
		local tSrcEffData = { rTarget = rTarget, tFilter = tAttackFilter, tActionTags = rRoll.tActionTags, };
		local tTrgtEffData = { rTarget = rSource, tFilter = tAttackFilter, tActionTags = rRoll.tActionTags, };
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManager.getBonusDiceMod(rSource, "ATK", tSrcEffData);
		if (nEffectCount > 0) then
			bEffects = true;
		end
		if rTarget then
			local tAttackDice, nAttackMod, nAttackEffect = EffectManager.getBonusDiceMod(rTarget, "@ATK", tTrgtEffData);
			if nAttackEffect > 0 then
				bEffects = true;
				for _,vDie in ipairs(tAttackDice) do
					table.insert(aAddDice, vDie);
				end
				nAddMod = nAddMod + nAttackMod;
			end
		end
		if rRoll.sType == "grapple" then
			local aPFDice, nPFMod, nPFCount = EffectManager.getBonusDiceMod(rSource, "CMB", tSrcEffData);
			if nPFCount > 0 then
				bEffects = true;
				for _,v in ipairs(aPFDice) do
					table.insert(aAddDice, v);
				end
				nAddMod = nAddMod + nPFMod;
			end
			if rTarget then
				local tAttackDice, nAttackMod, nAttackEffect = EffectManager.getBonusDiceMod(rTarget, "@CMB", tTrgtEffData);
				if nAttackEffect > 0 then
					bEffects = true;
					for _,vDie in ipairs(tAttackDice) do
						table.insert(aAddDice, vDie);
					end
					nAddMod = nAddMod + nAttackMod;
				end
			end
		end
		
		local nEffectCrit = EffectManager.getMinMod(rSource, "CRIT", tSrcEffData);
		if nEffectCrit then
			bEffects = true;
			rRoll.nCrit = math.max(math.min(rRoll.nCrit or 20, nEffectCrit), 2);
		end
		if EffectManager.hasCondition(rSource, "KEEN", tSrcEffData) then
			bEffects = true;
			rRoll.nCrit = math.max(((rRoll.nCrit or 20) * 2) - 21, 2);
			table.insert(aAddDesc, "[KEEN]");
		end

		-- Get condition modifiers
		if EffectManager.hasCondition(rSource, "Ethereal") and not EffectManager.hasCondition(rTarget, "Ethereal") then
			bEffects = true;
			nAddMod = nAddMod + 2;
			if not bUncannyDodge then
				bCA = true;
			end
		elseif EffectManager.hasCondition(rSource, "Invisible") and 
				((rRoll.sRange == "R") or not ActorManager35E.hasRollFeat(rTarget, "Blind-Fight")) then
			bEffects = true;
			nAddMod = nAddMod + 2;
			if not bUncannyDodge then
				bCA = true;
			end
		elseif EffectManager.hasCondition(rSource, "CA", tSrcEffData) then
			bEffects = true;
			bCA = true;
		elseif EffectManager.hasCondition(rTarget, "@CA", tTrgtEffData) then
			bEffects = true;
			bCA = true;
		end
		if bCA then
			table.insert(aAddDesc, "[CA]");
		end

		if EffectManager.hasCondition(rSource, "Blinded") then
			bEffects = true;
			table.insert(aAddDesc, "[BLINDED]");
		end
		if not DataCommon.isPFRPG() then
			if EffectManager.hasCondition(rSource, "Incorporeal") and (rRoll.sRange == "M") and not string.match(string.lower(rRoll.sDesc), "incorporeal touch") then
				bEffects = true;
				table.insert(aAddDesc, "[INCORPOREAL]");
			end
		end
		if EffectManager.hasCondition(rSource, "Dazzled") then
			bEffects = true;
			nAddMod = nAddMod - 1;
		end
		if EffectManager.hasCondition(rSource, "Slowed") then
			bEffects = true;
			nAddMod = nAddMod - 1;
		end
		if EffectManager.hasCondition(rSource, "Entangled") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end
		if rRoll.sType == "attack" and 
				(EffectManager.hasCondition(rSource, "Pinned") or
				EffectManager.hasCondition(rSource, "Grappled")) then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end
		if EffectManager.hasCondition(rSource, "Frightened") or 
				EffectManager.hasCondition(rSource, "Panicked") or
				EffectManager.hasCondition(rSource, "Shaken") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end
		if EffectManager.hasCondition(rSource, "Sickened") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end

		-- Get other effect modifiers
		if EffectManager.hasCondition(rSource, "Squeezing") then
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
		local nBonusStat, nBonusEffects = ActorManagerD20.getAbilityEffectsBonus(rSource, sActionStat);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end
		
		-- Get negative levels
		local nNegLevelMod, nNegLevelCount = EffectManager.getBonusMod(rSource, "NLVL");
		if nNegLevelCount > 0 then
			bEffects = true;
			nAddMod = nAddMod - nNegLevelMod;
		end
	end
	
	if (rRoll.nCrit or 20) < 20 then
		table.insert(aAddDesc, string.format("[CRIT %d]", rRoll.nCrit));
	end

	DiceRollManager.addRollEffectDiceMod(rSource, rRoll, aAddDice, nAddMod);
	if bEffects then
		table.insert(aAddDesc, EffectManager.buildEffectDiceModOutput(aAddDice, nAddMod));
	end
	if #aAddDesc > 0 then
		rRoll.sDesc = StringManager.appendLine(rRoll.sDesc, table.concat(aAddDesc, "\r"));
	end
	
	-- Add other modifiers
	if bSuperiorCover then
		rRoll.nMod = rRoll.nMod - 10;
	elseif bCover then
		rRoll.nMod = rRoll.nMod - 7;
	elseif bPartialCover then
		rRoll.nMod = rRoll.nMod - 4;
	elseif bMinimumCover then
		rRoll.nAddMod = rRoll.nMod - 2;
	end

	applySizeEffectsToModRoll(rSource, rTarget, rRoll);
end
function applySizeEffectsToModRoll(rSource, _, rRoll)
	if not rSource then
		return;
	end

	local nActorSize, nBaseSize = ActorCommonManager.getSize(rSource);
	if nActorSize == nBaseSize then
		return;
	end

	local nEffectBonus;
	if rRoll.sType == "grapple" then
		-- Smaller grants penalty; Larger grants bonus
		nEffectBonus = nActorSize - nBaseSize;
		nEffectBonus = nEffectBonus * 4;
	else
		-- Smaller grants bonus; Larger grants penalty
		nActorSize = math.max(math.min(nActorSize, 4), -4);
		nBaseSize = math.max(math.min(nBaseSize, 4), -4);
		nEffectBonus = DataCommon.sizeCombatMod[nActorSize] - DataCommon.sizeCombatMod[nBaseSize];
	end

	rRoll.bEffects = true;
	rRoll.nMod = rRoll.nMod + nEffectBonus;
	table.insert(rRoll.tNotifications, string.format("[SIZE %+d]", nEffectBonus));
end

function onAttack(rSource, rTarget, rRoll)
	ActionAttackCore.decodeRollData(rRoll);
	
	local bIsSourcePC = ActorManager.isPC(rSource);
	local bAllowCC = OptionsManager.isOption("HRCC", "on") or (not bIsSourcePC and OptionsManager.isOption("HRCC", "npc"));
	
	if ActionCore.isActionText(rRoll.sDesc, "action_cm_tag") then
		rRoll.sType = "grapple";
	end
	
	rRoll.aMessages = {};
	
	-- If we have a target, then calculate the defense we need to exceed
	if rRoll.sType == "critconfirm" then
		local sDefenseVal = rRoll.sDesc:match(" %[AC (%d+)%]");
		if sDefenseVal then
			rRoll.nDefenseVal = tonumber(sDefenseVal);
		end
		rRoll.nMissChance = tonumber(rRoll.sDesc:match("%[MISS CHANCE (%d+)%%%]")) or 0;
	else
		rRoll.nDefenseVal, rRoll.nAtkEffectsBonus, rRoll.nDefEffectsBonus, rRoll.nMissChance = ActorManager35E.getDefenseValue(rSource, rTarget, rRoll);
		if rRoll.nAtkEffectsBonus ~= 0 then
			rRoll.nTotal = rRoll.nTotal + rRoll.nAtkEffectsBonus;
			table.insert(rRoll.aMessages, EffectManager.buildEffectOutput(rRoll.nAtkEffectsBonus));
		end
		if rRoll.nDefEffectsBonus ~= 0 then
			rRoll.nDefenseVal = rRoll.nDefenseVal + rRoll.nDefEffectsBonus;
			table.insert(rRoll.aMessages, EffectManager.buildDefEffectOutput(rRoll.nDefEffectsBonus));
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
	local bOutOfRange = rRoll.bOutOfRange or (rRoll.sDesc and rRoll.sDesc:match("%[OUT OF RANGE"));
	if bOutOfRange then
		rRoll.sResult = "miss";
		table.insert(rRoll.aMessages, "[OUT OF RANGE]");
	elseif rRoll.nFirstDie >= 20 then
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

	GameManager.callEventFunctions("onAttackPreResolve", rSource, rTarget, rRoll);
	ActionAttack.onPreAttackResolve(rSource, rTarget, rRoll);

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	if rRoll.sType == "critconfirm" then
		rMessage.text = rMessage.text:gsub(" %[AC %d+%]", "");
		rMessage.text = rMessage.text:gsub(" %[MISS CHANCE %d+%%%]", "");
	end
	ActionAttack.onAttackResolve(rSource, rTarget, rRoll, rMessage);

	ActionAttack.onPostAttackResolve(rSource, rTarget, rRoll);
	GameManager.callEventFunctions("onAttackPostResolve", rSource, rTarget, rRoll);
end

function onPreAttackResolve(rSource, rTarget, rRoll)
	-- Do nothing; location to override
end
function onAttackResolve(rSource, rTarget, rRoll, rMessage)
	Comm.deliverChatMessage(rMessage);

	if rRoll.sResult == "crit" then
		ActionAttackCore.setCritState(rSource, rTarget);
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
				
			local tCCDice, nCCMod, nCCEffects = EffectManager.getBonusDiceMod(rSource, "CC", { rTarget = rTarget, });
			if (nCCEffects > 0) then
				local sMod = StringManager.convertDiceToString(tCCDice, nCCMod, true);
				rCritConfirmRoll.sDesc = string.format("%s [CONFIRM %s]", rRoll.sDesc, sMod);
			else
				rCritConfirmRoll.sDesc = rRoll.sDesc .. " [CONFIRM]";
			end

			DiceRollManager.addRollEffectDice(rSource, rCritConfirmRoll, tCCDice);
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
function onPostAttackResolve(rSource, rTarget, rRoll)
	-- HANDLE FUMBLE/CRIT HOUSE RULES
	local sOptionHRFC = OptionsManager.getOption("HRFC");
	if rRoll.sResult == "fumble" and ((sOptionHRFC == "both") or (sOptionHRFC == "fumble")) then
		ActionAttack.notifyApplyHRFC("Fumble");
	end
	if rRoll.sResult == "crit" and ((sOptionHRFC == "both") or (sOptionHRFC == "criticalhit")) then
		ActionAttack.notifyApplyHRFC("Critical Hit");
	end
	
	-- HANDLE ATTACK OF OPPORTUNITY TRACKING
	if rRoll.bOpportunity then
		ActionAttack.notifyApplyAoO(rSource);
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
			rMessage.icon = "action_attack_miss";
			ActionAttackCore.clearCritState(rSource, rTarget);
		else
			rMessage.icon = "action_attack";
		end
	else
		rMessage.text = rMessage.text .. " [HIT]";
		if rTarget then
			rMessage.icon = "action_attack_hit";
		else
			rMessage.icon = "action_attack";
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
	msgShort.text = string.format("%s\r->", msgShort.text);
	msgLong.text = string.format("%s\r->", msgLong.text);
	if rTarget then
		local sTargetName = ActorManager.getDisplayName(rTarget);
		msgShort.text = string.format("%s [at %s]", msgShort.text, sTargetName);
		msgLong.text = string.format("%s [at %s]", msgLong.text, sTargetName);
	end

	-- Extra roll information
	msgShort.icon = "action_attack";
	if (rRoll.sResults or "") ~= "" then
		msgLong.text = string.format("%s %s", msgLong.text, rRoll.sResults);
		if rRoll.sResults:match("%[CRITICAL HIT%]") then
			msgLong.icon = "action_attack_crit";
		elseif rRoll.sResults:match("HIT%]") then
			msgLong.icon = "action_attack_hit";
		elseif rRoll.sResults:match("MISS%]") then
			msgLong.icon = "action_attack_miss";
		else
			msgLong.icon = "action_attack";
		end
	else
		msgLong.icon = "action_attack";
	end

	ActionsManager.outputResult(rRoll.bTower, rSource, rTarget, msgLong, msgShort);
end