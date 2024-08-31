-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

-- Adjusted
function collapse()
	proficienciestitle.collapse();
	featstitle.collapse();
	specialabilitiestitle.collapse();
	traitstitle.collapse();
	languagestitle.collapse();
end

-- Adjusted
function expand()
	proficienciestitle.expand();
	featstitle.expand();
	specialabilitiestitle.expand();
	traitstitle.expand();
	languagestitle.expand();
end

function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		return CharManager.addInfoDB(getDatabaseNode(), sClass, sRecord);
	end
end