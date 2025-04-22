-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function isPFRPG()
	return false;
end

-- Abilities (database names)
abilities = {
	"strength",
	"dexterity",
	"constitution",
	"intelligence",
	"wisdom",
	"charisma"
};

ability_ltos = {
	["strength"] = "STR",
	["dexterity"] = "DEX",
	["constitution"] = "CON",
	["intelligence"] = "INT",
	["wisdom"] = "WIS",
	["charisma"] = "CHA"
};

ability_stol = {
	["STR"] = "strength",
	["DEX"] = "dexterity",
	["CON"] = "constitution",
	["INT"] = "intelligence",
	["WIS"] = "wisdom",
	["CHA"] = "charisma"
};

-- Saves
save_ltos = {
	["fortitude"] = "FORT",
	["reflex"] = "REF",
	["will"] = "WILL"
};

save_stol = {
	["FORT"] = "fortitude",
	["REF"] = "reflex",
	["WILL"] = "will"
};

-- Values for wound comparison
healthstatusfull = "healthy";
healthstatushalf = "bloodied";
healthstatuswounded = "wounded";

-- Values for alignment comparison
alignment_lawchaos = {
	["lawful"] = 1,
	["chaotic"] = 3,
	["l"] = 1,
	["c"] = 3,
	["lg"] = 1,
	["ln"] = 1,
	["le"] = 1,
	["cg"] = 3,
	["cn"] = 3,
	["ce"] = 3,
};
alignment_goodevil = {
	["good"] = 1,
	["evil"] = 3,
	["g"] = 1,
	["e"] = 3,
	["lg"] = 1,
	["le"] = 3,
	["ng"] = 1,
	["ne"] = 3,
	["cg"] = 1,
	["ce"] = 3,
};
alignment_neutral = "n";

-- Values for size comparison
creaturesize = {
	["fine"] = -4,
	["diminutive"] = -3,
	["tiny"] = -2,
	["small"] = -1,
	["medium"] = 0,
	["large"] = 1,
	["huge"] = 2,
	["gargantuan"] = 3,
	["colossal"] = 4,
	["f"] = -4,
	["d"] = -3,
	["t"] = -2,
	["s"] = -1,
	["m"] = 0,
	["l"] = 1,
	["h"] = 2,
	["g"] = 3,
	["c"] = 4,
};

-- Values for creature type comparison
creaturedefaulttype = "humanoid";
creaturehalftype = "half-";
creaturehalftypesubrace = "human";
-- NOTE: Multi-word types must come before single word types
creaturetype = { 
	-- "magical beast",
	-- "monstrous humanoid",
	-- "aberration",
	"animal",
	-- "construct",
	-- "dragon",
	-- "elemental",
	-- "fey",
	-- "giant",
	"humanoid",
	"ooze",
	-- "outsider",
	"plant",
	-- "undead",
	"vermin",
};
-- NOTE: Multi-word types must come before single word types
creaturesubtype = {
	-- "living construct", -- Monster subtypes
	-- "air",
	-- "angel",
	"aquatic",
	-- "archon",
	"augmented",
	-- "chaotic",
	-- "cold",
	-- "demon",
	-- "devil",
	-- "earth",
	-- "evil",
	-- "extraplanar",
	-- "fire",
	-- "good",
	-- "incorporeal",
	-- "lawful",
	-- "native",
	-- "psionic",
	"shapechanger",
	"swarm",
	"water",
	"aquatic", -- Humanoid subtypes
	-- "dwarf",
	-- "elf", 
	-- "gnoll",
	-- "gnome", 
	-- "goblinoid",
	-- "gnoll",
	-- "halfling",
	"human",
	-- "orc",
	"reptilian",
};

-- Values supported in effect conditionals
conditionaltags = {
};

-- Conditions supported in effect conditionals and for token widgets
-- NOTE: From rules, missing dying, staggered and disabled
conditions = {
	"blinded", 
	"climbing",
	"confused",
	"cowering",
	"dazed",
	"dazzled",
	"deafened", 
	"entangled", 
	"exhausted",
	"fascinated",
	"fatigued",
	"flat-footed",
	"frightened", 
	"grappled", 
	"helpless",
	"incorporeal", 
	"invisible", 
	"kneeling",
	"nauseated",
	"panicked", 
	"paralyzed",
	"petrified",
	"pinned", 
	"prone", 
	"rebuked",
	"running",
	"shaken", 
	"sickened", 
	"sitting",
	"slowed", 
	"squeezing", 
	"stable", 
	"stunned",
	"turned",
	"unconscious"
};

