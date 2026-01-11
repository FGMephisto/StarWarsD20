-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	CampaignSetupManager.addAutoLoadRules(_tAutoLoadRules);
	CampaignSetupManager.addModuleSetsByMode(_tDataModuleSets);

	ModifierManager.addModWindowPresets(_tModifierWindowPresets);
	ModifierManager.addKeyExclusionSets(_tModifierExclusionSets);
end

_tAutoLoadRules = {
	-- { key = "PHB", load = { "3.5E Basic Rules", "3.5E Spells", }, playerload = { "3.5E Basic Rules", "3.5E Spells", }, },
	-- { key = "DMG", load = { "3.5E Magic Items", "3.5E Magic Items", }, },
	-- { key = "MM", load = { "3.5E Monsters", }, },
};
_tDataModuleSets = 
-- {
	-- ["client"] =
	-- {
		-- {
			-- name = "3.5E - SRD",
			-- modules =
			-- {
				-- { name = "3.5E Basic Rules" },
				-- { name = "3.5E Spells" },
			-- },
		-- },
	-- },
	-- ["host"] =
	-- {
		-- {
			-- name = "3.5E - SRD",
			-- modules =
			-- {
				-- { name = "3.5E Basic Rules" },
				-- { name = "3.5E Magic Items" },
				-- { name = "3.5E Monsters" },
				-- { name = "3.5E Spells" },
			-- },
		-- },
	-- },
};


-- Shown in Modifiers window
-- NOTE: Set strings for "modifier_category_*" and "modifier_label_*"
-- ToDo: ATT_MULTISHOT / AUTO should come directly from the attack, not as a modifier
_tModifierWindowPresets = -- Adjusted
{
	{ 
		sCategory = "attack",
		tPresets = 
		{
			"ATT_TCH",
			-- "DEF_PCOVER",
			"ATT_FF",
			-- "DEF_COVER",
			"ATT_OPP",
			"ATT_MULTIFIRE",
			"ATT_MULTISHOT",
			"ATT_RAPIDSHOT",
			"ATT_AUTOFIRE",
			"ATT_PBLANK",
			"ATT_ITMELEE",
			"ATT_CHARGE",
			"ATT_HGROUND",
			"ATT_FLANK",
			"ATT_PRONE",
			"ATT_CONC"
		},
	},
	{ 
		sCategory = "defense",
		tPresets = 
		{
			"DEF_MCOVER",
			"DEF_PCOVER",
			"DEF_COVER",
			"DEF_SCOVER",
			"DEF_DODGE",
			"DEF_KNEELING",
			"DEF_PRONE",
			"DEF_RUN",
			"DEF_PINNED",
			"DEF_MCONC",
			"DEF_PCONC",
			"DEF_CONC",
			"DEF_SCONC",
			"DEF_TCONC",
		},
	},
	{ 
		sCategory = "damage",
		tPresets = { 
			"DMG_CRIT",
			"DMG_HALF",
		}
	},
};

-- ToDo: ATT_MULTISHOT / AUTO should come directly from the attack, not as a modifier
_tModifierExclusionSets =
{
	{ "DEF_PCOVER", "DEF_COVER", "DEF_SCOVER" },
	{ "ATT_MULTISHOT", "ATT_AUTOFIRE" },
	{ "DEF_MCOVER", "DEF_PCOVER", "DEF_COVER", "DEF_SCOVER" },
	{ "DEF_KNEELING", "DEF_PRONE", "DEF_RUN", "DEF_PINNED" },
	{ "DEF_DODGE", "DEF_KNEELING", "DEF_PRONE" },
	{ "DEF_CONC", "DEF_TCONC", "DEF_MCONC", "DEF_PCONC", "DEF_SCONC" },
};