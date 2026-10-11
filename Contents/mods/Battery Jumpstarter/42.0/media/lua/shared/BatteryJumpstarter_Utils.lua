local BatteryJumpstarter = {}

BatteryJumpstarter.ITEM_TYPE = "Base.Jumpstarter"

local function getSandboxVar(name, default)
    local vars = SandboxVars.BatteryJumpstarter
    if vars and vars[name] ~= nil then
        return vars[name]
    end
    return default
end

-- Chance (0-100) that a jumpstart attempt succeeds
function BatteryJumpstarter.getSuccessChance()
    return getSandboxVar("SuccessChance", 75)
end

-- Battery charge (0-1) after a successful jumpstart
function BatteryJumpstarter.getChargeAfterJumpstart()
    return getSandboxVar("BatteryChargeAfterJumpstart", 15) / 100
end

-- Battery charge (0-1) the battery must be at or below to be jumpstarted
function BatteryJumpstarter.getMaxBatteryCharge()
    return getSandboxVar("MaxBatteryChargeToJumpstart", 10) / 100
end

-- Generator fuel (litres, out of 10) consumed per jumpstarter use recharged
function BatteryJumpstarter.getFuelPerCharge()
    return getSandboxVar("FuelPerCharge", 0.1)
end

function BatteryJumpstarter.toPercent(value)
    return math.floor(value * 100 + 0.5) .. "%"
end

function BatteryJumpstarter.canBatteryBeJumpstarted(battery)
    return battery ~= nil and battery:getCurrentUsesFloat() <= BatteryJumpstarter.getMaxBatteryCharge() + 0.0001
end

-- Returns the carried jumpstarter (bags included) with the most charge left, or nil if all are empty
function BatteryJumpstarter.getChargedJumpstarter(playerObj)
    local jumpstarters = playerObj:getInventory():getAllTypeRecurse(BatteryJumpstarter.ITEM_TYPE)
    local best
    for i = 0, jumpstarters:size() - 1 do
        local jumpstarter = jumpstarters:get(i)
        if jumpstarter:getCurrentUses() > 0 and (not best or jumpstarter:getCurrentUses() > best:getCurrentUses()) then
            best = jumpstarter
        end
    end
    return best
end

-- Returns the carried jumpstarter (bags included) with the least charge, or nil if all are full
function BatteryJumpstarter.getRechargeableJumpstarter(playerObj)
    local jumpstarters = playerObj:getInventory():getAllTypeRecurse(BatteryJumpstarter.ITEM_TYPE)
    local best
    for i = 0, jumpstarters:size() - 1 do
        local jumpstarter = jumpstarters:get(i)
        if not jumpstarter:isFullUses() and (not best or jumpstarter:getCurrentUses() < best:getCurrentUses()) then
            best = jumpstarter
        end
    end
    return best
end

-- Sets the vehicle's battery charge (0-1) and syncs it to clients. Runs on the server, or locally in singleplayer
function BatteryJumpstarter.setBatteryCharge(vehicle, charge)
    local part = vehicle:getPartById("Battery")
    local battery = part and part:getInventoryItem()
    if not battery then return end
    battery:setCurrentUsesFloat(charge)
    vehicle:transmitPartUsedDelta(part)
end

function BatteryJumpstarter.hasJumpstarter(playerObj)
    return playerObj:getInventory():getFirstTypeRecurse(BatteryJumpstarter.ITEM_TYPE) ~= nil
end

return BatteryJumpstarter
