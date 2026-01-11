-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
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

currencies = { -- Adjusted
	{ name = "Credits", weight = 0.0, value = 1 },
};
currencyDefault = "Credits";

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
	-- ["spell_darkness"] = {
		-- sColor = "FF000000",
		-- nBright = 4,
		-- nDim = 4,
		-- nDuration = 100,
	-- },
	-- ["spell_daylight"] = {
		-- sColor = "FFFFF7E6",
		-- nBright = 12,
		-- nDim = 24,
		-- nDuration = 300,
	-- },
	-- ["spell_light"] = {
		-- sColor = "FFFFF3E1",
		-- nBright = 4,
		-- nDim = 8,
		-- nDuration = 100,
	-- },
};

function onInit() -- Adjusted
	CharEncumbranceManager.addStandardCalc("Star Wars D20");
	CombatListManager.registerStandardInitSupport();
	ImageDeathMarkerManager.registerStandardDeathMarkersDnD();
	SoundsetManager.registerStandardSettingsCastAndAttack();
	SoundsetManager.setRecordTypeDropCallback("spell", SoundsetManager.handleStandardSpellDrop);

	if not DataCommon.isPFRPG() then
		VisionManager.addVisionField("specialqualities");
	end
	VisionManager.addLightDefaults(tokenLightDefaults);

	-- Languages
	languages = {
		-- [Interface.getString("language_value_abyssal")] = "Infernal",
		-- [Interface.getString("language_value_aquan")] = "Elven",
		-- [Interface.getString("language_value_auran")] = "Draconic",
		-- [Interface.getString("language_value_celestial")] = "Celestial",
		-- [Interface.getString("language_value_common")] = "",
		-- [Interface.getString("language_value_draconic")] = "Draconic",
		-- [Interface.getString("language_value_druidic")] = "Elven",
		-- [Interface.getString("language_value_dwarven")] = "Dwarven",
		-- [Interface.getString("language_value_elven")] = "Elven",
		-- [Interface.getString("language_value_giant")] = "Dwarven",
		-- [Interface.getString("language_value_gnoll")] = "",
		-- [Interface.getString("language_value_gnome")] = "Dwarven",
		-- [Interface.getString("language_value_goblin")] = "Dwarven",
		-- [Interface.getString("language_value_halfling")] = "",
		-- [Interface.getString("language_value_ignan")] = "Draconic",
		-- [Interface.getString("language_value_infernal")] = "Infernal",
		-- [Interface.getString("language_value_orc")] = "Dwarven",
		-- [Interface.getString("language_value_sylvan")] = "Elven",
		-- [Interface.getString("language_value_terran")] = "Dwarven",
		-- [Interface.getString("language_value_undercommon")] = "Elven",
		[Interface.getString("language_value_Basic")] = "Basic",
		[Interface.getString("language_value_Binary")] = "Binary",
		[Interface.getString("language_value_Bothese")] = "Bothese",
		[Interface.getString("language_value_Cerean")] = "Cerean",
		[Interface.getString("language_value_Dosh")] = "Dosh",
		[Interface.getString("language_value_Dug")] = "Dug",
		[Interface.getString("language_value_Durese")] = "Durese",
		[Interface.getString("language_value_Ewokese")] = "Ewokese",
		[Interface.getString("language_value_Gamorrean")] = "Gamorrean",
		[Interface.getString("language_value_Geonosian")] = "Geonosian",
		[Interface.getString("language_value_Gungan")] = "Gungan",
		[Interface.getString("language_value_Huttese")] = "Huttese",
		[Interface.getString("language_value_Ithorese")] = "Ithorese",
		[Interface.getString("language_value_Jawa_Trade")] = "Jawa Trade Language",
		[Interface.getString("language_value_Kaminoan")] = "Kaminoan",
		[Interface.getString("language_value_Kel_Dor")] = "Kel Dor",
		[Interface.getString("language_value_Mon_Calamarian")] = "Mon Calamarian",
		[Interface.getString("language_value_Neimoidian")] = "Neimoidian",
		[Interface.getString("language_value_Quarrenese")] = "Quarrenese",
		[Interface.getString("language_value_Rodese")] = "Rodese",
		[Interface.getString("language_value_Ryl")] = "Ryl",
		[Interface.getString("language_value_Sith")] = "Sith",
		[Interface.getString("language_value_Sullustese")] = "Sullustese",
		[Interface.getString("language_value_Yuuzhan_Vong")] = "Yuuzhan Vong",
		[Interface.getString("language_value_Zabrak")] = "Zabrak",
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
		-- [Interface.getString("language_value_celestial")] = "Celestial",
		-- [Interface.getString("language_value_draconic")] = "Draconic",
		-- [Interface.getString("language_value_dwarven")] = "Dwarven",
		-- [Interface.getString("language_value_elven")] = "Elven",
		-- [Interface.getString("language_value_infernal")] = "Infernal",
		[Interface.getString("language_value_Binary")] = "Infernal",
		[Interface.getString("language_value_Bothese")] = "Infernal",
		[Interface.getString("language_value_Cerean")] = "Infernal",
		[Interface.getString("language_value_Dosh")] = "Infernal",
		[Interface.getString("language_value_Dug")] = "Infernal",
		[Interface.getString("language_value_Durese")] = "Infernal",
		[Interface.getString("language_value_Ewokese")] = "Infernal",
		[Interface.getString("language_value_Gamorrean")] = "Infernal",
		[Interface.getString("language_value_Geonosian")] = "Infernal",
		[Interface.getString("language_value_Gungan")] = "Infernal",
		[Interface.getString("language_value_Huttese")] = "Infernal",
		[Interface.getString("language_value_Ithorese")] = "Infernal",
		[Interface.getString("language_value_Jawa_Trade")] = "Infernal",
		[Interface.getString("language_value_Kaminoan")] = "Infernal",
		[Interface.getString("language_value_Kel_Dor")] = "Infernal",
		[Interface.getString("language_value_Mon_Calamarian")] = "Infernal",
		[Interface.getString("language_value_Neimoidian")] = "Infernal",
		[Interface.getString("language_value_Quarrenese")] = "Infernal",
		[Interface.getString("language_value_Rodese")] = "Infernal",
		[Interface.getString("language_value_Ryl")] = "Infernal",
		[Interface.getString("language_value_Sith")] = "Infernal",
		[Interface.getString("language_value_Sullustese")] = "Infernal",
		[Interface.getString("language_value_Yuuzhan_Vong")] = "Infernal",
		[Interface.getString("language_value_Zabrak")] = "Infernal",
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
		rRoll.aDice = DiceRollManager.getActorDice({ "d20" }, rActor);
		rRoll.nMod = ActorManager35E.getAbilityBonus(rActor, "constitution");
		
		local nHP = 0;
		local nWounds = 0;
		local nodeActor = ActorManager.getCreatureNode(rActor);
		if nodeActor then
			if ActorManager.isPC(rActor) then
				nHP = DB.getValue(nodeActor, "hp.total", 0);
				nWounds = DB.getValue(nodeActor, "hp.wounds", 0);
			else
				nHP = DB.getValue(nodeActor, "hp", 0);
				nWounds = DB.getValue(nodeActor, "wounds", 0);
			end
		end
			
		if nHP > 0 and nWounds > nHP then
			rRoll.sDesc = string.format("%s [at %+d]", rRoll.sDesc, (nHP - nWounds));
			rRoll.nMod = rRoll.nMod + (nHP - nWounds);
		end
	else
		rRoll.aDice = DiceRollManager.getActorDice({ "d100" }, rActor);
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
		local rRoll = {
			sType = "concentration",
			sDesc = "[CONCENTRATION]",
		};
		rRoll.aDice = DiceRollManager.getActorDice({ "d20" }, rActor);
	
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

		if ActorManager.isPC(rActor) then
			nValue = CharManager.getSkillValue(rActor, sSkill);
		elseif ActorManager.isRecordType(rActor, "npc") then
			local nodeActor = ActorManager.getCreatureNode(rActor);
			if nodeActor then
				local sSkills = DB.getValue(nodeActor, "skills", "");
				local aSkillClauses = StringManager.split(sSkills, ",;\r\n", true);
				for i = 1, #aSkillClauses do
					local nStarts, nEnds, sLabel, sSign, sMod = string.find(aSkillClauses[i], "([%w%s%(%)]*[%w%(%)]+)%s*([%+%-–]?)(%d*)");
					if nStarts and string.lower(sSkill) == string.lower(sLabel) and sMod ~= "" then
						nValue = tonumber(sMod) or 0;
						if sSign == "-" or sSign == "–" then
							nValue = 0 - nValue;
						end
						break;
					end
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

