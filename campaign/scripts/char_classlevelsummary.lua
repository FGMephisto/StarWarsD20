-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	DB.addHandler(DB.getPath(window.getDatabaseNode(), "classes"), "onChildUpdate", updateValue);
	updateValue();
end
function onClose()
	DB.removeHandler(DB.getPath(window.getDatabaseNode(), "classes"), "onChildUpdate", updateValue);
end

function updateValue()
	setValue(CharManager.getClassLevelSummary(window.getDatabaseNode()));
end
