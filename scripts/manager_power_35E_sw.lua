-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	local tPowerHandlers = {
		fnGetActorNode = getPowerActorNode,
		fnUsePower = usePower,
		fnParse = parsePower,
		fnUpdateDisplay = updatePowerDisplay,
	};
	PowerManagerCore.registerPowerHandlers(tPowerHandlers);

	local tPowerActionHandlers = {
		fnGetButtonIcons = getActionButtonIcons,
		fnGetText = getActionText,
		fnGetTooltip = getActionTooltip,
		fnPerform = performAction,
	};
	PowerActionManagerCore.registerActionType("", tPowerActionHandlers);
	PowerActionManagerCore.registerActionType("cast", {});
	PowerActionManagerCore.registerActionType("damage", {});
	PowerActionManagerCore.registerActionType("heal", {});
	PowerActionManagerCore.registerActionType("effect", {});
end

function getPowerActorNode(node)
	if not node then
		return nil;
	end
	local nodeParent = DB.getParent(node);
	while nodeParent do
		local sParent = DB.getName(nodeParent);
		if sParent == "charsheet" or sParent == "npc" then
			return nodeParent;
		end
		local nodeGP = DB.getParent(nodeParent);
		if nodeGP then
			local sGP = DB.getName(nodeGP);
			if sGP == "charsheet" or sGP == "npc" then
				return nodeParent;
			end
		end
		if DB.getChild(nodeParent, "inventorylist") or DB.getChild(nodeParent, "spellset") or DB.getChild(nodeParent, "skilllist") then
			return nodeParent;
		end
		nodeParent = DB.getParent(nodeParent);
	end
	local sPath = DB.getPath(node);
	local sCharPath = sPath:match("^([^.]*%.id%-%d+)");
	if sCharPath then
		return DB.findNode(sCharPath);
	end
	return nil;
end

function getSpellClassNode(node)
	if not node then
		return nil;
	end
	local nodeParent = DB.getParent(node);
	while nodeParent do
		local nodeGP = DB.getParent(nodeParent);
		if nodeGP and DB.getName(nodeGP) == "spellset" then
			return nodeParent;
		end
		nodeParent = DB.getParent(nodeParent);
	end
	return nil;
end

function usePower(node, draginfo)
	local nodeSpellClass = getSpellClassNode(node);
	if nodeSpellClass and DB.getValue(nodeSpellClass, "castertype", "") ~= "points" then
		PowerManagerCore.performDefaultPowerUse(node);
		return;
	end

	local nodeChar = getPowerActorNode(node);
	local rActor = ActorManager.resolveActor(nodeChar);

	-- Resolve skill node (by skillpath or by name matching)
	local sSkillPath = DB.getValue(node, "skillpath", "");
	local nodeSkill = nil;
	if sSkillPath ~= "" then
		nodeSkill = DB.findNode(sSkillPath);
	end

	if not nodeSkill and nodeChar then
		local sPowerName = DB.getValue(node, "name", "");
		local sPowerNameLower = StringManager.trim(sPowerName):lower();
		local sSchoolLower = StringManager.trim(DB.getValue(node, "school", "")):lower();
		for _, vSkillNode in pairs(DB.getChildren(nodeChar, "skilllist")) do
			local sName = StringManager.trim(DB.getValue(vSkillNode, "name", "")):lower();
			local sLabel = StringManager.trim(DB.getValue(vSkillNode, "label", "")):lower();
			if (sPowerNameLower ~= "" and (sName == sPowerNameLower or sLabel == sPowerNameLower)) or
			   (sSchoolLower ~= "" and (sName == sSchoolLower or sLabel == sSchoolLower)) then
				nodeSkill = vSkillNode;
				break;
			end
		end
	end

	local sSkillName = "";
	local sSkillStat = nil;
	local nSkillTotal = 0;

	if nodeSkill then
		sSkillName = DB.getValue(nodeSkill, "label", "");
		if sSkillName == "" then
			sSkillName = DB.getValue(nodeSkill, "name", "");
		end
		sSkillStat = DB.getValue(nodeSkill, "stat", "");
		if sSkillStat == "" then
			sSkillStat = nil;
		end
		nSkillTotal = DB.getValue(nodeSkill, "total", 0);
	end

	if sSkillName == "" then
		sSkillName = DB.getValue(node, "name", "");
	end

	local nMisc = DB.getValue(node, "misc", 0);
	local nSkillMod = DB.getValue(node, "total", nil);
	if not nSkillMod then
		nSkillMod = nSkillTotal + nMisc;
	end

	local sPowerName = DB.getValue(node, "name", "");
	local sExtra = nil;
	if sPowerName ~= "" and sSkillName ~= "" and sPowerName:lower() ~= sSkillName:lower() then
		sExtra = string.format("(%s)", sPowerName);
	end

	if rActor and sSkillName ~= "" then
		ActionSkill.performRoll(draginfo, rActor, sSkillName, nSkillMod, sSkillStat, sExtra);
	else
		ChatManager.Message(PowerManagerCore.getPowerOutput(node), ActorManager.isPC(rActor), rActor);
	end
