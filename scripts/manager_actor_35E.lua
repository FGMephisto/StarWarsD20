-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	GameManager.setRecordFieldMap("", "hptotal", "hp");

	GameManager.setOption("abilityeffectcond", "3.5E");

	GameManager.setFunction("onActorGetAbilityScore", ActorManager35E.getAbilityScore);
	GameManager.setFunction("onActorGetAbilityDamage", ActorManager35E.getAbilityDamage);
	GameManager.setFunction("onActorGetBonus", ActorManager35E.getBonus);
	GameManager.setFunction("onActorGetEffectsBonus", ActorManager35E.getEffectsBonus);
	GameManager.setFunction("onActorGetHealthStatus", ActorManager35E.getWoundPercent);
	GameManager.setFunction("onActorRest", ActorManager35E.rest);
end

--
--	HEALTH
-- 

-- NOTE: Always default to using CT node as primary to make sure 
--		that all bars and statuses are synchronized in combat tracker
--		(Cross-link network updates between PC and CT fields can occur in either order, 
--		depending on where the scripts or end user updates.)
-- NOTE 2: We can not use default effect checking in this function; 
-- 		as it will cause endless loop with conditionals that check health
function getWoundPercent(rActor)
	local nHP = GameManager.getRecordFieldValue(rActor, "hptotal", 0);
	local nTemp = GameManager.getRecordFieldValue(rActor, "hptemp", 0);
	local nWounds = GameManager.getRecordFieldValue(rActor, "wounds", 0);
	local nNonlethal = GameManager.getRecordFieldValue(rActor, "nonlethal", 0);

	local nPercentLethal = 0;
	local nPercentNonlethal = 0;
	if nHP > 0 then
		nPercentLethal = nWounds / nHP;
		nPercentNonlethal = (nWounds + nNonlethal) / (nHP + nTemp);
	end

	local sStatus;
	local bDiesAtZero = false;
	if ActorCommonManager.isCreatureTypeDnD(rActor, "construct,undead,swarm") then
		bDiesAtZero = true;
	end
	if bDiesAtZero and nPercentLethal >= 1 then
		sStatus = ActorHealthManager.STATUS_DEAD;
	elseif nPercentLethal > 1 then
		local nDying = GameSystem.getDeathThreshold(rActor);
		
		if (nWounds - nHP) < nDying then
			sStatus = ActorHealthManager.STATUS_DYING;
		else
			sStatus = ActorHealthManager.STATUS_DEAD;
		end
	elseif nPercentNonlethal > 1 then
		sStatus = ActorHealthManager.STATUS_UNCONSCIOUS;
	elseif nPercentLethal == 1 then
		sStatus = ActorHealthManager.STATUS_DISABLED;
	elseif nPercentNonlethal == 1 then
		sStatus = ActorHealthManager.STATUS_STAGGERED;
	else
		sStatus = ActorHealthManager.getDefaultStatusFromWoundPercent(nPercentNonlethal);
	end
	
	return nPercentNonlethal, sStatus, nPercentLethal;
end
function getPCSheetWoundColor(nodePC)
	local nPercentNonlethal, sStatus, nPercentLethal = ActorManager35E.getWoundPercent(nodePC);

	if nPercentLethal > 1 then
		return ColorManager.getUIColor("health_dyingordead");
	elseif nPercentNonlethal > 1 then
		return ColorManager.getUIColor("health_unconscious");
	elseif nPercentLethal == 1 then
		return ColorManager.getUIColor("health_simple_bloodied");
	elseif nPercentNonlethal == 1 then
		return ColorManager.getUIColor("health_simple_bloodied");
	end
	return ColorManager.getHealthColor(nPercentNonlethal, false);
end

--
--	ABILITY SCORES
--