-- Bonus/penalty effect types for token widgets
bonuscomps = {
	"INIT",
	"ABIL",
	"AC",
	"ATK",
	"CMB",
	"CMD",
	"DMG",
	"DMGS",
	"HEAL",
	"SAVE",
	"SKILL",
	"STR",
	"CON",
	"DEX",
	"INT",
	"WIS",
	"CHA",
	"FORT",
	"REF",
	"WILL"
};

-- Condition effect types for token widgets
condcomps = {
	["blinded"] = "cond_blinded",
	["confused"] = "cond_confused",
	["cowering"] = "cond_frightened",
	["dazed"] = "cond_dazed",
	["dazzled"] = "cond_dazed",
	["deafened"] = "cond_deafened",
	["entangled"] = "cond_restrained",
	["exhausted"] = "cond_weakened",
	["fascinated"] = "cond_charmed",
	["fatigued"] = "cond_weakened",
	["flat-footed"] = "cond_surprised",
	["flatfooted"] = "cond_surprised",
	["frightened"] = "cond_frightened",
	["grappled"] = "cond_grappled",
	["helpless"] = "cond_helpless",
	["incorporeal"] = "cond_incorporeal",
	["invisible"] = "cond_invisible",
	["nauseated"] = "cond_sickened",
	["panicked"] = "cond_frightened",
	["paralyzed"] = "cond_paralyzed",
	["petrified"] = "cond_paralyzed",
	["pinned"] = "cond_pinned",
	["prone"] = "cond_prone",
	["rebuked"] = "cond_turned",
	["shaken"] = "cond_frightened",
	["sickened"] = "cond_sickened",
	["slowed"] = "cond_slowed",
	["stunned"] = "cond_stunned",
	["turned"] = "cond_turned",
	["unconscious"] = "cond_unconscious",
	-- Similar to conditions
	["ca"] = "cond_advantage",
	["grantca"] = "cond_disadvantage",
	["conc"] = "cond_conceal",
	["tconc"] = "cond_conceal",
	["cover"] = "cond_cover",
	["scover"] = "cond_cover",
};

-- Other visible effect types for token widgets
othercomps = {
	["CONC"] = "cond_conceal",
	["TCONC"] = "cond_conceal",
	["COVER"] = "cond_cover",
	["SCOVER"] = "cond_cover",
	["NLVL"] = "cond_penalty",
	["IMMUNE"] = "cond_immune",
	["RESIST"] = "cond_resistance",
	["VULN"] = "cond_vulnerable",
	["REGEN"] = "cond_regeneration",
	["FHEAL"] = "cond_regeneration",
	["DMGO"] = "cond_bleed",
};

-- Effect components which can be targeted
targetableeffectcomps = {
	"CONC",
	"TCONC",
	"COVER",
	"SCOVER",
	"AC",
	"CMD",
	"SAVE",
	"ATK",
	"CMB",
	"DMG",
	"IMMUNE",
	"VULN",
	"RESIST"
};

connectors = {
	"and",
	"or"
};

-- Range types supported
rangetypes = {
	"melee",
	"ranged"
};

-- Damage types supported
energytypes = {
	"acid",  		-- ENERGY DAMAGE TYPES
	"cold",
	"electricity",
	"fire",
	"sonic",
	"force",  		-- OTHER SPELL DAMAGE TYPES
	-- "positive",
	-- "negative",
	"energy",
	"ion",
};

immunetypes = {
	"acid",  		-- ENERGY DAMAGE TYPES
	"cold",
	"electricity",
	"fire",
	"sonic",
	-- "nonlethal",	-- SPECIAL DAMAGE TYPES
	"critical",
	"poison",		-- OTHER IMMUNITY TYPES
	-- "sleep",
	-- "paralysis",
	-- "petrification",
	-- "charm",
	-- "sleep",
	-- "fear",
	-- "disease",
	-- "mind-affecting",
	"force",
	"energy",
	"ion",
};

dmgtypes = {
	"acid",  		-- ENERGY DAMAGE TYPES
	"cold",
	"electricity",
	"fire",
	"sonic",
	"force",  		-- OTHER SPELL DAMAGE TYPES
	-- "positive",
	-- "negative",
	-- "adamantine", 	-- WEAPON PROPERTY DAMAGE TYPES
	"bludgeoning",
	-- "cold iron",
	-- "epic",
	-- "magic",
	"piercing",
	-- "silver",
	"slashing",
	-- "chaotic",		-- ALIGNMENT DAMAGE TYPES
	-- "evil",
	-- "good",
	-- "lawful",
	-- "nonlethal",	-- SPECIAL DAMAGE TYPES
	-- "spell",
	"critical",
	-- "precision",
	"energy",
	"ion",
};

