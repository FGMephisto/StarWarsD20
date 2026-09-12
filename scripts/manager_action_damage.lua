-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	GameManager.setOption("atktype", "3.5E");
	GameManager.setOption("critical", "3.5E");
	GameManager.setOption("critmult", "3.5E");
	GameManager.setOption("dmgfortification", "3.5E");
	GameManager.setOption("dmgmin", "3.5E");
	GameManager.setOption("dmgvuln", "3.5E");
	GameManager.setOption("incorporeal", "3.5E");
	GameManager.setOption("metamagic", "3.5E");
	GameManager.setOption("negativehp", "3.5E");
	GameManager.setOption("nonlethal", "3.5E");
	GameManager.setOption("regeneration", "3.5E");
	GameManager.setOption("rest", "3.5E");

	EffectManager.setTagOptions("ESIZE", { bIgnoreExpire = true, bIgnoreTarget = true });

	ActionDamageD20.registerStandardDamageHealHandlers();
	GameManager.setMultiKeyFunction("onActionPreModRoll", "damage", ActionDamage.onPreModRoll);
	GameManager.setFunction("onHealthApplyStatusChange", ActionDamage.applyStatusChangeSW);
	GameManager.setFunction("onDamageApplyResults", ActionDamage.applyDamageResultsSW);

	ActionsManager.registerModHandler("stabilization", modStabilization);
	ActionsManager.registerResultHandler("stabilization", onStabilization);
end

--
--	CUSTOM DAMAGE
--

function onPreModRoll(rSource, rTarget, rRoll)
	ActionDamage.applySizeEffectsToModRoll(rSource, rTarget, rRoll);