function getAbilityScore(rActor, sAbility, nodeSpellClass)
	if not sAbility then
		return -1;
	end
	local nodeActor = ActorManager.getCreatureNode(rActor);
	if not nodeActor then
		return 0;
	end
	
	local sShort = sAbility:sub(1,3):lower();
	if ActorManager.isPC(rActor) then
		if sShort == "lev" or sShort == "lvl" then
			return DB.getValue(nodeActor, "level", 0);
		elseif sShort == "bab" then
			return DB.getValue(nodeActor, "attackbonus.base", 0);
		elseif sShort == "cl" and nodeSpellClass then
			return DB.getValue(nodeSpellClass, "cl", 0);
		elseif sShort == "cmb" then
			return DB.getValue(nodeActor, "attackbonus.base", 0);
		elseif sShort == "str" then
			return DB.getValue(nodeActor, "abilities.strength.score", 0);
		elseif sShort == "dex" then
			return DB.getValue(nodeActor, "abilities.dexterity.score", 0);
		elseif sShort == "con" then
			return DB.getValue(nodeActor, "abilities.constitution.score", 0);
		elseif sShort == "int" then
			return DB.getValue(nodeActor, "abilities.intelligence.score", 0);
		elseif sShort == "wis" then
			return DB.getValue(nodeActor, "abilities.wisdom.score", 0);
		elseif sShort == "cha" then
			return DB.getValue(nodeActor, "abilities.charisma.score", 0);
		end
	elseif ActorManager.isRecordType(rActor, "npc") then
		if sShort == "lev" or sShort == "lvl" then
			return tonumber(string.match(DB.getValue(nodeActor, "hd", ""), "^(%d+)")) or 0;
		elseif sShort == "bab" then
			local sBABGrp = DB.getValue(nodeActor, "babgrp", "");
			local sBAB = sBABGrp:match("[+-]?%d+");
			return tonumber(sBAB) or 0;
		elseif sShort == "cl" and nodeSpellClass then
			return DB.getValue(nodeSpellClass, "cl", 0);
		elseif sShort == "cmb" then
			local sBABGrp = DB.getValue(nodeActor, "babgrp", "");
			local sBAB = sBABGrp:match("CMB ([+-]?%d+)");
			if not sBAB then
				sBAB = sBABGrp:match("[+-]?%d+");
			end
			return tonumber(sBAB) or 0;
		elseif sShort == "cl" and nodeSpellClass then
			return DB.getValue(nodeSpellClass, "cl", 0);
		elseif sShort == "str" then
			return DB.getValue(nodeActor, "strength", 0);
		elseif sShort == "dex" then
			return DB.getValue(nodeActor, "dexterity", 0);
		elseif sShort == "con" then
			return DB.getValue(nodeActor, "constitution", 0);
		elseif sShort == "int" then
			return DB.getValue(nodeActor, "intelligence", 0);
		elseif sShort == "wis" then
			return DB.getValue(nodeActor, "wisdom", 0);
		elseif sShort == "cha" then
			return DB.getValue(nodeActor, "charisma", 0);
		end
	end
	
	return -1;
end
function getAbilityDamage(rActor, sAbility)
	if not sAbility then
		return 0;
	end
	
	if not ActorManager.isPC(rActor) then
		return 0;
	end
	local nodeActor = ActorManager.getCreatureNode(rActor);
	if not nodeActor then
		return 0;
	end

	local sShort = sAbility:sub(1,3):lower();
	if sShort == "str" then
		return DB.getValue(nodeActor, "abilities.strength.damage", 0);
	elseif sShort == "dex" then
		return DB.getValue(nodeActor, "abilities.dexterity.damage", 0);
	elseif sShort == "con" then
		return DB.getValue(nodeActor, "abilities.constitution.damage", 0);
	elseif sShort == "int" then
		return DB.getValue(nodeActor, "abilities.intelligence.damage", 0);
	elseif sShort == "wis" then
		return DB.getValue(nodeActor, "abilities.wisdom.damage", 0);
	elseif sShort == "cha" then
		return DB.getValue(nodeActor, "abilities.charisma.damage", 0);
	end
	
	return 0;
