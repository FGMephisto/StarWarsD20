--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onChar(nKeyCode)
	-- If alpha or slash character, then build a potential autocomplete
	if ((nKeyCode >= 65) and (nKeyCode <= 90)) or ((nKeyCode >= 97) and (nKeyCode <= 122)) or (nKeyCode == 47) then
		self.checkAutoComplete();
	-- If space (32) or tab (9), then perform autocomplete
	elseif (nKeyCode == 32) or (nKeyCode == 9) then
		self.performAutoComplete();
	end
end

function checkAutoComplete()
	local nCursor = self.getCursorPosition();
	local s = self.getValue();

	local tStrings, tStringStats = StringManager.split(s, ",;\r\n", true);
	for i = 1, #tStrings do
		if nCursor == tStringStats[i].endpos then
			if tStrings[i]:match("^([%a%s%(%)/]*[%a%(%)/]+)$") then
				local sCompletion = self.getCompletion(tStrings[i]);
				if sCompletion ~= "" then
					local sNewValue = s:sub(1, nCursor-1) .. sCompletion .. s:sub(nCursor);
					self.setValue(sNewValue);
					self.setSelectionPosition(nCursor + #sCompletion);
				end
			end
			return;
		end
	end
end

function performAutoComplete()
	local nLastCursor = self.getCursorPosition() - 1;
	if nLastCursor <= 0 then
		return;
	end
	local s = self.getValue();

	local tStrings, tStringStats = StringManager.split(s, ",;\r\n", true);
	for i = 1, #tStrings do
		if nLastCursor == tStringStats[i].endpos then
			if tStrings[i]:match("^([%a%s%(%)/]*[%a%(%)/]+)$") then
				local sCompletion = self.getCompletion(tStrings[i]);
				if sCompletion ~= "" then
					local sNewValue = s:sub(1, nLastCursor - 1) .. sCompletion .. s:sub(nLastCursor);
					self.setValue(StringManager.trim(sNewValue));
					self.setCursorPosition(nLastCursor + #sCompletion);
					self.setSelectionPosition(nLastCursor + #sCompletion);
				end
			end
			return;
		end
	end
end

function getCompletion(s)
	local sLower = s:lower();
	local tList = target and target[1] and DataCommon[target[1]];
	if not tList then
		return "";
	end
	for k,v in pairs(tList) do
		local sEntry = type(k) == "string" and k or v;
		if sLower == sEntry:sub(1, #s):lower() then
			return sEntry:sub(#s + 1);
		end
	end
	return "";
end