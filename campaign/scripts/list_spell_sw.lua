-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bCounting = false;
function onListChanged()
	if not bCounting then
		bCounting = true;
		WindowManager.callOuterWindowFunction(window, "onSpellCounterUpdate");
		bCounting = false;
	end
end

function addEntry(bFocus)
	local w = createWindow();
	
	-- Set the focus to the name if requested.
	if bFocus and w then
		w.header.subwindow.name.setFocus();
	end
	
	return w;
end

function onEnter()
	if Input.isShiftPressed() then
		self.addEntry(true);
		return true;
	end
	
	return false;
end

function onFilter(w)
	return w.getFilter();
end

function onDrop(x, y, draginfo)
	-- Do not process message; pass it directly to level list
	return false;
end