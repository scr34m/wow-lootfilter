LootFilter = {}

LootFilter.print = function (value)
	if (value == nil) then
		value= ""
	end
	DEFAULT_CHAT_FRAME:AddMessage("Loot Filter - "..value, 1.0, 1.0, 1.0)
end

LootFilter.command= function (text)
	link = text
	text = text:lower()
	if (text == nil) then
		text = ''
	end

	local cmd = ''
	local i = string.find(text, ' ')

	if (i == nil) then
		cmd = text
	else
		cmd = string.sub(text, 0, i - 1)
		arg = string.sub(text, i + 1)
	end

	if cmd == "status" then LootFilter.showStatus()
	elseif cmd == "add" then
		LootFilter.addItem(arg)
	elseif cmd == "remove" then
		LootFilter.removeItem(arg)
	elseif cmd == "on" then
		LootFilterVars.enabled = true
		LootFilter.print("Loot Filter turned on.")
	elseif cmd == "off" then
		LootFilterVars.enabled = false
		LootFilter.print("Loot Filter turned off.")
	elseif cmd == "notify" then
		if (LootFilterVars.notifydelete) then
			LootFilterVars.notifydelete = false
			LootFilter.print("Notify on delete has been turned off.")
		else
			LootFilterVars.notifydelete = true
			LootFilter.print("Notify on delete has been turned on.")
		end
	else
		LootFilter.showHelp()
	end
end

LootFilter.removeItem = function(itemLink)
	local itemName = GetItemInfo(itemLink) 
	local _, _, itemID = string.find(itemLink, "item:(%d+):")

	if itemName and itemID then
		LootFilterVars.items[itemID] = nil
		LootFilter.print("Removed " ..itemName)
 	else
		LootFilter.print("Wrong item link used")
 	end
end

LootFilter.addItem = function(itemLink)
	local itemName = GetItemInfo(itemLink) 
	local _, _, itemID = string.find(itemLink, "item:(%d+):")

	if itemName and itemID then
		LootFilterVars.items[itemID] = itemName
		LootFilter.print("Added " ..itemName)
 	else
		LootFilter.print("Wrong item link used")
 	end
end

function _length(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

LootFilter.showStatus = function()
	if (LootFilterVars.enabled) then
		LootFilter.print("Loot filter is turned on.")
	else
		LootFilter.print("Loot filter is turned off.")
	end

	if _length(LootFilterVars.items) > 0 then 
		LootFilter.print("Items on the list:")
		for k,v in pairs(LootFilterVars.items) do 
			LootFilter.print(" - " .. v)
		end
	end
end

LootFilter.showHelp= function ()
	LootFilter.print("Loot Filter usage:")
	LootFilter.print("/lf on/off , turns filtering on or off")
	LootFilter.print("/lf status , shows you all filter information")
	LootFilter.print("/lf add <item link> , removes a string that should not be filtered")
	LootFilter.print("/lf remove <item link> , removes a string that should be filtered")
end

LootFilter.lootValid= function (name)
	for k,v in pairs(LootFilterVars.items) do 
		if v == name then
			return true
		end
	end
	return false;
end;

SLASH_LOOTFILTER1= "/lf"
SlashCmdList["LOOTFILTER"] = LootFilter.command

LootFilterVars = LootFilterVars or {}	
LootFilterVars.enabled = LootFilterVars.enabled or false
LootFilterVars.items = LootFilterVars.items or {}

-- TODO warning on auto loot enabled
-- TODO warning on auto loot key is shift

local frame, events = CreateFrame("Frame", "LootFilter"), {}
function events:LOOT_OPENED(...)
	if LootFilterVars.enabled and (IsFishingLoot() or not IsShiftKeyDown()) then
		local numitems = GetNumLootItems()
		for i=1, numitems, 1 do
			local _, name, _ = GetLootSlotInfo(i)
			if not LootFilter.lootValid(name) then
				LootSlot(i)
			else
				LootFilter.print("Not looted " .. name)
			end
		end
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
 events[event](self, ...) -- call one of the functions above
end)
for k, v in pairs(events) do
 frame:RegisterEvent(k) -- Register all events for which handlers have been defined
end


