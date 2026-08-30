# Star Wars d20 Ruleset - Implementation Changelog (Since April 2026)

This document outlines all major architectural improvements, ruleset adaptations, UI enhancements, and bug fixes implemented in the **Star Wars d20 ruleset for Fantasy Grounds Unity** since April 2026.

---

## 1. Combat, Health & Damage Mechanics (August 2026)

### Vitality Points (VP) & Wound Points (WP) System
- **VP Absorption**: Damage rolls first deplete the character's Vitality Points pool. Chat notifications now display `[VP ABSORBED: X]` using authentic Star Wars d20 terminology rather than legacy temporary HP tags.
- **Wound Damage & Health Application**: Leftover damage penetrating past Vitality Points is applied directly to Wound Points (or directly on Critical Hits).

### Armor Damage Reduction (DR) (GitHub Issue #8)
- **Authentic SW d20 Armor Model**: In Star Wars Revised d20 rules, armor provides Damage Reduction (DR) to Wound Points rather than a static Defense bonus.
- **Inventory Integration**: Equipping armor (`carried = worn`) automatically aggregates the item's `dr` property and populates the character's `defenses.damagereduction` and Combat Tracker `dr` fields.
- **Combat Resolution**: Penetrating wound damage (and critical hits) is reduced by the armor's DR rating, reporting `[ARMOR DR: X]` in chat.

### Vehicle, Creature & Size DR (GitHub Issue #7)
- **Universal DR Engine**: Overrode the default 3.5E restriction (which skipped DR for energy weapons) so that `DR: X` and vehicle DR protect against blaster/energy attacks as well as physical damage.
- **Vehicle Hull Protection**: Vehicles (which have 0 VP) protect their Hull points directly with their DR value on incoming attacks.
- **Combat Tracker Effect Support**: Supports `DR: X`, `ARMORDR: X`, and `ADR: X` effect tags.
- **NPC & Vehicle Post-Add**: Dragging NPC and Vehicle records to the Combat Tracker automatically populates their `dr` field on the CT node.

### Lightsaber Bypass Mechanics
- Attacks made with lightsabers (detected via weapon name, damage type `energy, lightsaber`, or properties) automatically bypass Armor and Structural Damage Reduction as per Star Wars d20 rules.

### Lost Wound Points & Fatigue Rule (GitHub Issue #11)
- **Automatic Fatigue**: Whenever a character suffers damage to their Wound Points (`wounds > 0`), the `Fatigued` condition is automatically applied (`[FATIGUED]`), inflicting standard -2 Str / -2 Dex penalties and prohibiting running or charging.
- **Automatic Recovery**: When all wound damage is healed (`wounds <= 0`), the `Fatigued` condition is automatically removed.

### Removal of Unused Spell Resistance (SR)
- Removed all legacy D&D "Spell Resistance" (SR) controls and labels from the Combat Tracker defense section and Party Sheet, as Star Wars d20 resolves Force powers via skills, saving throws, and Force Defense rather than a numerical SR stat.

---

## 2. Combat Tracker & Character Sheet Layouts (August 2026)

### Combat Tracker Defense Section Overhaul
- Redesigned the Combat Tracker defense block into a clean, 4-column layout:
  - **Column 1**: Defense (`DEF`) / Fortitude Save (`Fort`)
  - **Column 2**: Flat-Footed Defense (`FF`) / Reflex Save (`Ref`)
  - **Column 3**: Touch Defense (`Tch`) / Will Save (`Will`)
  - **Column 4**: Damage Reduction (`DR`)
- Converted `dr` on the Combat Tracker to a string-based crosslink (`string_ct` / `hsx`) to prevent database type conflicts (`string` vs `number`) with character sheets.
- Added automatic database node type migration in `char_main.lua` and `ct_entry.lua` for backwards compatibility with existing campaign data.
- Fixed layout anchor warning for the `wounds` control on `charsheet_main`.

---

## 3. Theme, Graphics & Visual Assets (May – July 2026)

### Sci-Fi Theme & Frame Overhaul
- **Frames**: Updated window frames, headers, and backgrounds for character sheets, Combat Tracker, chatbox, groupbox, referencelist, storybox, token bags, and utility dialogs.
- **Sidebar & Dock**: Rebuilt sidebar dock categories, buttons, and state icons for clean navigation in Fantasy Grounds Unity.
- **Star Wars Nomenclature**: Replaced remaining D&D fantasy string resources with Star Wars equivalents (Defense, Vitality, Wounds, Force Resistance, etc.).

---

## 4. Skills System Modernization (April – May 2026)

### Full Skill System Stabilization
- Re-architected skill list controls with dedicated script controllers (`char_skills_main_sw.lua`, `char_skilllist_sw.lua`, `char_skilllist_item_sw.lua`, `char_skilllist_detailed_item_sw.lua`).
- Added robust database node validation guards to eliminate script errors when manipulating character skill entries.
- Implemented support for cross-class skill rank limits and cost calculations.
- Integrated Force skill categorizations (Alter, Control, Sense aspects).

---

## 5. Action & Effect Pipeline Refactor (April 2026)

### Modernized Action Management
- Modularized handlers for attacks, damage, saving throws, ability checks, and skill rolls (`manager_action_attack_sw.lua`, `manager_action_damage.lua`, `manager_action_skill_sw.lua`, etc.).
- Cleaned up obsolete helper scripts and standardized event registrations using `GameManager` and `ActionsManager`.
