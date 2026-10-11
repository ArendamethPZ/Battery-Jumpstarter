require "TimedActions/ISBaseTimedAction"
local BatteryJumpstarter = require("BatteryJumpstarter_Utils")

BatteryJumpstarter_JumpstarterTimedAction = ISBaseTimedAction:derive("BatteryJumpstarter_JumpstarterTimedAction")

function BatteryJumpstarter_JumpstarterTimedAction:isValid() -- Check if the action can be done
    return self.vehicle ~= nil
        and self.character:getInventory():contains(self.item)
        and self.item:getCurrentUses() > 0
        and BatteryJumpstarter.canBatteryBeJumpstarted(self.part:getInventoryItem())
end

function BatteryJumpstarter_JumpstarterTimedAction:waitToStart() -- Wait until return false
    self.character:faceThisObject(self.vehicle)
    return self.character:shouldBeTurning()
end

function BatteryJumpstarter_JumpstarterTimedAction:update() -- Trigger every game update when the action is performed
    self.character:faceThisObject(self.vehicle)
    self.item:setJobDelta(self:getJobDelta())
    self.character:setMetabolicTarget(Metabolics.LightWork)
end

function BatteryJumpstarter_JumpstarterTimedAction:start() -- Trigger when the action starts
    self.item:setJobType(getText("Tooltip_jumpSAction"))
    self.item:setJobDelta(0.0)
    self:setActionAnim("VehicleWorkOnMid")
    self.sound = self.character:playSound("BatteryJumpstarter_Zap")
end

function BatteryJumpstarter_JumpstarterTimedAction:stop() -- Trigger if the action is cancelled
    if self.sound then
        self.character:stopOrTriggerSound(self.sound)
    end
    self.item:setJobDelta(0.0)
    ISBaseTimedAction.stop(self)
end

function BatteryJumpstarter_JumpstarterTimedAction:perform() -- Trigger when the action is complete (client)
    self.item:setJobDelta(0.0)
    ISBaseTimedAction.perform(self)
end

function BatteryJumpstarter_JumpstarterTimedAction:complete() -- Trigger when the action is complete (server/singleplayer)
    local battery = self.part:getInventoryItem()
    if not BatteryJumpstarter.canBatteryBeJumpstarted(battery) or self.item:getCurrentUses() <= 0 then
        return false
    end

    self.item:UseAndSync()

    local success = ZombRand(100) < BatteryJumpstarter.getSuccessChance()
    if success then
        battery:setCurrentUsesFloat(math.max(battery:getCurrentUsesFloat(), BatteryJumpstarter.getChargeAfterJumpstart()))
        self.vehicle:transmitPartUsedDelta(self.part)
    end

    -- Flashes the mechanics window green/red
    self.character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, { success = success })

    return true
end

function BatteryJumpstarter_JumpstarterTimedAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 200
end

-- Parameter names must match the fields set below, B42 uses them to recreate the action on the server
function BatteryJumpstarter_JumpstarterTimedAction:new(character, part, item)
    local o = ISBaseTimedAction.new(self, character)
    o.part = part
    o.vehicle = part:getVehicle()
    o.item = item
    o.jobType = getText("Tooltip_attempt")
    o.maxTime = o:getDuration()
    return o
end