end
function findSkillSourceActionsNode(nodeSkill)
	if not nodeSkill then
		return nil;
	end

	-- 1. Check if the skill itself on the character sheet has actions
	local nodeSkillActions = DB.getChild(nodeSkill, "actions");
	if nodeSkillActions and DB.getChildCount(nodeSkillActions) > 0 then
		return nodeSkillActions;
	end

	-- 2. Check if skill has a shortcut pointing to a reference skill
	local sClass, sRecord = DB.getValue(nodeSkill, "shortcut", "", "");
	if sRecord ~= "" then
		local nodeRef = DB.findNode(sRecord);
		if nodeRef then
			local nodeRefActions = DB.getChild(nodeRef, "actions");
			if nodeRefActions and DB.getChildCount(nodeRefActions) > 0 then
				return nodeRefActions;
			end
		end
	end

	-- 3. Search LibraryData mappings for skill
	local sSkillName = DB.getValue(nodeSkill, "label", "");
	if sSkillName == "" then
		sSkillName = DB.getValue(nodeSkill, "name", "");
	end
	local sStripName = StringManager.strip(sSkillName);
	if sStripName ~= "" then
		local aMappings = LibraryData.getMappings("skill");
		for _, vMapping in ipairs(aMappings) do
			for _, vNode in ipairs(DB.getChildrenGlobal(vMapping)) do
				local sName = DB.getValue(vNode, "name", "");
				if sName == "" then
					sName = DB.getValue(vNode, "label", "");
				end
				if StringManager.strip(sName) == sStripName then
					local nodeRefActions = DB.getChild(vNode, "actions");
					if nodeRefActions and DB.getChildCount(nodeRefActions) > 0 then
						return nodeRefActions;
					end
				end
			end
		end
	end

	return nil;
end

function copySkillActionsToPower(nodeSkill, nodePower, bForceReCopy)
	if not nodePower or not nodeSkill then
		return false;
	end
	local nodePowerActions = DB.createChild(nodePower, "actions");
	if not nodePowerActions then
		return false;
	end

	if not bForceReCopy and (DB.getChildCount(nodePowerActions) > 0) then
		return false;
	end

	local nodeSrcActions = findSkillSourceActionsNode(nodeSkill);
	if not nodeSrcActions or DB.getChildCount(nodeSrcActions) == 0 then
		return false;
	end

	if bForceReCopy or DB.getChildCount(nodePowerActions) > 0 then
		DB.deleteChildren(nodePowerActions);
	end

	for _, nodeSrcAction in ipairs(DB.getChildList(nodeSrcActions)) do
		local nodeNewAction = DB.createChild(nodePowerActions);
		if nodeNewAction then
			DB.copyNode(nodeSrcAction, nodeNewAction);
		end
	end
	return true;
end

function parsePower(node)
	local sSkillPath = DB.getValue(node, "skillpath", "");
	local nodeSkill = nil;
	if sSkillPath ~= "" then
		nodeSkill = DB.findNode(sSkillPath);
	end
	if not nodeSkill then
		local nodeChar = getPowerActorNode(node);
		if nodeChar then
			local sPowerName = DB.getValue(node, "name", "");
			local sPowerNameLower = StringManager.trim(sPowerName):lower();
			if sPowerNameLower ~= "" then
				for _, vSkillNode in pairs(DB.getChildren(nodeChar, "skilllist")) do
					local sName = StringManager.trim(DB.getValue(vSkillNode, "name", "")):lower();
					local sLabel = StringManager.trim(DB.getValue(vSkillNode, "label", "")):lower();
					if sName == sPowerNameLower or sLabel == sPowerNameLower then
						nodeSkill = vSkillNode;
						break;
					end
				end
			end
		end
	end

	if nodeSkill and copySkillActionsToPower(nodeSkill, node, true) then
		return;
	end

	SpellManager.parseSpell(node);
