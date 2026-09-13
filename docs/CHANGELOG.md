# Star Wars d20 Ruleset - Release Notes

This document highlights the major features, gameplay mechanics, user interface improvements, and bug fixes for the **Star Wars d20 ruleset for Fantasy Grounds Unity**.

---

## 1. Skill Actions Tab, Combat Weapons & Stun Range (September 13, 2026)

### Skill Records Actions Tab (5E Layout)
- **Dedicated Actions Tab on Skills**: Skill records (`record_skill_sw.xml`) now feature a tabbed interface with **Main** and **Actions** tabs.
- **5E-Style Action Management**: Designed the skill actions editor using the modern 5E layout featuring framed groupbox lists and a bottom quick-action toolbar to add Cast, Damage, Heal, and Effect actions.
- **Automatic Force Power Synchronization**: Pre-configured actions on Force skills now automatically synchronize to the character sheet's Force Powers when powers are added or populated.
- **Streamlined Force Points**: Hidden the legacy cost field and defaulted power cost to 0, supporting manual player handling for Force points.

### Weapon Line & Combat Mode Fixes
- **Equipped / Carried State Visibility**: Fixed an issue where character sheet weapons vanished upon switching to Combat mode. The `carried` state toggle remains visible across modes and triggers immediate list filter updates when toggled.

### Stun Weapon Mechanics & Visuals
- **Dedicated Stun Button Graphic**: Replaced the generic purple effect button on weapons with a custom electric cyan lightning action icon (`button_action_stun` and `button_action_stun_down`).
- **Authentic Stun Range Restriction**: Enforced the Star Wars d20 rule (*Revised Core Rulebook*, p. 64) where blaster stun beams have a maximum range of **6 meters**. Within 6m, the weapon's normal range increments apply; beyond 6m, attacks are automatically flagged `[OUT OF RANGE]` and resolve as an automatic miss.

### Runtime Stability
- **Resolved Script Warning**: Restored `list_spell.lua` to ensure zero script load warnings in Fantasy Grounds Unity runtime logs.

---

## 2. Force Powers & Actions Overhaul (September 2026)

### Force Skill Integration & Direct Rolling
- **Direct Force Skill Links**: Clicking the link shortcut beside a Force power now opens the relevant Force Skill description sheet rather than a fantasy spell sheet.
- **Roll Force Checks from the Actions Tab**: Double-click or drag the total bonus on any Force power row to roll your Force skill check directly to chat.

### Star Wars Saving Throw DCs
- **Opposed Skill Checks**: Powers that call for a saving throw can now be set to **Check**, automatically setting the save DC to the result of your Force skill check (`[WILL vs Check]`).
- **Fixed & Ability-Based DCs**: Added quick DC modes for fixed difficulty (e.g., standard DC 15 for tech and stun weapons) and class/species abilities ($10 + \text{half level} + \text{ability modifier}$).
- **Clean Chat Announcements**: Save prompts in chat clearly display the required save type and DC without phantom fantasy spell level adjustments.

### Streamlined Action Editors
- **Compact Damage Editor**: Streamlined the damage editor into a clean single line with a dedicated damage type column.
- **Bypass DR Toggle**: Clarified the damage reduction toggle to **Bypass DR? [ Yes / No ]**, making it obvious whether the power or attack bypasses armor and vehicle protection.
- **Simplified Duration & Attack Controls**: Cleaned up the duration editor for easier time tracking and removed non-functional fantasy skill attack options.

### Star Wars Terminology & Polish
- Replaced fantasy "Cast" tooltips with **Use**.
- Updated power and ability pop-up windows to Star Wars naming (e.g., *Force/Ability Use*, *Force/Ability Attack*, *Force/Ability Damage*, *Force/Ability Effect*, *Force/Ability Save*).
- Updated concentration check messages to reference Force classes instead of spell classes.

### Vitality Die, Health & Leveling
- **Vitality Die Terminology**: Replaced legacy fantasy "Hit Die" terminology with **Vitality Die** across class records and UI strings.
- **Automated VP & WP Progression**: 1st level character creation now properly sets max Vitality Points (max Vitality Die + Con modifier) into the character's VP pool, and initializes Wound Points (WP) equal to the character's Constitution score. Additional class levels add rolled/average Vitality Points to VP.

