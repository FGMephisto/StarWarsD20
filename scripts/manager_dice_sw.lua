-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local _tActorDiceSystemRules = {
	-- ["dragon_red"] = { 
		-- sName = "Red Dragon|Red Dragon, Adult|Red Dragon, Ancient|Red Dragon, Great wyrm|Red Dragon, Juvenile|Red Dragon, Mature adult|Red Dragon, Old|Red Dragon, Very old|Red Dragon, Very young|Red Dragon, Wyrm|Red Dragon, Wyrmling|Red Dragon, Young|Red Dragon, Young adult|Skeleton, Young Adult Red Dragon",
		-- sDefaultKey = "dragon_red", 
	-- },
	-- ["dragon_blue"] = { 
		-- sName = "Blue Dragon|Blue Dragon, Adult|Blue Dragon, Ancient|Blue Dragon, Great wyrm|Blue Dragon, Juvenile|Blue Dragon, Mature adult|Blue Dragon, Old|Blue Dragon, Very old|Blue Dragon, Very young|Blue Dragon, Wyrm|Blue Dragon, Wyrmling|Blue Dragon, Young|Blue Dragon, Young adult",
		-- sDefaultKey = "dragon_blue", 
	-- },
	-- ["dragon_green"] = { 
		-- sName = "Green Dragon|Green Dragon, Adult|Green Dragon, Ancient|Green Dragon, Great wyrm|Green Dragon, Juvenile|Green Dragon, Mature adult|Green Dragon, Old|Green Dragon, Very old|Green Dragon, Very young|Green Dragon, Wyrm|Green Dragon, Wyrmling|Green Dragon, Young|Green Dragon, Young adult",
		-- sDefaultKey = "dragon_green", 
	-- },
	-- ["dragon_black"] = { 
		-- sName = "Black Dragon|Black Dragon, Adult|Black Dragon, Ancient|Black Dragon, Great wyrm|Black Dragon, Juvenile|Black Dragon, Mature adult|Black Dragon, Old|Black Dragon, Very old|Black Dragon, Very young|Black Dragon, Wyrm|Black Dragon, Wyrmling|Black Dragon, Young|Black Dragon, Young adult",
		-- sDefaultKey = "dragon_black", 
	-- },
	-- ["dragon_white"] = { 
		-- sName = "White Dragon|White Dragon, Adult|White Dragon, Ancient|White Dragon, Great wyrm|White Dragon, Juvenile|White Dragon, Mature adult|White Dragon, Old|White Dragon, Very old|White Dragon, Very young|White Dragon, Wyrm|White Dragon, Wyrmling|White Dragon, Young|White Dragon, Young adult",
		-- sDefaultKey = "dragon_white", 
	-- },
	-- ["dragon_gold"] = { 
		-- sName = "Gold Dragon|Gold Dragon, Adult|Gold Dragon, Ancient|Gold Dragon, Great wyrm|Gold Dragon, Juvenile|Gold Dragon, Mature adult|Gold Dragon, Old|Gold Dragon, Very old|Gold Dragon, Very young|Gold Dragon, Wyrm|Gold Dragon, Wyrmling|Gold Dragon, Young|Gold Dragon, Young adult",
		-- sDefaultKey = "dragon_gold", 
	-- },
	-- ["dragon_silver"] = { 
		-- sName = "Silver Dragon|Silver Dragon, Adult|Silver Dragon, Ancient|Silver Dragon, Great wyrm|Silver Dragon, Juvenile|Silver Dragon, Mature adult|Silver Dragon, Old|Silver Dragon, Very old|Silver Dragon, Very young|Silver Dragon, Wyrm|Silver Dragon, Wyrmling|Silver Dragon, Young|Silver Dragon, Young adult",
		-- sDefaultKey = "dragon_silver", 
	-- },
	-- ["dragon_bronze"] = { 
		-- sName = "Bronze Dragon|Bronze Dragon, Adult|Bronze Dragon, Ancient|Bronze Dragon, Great wyrm|Bronze Dragon, Juvenile|Bronze Dragon, Mature adult|Bronze Dragon, Old|Bronze Dragon, Very old|Bronze Dragon, Very young|Bronze Dragon, Wyrm|Bronze Dragon, Wyrmling|Bronze Dragon, Young|Bronze Dragon, Young adult",
		-- sDefaultKey = "dragon_bronze", 
	-- },
	-- ["dragon_copper"] = { 
		-- sName = "Copper Dragon|Copper Dragon, Adult|Copper Dragon, Ancient|Copper Dragon, Great wyrm|Copper Dragon, Juvenile|Copper Dragon, Mature adult|Copper Dragon, Old|Copper Dragon, Very old|Copper Dragon, Very young|Copper Dragon, Wyrm|Copper Dragon, Wyrmling|Copper Dragon, Young|Copper Dragon, Young adult",
		-- sDefaultKey = "dragon_copper", 
	-- },
	-- ["dragon_brass"] = { 
		-- sName = "Brass Dragon|Brass Dragon, Adult|Brass Dragon, Ancient|Brass Dragon, Great wyrm|Brass Dragon, Juvenile|Brass Dragon, Mature adult|Brass Dragon, Old|Brass Dragon, Very old|Brass Dragon, Very young|Brass Dragon, Wyrm|Brass Dragon, Wyrmling|Brass Dragon, Young|Brass Dragon, Young adult",
		-- sDefaultKey = "dragon_brass", 
	-- },
	-- ["elemental_air"] = { 
		-- sName = "Air Elemental|Air Elemental, Elder|Air Elemental, Greater|Air Elemental, Huge|Air Elemental, Large|Air Elemental, Medium|Air Elemental, Small|Mephit, Air",
		-- sDefaultKey = "elemental_air", 
	-- },
	-- ["elemental_earth"] = { 
		-- sName = "Earth Elemental|Earth Elemental, Elder|Earth Elemental, Greater|Earth Elemental, Huge|Earth Elemental, Large|Earth Elemental, Medium|Earth Elemental, Small|Mephit, Earth",
		-- sDefaultKey = "elemental_earth", 
	-- },
	-- ["elemental_fire"] = { 
		-- sName = "Fire Elemental|Elemental, Fire, Huge|Elemental, Fire, Large|Elemental, Fire, Small|Fire Elemental, Elder|Fire Elemental, Greater|Fire Elemental, Medium|Mephit, Fire|Azer|Salamander, Average|Salamander, Flamebrother|Salamander, Noble|Genie, Efreeti|Hellhound|Hellhound, Nessian Warhound",
		-- sDefaultKey = "elemental_fire", 
	-- },
	-- ["elemental_water"] = { 
		-- sName = "Water Elemental|Elemental, Water, Elder|Elemental, Water, Huge|Elemental, Water, Medium|Elemental, Water, Small|Mephit, Water|Water Elemental, Greater|Water Elemental, Large|Devil, Ice (Gelugon)",
		-- sDefaultKey = "elemental_water", 
	-- },
	-- ["demonic"] = { 
		-- sName = "Demonic|Demon, Babau|Demon, Balor|Demon, Bebilith|Demon, Dretch|Demon, Glabrezu|Demon, Hezrou|Demon, Marilith|Demon, Nalfeshnee|Demon, Quasit|Demon, Retriever|Demon, Succubus|Demon, Vrock|Devil, Barbed (Hamatula)|Devil, Bearded (Barbazu)|Devil, Bone (Osyluth)|Devil, Chain (Kyton)|Devil, Erinyes|Devil, Hellcat (Bezekira)|Devil, Horned (Cornugon)|Devil, Imp|Devil, Lemure|Devil, Pit Fiend",
		-- sDefaultKey = "demonic", 
	-- },
	-- ["celestial"] = { 
		-- sName = "Celestial|Angel, Astral Deva|Angel, Planetar|Angel, Solar|Archon, Hound|Archon, Hound, Hero, 11th-Level Paladin|Archon, Lantern|Archon, Trumpet",
		-- sDefaultKey = "celestial", 
	-- },
};
local _tActorSystemDefaults = {
	-- ["dragon_red"] = {
		-- { diceskin = 282 }
	-- },
	-- ["dragon_blue"] = {
		-- { diceskin = 283 }
	-- },
	-- ["dragon_green"] = {
		-- { diceskin = 284 }
	-- },
	-- ["dragon_black"] = {
		-- { diceskin = 285 }
	-- },
	-- ["dragon_white"] = {
		-- { diceskin = 286 }
	-- },
	-- ["dragon_gold"] = {
		-- { diceskin = 287 }
	-- },
	-- ["dragon_silver"] = {
		-- { diceskin = 288 }
	-- },
	-- ["dragon_bronze"] = {
		-- { diceskin = 289 }
	-- },
	-- ["dragon_copper"] = {
		-- { diceskin = 290 }
	-- },
	-- ["dragon_brass"] = {
		-- { diceskin = 291 }
	-- },
	-- ["elemental_air"] = {
		-- { diceskin = 108 }
	-- },
	-- ["elemental_earth"] = {
		-- { diceskin = 107 }
	-- },
	-- ["elemental_fire"] = {
		-- { diceskin = 106 }
	-- },
	-- ["elemental_water"] = {
		-- { diceskin = 109 }
	-- },
	-- ["demonic"] = {
		-- { diceskin = 270 },
		-- { diceskin = 0, dicebodycolor="FF000000", dicetextcolor="FFFF000" }
	-- },
	-- ["celestial"] = {
		-- { diceskin = 262 }
	-- },		
};
local _tActorTypeDefaults = {
	-- ["aberration"] = {
		-- { diceskin = 261 }
	-- },
	["animal"] = {
		{ diceskin = 269 },
		{ diceskin = 95 }
	},
	-- ["construct"] = {
		-- { diceskin = 265 }
	-- },
	-- ["elemental"] = {
		-- { diceskin = 108 }
	-- },
	-- ["fey"] = {
		-- { diceskin = 263 }
	-- },
	-- ["giant"] = {
		-- { diceskin = 267 }
	-- },
	-- ["ooze"] = {
		-- { diceskin = 266 }
	-- },
	["plant"] = {
		{ diceskin = 268 }
	},
	-- ["undead"] = {
		-- { diceskin = 260 },
		-- { diceskin = 101 }
	-- },
};

