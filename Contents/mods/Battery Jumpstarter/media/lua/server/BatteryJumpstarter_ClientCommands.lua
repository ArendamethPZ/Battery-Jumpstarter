local Commands = {}

function Commands.increaseUsedDelta(vehicleId)
	local vehicle = getVehicleById(vehicleId)
	if not vehicle then return end
	local part = vehicle:getPartById('Battery')
	if not part or not part:getInventoryItem() or part:getInventoryItem():getUsedDelta() > 0.1 then return end
	part:getInventoryItem():setUsedDelta(0.15)
	vehicle:transmitPartUsedDelta(part)
end

local function OnClientCommand(module, command, player, args)
    if module == 'BatteryJumpstarter' and Commands[command] then
        Commands[command](args[1])
    end
end

Events.OnClientCommand.Add(OnClientCommand)