require "Vehicles/ISUI/ISVehicleMechanics"
local BatteryJumpstarter = require("BatteryJumpstarter_Utils")

local old_ISVehicleMechanics_doPartContextMenu = ISVehicleMechanics.doPartContextMenu

function ISVehicleMechanics:doPartContextMenu(part, x, y)
    old_ISVehicleMechanics_doPartContextMenu(self, part, x, y)

    -- Same early returns as vanilla, in which case no context menu was created
    if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then return end
    local playerObj = getSpecificPlayer(self.playerNum)
    if playerObj:getVehicle() ~= nil and not (isDebugEnabled() or (isClient() and (isAdmin() or getAccessLevel() == "moderator"))) then return end

    -- Conditions to jumpstart the Battery:
    -- 1. Battery exists
    -- 2. Player has a Jumpstarter
    -- 3. Jumpstarter is not empty
    -- 4. Battery charge is at or below the sandbox threshold
    if part:getId() ~= "Battery" then return end
    local battery = part:getInventoryItem()
    if not battery then return end

    local jumpstarter = BatteryJumpstarter.getChargedJumpstarter(playerObj)
    local option = self.context:addOption(getText("ContextMenu_BatteryJumpstarter"), playerObj, BatteryJumpstarter.onBatteryJumpstart, part, jumpstarter)

    local description = "<RGB:0,1,0> " .. getText("Tooltip_chanceOfSuccess") .. ": " .. BatteryJumpstarter.getSuccessChance() .. "% <LINE> <LINE>"

    if jumpstarter then
        description = description .. " <RGB:1,1,1> " .. getText("Tooltip_chargedJumpstarter") .. " 1/1 <LINE>"
        description = description .. " <RGB:1,1,1> " .. getText("Tooltip_remainingUses") .. " " .. jumpstarter:getCurrentUses() .. "/" .. jumpstarter:getMaxUses() .. " <LINE>"
    else
        option.notAvailable = true
        description = description .. " <RED> " .. getText("Tooltip_chargedJumpstarter") .. " 0/1 <LINE>"
    end

    local batteryText = getText("Tooltip_BatteryJumpstarter_BatteryCharge", BatteryJumpstarter.toPercent(BatteryJumpstarter.getMaxBatteryCharge()), BatteryJumpstarter.toPercent(battery:getCurrentUsesFloat()))
    if BatteryJumpstarter.canBatteryBeJumpstarted(battery) then
        description = description .. " <RGB:1,1,1> " .. batteryText .. " <LINE>"
    else
        option.notAvailable = true
        description = description .. " <RED> " .. batteryText .. " <LINE>"
    end

    local tooltip = ISToolTip:new()
    tooltip:initialise()
    tooltip:setVisible(false)
    tooltip.description = description
    option.toolTip = tooltip

    if getDebug() then
        self.context:addOption("DBG: Set Battery Charge", playerObj, BatteryJumpstarter.onDebugSetBatteryCharge, part)
    end
end

function BatteryJumpstarter.onDebugSetBatteryChargeAux(target, button, playerObj, part)
    if button.internal ~= "OK" then return end
    local charge = tonumber(button.parent.entry:getText())
    if not charge then return end
    charge = math.max(0, math.min(charge, 100)) / 100

    local vehicle = part:getVehicle()
    if isClient() then
        sendClientCommand(playerObj, "BatteryJumpstarter", "setBatteryCharge", { vehicle = vehicle:getId(), charge = charge })
    else
        BatteryJumpstarter.setBatteryCharge(vehicle, charge)
    end
end

function BatteryJumpstarter.onDebugSetBatteryCharge(playerObj, part)
    local currentCharge = tostring(math.floor(part:getInventoryItem():getCurrentUsesFloat() * 100 + 0.5))
    local modal = ISTextBox:new(0, 0, 280, 180, "Battery Charge (0-100):", currentCharge,
        nil, BatteryJumpstarter.onDebugSetBatteryChargeAux, playerObj:getPlayerNum(), playerObj, part)
    modal:initialise()
    modal:addToUIManager()
end

function BatteryJumpstarter.onBatteryJumpstart(playerObj, part, jumpstarter)
    if playerObj:getVehicle() then
        ISVehicleMenu.onExit(playerObj)
    end

    ISVehiclePartMenu.toPlayerInventory(playerObj, jumpstarter)
    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea()))
    ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, jumpstarter, 50, true))
    ISTimedActionQueue.add(BatteryJumpstarter_JumpstarterTimedAction:new(playerObj, part, jumpstarter))
end