### Combat Conditions & Dual-Wielding
- **Run Condition**: Running characters lose their Dexterity bonus to Defense and on Reflex saves. If a character possesses the **Run** feat, their Dexterity bonus to Defense is preserved while running.
- **Two-Weapon Fighting & Off-Hand Melee**: Added a dedicated **Melee Off-Hand** weapon state to the character sheet. Automatically applies authentic Star Wars d20 two-weapon fighting penalties based on `Two-Weapon Fighting`, `Multiweapon Fighting`, and `Ambidexterity` feats, limits off-hand iterative attacks unless possessing `Improved Two-Weapon Fighting`, and calculates 0.5x Strength modifier damage.

### Character Sheet & Feat Enhancements
- **Reputation Bonus**: Added a dedicated **Reputation** field to the character sheet Notes tab. Automatically calculates reputation progression from class levels while allowing manual adjustments, and supports applying the character's Reputation bonus to Bluff, Diplomacy, Gather Information, and Intimidate checks.
- **Notes Tab Organization**: Rebuilt the character details section of the Notes tab into an elegant framed two-row layout. Physical traits (Gender, Age, Height, Weight, Size) span across the full top row, while Force Points, Dark Side Points, and Reputation sit cleanly below with clear, uncrowded labels.
- **Inventory & Encumbrance Display**: Restored standard frame sizing in the Inventory tab, ensuring armor penalties and encumbrance values display neatly without overlapping box borders.
- **Force Feats Recognition**: Added dynamic `[Force]` badge display on character sheet feat lists for all feats with the Force descriptor, with standardized Prerequisite, Benefit, Normal, and Special sections.

---

## 2. Combat, Health & Damage Mechanics (August 2026)

### Vitality Points (VP) & Wound Points (WP)
- **Vitality Point Absorption**: Damage automatically depletes a character's Vitality Points pool first, with chat notifications displaying `[VP ABSORBED: X]`.
- **Wound Damage**: Damage exceeding Vitality Points is applied directly to Wound Points. Critical hits bypass Vitality and strike Wound Points directly.
- **Automatic Fatigue**: Taking any damage to Wound Points automatically inflicts the **Fatigued** condition (-2 Strength, -2 Dexterity, no running/charging). The condition is automatically removed once all wound damage is healed.

### Damage Reduction (DR) & Armor
- **Authentic Armor Mechanics**: Equipping armor automatically applies its Damage Reduction (DR) rating to protect your Wound Points, displaying `[ARMOR DR: X]` in chat when hit.
- **Energy & Blaster DR**: Vehicle, creature, and natural armor DR protect against energy and blaster attacks in addition to physical attacks.
- **Vehicle Hull Protection**: Attacks on vehicles directly apply against Hull points after factoring in vehicle DR.
- **Lightsaber Bypass**: Lightsaber attacks automatically ignore both armor and structural Damage Reduction.
- **Spell Resistance Removed**: Removed obsolete fantasy "Spell Resistance" fields from sheets and the Combat Tracker.

---

## 3. Combat Tracker & Character Sheet Layouts (August 2026)

### Combat Tracker Defenses
- Reorganized the Combat Tracker defense section into four clean columns:
  - **Column 1**: Defense (`DEF`) and Fortitude Save (`Fort`)
  - **Column 2**: Flat-Footed Defense (`FF`) and Reflex Save (`Ref`)
  - **Column 3**: Touch Defense (`Tch`) and Will Save (`Will`)
  - **Column 4**: Damage Reduction (`DR`)
- Combat Tracker records automatically populate DR when dropping NPCs and vehicles into combat.

---

## 4. Theme & Sci-Fi Visual Styling (May – July 2026)

### Visual Experience
- **Star Wars Themed UI**: Custom sci-fi frames, headers, and backgrounds across character sheets, the Combat Tracker, chat window, and story panels.
- **Updated Sidebar**: Modernized sidebar buttons and icons for easy navigation in Fantasy Grounds Unity.
- **Full Sci-Fi Nomenclature**: Consistent Star Wars terms throughout all tabs and tooltips (Defense, Vitality, Wounds, Force Resistance, etc.).

---

## 5. Skills System Modernization (April – May 2026)

### Skills Tab Enhancements
- **Force Aspects**: Added clear categorization for Force skills into Alter, Control, and Sense aspects.
- **Cross-Class Calculations**: Accurate cross-class skill rank limits and skill point purchasing costs.
- **Stability & Performance**: Improved skill sheet responsiveness and reliability when editing, adding, or deleting character skills.

---

## 6. Combat Actions & Automation (April 2026)

### Unified Action Engine
- Rebuilt attack, damage, saving throw, and skill roll handling for smoother automation with Fantasy Grounds Unity combat and effect systems.
