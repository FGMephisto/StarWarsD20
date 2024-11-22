-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	ModifierManager.addModWindowPresets(_tModifierWindowPresets);
	ModifierManager.addKeyExclusionSets(_tModifierExclusionSets);

	for k,v in pairs(_tDataModuleSets) do
		for _,v2 in ipairs(v) do
			Desktop.addDataModuleSet(k, v2);
		end
	end
end

-- Shown in Modifiers window
-- NOTE: Set strings for "modifier_category_*" and "modifier_label_*"
-- Adjusted
-- ToDo: ATT_MULTISHOT / AUTO should come directly from the attack, not as a modifier
_tModifierWindowPresets =
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

-- Shown in Campaign Setup window
_tDataModuleSets = 
{
	["client"] =
	{
		{
			name = "Star Wars D20",
			modules =
			{
				{ name = "Star Wars D20 Assets", displayname = "Star Wars D20 Assets" },
			},
		},
	},
	["host"] =
	{
		{
			name = "Star Wars D20",
			modules =
			{
				{ name = "Star Wars D20 Assets", displayname = "Star Wars D20 Assets" },
			},
		},
	},
};
