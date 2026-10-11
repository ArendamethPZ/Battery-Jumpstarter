require "ISUI/ISWorldObjectContextMenu"
require "Vehicles/ISUI/ISVehiclePartMenu"
local BatteryJumpstarter = require("BatteryJumpstarter_Utils")

local function onFillWorldObjectContextMenu(player, context, worldobjects, test)
    if test then return end

    local generator
    for _, worldObject in ipairs(worldobjects) do
        if instanceof(worldObject, "IsoGenerator") then
            generator = worldObject
            break
        end
    end
    if not generator or not generator:isActivated() then return end

    local playerObj = getSpecificPlayer(player)
    if not BatteryJumpstarter.hasJumpstarter(playerObj) then return end

    local jumpstarter = BatteryJumpstarter.getRechargeableJumpstarter(playerObj)
    local fuelPerCharge = BatteryJumpstarter.getFuelPerCharge()
    local option = context:addOption(getText("ContextMenu_rechargeOption"), worldobjects, BatteryJumpstarter.onJumpstarterRecharge, generator, playerObj, jumpstarter)

    local description
    if jumpstarter then
        description = "<RGB:0,1,0> " .. getText("Tooltip_generator_disc") .. " <LINE> <LINE>"
        description = description .. " <RGB:1,1,1> " .. getText("Tooltip_remainingUses") .. " " .. jumpstarter:getCurrentUses() .. "/" .. jumpstarter:getMaxUses() .. " <LINE>"

        local fuelText = getText("Tooltip_BatteryJumpstarter_FuelPerCharge", luautils.round(fuelPerCharge, 2))
        if generator:getFuel() >= fuelPerCharge then
            description = description .. " <RGB:1,1,1> " .. fuelText .. " <LINE>"
        else
            option.notAvailable = true
            description = description .. " <RED> " .. fuelText .. " <LINE>"
        end
    else
        option.notAvailable = true
        description = "<RED> " .. getText("Tooltip_fullyCharged") .. " <LINE>"
    end

    local tooltip = ISToolTip:new()
    tooltip:initialise()
    tooltip:setVisible(false)
    tooltip.description = description
    option.toolTip = tooltip
end

function BatteryJumpstarter.onJumpstarterRecharge(worldobjects, generator, playerObj, jumpstarter)
    ISVehiclePartMenu.toPlayerInventory(playerObj, jumpstarter)
    if luautils.walkAdj(playerObj, generator:getSquare()) then
        ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, jumpstarter, 50, true))
        for _ = 1, jumpstarter:getMaxUses() - jumpstarter:getCurrentUses() do
            ISTimedActionQueue.add(BatteryJumpstarter_GeneratorTimedAction:new(playerObj, generator, jumpstarter))
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