basicdmgtypes = {
	"acid",  		-- ENERGY DAMAGE TYPES
	"cold",
	"electricity",
	"energy",
	"fire",
	"sonic",
	"force",  		-- OTHER SPELL DAMAGE TYPES
	"positive",
	"negative",
	"bludgeoning", 	-- WEAPON PROPERTY DAMAGE TYPES
	"piercing",
	"slashing",
	"ion",
};

specialdmgtypes = {
	-- "nonlethal",
	-- "spell",
	"critical",
	-- "precision",
};

-- Bonus types supported in power descriptions
bonustypes = {
	-- "alchemical",
	"armor",
	"circumstance",
	"competence",
	"deflection",
	"dodge",
	"enhancement",
	"insight",
	"luck",
	"morale",
	"natural",
	"profane",
	"racial",
	"resistance",
	-- "sacred",
	-- "shield",
	"size",
	"trait",
};

stackablebonustypes = {
	"circumstance",
	"dodge"
};

-- Armor class bonus types
-- (Map text types to internal types)
actypes = {
	["dex"] = "dex",
	["armor"] = "armor",
	["shield"] = "shield",
	["natural"] = "natural",
	["dodge"] = "dodge",
	["deflection"] = "deflection",
	["size"] = "size",
};

acarmormatch = {
	-- "padded",
	-- "padded armor",
	-- "padded barding",
	-- "leather",
	-- "leather armor",
	-- "leather barding",
	-- "studded leather",
	-- "studded leather armor",
	-- "studded leather barding",
	-- "chain shirt",
	-- "chain shirt barding",
	-- "hide",
	-- "hide armor",
	-- "hide barding",
	-- "scale mail",
	-- "scale mail barding",
	-- "chainmail",
	-- "chainmail barding",
	-- "breastplate",
	-- "breastplate barding",
	-- "splint mail",
	-- "splint mail barding",
	-- "banded mail",
	-- "banded mail barding",
	-- "half-plate",
	-- "half-plate armor",
	-- "half-plate barding",
	-- "full plate",
	-- "full plate armor",
	-- "full plate barding",
	-- "plate barding",
	-- "bracers of armor",
	-- "mithral chain shirt",
	"Blast helmet, vest",
	"Combat jumpsuit",
	"Padded flight suit",
	"Armored flight suit",
	"Battle armor, padded",
	"Battle armor, medium",
	"Armored spacesuit",
	"Battle armor, heavy",
	"Corellian powersuit",
	"Stormtrooper armor",
	"Battleframe",
};

acshieldmatch = {
	-- "buckler",
	-- "light shield",
	-- "light wooden shield",
	-- "light steel shield",
	-- "heavy shield",
	-- "heavy wooden shield",
	-- "heavy steel shield",
	-- "tower shield",
};

acdeflectionmatch = {
	-- "ring of protection"
};

-- Spell effects supported in spell descriptions
spelleffects = {
	"blinded",
	"confused",
	"cowering",
	"dazed",
	"dazzled",
	"deafened",
	"entangled",
	"exhausted",
	"fascinated",
	"frightened",
	"helpless",
	"invisible",
	"panicked",
	"paralyzed",
	"shaken",
	"sickened",
	"slowed",
	"stunned",
	"unconscious"
};

