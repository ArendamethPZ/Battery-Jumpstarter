if isClient() then return end

local BatteryJumpstarter = require("BatteryJumpstarter_Utils")

local Commands = {}

-- Debug option from the vehicle mechanics menu. Same permission vanilla uses for its mechanics cheats
function Commands.setBatteryCharge(player, args)
    if not checkPermissions(player, Capability.UseMechanicsCheat) then return end
    local vehicle = getVehicleById(args.vehicle)
    if not vehicle or type(args.charge) ~= "number" then return end
    BatteryJumpstarter.setBatteryCharge(vehicle, math.max(0, math.min(args.charge, 1)))
end

local function onClientCommand(module, command, player, args)
    if module == "BatteryJumpstarter" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(onClientCommand)
