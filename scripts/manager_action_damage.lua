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
	GameManager.setOption("incorporeal", "3.5E");
	GameManager.setOption("metamagic", "3.5E");
	GameManager.setOption("negativehp", "3.5E");
	GameManager.setOption("nonlethal", "3.5E");
	GameManager.setOption("regeneration", "3.5E");
	GameManager.setOption("rest", "3.5E");

	ActionDamageD20.registerStandardDamageHealHandlers();

	ActionsManager.registerModHandler("stabilization", modStabilization);
	ActionsManager.registerResultHandler("stabilization", onStabilization);
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