-- NPC damage properties
weapondmgtypes = {
	-- ["axe"] = "slashing",
	-- ["battleaxe"] = "slashing",
	-- ["bolas"] = "bludgeoning,nonlethal",
	-- ["chain"] = "piercing",
	-- ["club"] = "bludgeoning",
	-- ["crossbow"] = "piercing",
	-- ["dagger"] = "piercing,slashing",
	-- ["dart"] = "piercing",
	-- ["falchion"] = "slashing",
	-- ["flail"] = "bludgeoning",
	-- ["glaive"] = "slashing",
	-- ["greataxe"] = "slashing",
	-- ["greatclub"] = "bludgeoning",
	-- ["greatsword"] = "slashing",
	-- ["guisarme"] = "slashing",
	-- ["halberd"] = "piercing,slashing",
	-- ["hammer"] = "bludgeoning",
	-- ["handaxe"] = "slashing",
	-- ["javelin"] = "piercing",
	-- ["kama"] = "slashing",
	-- ["kukri"] = "slashing",
	-- ["lance"] = "piercing",
	-- ["longbow"] = "piercing",
	-- ["longspear"] = "piercing",
	-- ["longsword"] = "slashing",
	-- ["mace"] = "bludgeoning",
	-- ["morningstar"] = "bludgeoning,piercing",
	-- ["nunchaku"] = "bludgeoning",
	-- ["pick"] = "piercing",
	-- ["quarterstaff"] = "bludgeoning",
	-- ["ranseur"] = "piercing",
	-- ["rapier"] = "piercing",
	-- ["sai"] = "bludgeoning",
	-- ["sap"] = "bludgeoning,nonlethal",
	-- ["scimitar"] = "slashing",
	-- ["scythe"] = "piercing,slashing",
	-- ["shortbow"] = "piercing",
	-- ["shortspear"] = "piercing",
	-- ["shuriken"] = "piercing",
	-- ["siangham"] = "piercing",
	-- ["sickle"] = "slashing",
	-- ["sling"] = "bludgeoning",
	-- ["spear"] = "piercing",
	-- ["sword"] = {["short"] = "piercing", ["*"] = "slashing"},
	-- ["trident"] = "piercing",
	-- ["urgrosh"] = "piercing,slashing",
	-- ["waraxe"] = "slashing",
	-- ["warhammer"] = "bludgeoning",
	-- ["whip"] = "slashing",
	["Unarmed"] = "bludgeoning",
	["Unarmed (Small)"] = "bludgeoning",
	["Atlatl"] = "bludgeoning",
	["Cesta"] = "bludgeoning",
	["Energy balls"] = "energy",
	["Club"] = "bludgeoning",
	["Baton"] = "bludgeoning",
	["Combat gloves"] = "bludgeoning",
	["Force pike"] = "slashing",
	["Gaderffii"] = "slashing, piercing",
	["Knife"] = "piercing",
	["Lightsaber"] = "energy",
	["Lightsaber, double"] = "energy",
	["Longsword"] = "slashing",
	["Mace, light"] = "bludgeoning",
	["Quarterstaff"] = "bludgeoning",
	["Spear"] = "piercing",
	["Stun batton"] = "bludgeoning",
	["Vibro-ax"] = "slashing",
	["Vibroblade"] = "slashing",
	["Vibrodagger"] = "slashing",
	["Blaster pistol"] = "energy",
	["Blaster, heavy"] = "energy",
	["Blaster, hold-out"] = "energy",
	["Blaster, sporting"] = "energy",
	["Ion gun pistol"] = "energy",
	["Blaster carbine"] = "energy",
	["Blaster rifle"] = "energy",
	["Blaster rifle, sporting"] = "energy",
	["Blaster, lt. repeat"] = "energy",
	["Ion gun rifle"] = "energy",
	["Grenade, frag"] = "slashing",
	["Grenade, stun"] = "energy",
	["Thermal detonator"] = "energy",
	["Net"] = "",
	["Electro-net"] = "",
	["Sling"] = "",
	["Bow"] = "piercing",
	["Slugthrower, pistol"] = "piercing",
	["Slugthrower, rifle"] = "piercing",
	["Bowcaster"] = "energy",
	["Blaster cannon"] = "energy",
	["Blaster, hvy repeat"] = "energy",
	["Blaster, E-Web"] = "energy",
}

naturaldmgtypes = {
	["arm"] = "bludgeoning",
	["bite"] = "piercing,slashing,bludgeoning",
	["butt"] = "bludgeoning",
	["claw"] =  "piercing,slashing",
	["foreclaw"] =  "piercing,slashing",
	["gore"] = "piercing",
	["hoof"] = "bludgeoning",
	["hoove"] = "bludgeoning",
	["horn"] = "piercing",
	["pincer"] = "bludgeoning",
	["quill"] = "piercing",
	["ram"] = "bludgeoning",
	["rock"] = "bludgeoning",
	["slam"] = "bludgeoning",
	["snake"] = "piercing,slashing,bludgeoning",
	["spike"] = "piercing",
	["stamp"] = "bludgeoning",
	["sting"] = "piercing",
	["swarm"] = "piercing,slashing,bludgeoning",
	["tail"] = "bludgeoning",
	["talon"] =  "piercing,slashing",
	["tendril"] = "bludgeoning",
	["tentacle"] = "bludgeoning",
	["wing"] = "bludgeoning",
}

-- Skill properties
sensesdata = {
	["Listen"] = {
			stat = "wisdom"
		},
	["Spot"] = {
			stat = "wisdom"
		},
}