end
function getAbilityBonus(rActor, sStat, nodeSpellClass)
	if not rActor or ((sStat or "") == "") then
		return 0;
	end
	
	-- CHECK HALF/DOUBLE MODIFIERS
	local bHalf = false;
	local bDouble = false;
	if string.match(sStat, "^half") then
		bHalf = true;
		sStat = string.sub(sStat, 5);
	end
	if string.match(sStat, "^double") then
		bDouble = true;
		sStat = string.sub(sStat, 7);
	end

	-- GET ABILITY VALUE
	local nStatScore = getAbilityScore(rActor, sStat, nodeSpellClass);
	if nStatScore < 0 then
		return 0;
	end
	
	local nStatVal = 0;
	if StringManager.contains(DataCommon.abilities, sStat) then
		if ActorManager.isPC(rActor) then
			local nodeActor = ActorManager.getCreatureNode(rActor);
			if nodeActor then
				nStatVal = nStatVal + DB.getValue(nodeActor, "abilities." .. sStat .. ".bonusmodifier", 0);
				
				local nAbilityDamage = DB.getValue(nodeActor, "abilities." .. sStat .. ".damage", 0);
				if DataCommon.isPFRPG() then
					if nAbilityDamage >= 0 then
						nAbilityDamage = math.floor(nAbilityDamage / 2) * 2;
					else
						nAbilityDamage = math.ceil(nAbilityDamage / 2) * 2;
					end
				end
				nStatScore = nStatScore - nAbilityDamage;
			end
		end
		nStatVal = nStatVal + math.floor((nStatScore - 10) / 2);
	else
		nStatVal = nStatScore;
	end
	
	-- APPLY HALF/DOUBLE MODIFIERS
	if bDouble then
		nStatVal = nStatVal * 2;
	end
	if bHalf then
		nStatVal = math.floor(nStatVal / 2);
	end

	-- RESULTS
	return nStatVal;
end

--
--	DEFENSES
--

function getSpellDefense(rAttacker, rDefender)
	local nSR = 0;

	if ActorManager.isPC(rDefender) then
		local nodeActor = ActorManager.getCreatureNode(rDefender);
		if nodeActor then
			nSR = DB.getValue(nodeActor, "defenses.sr.total", 0);
		end
	elseif ActorManager.isRecordType(rDefender, "npc") then
		local nodeCT = ActorManager.getCTNode(rDefender);
		if nodeCT then
			nSR = DB.getValue(nodeCT, "sr", 0);
		else
			local nodeActor = ActorManager.getCreatureNode(rDefender);
			if nodeActor then
				local sSpecialQualities = DB.getValue(nodeActor, "specialqualities", ""):lower();
				local sSpellResist = sSpecialQualities:match("spell resistance (%d+)");
				if not sSpellResist then
					sSpellResist = sSpecialQualities:match("sr (%d+)");
				end
				if sSpellResist then
					nSR = tonumber(sSpellResist) or 0;
				end
			end
		end
	end

	nSR = nSR + EffectManager.getBonusMod(rDefender, "SR", { rTarget = rAttacker, });

	return nSR;
end

