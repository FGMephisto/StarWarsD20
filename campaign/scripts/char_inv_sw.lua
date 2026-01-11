-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
-- File adjusted for Star Wars 3.5E
--

function onInit()
	if super and super.onInit then
		super.onInit();
	end

	self.onEncumbranceLimitChanged();
	DB.addHandler(DB.getPath(getDatabaseNode(), "abilities.strength.score"), "onUpdate", self.onStrengthChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "size"), "onUpdate", self.onSizeChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.stradj"), "onUpdate", self.onEncumbranceLimitChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.carrymult"), "onUpdate", self.onEncumbranceLimitChanged);
end
function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "abilities.strength.score"), "onUpdate", self.onStrengthChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "size"), "onUpdate", self.onSizeChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.stradj"), "onUpdate", self.onEncumbranceLimitChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.carrymult"), "onUpdate", self.onEncumbranceLimitChanged);
end

function onLockModeChanged(bReadOnly)
	if super and super.onLockModeChanged then
		super.onLockModeChanged(bReadOnly);
	end

	if WindowManager.getTopWindow(self).getClass() ~= "charsheetmini" then
		local tFields = { "usearmormaxstatbonus", "armormaxstatbonus", "armorcheckpenalty", "spellfailure", };
		WindowManager.callSafeControlsSetLockMode(self, tFields, bReadOnly);
	end
end

function onStrengthChanged()
	self.onEncumbranceLimitChanged();
end
function onSizeChanged()
	self.onEncumbranceLimitChanged();
end

function onEncumbranceLimitChanged() -- Adjusted
	local nodeChar = getDatabaseNode();

	local nHeavy = 0;
	local nStrength = DB.getValue(nodeChar, "abilities.strength.score", 10);
	nStrength = nStrength + DB.getValue(nodeChar, "encumbrance.stradj", 0);
	if nStrength > 0 then
		
		-- Up to strength 10
		if nStrength <= 10 then
			nHeavy = nStrength * 5;
			
		-- Above strength 10 and adding required adjustment to compensate for rounding if math.floor returns 11 or 17
		elseif math.floor((10 * math.pow(2, math.fmod(nStrength, 5) / 5)) + 0.5) == 11 then
			nHeavy = 1.25 * math.pow(2, math.floor(nStrength / 5)) * (math.floor((10 * math.pow(2, math.fmod(nStrength, 5) / 5)) + 0.5)+0.5);
		elseif math.floor((10 * math.pow(2, math.fmod(nStrength, 5) / 5)) + 0.5) == 17 then
			nHeavy = 1.25 * math.pow(2, math.floor(nStrength / 5)) * (math.floor((10 * math.pow(2, math.fmod(nStrength, 5) / 5)) + 0.5)+0.5);
		elseif nStrength >= 10 then
			nHeavy = 1.25 * math.pow(2, math.floor(nStrength / 5)) * math.floor((10 * math.pow(2, math.fmod(nStrength, 5) / 5)) + 0.5);
		end
	end
	
	nHeavy = nHeavy * DB.getValue(nodeChar, "encumbrance.carrymult", 1);

	local nLight = 0;
	local nMedium = 0;
	local nLiftOver = nHeavy;
	local nLiftOff = nHeavy * 2;
	local nPushDrag = nHeavy * 5;

	-- Calculate Light, adding required adjustment to compensate for rounding down to the next x.5 
	if math.fmod(nHeavy / 3, math.floor(nHeavy / 3)) >= 0.5 then
		nLight = math.floor(nHeavy / 3)+0.5;
	else
		nLight = math.floor(nHeavy / 3);
	end

	-- Calculate Medium, adding required adjustment to compensate for rounding down to the next x.5 
	if math.fmod((nHeavy / 3 * 2), math.floor(nHeavy / 3 * 2)) >= 0.5 then
		nMedium = math.floor(nHeavy / 3 * 2) + 0.5;
	else
		nMedium = math.floor(nHeavy / 3 * 2);
	end	

	local nSize = ActorCommonManager.getCreatureSizeDnD3(ActorManager.resolveActor(nodeChar));
	if (nSize < 0) then
		local nMult = 0;
		if (nSize == -1) then
			nMult = 0.75;
		elseif (nSize == -2) then
			nMult = 0.5;
		elseif (nSize == -3) then
			nMult = .25;
		elseif (nSize == -4) then
			nMult = .125;
		end
			
		nLight = math.floor(((nLight * nMult) * 100) + 0.5) / 100;
		nMedium = math.floor(((nMedium * nMult) * 100) + 0.5) / 100;
		nHeavy = math.floor(((nHeavy * nMult) * 100) + 0.5) / 100;
		nLiftOver = math.floor(((nLiftOver * nMult) * 100) + 0.5) / 100;
		nLiftOff = math.floor(((nLiftOff * nMult) * 100) + 0.5) / 100;
		nPushDrag = math.floor(((nPushDrag * nMult) * 100) + 0.5) / 100;
	elseif (nSize > 0) then
		local nMult = math.pow(2, nSize);
		
		nLight = nLight * nMult;
		nMedium = nMedium * nMult;
		nHeavy = nHeavy * nMult;
		nLiftOver = nLiftOver * nMult;
		nLiftOff = nLiftOff * nMult;
		nPushDrag = nPushDrag * nMult;
	end

	DB.setValue(nodeChar, "encumbrance.lightload", "number", nLight);
	DB.setValue(nodeChar, "encumbrance.mediumload", "number", nMedium);
	DB.setValue(nodeChar, "encumbrance.heavyload", "number", nHeavy);
	DB.setValue(nodeChar, "encumbrance.liftoverhead", "number", nLiftOver);
	DB.setValue(nodeChar, "encumbrance.liftoffground", "number", nLiftOff);
	DB.setValue(nodeChar, "encumbrance.pushordrag", "number", nPushDrag);
end