-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = true },
	["table"] = { },
	["effect"] = { sIcon = "action_effect", sTargeting = "all" },
	["attack"] = { sIcon = "action_attack", sTargeting = "each", bUseModStack = true },
	["grapple"] = { sIcon = "action_attack", sTargeting = "each", bUseModStack = true },
	["damage"] = { sIcon = "action_damage", sTargeting = "each", bUseModStack = true },
	["heal"] = { sIcon = "action_heal", sTargeting = "all", bUseModStack = true },
	["cast"] = { sTargeting = "each" },
	["castclc"] = { sTargeting = "each" },
	["castsave"] = { sTargeting = "each" },
	["clc"] = { sTargeting = "each", bUseModStack = true },
	["spellsave"] = { sTargeting = "each" },
	["spdamage"] = { sIcon = "action_damage", sTargeting = "all", bUseModStack = true },
	["skill"] = { bUseModStack = true },
	["init"] = { bUseModStack = true },
	["save"] = { bUseModStack = true },
	["ability"] = { bUseModStack = true },
	-- PF SPECIFIC
	["concentration"] = { bUseModStack = true },
	-- TRIGGERED
	["critconfirm"] = { sIcon = "action_attack" },
	["misschance"] = { },
	["stabilization"] = { },
};

targetactions = {
	"attack",
	"critconfirm",
	"grapple",
	"damage",
	"spdamage",
	"heal",
	"effect",
	"cast",
	"clc",
	"spellsave"
};

currencies = { 
	{ name = "PP", weight = 0.02, value = 10 },
	{ name = "GP", weight = 0.02, value = 1 },
	{ name = "SP", weight = 0.02, value = 0.1 },
	{ name = "CP", weight = 0.02, value = 0.01 },
};
currencyDefault = "GP";

tokenLightDefaults = {
	["candle"] = {
		sColor = "FFFFFCC3",
		nBright = 0,
		nDim = 1,
		sAnimType = "flicker",
		nAnimSpeed = 100,
		nDuration = 600,
	},
	["lamp"] = {
		sColor = "FFFFF3E1",
		nBright = 3,
		nDim = 6,
		sAnimType = "flicker",
		nAnimSpeed = 25,
		nDuration = 3600,
	},
	["torch"] = {
		sColor = "FFFFF3E1",
		nBright = 4,
		nDim = 8,
		sAnimType = "flicker",
		nAnimSpeed = 25,
		nDuration = 600,
	},
	["lantern"] = {
		sColor = "FFF9FEFF",
		nBright = 6,
		nDim = 12,
		nDuration = 3600,
	},
	["sunrod"] = {
		sColor = "FFFFF7E6",
		nBright = 6,
		nDim = 12,
		nDuration = 3600,
	},
	["spell_darkness"] = {
		sColor = "FF000000",
		nBright = 4,
		nDim = 4,
		nDuration = 100,
	},
	["spell_daylight"] = {
		sColor = "FFFFF7E6",
		nBright = 12,
		nDim = 24,
		nDuration = 300,
	},
	["spell_light"] = {
		sColor = "FFFFF3E1",
		nBright = 4,
		nDim = 8,
		nDuration = 100,
	},
};

function onInit()
	if not DataCommon.isPFRPG() then
		VisionManager.addVisionField("specialqualities");
	end
	VisionManager.addLightDefaults(tokenLightDefaults);

	-- Languages
	languages = {
		[Interface.getString("language_value_abyssal")] = "Infernal",
		[Interface.getString("language_value_aquan")] = "Elven",
		[Interface.getString("language_value_auran")] = "Draconic",
		[Interface.getString("language_value_celestial")] = "Celestial",
		[Interface.getString("language_value_common")] = "",
		[Interface.getString("language_value_draconic")] = "Draconic",
		[Interface.getString("language_value_druidic")] = "Elven",
		[Interface.getString("language_value_dwarven")] = "Dwarven",
		[Interface.getString("language_value_elven")] = "Elven",
		[Interface.getString("language_value_giant")] = "Dwarven",
		[Interface.getString("language_value_gnoll")] = "",
		[Interface.getString("language_value_gnome")] = "Dwarven",
		[Interface.getString("language_value_goblin")] = "Dwarven",
		[Interface.getString("language_value_halfling")] = "",
		[Interface.getString("language_value_ignan")] = "Draconic",
		[Interface.getString("language_value_infernal")] = "Infernal",
		[Interface.getString("language_value_orc")] = "Dwarven",
		[Interface.getString("language_value_sylvan")] = "Elven",
		[Interface.getString("language_value_terran")] = "Dwarven",
		[Interface.getString("language_value_undercommon")] = "Elven",
	}
	if DataCommon.isPFRPG() then
		-- languages[Interface.getString("language_value_aboleth")] = "";
		languages[Interface.getString("language_value_catfolk")] = "";
		languages[Interface.getString("language_value_grippli")] = "";
		-- languages[Interface.getString("language_value_samsaran")] = "";
		-- languages[Interface.getString("language_value_strix")] = "";
		-- languages[Interface.getString("language_value_tengu")] = "";
		languages[Interface.getString("language_value_vanaran")] = "";
		languages[Interface.getString("language_value_vishkanya")] = "";
		-- languages[Interface.getString("language_value_wayang")] = "";
	end
	languagefonts = {
		[Interface.getString("language_value_celestial")] = "Celestial",
		[Interface.getString("language_value_draconic")] = "Draconic",
		[Interface.getString("language_value_dwarven")] = "Dwarven",
		[Interface.getString("language_value_elven")] = "Elven",
		[Interface.getString("language_value_infernal")] = "Infernal",
	}

	if DataCommon.isPFRPG() then
		languages[Interface.getString("language_value_aklo")] = "";
	end