function getDefenseValue(rAttacker, rDefender, rRoll)
	-- VALIDATE
	if not rDefender or not rRoll then
		return nil, 0, 0, 0;
	end
	
	local sAttack = rRoll.sDesc;
	
	-- DETERMINE ATTACK TYPE AND DEFENSE
	local sAttackType = ActionAttackCore.decodeRangeText(sAttack);
	local bOpportunity = sAttack:match("%[OPPORTUNITY%]");
	local bTouch = (rRoll.sType == "attack") and (sAttack:match("%[TOUCH%]"));
	local bFlatFooted = sAttack:match("%[FF%]");
	local nCover = tonumber(sAttack:match("%[COVER %-(%d)%]")) or 0;
	local bConceal = sAttack:match("%[CONCEAL%]");
	local bTotalConceal = sAttack:match("%[TOTAL CONC%]");
	local bAttackerBlinded = sAttack:match("%[BLINDED%]");

	-- Determine the defense database node name
	local nDefense = 10;
	local nFlatFootedMod = 0;
	local nTouchMod = 0;
	local sDefenseStat = "dexterity";
	local sDefenseStat2 = "";
	local sDefenseStat3 = "";
	if rRoll.sType == "grapple" then
		sDefenseStat3 = "strength";
	end

	local nodeDefender = ActorManager.getCreatureNode(rDefender);
	if not nodeDefender then
		return nil, 0, 0, 0;
	end

	if ActorManager.isPC(rDefender) then
		if rRoll.sType == "attack" then
			nDefense = DB.getValue(nodeDefender, "ac.totals.general", 10);
			nFlatFootedMod = nDefense - DB.getValue(nodeDefender, "ac.totals.flatfooted", 10);
			nTouchMod = nDefense - DB.getValue(nodeDefender, "ac.totals.touch", 10);
		else
			nDefense = DB.getValue(nodeDefender, "ac.totals.cmd", 10);
			nFlatFootedMod = DB.getValue(nodeDefender, "ac.totals.general", 10) - DB.getValue(nodeDefender, "ac.totals.flatfooted", 10);
		end
		sDefenseStat = DB.getValue(nodeDefender, "ac.sources.ability", "");
		if sDefenseStat == "" then
			sDefenseStat = "dexterity";
		end
		sDefenseStat2 = DB.getValue(nodeDefender, "ac.sources.ability2", "");
		if rRoll.sType == "grapple" then
			sDefenseStat3 = DB.getValue(nodeDefender, "ac.sources.cmdability", "");
			if sDefenseStat3 == "" then
				sDefenseStat3 = "strength";
			end
		end
	else
		local nodeCT = ActorManager.getCTNode(rDefender);
		if nodeCT then
			nodeDefender = nodeCT;
			if rRoll.sType == "attack" then
				nDefense = DB.getValue(nodeDefender, "ac_final", 10);
				nFlatFootedMod = nDefense - DB.getValue(nodeDefender, "ac_flatfooted", 10);
				nTouchMod = nDefense - DB.getValue(nodeDefender, "ac_touch", 10);
			else
				nDefense = DB.getValue(nodeDefender, "cmd", 10);
				nFlatFootedMod = DB.getValue(nodeDefender, "ac_final", 10) - DB.getValue(nodeDefender, "ac_flatfooted", 10);
			end
		elseif ActorManager.isRecordType(rDefender, "npc") then
			if rRoll.sType == "attack" then
				local sAC = DB.getValue(nodeDefender, "ac", "");
				nDefense = tonumber(string.match(sAC, "^%s*(%d+)")) or 10;

				local sFlatFootedAC = string.match(sAC, "flat-footed (%d+)");
				if sFlatFootedAC then
					nFlatFootedMod = nDefense - tonumber(sFlatFootedAC);
				else
					nFlatFootedMod = getAbilityBonus(rDefender, sDefenseStat);
				end
				
				local sTouchAC = string.match(sAC, "touch (%d+)");
				if sTouchAC then
					nTouchMod = nDefense - tonumber(sTouchAC);
				end
			else
				local sBABGrp = DB.getValue(nodeDefender, "babgrp", "");
				local sMatch = string.match(sBABGrp, "CMD ([+-]?[0-9]+)");
				if sMatch then
					nDefense = tonumber(sMatch) or 10;
				else
					nDefense = 10;
				end
				
				local sAC = DB.getValue(nodeDefender, "ac", "");
				local nAC = tonumber(string.match(sAC, "^%s*(%d+)")) or 10;

				local sFlatFootedAC = string.match(sAC, "flat-footed (%d+)");
				if sFlatFootedAC then
					nFlatFootedMod = nAC - (tonumber(sFlatFootedAC) or 10);
				else
					nFlatFootedMod = getAbilityBonus(rDefender, sDefenseStat);
				end
			end
		else
			return nil, 0, 0, 0;
		end
	end

	nDefenseStatMod = getAbilityBonus(rDefender, sDefenseStat) + getAbilityBonus(rDefender, sDefenseStat2);
	
	-- MAKE SURE FLAT-FOOTED AND TOUCH ADJUSTMENTS ARE POSITIVE
	if nTouchMod < 0 then
		nTouchMod = 0;
	end
	if nFlatFootedMod < 0 then
		nFlatFootedMod = 0;
	end
	
	-- APPLY FLAT-FOOTED AND TOUCH ADJUSTMENTS
	if bTouch then
		nDefense = nDefense - nTouchMod;
	end
	if bFlatFooted then
		nDefense = nDefense - nFlatFootedMod;
	end
	
	-- EFFECT MODIFIERS
	local nDefenseEffectMod = 0;
	local nMissChance = 0;
	if ActorManager.hasCT(rDefender) then
		-- SETUP
		local bCombatAdvantage = false;
		local bZeroAbility = false;
		local nBonusAC = 0;
		local nBonusStat = 0;
		local nBonusSituational = 0;
		
		local bPFMode = DataCommon.isPFRPG();
		
		-- BUILD ATTACK FILTER 
		local tAttackFilter = ActionCore.buildEffectFilter({ sRange = sAttackType, bOpportunity = bOpportunity, });

		-- CHECK IF COMBAT ADVANTAGE ALREADY SET BY ATTACKER EFFECT
		if sAttack:match("%[CA%]") then
			bCombatAdvantage = true;
		end

		local tAttEffData = { rTarget = rDefender, bTargetedOnly = true, };
		local tDefEffData = { rTarget = rAttacker, };
		
		-- GET DEFENDER SITUATIONAL MODIFIERS - GENERAL
		if EffectManager.hasText(rAttacker, "CA", tAttEffData) then
			bCombatAdvantage = true;
		end
		if EffectManager.hasText(rAttacker, "Invisible", tAttEffData) then
			nBonusSituational = nBonusSituational - 2;
			bCombatAdvantage = true;
		end
		if EffectManager.hasText(rDefender, "GRANTCA", tDefEffData) then
			bCombatAdvantage = true;
		end
		if EffectManager.hasCondition(rDefender, "Blinded") then
			nBonusSituational = nBonusSituational - 2;
			bCombatAdvantage = true;
		end
		if EffectManager.hasCondition(rDefender, "Cowering") or
				EffectManager.hasCondition(rDefender, "Rebuked") then
			nBonusSituational = nBonusSituational - 2;
			bCombatAdvantage = true;
		end
		if EffectManager.hasCondition(rDefender, "Slowed") then
			nBonusSituational = nBonusSituational - 1;
		end
		if EffectManager.hasCondition(rDefender, "Flat-footed") or 
				EffectManager.hasCondition(rDefender, "Flatfooted") or 
				EffectManager.hasCondition(rDefender, "Climbing") or 
				EffectManager.hasCondition(rDefender, "Running") then
			bCombatAdvantage = true;
		end
		if EffectManager.hasCondition(rDefender, "Pinned") then
			bCombatAdvantage = true;
			if bPFMode then
				nBonusSituational = nBonusSituational - 4;
			else
				if not EffectManager.hasCondition(rAttacker, "Grappled") then
					nBonusSituational = nBonusSituational - 4;
				end
			end
		elseif not bPFMode and EffectManager.hasCondition(rDefender, "Grappled") then
			if not EffectManager.hasCondition(rAttacker, "Grappled") then
				bCombatAdvantage = true;
			end
		end
		if EffectManager.hasCondition(rDefender, "Helpless") or 
				EffectManager.hasCondition(rDefender, "Paralyzed") or 
				EffectManager.hasCondition(rDefender, "Petrified") or
				EffectManager.hasCondition(rDefender, "Unconscious") then
			if sAttackType == "M" then
				nBonusSituational = nBonusSituational - 4;
			end
			bZeroAbility = true;
		end
		if EffectManager.hasCondition(rDefender, "Kneeling") or 
				EffectManager.hasCondition(rDefender, "Sitting") then
			if sAttackType == "M" then
				nBonusSituational = nBonusSituational - 2;
			elseif sAttackType == "R" then
				nBonusSituational = nBonusSituational + 2;
			end
		elseif EffectManager.hasCondition(rDefender, "Prone") then
			if sAttackType == "M" then
				nBonusSituational = nBonusSituational - 4;
			elseif sAttackType == "R" then
				nBonusSituational = nBonusSituational + 4;
			end
		end
		if EffectManager.hasCondition(rDefender, "Squeezing") then
			nBonusSituational = nBonusSituational - 4;
		end
		if EffectManager.hasCondition(rDefender, "Stunned") then
			nBonusSituational = nBonusSituational - 2;
			if rRoll.sType == "grapple" then
				nBonusSituational = nBonusSituational - 4;
			end
			bCombatAdvantage = true;
		end
		if EffectManager.hasText(rDefender, "Invisible", tDefEffData) then
			bTotalConceal = true;
		end
		
		-- DETERMINE EXISTING AC MODIFIER TYPES
		local aExistingBonusByType = getArmorComps(rDefender);
		
		local tDefFilterEffData = { rTarget = rAttacker, tFilter = tAttackFilter, };

		-- GET DEFENDER ALL DEFENSE MODIFIERS
		local aIgnoreEffects = {};
		if bTouch then
			table.insert(aIgnoreEffects, "armor");
			table.insert(aIgnoreEffects, "shield");
			table.insert(aIgnoreEffects, "natural");
		end
		if bFlatFooted or bCombatAdvantage then
			table.insert(aIgnoreEffects, "dodge");
		end
		if rRoll.sType == "grapple" then
			table.insert(aIgnoreEffects, "size");
		end
		local tACEffects = EffectManager.getBonusData(rDefender, "AC", tDefFilterEffData);
		for k,v in pairs(tACEffects) do
			if not StringManager.contains(aIgnoreEffects, k) then
				local sBonusType = DataCommon.actypes[k];
				if sBonusType then
					-- Dodge bonuses stack (by rules)
					if sBonusType == "dodge" then
						nBonusAC = nBonusAC + v.mod;
					-- Size bonuses stack (by usage expectation)
					elseif sBonusType == "size" then
						nBonusAC = nBonusAC + v.mod;
					elseif aExistingBonusByType[sBonusType] then
						if v.mod < 0 then
							nBonusAC = nBonusAC + v.mod;
						elseif v.mod > aExistingBonusByType[sBonusType] then
							nBonusAC = nBonusAC + v.mod - aExistingBonusByType[sBonusType];
						end
					else
						nBonusAC = nBonusAC + v.mod;
					end
				else
					nBonusAC = nBonusAC + v.mod;
				end
			end
		end
		if rRoll.sType == "grapple" then
			local nPFMod, nPFCount = EffectManager.getBonusMod(rDefender, "CMD", { rTarget = rAttacker, tFilter = tAttackFilter, });
			if nPFCount > 0 then
				nBonusAC = nBonusAC + nPFMod;
			end
		end
		
		-- GET DEFENDER DEFENSE STAT MODIFIERS
		local nBonusStat = 0;
		local nBonusStat1 = ActorManagerD20.getAbilityEffectsBonus(rDefender, sDefenseStat);
		if ActorManager.isPC(rDefender) and (nBonusStat1 > 0) then
			if DB.getValue(nodeDefender, "encumbrance.armormaxstatbonusactive", 0) == 1 then
				local nCurrentStatBonus = getAbilityBonus(rDefender, sDefenseStat);
				local nMaxStatBonus = math.max(DB.getValue(nodeDefender, "encumbrance.armormaxstatbonus", 0), 0);
				local nMaxEffectStatModBonus = math.max(nMaxStatBonus - nCurrentStatBonus, 0);
				if nBonusStat1 > nMaxEffectStatModBonus then 
					nBonusStat1 = nMaxEffectStatModBonus; 
				end
			end
		end
		if not bFlatFooted and not bCombatAdvantage and sDefenseStat == "dexterity" then
			nFlatFootedMod = nFlatFootedMod + nBonusStat1;
		end
		nBonusStat = nBonusStat + nBonusStat1;
		local nBonusStat2 = ActorManagerD20.getAbilityEffectsBonus(rDefender, sDefenseStat2);
		if not bFlatFooted and not bCombatAdvantage  and sDefenseStat2 == "dexterity" then
			nFlatFootedMod = nFlatFootedMod + nBonusStat2;
		end
		nBonusStat = nBonusStat + nBonusStat2;
		local nBonusStat3 = ActorManagerD20.getAbilityEffectsBonus(rDefender, sDefenseStat3);
		if not bFlatFooted and not bCombatAdvantage  and sDefenseStat3 == "dexterity" then
			nFlatFootedMod = nFlatFootedMod + nBonusStat3;
		end
		nBonusStat = nBonusStat + nBonusStat3;
		if bFlatFooted or bCombatAdvantage then
			-- IF NEGATIVE AND AC STAT BONUSES, THEN ONLY APPLY THE AMOUNT THAT EXCEEDS AC STAT BONUSES
			if nBonusStat < 0 then
				if nDefenseStatMod > 0 then
					nBonusStat = math.min(nDefenseStatMod + nBonusStat, 0);
				end
				
			-- IF POSITIVE AND AC STAT PENALTIES, THEN ONLY APPLY UP TO AC STAT PENALTIES
			else
				if nDefenseStatMod < 0 then
					nBonusStat = math.min(nBonusStat, -nDefenseStatMod);
				else
					nBonusStat = 0;
				end
			end
		end
		
		-- HANDLE NEGATIVE LEVELS
		if rRoll.sType == "grapple" then
			local nNegLevelMod, nNegLevelCount = EffectManager.getBonusMod(rSource, "NLVL");
			if nNegLevelCount > 0 then
				nBonusSituational = nBonusSituational - nNegLevelMod;
			end
		end
		
		-- HANDLE DEXTERITY MODIFIER REMOVAL
		if bZeroAbility then
			if bFlatFooted then
				nBonusSituational = nBonusSituational - 5;
			else
				nBonusSituational = nBonusSituational - nFlatFootedMod - 5;
			end
		elseif bCombatAdvantage and not bFlatFooted then
			nBonusSituational = nBonusSituational - nFlatFootedMod;
		end

		-- GET DEFENDER SITUATIONAL MODIFIERS - COVER
		if nCover < 8 then
			if EffectManager.hasTextOrTag(rDefender, "SCOVER", tDefEffData) then
				nBonusSituational = nBonusSituational + 8 - nCover;
			elseif nCover < 4 then
				if EffectManager.hasTextOrTag(rDefender, "COVER", tDefEffData) then
					nBonusSituational = nBonusSituational + 4 - nCover;
				elseif nCover < 2 then
					if EffectManager.hasTextOrTag(rDefender, "PCOVER", tDefEffData) then
						nBonusSituational = nBonusSituational + 2 - nCover;
					end
				end
			end
		end
		
		-- GET DEFENDER SITUATIONAL MODIFIERS - CONCEALMENT
		if bTotalConceal or bAttackerBlinded or EffectManager.hasTextOrTag(rDefender, "TCONC", tDefEffData) then
			nMissChance = 50;
		else
			if EffectManager.hasTextOrTag(rDefender, "CONC", tDefEffData) then
				nMissChance = 20;
			end
		end
		
		-- CHECK INCORPOREALITY
		if not bPFMode then
			local bIncorporealAttack = false;
			if sAttack:match("%[INCORPOREAL%]") then
				bIncorporealAttack = true;
			end
			local bIncorporealDefender = EffectManager.hasCondition(rDefender, "Incorporeal");

			if bIncorporealDefender and not bIncorporealAttack then
				nMissChance = 50;
			end
		end
		
		-- ADD IN EFFECT MODIFIERS
		nDefenseEffectMod = nBonusAC + nBonusStat + nBonusSituational;
	
	-- NO DEFENDER SPECIFIED, SO JUST LOOK AT THE ATTACK ROLL MODIFIERS
	else
		if bTotalConceal or bAttackerBlinded then
			nMissChance = 50;
		elseif bConceal then
			nMissChance = 20;
		end
		
		if bIncorporealAttack then
			nMissChance = 50;
		end
	end
	
	-- Return the final defense value
	return nDefense, 0, nDefenseEffectMod, nMissChance;