end
function updatePowerDisplay(w)
	if w.minisheet then
		return;
	end
	if not w.header or not w.header.subwindow then
		return;
	end
	if not w.header.subwindow.shortdescription or not w.header.subwindow.actionsmini then
		return;
	end

	local nodeActor = PowerManagerCore.getPowerActorNode(w.getDatabaseNode());
	local sDisplayMode = "";
	if ActorManager.isPC(nodeActor) then
		sDisplayMode = DB.getValue(nodeActor, "spelldisplaymode", "");
	else
		sDisplayMode = "action";
	end

	if sDisplayMode == "action" then
		w.header.subwindow.shortdescription.setVisible(false);
		w.header.subwindow.actionsmini.setVisible(true);
	else
		w.header.subwindow.shortdescription.setVisible(true);
		w.header.subwindow.actionsmini.setVisible(false);
	end
end

function getActionButtonIcons(node, tData)
	if tData.sType == "cast" then
		if tData.sSubRoll == "atk" then
			return "button_action_attack", "button_action_attack_down";
		elseif tData.sSubRoll == "clc" then
			return "button_roll", "button_roll_down";
		elseif tData.sSubRoll == "save" then
			return "button_roll", "button_roll_down";
		end
		return "button_roll", "button_roll_down";
	elseif tData.sType == "damage" then
		return "button_action_damage", "button_action_damage_down";
	elseif tData.sType == "heal" then
		return "button_action_heal", "button_action_heal_down";
	elseif tData.sType == "effect" then
		return "button_action_effect", "button_action_effect_down";
	end
	return "", "";
end
function getActionText(node, tData)
	if tData.sType == "cast" then
		if tData.sSubRoll == "atk" then
			return SpellManager.getActionAttackText(node);
		elseif tData.sSubRoll == "clc" then
			return SpellManager.getActionCLText(node);
		elseif tData.sSubRoll == "save" then
			return SpellManager.getActionSaveText(node);
		end
		return "";
	elseif tData.sType == "damage" then
		return SpellManager.getActionDamageText(node);
	elseif tData.sType == "heal" then
		return SpellManager.getActionHealText(node);
	elseif tData.sType == "effect" then
		if tData.sSubRoll == "duration" then
			return SpellManager.getActionEffectDurationText(node);
		else
			return PowerActionManagerCore.getActionEffectText(node, tData);
		end
	end
	return "";
end
function getActionTooltip(node, tData)
	if tData.sType == "cast" then
		if tData.sSubRoll == "atk" then
			return string.format("%s: %s", Interface.getString("power_tooltip_attack"), PowerActionManagerCore.getActionText(node, tData));
		elseif tData.sSubRoll == "clc" then
			return string.format("%s: %s", Interface.getString("power_tooltip_cl"), PowerActionManagerCore.getActionText(node, tData));
		elseif tData.sSubRoll == "save" then
			return string.format("%s: %s", Interface.getString("power_tooltip_save"), PowerActionManagerCore.getActionText(node, tData));
		end
		local tTooltip = {};
		table.insert(tTooltip, Interface.getString("power_tooltip_cast"));
		local sCL = SpellManager.getActionCLText(node)
		if sCL ~= "" then
			table.insert(tTooltip, string.format("%s: %s", Interface.getString("power_tooltip_cl"), sCL));
		end
		local sAttack = SpellManager.getActionAttackText(node);
		if sAttack ~= "" then
			table.insert(tTooltip, string.format("%s: %s", Interface.getString("power_tooltip_attack"), sAttack));
		end
		local sSave = SpellManager.getActionSaveText(node);
		if sSave ~= "" then
			table.insert(tTooltip, string.format("%s: %s", Interface.getString("power_tooltip_save"), sSave));
		end
		return table.concat(tTooltip, "\r");
	elseif tData.sType == "damage" then
		return string.format("%s: %s", Interface.getString("power_tooltip_damage"), PowerActionManagerCore.getActionText(node, tData));
	elseif tData.sType == "heal" then
		return string.format("%s: %s", Interface.getString("power_tooltip_heal"), PowerActionManagerCore.getActionText(node, tData));
	elseif tData.sType == "effect" then
		return PowerActionManagerCore.getActionEffectTooltip(node, tData);
	end
	return "";
end
function performAction(node, tData)
	SpellManager.onSpellAction(tData.draginfo, node, tData and tData.sSubRoll);
end