end
function applySizeEffectsToModRoll(rSource, rTarget, rRoll)
	if not rRoll or rRoll.bOngoing or rRoll.bSpell or (#(rRoll.clauses or {}) == 0) then
		return;
	end
	if StringManager.contains(StringManager.splitByPattern((rRoll.clauses[1].dmgtype or ""), ",", true), "nosize") then
		return;
	end

	local nActorSize, nBaseSize = ActorCommonManager.getSize(rSource);
	nActorSize = nActorSize + EffectManager.getBonusMod(rSource, "ESIZE", { rTarget = rTarget, tFilter = ActionCore.buildEffectFilter(rRoll), tActionTags = rRoll.tActionTags, });
	if nActorSize == nBaseSize then
		return;
	end

	local tDice = rRoll.clauses[1].dice or {};
	local nDice = #tDice;
	local sDice = ((nDice > 0) and (nDice .. tDice[1])) or "1d1";

	local sNewDice, nDiceProgression = ActionDamage.applyDamageDiceStringProgression(sDice, nBaseSize, nActorSize - nBaseSize);

	rRoll.clauses[1].dice = DiceManager.convertStringToDice(sNewDice);
	local nNewDice = #(rRoll.clauses[1].dice or {});

	for i = 1, math.min(nDice, nNewDice) do
		local tDie = rRoll.aDice[i];
		if tDie then
			tDie.type = rRoll.clauses[1].dice[1];
		end
	end
	for i = nNewDice + 1, nDice do
		table.remove(rRoll.aDice, nNewDice + 1);
	end
	for i = nDice + 1, nNewDice do
		local tDie = rRoll.aDice[1];
		if tDie then
			table.insert(rRoll.aDice, tDie);
		end
	end

	rRoll.bEffects = true;
	table.insert(rRoll.tNotifications, string.format("[SIZE %+dD]", nDiceProgression));
end

-- From the Paizo official FAQ:
--		https://paizo.com/paizo/faq/v5748nruor1fm#v5748eaic9t3f
-- When the damage dealt by a creature’s weapons or natural attacks changes due to a change in its size (or the size of its weapon), use the following rules to determine the new damage.
-- • If the size increases by one step, look up the original damage on the chart and increase the damage by two steps.
--		If the initial size is Small or lower (or is treated as Small or lower) or the initial damage is 1d6 or less, instead increase the damage by one step.
-- • If the size decreases by one step, look up the original damage on the chart and decrease the damage by two steps.
--		If the initial size is Medium or lower (or is treated as Medium or lower) or the initial damage is 1d8 or less, instead decrease the damage by one step.
-- • If the exact number of original dice is not found on this chart, apply the following before adjusting the damage dice.
--		If the damage is a number of d6, find the next lowest number of d6 on the chart and use that number of d8 as the original damage value (for example, 10d6 would instead be treated as 8d8).
--		If the damage is a number of d8, find the next highest number of d8 on the chart and use that number of d6 as the original damage value (for example, 5d8 would instead be treated as 6d6).
--		Once you have the new damage value, adjust by the number of steps noted above.
-- • If the die type is not referenced on this chart, apply the following rules before adjusting the damage dice.
--		2d4 counts as 1d8 on the chart, 3d4 counts as 2d6 on the chart, and so on for higher numbers of d4.
--		1d12 counts as 2d6 on the chart, and so on for higher numbers of d12.
-- • Finally, 2d10 increases to 4d8 and decreases to 2d8, regardless of the initial size, and so on for higher numbers of d10.
local _tDamageDiceProgression = {
	"1d1", "1d2", "1d3", "1d4", "1d6", "1d8", "1d10",
	"2d6", "2d8", "3d6", "3d8", "4d6", "4d8", "6d6",
	"6d8", "8d6", "8d8", "12d6", "12d8", "16d6", "24d6",
};
function applyDamageDiceStringProgression(sDice, nBaseSize, nSizeMod)
	local nProgressionIndex = ActionDamage.getDamageDiceProgressionIndex(sDice, (nSizeMod > 0));

	local nDiceProgression = 0;
	if nSizeMod > 0 then
		for _ = 1, nSizeMod do
			if nProgressionIndex < 6 or nBaseSize < 0 then
				nProgressionIndex = nProgressionIndex + 1;
				nDiceProgression = nDiceProgression + 1;
			else
				nProgressionIndex = nProgressionIndex + 2;
				nDiceProgression = nDiceProgression + 2;
			end
			nBaseSize = nBaseSize + 1;
		end
	else
		for _ = -1, nSizeMod, -1 do
			if nProgressionIndex <= 6 or nBaseSize <= 0 then
				nProgressionIndex = nProgressionIndex - 1;
				nDiceProgression = nDiceProgression - 1;
			else
				nProgressionIndex = nProgressionIndex - 2;
				nDiceProgression = nDiceProgression - 2;
			end
			nBaseSize = nBaseSize - 1;
		end
	end
	local sNewDice = ActionDamage.getDamageDiceProgressionString(nProgressionIndex);

	return sNewDice, nDiceProgression;
end
function getDamageDiceProgressionIndex(sDice, bIncrease)
	sDice = ActionDamage.fixDamageDiceProgressionString(sDice, bIncrease);

	local nDieCount, nDieSides = ActionDamage.getDieDetails(sDice);
	for k,sProgDice in ipairs(_tDamageDiceProgression) do
		if sDice == sProgDice then
			return k;
		end
		local nProgDieCount, _ = ActionDamage.getDieDetails(sProgDice);
		if nDieSides == 6 and nDieCount < nProgDieCount then
			return k - 1;
		elseif nDieSides == 8 and nDieCount < nProgDieCount then
			return k;
		end
	end
end
-- Clean up dice not in table, per rules 3-5 above
function fixDamageDiceProgressionString(sDice, bIncrease)
	local nDieCount, nDieSides = ActionDamage.getDieDetails(sDice);

	local sNewDice;
	if nDieSides == 12 then
		sNewDice = string.format("%dd6", nDieCount + 1);
	elseif nDieSides == 10 then
		if (nDieCount > 1) then
			if bIncrease then
				sNewDice = string.format("%dd8", 2 * nDieCount);
			else
				sNewDice = string.format("%dd8", nDieCount);
			end
		end
	elseif nDieSides == 8 then
		if nDieCount == 5 then
			sNewDice = "6d6";
		elseif nDieCount == 7 then
			sNewDice = "8d6";
		elseif nDieCount >= 9 and nDieCount <= 11 then
			sNewDice = "12d6";
		elseif nDieCount >= 13 and nDieCount <= 15 then
			sNewDice = "16d6";
		end
	elseif nDieSides == 6 then
		if nDieCount == 5 then
			sNewDice = "4d8";
		elseif nDieCount == 7 then
			sNewDice = "6d8";
		elseif nDieCount >= 9 and nDieCount <= 11 then
			sNewDice = "8d8";
		elseif nDieCount >= 13 and nDieCount <= 15 then
			sNewDice = "12d8";
		end
	elseif nDieSides == 4 then
		if nDiceCount == 2 then
			sNewDice = "1d8";
		elseif nDieCount > 2 then
			sNewDice = string.format("%dd6", nDieCount - 1);
		end
	end
	if sNewDice then
		return ActionDamage.fixDamageDiceProgressionString(sNewDice, bIncrease);
	end
	return sDice;
end
function getDieDetails(sDice)
	local sDieCount, sDieSides = (sDice or ""):match("(%d+)d(%d+)");
	return tonumber(sDieCount) or 1, tonumber(sDieSides) or 1;
end
function getDamageDiceProgressionString(nIndex)
	if nIndex <= 0 then
		return "1d1";
	elseif nIndex > #_tDamageDiceProgression then
		if (nIndex - #_tDamageDiceProgression) % 2 == 1 then
			local nDice = 16 * (math.floor((nIndex - #_tDamageDiceProgression) / 2) + 1);
			return string.format("%dd6", nDice);
		else
			nDice = 24 * (math.floor((nIndex - #_tDamageDiceProgression) / 2) + 1);
			return string.format("%dd6", nDice);
		end
	end
	return _tDamageDiceProgression[nIndex];
end

--
--	STABILIZATION ROLL
--

function performStabilizationRoll(rActor)
	local rRoll = GameSystem.getStabilizationRoll(rActor);
	ActionsManager.performAction(nil, rActor, rRoll);
end
function modStabilization(rSource, rTarget, rRoll)
	GameSystem.modStabilization(rSource, rTarget, rRoll);
end
function onStabilization(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	local bSuccess = GameSystem.getStabilizationResult(rRoll);
	if bSuccess then
		rMessage.text = StringManager.appendLine(rMessage.text, "[SUCCESS]");
	else
		rMessage.text = StringManager.appendLine(rMessage.text, "[FAILURE]");
	end
	
	Comm.deliverChatMessage(rMessage);

	if bSuccess then
		EffectManager.addCondition(rSource, "Stable");
	else
		ActionDamage.applyFailedStabilization(rSource, rRoll.bSecret);
	end

	GameManager.callEventFunctions("onSavePostResolve", rSource, nil, rRoll);
end
function applyFailedStabilization(rActor, bSecret)
	local rRoll = {
		sType = "damage",
		bSecret = bSecret,
		sDesc = string.format("[%s] Dying", Interface.getString("action_damage_tag")),
		nTotal = 1,
	};
	ActionHealthD20.apply(nil, rActor, rRoll);
end

--
--	SW D20 DAMAGE RESULTS (SHIELDS, VP, ARMOR DR VS SIZE DR, WP)
--

function applyDamageResultsSW(rSource, rTarget, rRoll, tApplyData)
	tApplyData.nConcentrationDamage = tApplyData.nAdjustedDamage;

	local bCritical = tApplyData.bCritical or (rRoll and rRoll.sDesc and (rRoll.sDesc:match("%[CRITICAL%]") or rRoll.sDesc:match("%[CRIT%]")));
	local bShielded = ActionDamage.isShieldedTarget(rTarget, tApplyData.tHealth);

	-- Step 1: Absorb damage with Shield Points (SP) or Vitality Points (VP)
	-- Active energy shield bubbles absorb critical hits; unprotected VP is bypassed on a critical hit.
	if (not bCritical) or bShielded then
		if ((tApplyData.tHealth["hp"].nTemp or 0) > 0) and ((tApplyData.nAdjustedDamage or 0) > 0) then
			local sAbsorbTag = bShielded and "[SHIELD ABSORBED: %d]" or "[VP ABSORBED: %d]";
			if tApplyData.nAdjustedDamage > tApplyData.tHealth["hp"].nTemp then
				table.insert(tApplyData.tNotifications, string.format(sAbsorbTag, tApplyData.tHealth["hp"].nTemp));
				tApplyData.nAdjustedDamage = tApplyData.nAdjustedDamage - tApplyData.tHealth["hp"].nTemp;
				tApplyData.tHealth["hp"].nTemp = 0;
			else
				table.insert(tApplyData.tNotifications, string.format(sAbsorbTag, tApplyData.nAdjustedDamage));
				tApplyData.tHealth["hp"].nTemp = tApplyData.tHealth["hp"].nTemp - tApplyData.nAdjustedDamage;
				tApplyData.nAdjustedDamage = 0;
			end
		end
		ActionHealthD20.applyDamageResultsNonlethal(rSource, rTarget, rRoll, tApplyData);
	end

	if (tApplyData.nAdjustedDamage or 0) <= 0 then
		return;
	end

	-- Step 2: Apply Damage Reduction (Armor DR vs. Size/Structural DR) only to damage penetrating into Wound Points
	local bLightsaber = ActionDamage.isLightsaberAttack(rSource, rRoll);
	local nArmorDR, nOtherDR, sOtherType = ActionDamage.getDamageReductionSW(rTarget, rSource, rRoll);

	-- Armor DR: bypassed by lightsabers
	if nArmorDR > 0 then
		if bLightsaber then
			table.insert(tApplyData.tNotifications, string.format("[LIGHTSABER BYPASSES ARMOR DR: %d]", nArmorDR));
		else
			local nPrev = tApplyData.nAdjustedDamage;
			tApplyData.nAdjustedDamage = math.max(0, tApplyData.nAdjustedDamage - nArmorDR);
			local nAbsorbed = nPrev - tApplyData.nAdjustedDamage;
			if nAbsorbed > 0 then
				table.insert(tApplyData.tNotifications, string.format("[ARMOR DR: %d]", nAbsorbed));
			end
		end
	end

	-- Size / Structural / Other DR: NOT bypassed by lightsabers
	if (nOtherDR > 0) and ((tApplyData.nAdjustedDamage or 0) > 0) then
		local nPrev = tApplyData.nAdjustedDamage;
		tApplyData.nAdjustedDamage = math.max(0, tApplyData.nAdjustedDamage - nOtherDR);
		local nAbsorbed = nPrev - tApplyData.nAdjustedDamage;
		if nAbsorbed > 0 then
			local sLabel = (sOtherType == "size" and "[SIZE DR: %d]") or (sOtherType == "structural" and "[STRUCTURAL DR: %d]") or "[DR: %d]";
			table.insert(tApplyData.tNotifications, string.format(sLabel, nAbsorbed));
		end
	end

	if (tApplyData.nAdjustedDamage or 0) <= 0 then
		return;
	end

	-- Step 3: Apply leftover damage to Wound Points
	ActionHealthD20.applyDamageResultsNormal(rSource, rTarget, rRoll, tApplyData);
	ActionHealthD20.applyDamageResultsDeathSave(rSource, rTarget, rRoll, tApplyData);
	ActionHealthD20.applyDamageResultsSystemShock(rSource, rTarget, rRoll, tApplyData);
end

function isLightsaberAttack(rSource, rRoll)
	if not rRoll then
		return false;
	end
	local sDesc = (rRoll.sDesc or ""):lower();
	if sDesc:match("lightsaber") then
		return true;
	end
	if rRoll.clauses then
		for _, tClause in ipairs(rRoll.clauses) do
			if (tClause.dmgtype or ""):lower():match("lightsaber") then
				return true;
			end
		end
	end
	return false;
end

function isShieldedTarget(rTarget, tHealth)
	if not rTarget or not tHealth or not tHealth["hp"] then
		return false;
	end
	if (tHealth["hp"].nTemp or 0) <= 0 then
		return false;
	end

	if EffectManager.hasCondition(rTarget, "SHIELD") or EffectManager.hasCondition(rTarget, "SHIELDS") then
		return true;
	end

	local nodeTarget = ActorManager.getCreatureNode(rTarget);
	if nodeTarget then
		local sNPCType = DB.getValue(nodeTarget, "npctype", ""):lower();
		if sNPCType == "vehicle" then
			return true;
		end
		local sType = DB.getValue(nodeTarget, "type", ""):lower();
		local sSQ = DB.getValue(nodeTarget, "specialqualities", ""):lower();
		if sType:match("droid") and (sSQ:match("shield") or sType:match("droideka") or sType:match("destroyer")) then
			return true;
		end
		if sSQ:match("shield generator") or sSQ:match("shield points") then
			return true;
		end
	end

	return false;
end

function getDamageReductionSW(rTarget, rSource, rRoll)
	if not rTarget then
		return 0, 0, "";
	end

	local nArmorDR = 0;
	local nOtherDR = 0;
	local sOtherType = "";

	local bVehicle = false;
	local bSizeDR = false;

	local nodeTarget = ActorManager.getCreatureNode(rTarget);
	if nodeTarget then
		local sNPCType = DB.getValue(nodeTarget, "npctype", ""):lower();
		local sType = DB.getValue(nodeTarget, "type", ""):lower();
		local sSQ = DB.getValue(nodeTarget, "specialqualities", ""):lower();

		if sNPCType == "vehicle" or sType:match("vehicle") or sType:match("starship") then
			bVehicle = true;
			sOtherType = "structural";
		elseif sType:match("huge") or sType:match("gargantuan") or sType:match("colossal") or sSQ:match("%(size%)") then
			bSizeDR = true;
			sOtherType = "size";
		end
	end

	-- Base DR from sheet (equipped armor on PC, or dr field on NPC)
	local nBaseDR = 0;
	local sDR = GameManager.getRecordFieldValueLinked(rTarget, "dr", "");
	if (sDR == "" or sDR == 0) then
		sDR = GameManager.getRecordFieldValueLinked(rTarget, "damagereduction", "");
	end
	if (sDR == "" or sDR == 0) then
		sDR = GameManager.getRecordFieldValueLinked(rTarget, "defenses.damagereduction", "");
	end
	if type(sDR) == "number" then
		nBaseDR = sDR;
	elseif type(sDR) == "string" and sDR ~= "" then
		nBaseDR = tonumber(sDR:match("(%d+)")) or 0;
	end

	if nBaseDR > 0 then
		if bVehicle or bSizeDR then
			nOtherDR = nOtherDR + nBaseDR;
		else
			nArmorDR = nArmorDR + nBaseDR;
		end
	end

	-- Effects: ARMORDR and ADR always classify as Armor DR
	local nArmorEffects = EffectManager.getBonusMod(rTarget, "ARMORDR") + EffectManager.getBonusMod(rTarget, "ADR");
	nArmorDR = nArmorDR + nArmorEffects;

	-- Effects: SIZEDR and NATURALDR classify as Size/Other DR
	local nSizeEffects = EffectManager.getBonusMod(rTarget, "SIZEDR") + EffectManager.getBonusMod(rTarget, "NATURALDR");
	if nSizeEffects > 0 then
		nOtherDR = nOtherDR + nSizeEffects;
		if sOtherType == "" then
			sOtherType = "size";
		end
	end

	-- Effects: DR tag
	-- If DR effect specifies "armor", it is armor DR; otherwise it applies as universal / other DR
	for _, tCompData in ipairs(EffectManager.getCompsDataByTag(rTarget, "DR", { rTarget = rSource, tActionTags = rRoll and rRoll.tActionTags })) do
		local sRemainder = (tCompData.remainder and table.concat(tCompData.remainder, " ") or ""):lower();
		local nVal = tCompData.mod or 0;
		if nVal > 0 then
			if sRemainder:match("armor") then
				nArmorDR = nArmorDR + nVal;
			else
				nOtherDR = nOtherDR + nVal;
				if sOtherType == "" then
					sOtherType = sRemainder:match("size") and "size" or "";
				end
			end
		end
	end

	return math.max(0, nArmorDR), math.max(0, nOtherDR), sOtherType;
end

--
--	SW D20 STATUS CHANGE (LOST WOUND POINTS / FATIGUED)
--

function applyStatusChangeSW(rSource, rTarget, rRoll, tApplyData)
	ActionHealthD20.applyStatusChangeDefault(rSource, rTarget, rRoll, tApplyData);

	if not rTarget or not tApplyData or not tApplyData.tHealth or not tApplyData.tHealth["hp"] then
		return;
	end

	local nWounds = tApplyData.tHealth["hp"].nWounds or 0;
	if tApplyData.sType == "damage" then
		if nWounds > 0 then
			if not EffectManager.hasCondition(rTarget, "Fatigued") then
				EffectManager.addCondition(rTarget, "Fatigued");
				table.insert(tApplyData.tNotifications, "[FATIGUED]");
			end
		end
	elseif tApplyData.sType == "heal" or tApplyData.sType == "fheal" or tApplyData.sType == "recovery" then
		if nWounds <= 0 then
			if EffectManager.hasCondition(rTarget, "Fatigued") then
				EffectManager.removeCondition(rTarget, "Fatigued");
			end
		end
	end
end