function onInit()
	DiceRollManager.registerActorSupportDnD();
	DiceManager35E.registerActorTypeDefaults();
	DiceManager35E.registerActorSystemDefaults();
	DiceManager35E.registerActorSystemRules();

	DiceManager35E.registerActions();
end

-- Adjusted
function registerActions()
	DiceRollManager.registerDamageTypeMode("critical");
	-- DiceRollManager.registerDamageTypeMode("precision");
	
	DiceRollManager.registerDamageKey();
	DiceRollManager.registerDamageTypeKey("acid", "life");
	DiceRollManager.registerDamageTypeKey("cold", "frost");
	DiceRollManager.registerDamageTypeKey("electricity", "lightning");
	DiceRollManager.registerDamageTypeKey("fire", "fire");
	DiceRollManager.registerDamageTypeKey("force", "arcane");
	-- DiceRollManager.registerDamageTypeKey("negative", "shadow");
	-- DiceRollManager.registerDamageTypeKey("positive", "light");
	DiceRollManager.registerDamageTypeKey("sonic", "storm");
	DiceRollManager.registerDamageTypeKey("energy", "fire");
	DiceRollManager.registerDamageTypeKey("ion", "lightning");

	DiceRollManager.registerDamageTypeKey("bludgeoning");
	DiceRollManager.registerDamageTypeKey("piercing");
	DiceRollManager.registerDamageTypeKey("slashing");

	-- DiceRollManager.registerDamageTypeKey("adamantine");
	-- DiceRollManager.registerDamageTypeKey("cold iron");
	-- DiceRollManager.registerDamageTypeKey("silver");

	-- DiceRollManager.registerDamageTypeKey("epic");
	-- DiceRollManager.registerDamageTypeKey("magic");

	DiceRollManager.registerHealKey();
	DiceRollManager.registerHealTypeKey("health", "light");
	DiceRollManager.registerHealTypeKey("temp", "water");
end

function registerActorTypeDefaults()
	for k,v in pairs(_tActorTypeDefaults) do
		DiceRollManager.setDiceSkinDefaults(k, v);
	end
end
function registerActorSystemDefaults()
	for k,v in pairs(_tActorSystemDefaults) do
		DiceRollManager.setDiceSkinDefaults(k, v);
	end
end
function registerActorSystemRules()
	for k,v in pairs(_tActorDiceSystemRules) do
		DiceRollManager.setActorSystem(k, v);
	end
end