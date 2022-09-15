-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	super.onInit();
	onHealthChanged();
end

function onFactionChanged()
	super.onFactionChanged();
	updateHealthDisplay();
end

function onHealthChanged()
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local sColor = ActorHealthManager.getHealthColor(rActor);
	
	wounds.setColor(sColor);
	status.setColor(sColor);
end

function updateHealthDisplay()
	local sOption;

	if friendfoe.getStringValue() == "friend" then
		sOption = OptionsManager.getOption("SHPC");
	else
		sOption = OptionsManager.getOption("SHNPC");
	end
	
	if sOption == "detailed" then
		hptemp.setVisible(true);
		hp.setVisible(true);
		wounds.setVisible(true);
		status.setVisible(false);
	elseif sOption == "status" then
		hptemp.setVisible(false);
		hp.setVisible(false);
		wounds.setVisible(false);
		status.setVisible(true);
	else
		hptemp.setVisible(false);
		hp.setVisible(false);
		wounds.setVisible(false);
		status.setVisible(false);
	end
end
