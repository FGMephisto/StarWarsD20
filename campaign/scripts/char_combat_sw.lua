-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

local bInitialized = false;

function isInitialized()
	return bInitialized;
end

function onInit()
	bInitialized = true;
	
	acstat.onValueChanged();
	acstat2.onValueChanged();
	fortitudestat.onValueChanged();
	reflexstat.onValueChanged();
	willstat.onValueChanged();
	initiativestat.onValueChanged();
	meleestat.onValueChanged();
	rangedstat.onValueChanged();
	grapplestat.onValueChanged();
end