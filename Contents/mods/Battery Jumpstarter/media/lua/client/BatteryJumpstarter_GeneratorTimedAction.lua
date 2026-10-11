require "TimedActions/ISBaseTimedAction"

BatteryJumpstarter_GeneratorTimedAction = ISBaseTimedAction:derive("BatteryJumpstarter_GeneratorTimedAction");

function BatteryJumpstarter_GeneratorTimedAction:isValid() -- Check if the action can be done
    return self.generator:getFuel() >= 1 and self.item:getUsedDelta() < 0.99
end

function BatteryJumpstarter_GeneratorTimedAction:update() -- Trigger every game update when the action is perform
    if self.generator:getFuel() < 1 then
        ISBaseTimedAction.stop(self);
    end
end

function BatteryJumpstarter_GeneratorTimedAction:waitToStart() -- Wait until return false
    self.character:faceThisObject(self.generator)
    return self.character:shouldBeTurning()
end

function BatteryJumpstarter_GeneratorTimedAction:start() -- Trigger when the action start
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Low")
    self.character:reportEvent("EventLootItem")
end

function BatteryJumpstarter_GeneratorTimedAction:stop() -- Trigger if the action is cancel
    ISBaseTimedAction.stop(self);
end

function BatteryJumpstarter_GeneratorTimedAction:perform() -- Trigger when the action is complete
    self.sound = self.character:playSound("beep")
    local currentDelta = self.item:getUsedDelta()
    local fuel = self.generator:getFuel()

    self.item:setUsedDelta(math.min(currentDelta + 0.2, 1))
    self.generator:setFuel(fuel - 1)
    ISBaseTimedAction.perform(self);
end

function BatteryJumpstarter_GeneratorTimedAction:new(character, generator, item) -- What to call in you code
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
    o.generator = generator;
    o.item = item;
    o.maxTime = 100; -- Time take by the action
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end