-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	registerDiceRolls();
	registerOptions();
	DecalManager.setDefault("images/decals/stw_decal.jpg@Star Wars D20 Assets");
end

-- ===================================================================================================================
-- Adjusted
-- ToDo: Review die connections to damage
-- ===================================================================================================================
function registerDiceRolls()
	DiceRollManager.registerDamageTypeMode("critical");
	DiceRollManager.registerDamageTypeMode("precision");
	
	DiceRollManager.registerDamageKey();
	DiceRollManager.registerDamageTypeKey("acid", "life");
	DiceRollManager.registerDamageTypeKey("cold", "frost");
	DiceRollManager.registerDamageTypeKey("electricity", "lightning");
	
	DiceRollManager.registerDamageTypeKey("fire", "fire");
	DiceRollManager.registerDamageTypeKey("force", "arcane");
	DiceRollManager.registerDamageTypeKey("negative", "shadow");
	DiceRollManager.registerDamageTypeKey("positive", "light");
	DiceRollManager.registerDamageTypeKey("sonic", "storm");

	DiceRollManager.registerDamageTypeKey("bludgeoning");
	DiceRollManager.registerDamageTypeKey("piercing");
	DiceRollManager.registerDamageTypeKey("slashing");

	-- DiceRollManager.registerDamageTypeKey("adamantine");
	-- DiceRollManager.registerDamageTypeKey("cold iron");
	-- DiceRollManager.registerDamageTypeKey("silver");

	-- DiceRollManager.registerDamageTypeKey("epic");
	-- DiceRollManager.registerDamageTypeKey("magic");

	DiceRollManager.registerDamageTypeKey("energy", "fire");
	DiceRollManager.registerDamageTypeKey("ion", "lightning");
	
	DiceRollManager.registerHealKey();
	DiceRollManager.registerHealTypeKey("health", "light");
	DiceRollManager.registerHealTypeKey("temp", "water");
end

function registerOptions()
	OptionsManager.registerOption2("RMMT", true, "option_header_client", "option_label_RMMT", "option_entry_cycler", 
			{ labels = "option_val_on|option_val_multi", values = "on|multi", baselabel = "option_val_off", baseval = "off", default = "multi" });

	OptionsManager.registerOption2("SHRR", false, "option_header_game", "option_label_SHRR", "option_entry_cycler", 
			{ labels = "option_val_on|option_val_pc", values = "on|pc", baselabel = "option_val_off", baseval = "off", default = "on" });

	OptionsManager.registerOption2("INIT", false, "option_header_combat", "option_label_INIT", "option_entry_cycler", 
			{ labels = "option_val_on|option_val_group", values = "on|group", baselabel = "option_val_off", baseval = "off", default = "group" });
	OptionsManager.registerOption2("ANPC", false, "option_header_combat", "option_label_ANPC", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2("BARC", false, "option_header_combat", "option_label_BARC", "option_entry_cycler", 
			{ labels = "option_val_tiered", values = "tiered", baselabel = "option_val_standard", baseval = "", default = "" });
	OptionsManager.registerOption2("SHPC", false, "option_header_combat", "option_label_SHPC", "option_entry_cycler", 
			{ labels = "option_val_detailed|option_val_status", values = "detailed|status", baselabel = "option_val_off", baseval = "off", default = "detailed" });
	OptionsManager.registerOption2("SHNPC", false, "option_header_combat", "option_label_SHNPC", "option_entry_cycler", 
			{ labels = "option_val_detailed|option_val_status", values = "detailed|status", baselabel = "option_val_off", baseval = "off", default = "status" });

	OptionsManager.registerOption2("HRCC", false, "option_header_houserule", "option_label_HRCC", "option_entry_cycler", 
			{ labels = "option_val_on|option_val_npc", values = "on|npc", baselabel = "option_val_off", baseval = "off", default = "on" });
	OptionsManager.registerOption2("HRIR", false, "option_header_houserule", "option_label_HRIR", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2("HRNH", false, "option_header_houserule", "option_label_HRNH", "option_entry_cycler", 
			{ labels = "option_val_max|option_val_random", values = "max|random", baselabel = "option_val_standard", baseval = "off", default = "off" });
	OptionsManager.registerOption2("HRST", false, "option_header_houserule", "option_label_HRST", "option_entry_cycler", 
			{ labels = "option_val_all|option_val_friendly", values = "all|on", baselabel = "option_val_off", baseval = "off", default = "on" });
	OptionsManager.registerOption2("HRFC", false, "option_header_houserule", "option_label_HRFC", "option_entry_cycler", 
			{ labels = "option_val_fumbleandcrit|option_val_fumble|option_val_crit", values = "both|fumble|criticalhit", baselabel = "option_val_off", baseval = "", default = "" });
end