end
function getArmorComps(rActor)
	local nodeActor = ActorManager.getCreatureNode(rActor);
	if not nodeActor then
		return {};
	end

	local tComps = {};
	
	if ActorManager.isPC(rActor) then
		local nACBonusComp = DB.getValue(nodeActor, "ac.sources.armor", 0);
		if nACBonusComp ~= 0 then
			tComps["armor"] = nACBonusComp;
		end
		nACBonusComp = DB.getValue(nodeActor, "ac.sources.shield", 0);
		if nACBonusComp ~= 0 then
			tComps["shield"] = nACBonusComp;
		end
		local sAbility = DB.getValue(nodeActor, "ac.sources.ability", "");
		if DataCommon.ability_ltos[sAbility] then
			tComps[DataCommon.ability_ltos[sAbility]] = getAbilityBonus(rActor, sAbility);
		end
		local sAbility2 = DB.getValue(nodeActor, "ac.sources.ability2", "");
		if DataCommon.ability_ltos[sAbility2] then
			tComps[DataCommon.ability_ltos[sAbility2]] = getAbilityBonus(rActor, sAbility2);
		end
		nACBonusComp = DB.getValue(nodeActor, "ac.sources.size", 0);
		if nACBonusComp ~= 0 then
			tComps["size"] = nACBonusComp;
		end
		nACBonusComp = DB.getValue(nodeActor, "ac.sources.naturalarmor", 0);
		if nACBonusComp ~= 0 then
			tComps["natural"] = nACBonusComp;
		end
		nACBonusComp = DB.getValue(nodeActor, "ac.sources.deflection", 0);
		if nACBonusComp ~= 0 then
			tComps["deflection"] = nACBonusComp;
		end
		nACBonusComp = DB.getValue(nodeActor, "ac.sources.dodge", 0);
		if nACBonusComp ~= 0 then
			tComps["dodge"] = nACBonusComp;
		end
		nACBonusComp = DB.getValue(nodeActor, "ac.sources.misc", 0);
		if nACBonusComp ~= 0 then
			tComps["misc"] = nACBonusComp;
		end
	elseif ActorManager.isRecordType(rActor, "npc") then
		local sAC = DB.getValue(nodeActor, "ac", ""):lower();
		local nAC = tonumber(sAC:match("^(%d+)")) or 10;
		local sACComps = sAC:match("%(([^)]+)%)");
		local nCompTotal = 10;
		if sACComps then
			local aACSplit = StringManager.split(sACComps, ",", true);
			for _,vACComp in ipairs(aACSplit) do
				local sACCompBonus, sACCompType = vACComp:match("^([+-]%d+)%s+(.*)$");
				if not sACCompType then
					sACCompType, sACCompBonus = vACComp:match("^(.*)%s+([+-]%d+)$");
				end
				local nACCompBonus = tonumber(sACCompBonus) or 0;
				if sACCompType and nACCompBonus ~= 0 then
					sACCompType = sACCompType:gsub("[+-]%d+", "");
					sACCompType = StringManager.trim(sACCompType);
					
					if DataCommon.actypes[sACCompType] then
						tComps[DataCommon.actypes[sACCompType]] = nACCompBonus;
						nCompTotal = nCompTotal + nACCompBonus;
					elseif StringManager.contains (DataCommon.acarmormatch, sACCompType) then
						tComps["armor"] = nACCompBonus;
						nCompTotal = nCompTotal + nACCompBonus;
					elseif StringManager.contains (DataCommon.acshieldmatch, sACCompType) then
						tComps["shield"] = nACCompBonus;
						nCompTotal = nCompTotal + nACCompBonus;
					elseif StringManager.contains (DataCommon.acdeflectionmatch, sACCompType) then
						tComps["deflection"] = nACCompBonus;
						nCompTotal = nCompTotal + nACCompBonus;
					end
				end
			end
		end
		if nCompTotal ~= nAC then
			tComps["misc"] = nAC - nCompTotal;
		end
	end

	return tComps;
end

--
--	BONUS
--

function getBonus(rActor, sKey, ...)
	if (sKey or "") ~= "" then
		sKey = DataCommon.ability_stol[sKey:upper()] or sKey:lower();
	end
	if StringManager.contains(DataCommon.abilities, sKey) then
		return ActorManager35E.getAbilityBonus(rActor, sKey, ...);
	end
	return ActorManager35E.getAbilityScore(rActor, sKey, ...);
end
function getEffectsBonus(rActor, sKey, ...)
	if (sKey or "") ~= "" then
		sKey = DataCommon.ability_stol[sKey:upper()] or sKey:lower();
	end
	if StringManager.contains(DataCommon.abilities, sKey) then
		return ActorManagerD20.getAbilityEffectsBonus(rActor, sKey, ...);
	end
	return 0, 0;
end

--
--	REST
--

function rest(rActor, sRestType)
	if not ActorCommonManager.restDefault(rActor, sRestType) then
		return false;
	end

	if ActorManager.isPC(rActor) then
		ActorManager35E.restPC(rActor, sRestType);
	end
	return true;
end
function restPC(rActor, sRestType)
	local nodeChar = ActorManager.getCreatureNode(rActor);
	SpellManager.resetSpells(nodeChar);
end
