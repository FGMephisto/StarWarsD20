-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	GameManager.setOption("atktype", "3.5E");
	GameManager.setOption("critical", "3.5E");
	GameManager.setOption("critmult", "3.5E");
	GameManager.setOption("dmgdr", "3.5E");
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
	GameManager.setMultiKeyFunction("onActionPostModRoll", "damage", ActionDamage.onPostModRoll);
	GameManager.setFunction("onHealthApplyStatusChange", ActionDamage.applyStatusChangeSW);
	GameManager.setFunction("onDamageApplyResults", ActionDamage.applyDamageResultsSW);

	ActionsManager.registerModHandler("stabilization", modStabilization);
	ActionsManager.registerResultHandler("stabilization", onStabilization);
end

--
--	CUSTOM DAMAGE
--

function onPostModRoll(rSource, rTarget, rRoll)
	applySizeEffectsToModRoll(rSource, rTarget, rRoll);
end
function applySizeEffectsToModRoll(rSource, rTarget, rRoll)
	if not rRoll or rRoll.bOngoing or (#(rRoll.clauses or {}) == 0) then
		return;
	end
	if StringManager.contains(StringManager.splitByPattern((rRoll.clauses[1].dmgtype or ""), ",", true), "nosize") then
		return;
	end

	local nActorSize, nBaseSize = ActorCommonManager.getSize(rSource);
	nActorSize = nActorSize + EffectManager.getBonusMod(rSource, "ESIZE", { rTarget = rTarget, tFilter = ActionCore.buildEffectFilter(rRoll), });
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
-- When the damage dealt by a creatureâ€™s weapons or natural attacks changes due to a change in its size (or the size of its weapon), use the following rules to determine the new damage.
-- â€¢ If the size increases by one step, look up the original damage on the chart and increase the damage by two steps.
--		If the initial size is Small or lower (or is treated as Small or lower) or the initial damage is 1d6 or less, instead increase the damage by one step.
-- â€¢ If the size decreases by one step, look up the original damage on the chart and decrease the damage by two steps.
--		If the initial size is Medium or lower (or is treated as Medium or lower) or the initial damage is 1d8 or less, instead decrease the damage by one step.
-- â€¢ If the exact number of original dice is not found on this chart, apply the following before adjusting the damage dice.
--		If the damage is a number of d6, find the next lowest number of d6 on the chart and use that number of d8 as the original damage value (for example, 10d6 would instead be treated as 8d8).
--		If the damage is a number of d8, find the next highest number of d8 on the chart and use that number of d6 as the original damage value (for example, 5d8 would instead be treated as 6d6).
--		Once you have the new damage value, adjust by the number of steps noted above.
-- â€¢ If the die type is not referenced on this chart, apply the following rules before adjusting the damage dice.
--		2d4 counts as 1d8 on the chart, 3d4 counts as 2d6 on the chart, and so on for higher numbers of d4.
--		1d12 counts as 2d6 on the chart, and so on for higher numbers of d12.
-- â€¢ Finally, 2d10 increases to 4d8 and decreases to 2d8, regardless of the initial size, and so on for higher numbers of d10.
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
		return ActionDamage.fixDamageDiceProgressionString(sDice, bIncrease);
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
		rMessage.text = rMessage.text .. " [SUCCESS]";
	else
		rMessage.text = rMessage.text .. " [FAILURE]";
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
--	SW D20 DAMAGE RESULTS (ARMOR DR VS VP / WP)
--

function applyDamageResultsSW(rSource, rTarget, rRoll, tApplyData)
	tApplyData.nConcentrationDamage = tApplyData.nAdjustedDamage;

	local bCritical = tApplyData.bCritical or (rRoll and rRoll.sDesc and (rRoll.sDesc:match("%[CRITICAL%]") or rRoll.sDesc:match("%[CRIT%]")));

	if not bCritical then
		-- Step 1: Absorb damage with Vitality Points (VP)
		if ((tApplyData.tHealth["hp"].nTemp or 0) > 0) and ((tApplyData.nAdjustedDamage or 0) > 0) then
			if tApplyData.nAdjustedDamage > tApplyData.tHealth["hp"].nTemp then
				table.insert(tApplyData.tNotifications, string.format("[VP ABSORBED: %d]", tApplyData.tHealth["hp"].nTemp));
				tApplyData.nAdjustedDamage = tApplyData.nAdjustedDamage - tApplyData.tHealth["hp"].nTemp;
				tApplyData.tHealth["hp"].nTemp = 0;
			else
				table.insert(tApplyData.tNotifications, string.format("[VP ABSORBED: %d]", tApplyData.nAdjustedDamage));
				tApplyData.tHealth["hp"].nTemp = tApplyData.tHealth["hp"].nTemp - tApplyData.nAdjustedDamage;
				tApplyData.nAdjustedDamage = 0;
			end
		end
		ActionHealthD20.applyDamageResultsNonlethal(rSource, rTarget, rRoll, tApplyData);
	end

	if (tApplyData.nAdjustedDamage or 0) <= 0 then
		return;
	end

	-- Step 2: Apply Armor DR only to damage that penetrates into Wound Points
	local nArmorDR = ActionDamage.getArmorDR(rTarget, rSource, rRoll);
	if nArmorDR > 0 then
		local nPrev = tApplyData.nAdjustedDamage;
		tApplyData.nAdjustedDamage = math.max(0, tApplyData.nAdjustedDamage - nArmorDR);
		local nAbsorbed = nPrev - tApplyData.nAdjustedDamage;
		if nAbsorbed > 0 then
			table.insert(tApplyData.tNotifications, string.format("[ARMOR DR: %d]", nAbsorbed));
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

function getArmorDR(rTarget, rSource, rRoll)
	if not rTarget then
		return 0;
	end

	-- Lightsabers ignore armor DR as per Star Wars d20 rules
	local sDamageTypes = "";
	if rRoll and rRoll.sDesc then
		sDamageTypes = rRoll.sDesc:lower();
	end
	if sDamageTypes:match("lightsaber") then
		return 0;
	end

	local nDR = 0;
	local sDR = GameManager.getRecordFieldValueLinked(rTarget, "dr", "");
	if (sDR == "" or sDR == 0) then
		sDR = GameManager.getRecordFieldValueLinked(rTarget, "damagereduction", "");
	end
	if (sDR == "" or sDR == 0) then
		sDR = GameManager.getRecordFieldValueLinked(rTarget, "defenses.damagereduction", "");
	end
	if type(sDR) == "number" then
		nDR = sDR;
	elseif type(sDR) == "string" and sDR ~= "" then
		nDR = tonumber(sDR:match("(%d+)")) or 0;
	end

	local nEffectDR = EffectManager.getBonusMod(rTarget, "DR") + EffectManager.getBonusMod(rTarget, "ARMORDR") + EffectManager.getBonusMod(rTarget, "ADR");
	nDR = nDR + nEffectDR;

	return math.max(0, nDR);
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
