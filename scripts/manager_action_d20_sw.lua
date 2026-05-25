--
-- Star Wars D20 ActionD20 Manager (Take 10 / Take 20)
--

function onInit()
	-- Register mutual exclusion: TAKE10 and TAKE20 cannot be active at the same time
	ModifierManager.addKeyExclusionSets({ { "TAKE10", "TAKE20" } });
	
	-- Hook applyModifiers to capture and serialize the keys to roll metadata
	local originalApplyModifiers = ActionsManager.applyModifiers;
	function newApplyModifiers(rSource, rTarget, rRoll, bSkipModStack)
		-- Filter: Take 10/20 is only allowed on skill and ability checks
		local bAllowed = (rRoll.sType == "skill" or rRoll.sType == "ability");
		
		if bAllowed then
			local bTake10 = ModifierManager.getKey("TAKE10");
			local bTake20 = ModifierManager.getKey("TAKE20");
			if bTake10 then
				rRoll.bTake10 = true;
				if (rRoll.sDesc or "") ~= "" then
					rRoll.sDesc = rRoll.sDesc .. " [TAKE 10]";
				else
					rRoll.sDesc = "[TAKE 10]";
				end
			end
			if bTake20 then
				rRoll.bTake20 = true;
				if (rRoll.sDesc or "") ~= "" then
					rRoll.sDesc = rRoll.sDesc .. " [TAKE 20]";
				else
					rRoll.sDesc = "[TAKE 20]";
				end
			end
		end
		return originalApplyModifiers(rSource, rTarget, rRoll, bSkipModStack);
	end
	ActionsManager.applyModifiers = newApplyModifiers;

	-- Hook handleResolution to intercept rolls after landing and replace d20 results
	local originalHandleResolution = ActionsManager.handleResolution;
	function newHandleResolution(rRoll, rSource, aTargets)
		ActionD20.checkTake1020(rRoll);
		originalHandleResolution(rRoll, rSource, aTargets);
	end
	ActionsManager.handleResolution = newHandleResolution;
end

function checkTake1020(rRoll)
	if not rRoll or not rRoll.aDice then return; end
	
	if rRoll.bTake10 or rRoll.bTake20 then
		local nTargetVal = rRoll.bTake10 and 10 or 20;
		local bReplaced = false;
		
		for _, vDie in ipairs(rRoll.aDice) do
			if vDie.type == "d20" then
				vDie.result = nTargetVal;
				vDie.value = nTargetVal;
				bReplaced = true;
			end
		end
		
		if bReplaced then
			-- Recalculate total with the new d20 value
			rRoll.nTotal = ActionsManager.total(rRoll);
		end
	end
end
