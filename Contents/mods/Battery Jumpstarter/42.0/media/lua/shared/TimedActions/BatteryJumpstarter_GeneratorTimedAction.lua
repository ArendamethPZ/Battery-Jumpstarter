require "TimedActions/ISBaseTimedAction"
local BatteryJumpstarter = require("BatteryJumpstarter_Utils")

BatteryJumpstarter_GeneratorTimedAction = ISBaseTimedAction:derive("BatteryJumpstarter_GeneratorTimedAction")

function BatteryJumpstarter_GeneratorTimedAction:isValid() -- Check if the action can be done
    return self.generator:getObjectIndex() ~= -1
        and self.generator:isActivated()
        and self.generator:getFuel() >= BatteryJumpstarter.getFuelPerCharge()
        and self.character:getInventory():contains(self.item)
        and not self.item:isFullUses()
end

function BatteryJumpstarter_GeneratorTimedAction:waitToStart() -- Wait until return false
    self.character:faceThisObject(self.generator)
    return self.character:shouldBeTurning()
end

function BatteryJumpstarter_GeneratorTimedAction:update() -- Trigger every game update when the action is performed
    self.character:faceThisObject(self.generator)
    self.item:setJobDelta(self:getJobDelta())
end

function BatteryJumpstarter_GeneratorTimedAction:start() -- Trigger when the action starts
    self.item:setJobType(getText("ContextMenu_rechargeOption"))
    self.item:setJobDelta(0.0)
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Low")
    self.character:reportEvent("EventLootItem")
end

function BatteryJumpstarter_GeneratorTimedAction:stop() -- Trigger if the action is cancelled
    self.item:setJobDelta(0.0)
    ISBaseTimedAction.stop(self)
end

function BatteryJumpstarter_GeneratorTimedAction:perform() -- Trigger when the action is complete (client)
    self.item:setJobDelta(0.0)
    self.character:playSound("BatteryJumpstarter_Beep")
    ISBaseTimedAction.perform(self)
end

function BatteryJumpstarter_GeneratorTimedAction:complete() -- Trigger when the action is complete (server/singleplayer)
    local fuelPerCharge = BatteryJumpstarter.getFuelPerCharge()
    if self.item:isFullUses() or self.generator:getFuel() < fuelPerCharge then
        return false
    end

    self.item:setCurrentUses(self.item:getCurrentUses() + 1)
    self.item:syncItemFields()

    self.generator:setFuel(self.generator:getFuel() - fuelPerCharge)
    self.generator:sync()

    return true
end

function BatteryJumpstarter_GeneratorTimedAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 100
end

-- Parameter names must match the fields set below, B42 uses them to recreate the action on the server
function BatteryJumpstarter_GeneratorTimedAction:new(character, generator, item)
    local o = ISBaseTimedAction.new(self, character)
    o.generator = generator
    o.item = item
    o.maxTime = o:getDuration()
    return o
end
