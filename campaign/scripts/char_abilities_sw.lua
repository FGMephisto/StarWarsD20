-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function collapse()
	proficienciestitle.collapse();
	featstitle.collapse();
	specialabilitiestitle.collapse();
	traitstitle.collapse();
	languagestitle.collapse();
end

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function expand()
	proficienciestitle.expand();
	featstitle.expand();
	specialabilitiestitle.expand();
	traitstitle.expand();
	languagestitle.expand();
end

-- ===================================================================================================================
-- Adjusted
-- ===================================================================================================================
function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		if StringManager.contains({"referencefeat", "referenceclassability", "referenceracialtrait"}, sClass) then
			CharManager.addInfoDB(getDatabaseNode(), sClass, sRecord, nodeTargetList);
			return true;
		end
	end
end