skilldata = {
	["Appraise"] = {
			stat = "intelligence"
		},
	["Astrogate"] = {
			stat = "intelligence",
			trainedonly = 1
		},
	["Balance"] = {
			stat = "dexterity",
		},
	["Bluff"] = {
			stat = "charisma"
		},
	["Climb"] = {
			stat = "strength",
			armorcheckmultiplier = 1
		},
	["Computer Use"] = {
			stat = "intelligence"
		},
	["Craft"] = {
			sublabeling = true,
			stat = "intelligence"
		},
	["Demolitions"] = {
			stat = "intelligence",
			trainedonly = 1
		},
	["Diplomacy"] = {
			stat = "charisma"
		},
	["Disable Device"] = {
			stat = "intelligence",
			trainedonly = 1
		},
	["Disguise"] = {
			stat = "charisma"
		},
	["Entertain"] = {
			sublabeling = true,
			stat = "charisma"
		},		
	["Escape Artist"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		},
	["Forgery"] = {
			stat = "intelligence"
		},
	["Gamble"] = {
			stat = "wisdom"
		},		
	["Gather Information"] = {
			stat = "charisma"
		},
	["Handle Animal"] = {
			stat = "charisma",
			trainedonly = 1
		},
	["Hide"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		},
	["Intimidate"] = {
			stat = "charisma"
		},
	["Jump"] = {
			stat = "strength",
			armorcheckmultiplier = 1
		},
	["Knowledge"] = {
			sublabeling = true,
			stat = "intelligence",
			trainedonly = 1
		},
	["Listen"] = {
			stat = "wisdom"
		},
	["Move Silently"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		},
	["Pilot"] = {
			stat = "dexterity",
			trainedonly = 1
		},
	["Profession"] = {
			sublabeling = true,
			stat = "wisdom",
			trainedonly = 1
		},
	["Read/Write Language"] = {
			sublabeling = true,
			stat = "None",
			trainedonly = 1			
		},		
	["Repair"] = {
			stat = "intelligence",
			trainedonly = 1
		},		
	["Ride"] = {
			stat = "dexterity"
		},
	["Search"] = {
			stat = "intelligence"
		},
	["Sense Motive"] = {
			stat = "wisdom"
		},
	["Sleight of Hand"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1,
			trainedonly = 1
		},
	["Speak Language"] = {
			sublabeling = true,
			stat = "None",
			trainedonly = 1			
		},
	["Spot"] = {
			stat = "wisdom"
		},
	["Survival"] = {
			stat = "wisdom"
		},
	["Swim"] = {
			stat = "strength",
		},
	["Treat Injury"] = {
			stat = "wisdom",
		},		
	["Tumble"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1,
			trainedonly = 1
		},
}

-- Coin labels
currency = { "Hard Currency", "Credit Chip" };

-- Party sheet drop down list data
psabilitydata = {
	"Strength",
	"Dexterity",
	"Constitution",
	"Intelligence",
	"Wisdom",
	"Charisma"
};

pssavedata = {
	"Fortitude",
	"Reflex",
	"Will"
};

psskilldata = {
	"Bluff",
	"Climb",
	"Diplomacy",
	"Gather Information",
	"Heal",
	"Hide",
	"Jump",
	"Intimidate",
	"Knowledge (Alien Spacies)",
	"Knowledge (History)",
	"Knowledge (Jedi Lore)",
	"Knowledge (Streetwise)",
	"Knowledge (Tactics)",
	"Knowledge (World Lore)",
	"Listen",
	"Move Silently",
	"Search",
	"Spot",
	"Survival"
};

-- PC/NPC Class properties

class_stol = {
	-- ["brb"] = "barbarian",
	-- ["brd"] = "bard",
	-- ["clr"] = "cleric",
	-- ["drd"] = "druid",
	-- ["ftr"] = "fighter",
	-- ["mnk"] = "monk",
	-- ["pal"] = "paladin",
	-- ["rgr"] = "ranger",
	-- ["rog"] = "rogue",
	-- ["sor"] = "sorcerer",
	-- ["wiz"] = "wizard",
	["sol"] = "soldier",
};

classdata = {
	-- Core
	["soldier"] = {
		hd = "d12", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 4,
		skills = "Astrogate (Int), Computer Use (Int), Craft (Int), Demolitions (Int), Intimidate (Cha), Knowledge (Int), Pilot (Dex), Profession (Wis), Repair (Int) and Treat Injury (Wis)",
	},
};