end

function getCharSelectDetailHost(nodeChar)
	local sValue = "";
	local nLevel = DB.getValue(nodeChar, "level", 0);
	if nLevel > 0 then
		sValue = "Level " .. math.floor(nLevel*100)*0.01;
	end
	return sValue;
end

function requestCharSelectDetailClient()
	return "name,#level";
end

function receiveCharSelectDetailClient(vDetails)
	return vDetails[1], "Level " .. math.floor(vDetails[2]*100)*0.01;
end

function getCharSelectDetailLocal(nodeLocal)
	local vDetails = {};
	table.insert(vDetails, DB.getValue(nodeLocal, "name", ""));
	table.insert(vDetails, DB.getValue(nodeLocal, "level", 0));
	return receiveCharSelectDetailClient(vDetails);
end

function getDistanceUnitsPerGrid()
	return 5;
end

function getDeathThreshold(rActor)
	local nDying = 10;

	if DataCommon.isPFRPG() then
		local nStat = ActorManager35E.getAbilityScore(rActor, "constitution");
		if nStat < 0 then
			nDying = 10;
		else
			nDying = nStat - ActorManager35E.getAbilityDamage(rActor, "constitution");
			if nDying < 1 then
				nDying = 1;
			end
		end
	end
	
	return nDying;
end

function getStabilizationRoll(rActor)
	local rRoll = { sType = "stabilization", sDesc = "[STABILIZATION]" };
	
	if DataCommon.isPFRPG() then
		rRoll.aDice = { "d20" };
		rRoll.nMod = ActorManager35E.getAbilityBonus(rActor, "constitution");
		
		local nHP = 0;
		local nWounds = 0;

		local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
		if sNodeType == "pc" then
			nHP = DB.getValue(nodeActor, "hp.total", 0);
			nWounds = DB.getValue(nodeActor, "hp.wounds", 0);
		elseif sNodeType == "ct" then
			nHP = DB.getValue(nodeActor, "hp", 0);
			nWounds = DB.getValue(nodeActor, "wounds", 0);
		end
			
		if nHP > 0 and nWounds > nHP then
			rRoll.sDesc = string.format("%s [at %+d]", rRoll.sDesc, (nHP - nWounds));
			rRoll.nMod = rRoll.nMod + (nHP - nWounds);
		end
	
	else
		rRoll.aDice = { "d100" };
		rRoll.nMod = 0;
	end
	
	return rRoll;
end

function modStabilization(rSource, rTarget, rRoll)
	if DataCommon.isPFRPG() then
		ActionAbility.modRoll(rSource, rTarget, rRoll);
	end
end

function getStabilizationResult(rRoll)
	local bSuccess = false;
	
	local nTotal = ActionsManager.total(rRoll);

	if DataCommon.isPFRPG() then
		local nFirstDie = 0;
		if #(rRoll.aDice) > 0 then
			nFirstDie = rRoll.aDice[1].result or 0;
		end
		
		if nFirstDie >= 20 or nTotal >= 10 then
			bSuccess = true;
		end
	else
		if nTotal <= 10 then
			bSuccess = true;
		end
	end
	
	return bSuccess;
end

function performConcentrationCheck(draginfo, rActor, nodeSpellClass)
	if DataCommon.isPFRPG() then
		local rRoll = { sType = "concentration", sDesc = "[CONCENTRATION]", aDice = { "d20" } };
	
		local sAbility = DB.getValue(nodeSpellClass, "dc.ability", "");
		local sAbilityEffect = DataCommon.ability_ltos[sAbility];
		if sAbilityEffect then
			rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
		end

		local nCL = DB.getValue(nodeSpellClass, "cl", 0);
		rRoll.nMod = nCL + ActorManager35E.getAbilityBonus(rActor, sAbility);
		
		local nCCMisc = DB.getValue(nodeSpellClass, "cc.misc", 0);
		if nCCMisc ~= 0 then
			rRoll.nMod = rRoll.nMod + nCCMisc;
			rRoll.sDesc = string.format("%s (Spell Class %+d)", rRoll.sDesc, nCCMisc);
		end
		
		ActionsManager.performAction(draginfo, rActor, rRoll);
	else
		local sSkill = "Concentration";
		local nValue = 0;

		local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
		if not nodeActor then
			return;
		end
		if sNodeType == "pc" then
			nValue = CharManager.getSkillValue(rActor, sSkill);
		elseif ActorManager.isRecordType(rActor, "npc") then
			local sSkills = DB.getValue(nodeActor, "skills", "");
			local aSkillClauses = StringManager.split(sSkills, ",;\r\n", true);
			for i = 1, #aSkillClauses do
				local nStarts, nEnds, sLabel, sSign, sMod = string.find(aSkillClauses[i], "([%w%s\(\)]*[%w\(\)]+)%s*([%+%-?]?)(%d*)");
				if nStarts and string.lower(sSkill) == string.lower(sLabel) and sMod ~= "" then
					nValue = tonumber(sMod) or 0;
					if sSign == "-" or sSign == "?" then
						nValue = 0 - nValue;
					end
					break;
				end
			end
		end
		
		local sExtra = nil;
		local nCCMisc = DB.getValue(nodeSpellClass, "cc.misc", 0);
		if nCCMisc ~= 0 then
			nValue = nValue + nCCMisc;
			sExtra = string.format("(Spell Class %+d)", nCCMisc);
		end
		
		ActionSkill.performRoll(draginfo, rActor, sSkill, nValue, nil, sExtra);
	end
end
