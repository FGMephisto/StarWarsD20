-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars D20
--

function onInit() -- Adjusted
	registerOptions();
	DecalManager.setDefault("images/decals/stw_decal.jpg@Star_Wars_D20_Assets");
end

function registerOptions()
	-- Per User
	OptionsManager.registerStandardOption("RMMT");

	-- Game
	OptionsManager.registerStandardOption("SHRR");
	OptionsManager.registerOptionData({
		sKey = "AUTO_SPELL_FAILURE", sGroupRes = "option_header_game",
		tCustom = {
			labelsres = "option_val_ASF_prompt|option_val_ASF_auto",
			values = "prompt|auto",
			baselabelres = "option_val_off",
			baseval = "",
			default = "auto",
		},
	});

	-- Combat
	OptionsManager.registerStandardOption("INIT");
	OptionsManager.registerStandardOption("BARC");
	OptionsManager.registerStandardOption("SHPC");
	OptionsManager.registerStandardOption("SHNPC");
	OptionsManager.registerOptionData({	sKey = "ANPC", sGroupRes = "option_header_combat", });

	-- House Rules
	OptionsManager.registerStandardOption("HRFC");
	OptionsManager.registerStandardOption("HRIR");
	OptionsManager.registerStandardOption("HRNH");
	OptionsManager.registerStandardOption("HRST");
	OptionsManager.registerOptionData({
		sKey = "HRCC", sGroupRes = "option_header_houserule",
		tCustom = { labelsres = "option_val_on|option_val_npc", values = "on|npc", baselabelres = "option_val_off", baseval = "off", default = "on", },
	});
end
