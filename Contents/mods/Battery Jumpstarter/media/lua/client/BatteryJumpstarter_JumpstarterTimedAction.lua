require "TimedActions/ISBaseTimedAction"

BatteryJumpstarter_JumpstarterTimedAction = ISBaseTimedAction:derive("BatteryJumpstarter_JumpstarterTimedAction");

function BatteryJumpstarter_JumpstarterTimedAction:isValid() -- Check if the action can be done
	if self.item:getUsedDelta() > 0.01 and self.part:getInventoryItem():getUsedDelta() <= 0.1 then
    	return true
    else
    	return false
    end

end

function BatteryJumpstarter_JumpstarterTimedAction:waitToStart() -- Wait until return false
    self.character:faceThisObject(self.vehicle)
    return self.character:shouldBeTurning()
end

function BatteryJumpstarter_JumpstarterTimedAction:start() -- Trigger when the action start
	self.item:setJobType(getText("Tooltip_jumpSAction"))
    self:setActionAnim("VehicleWorkOnMid")
    self.sound = self.character:playSound("zap")
end

function BatteryJumpstarter_JumpstarterTimedAction:stop() -- Trigger if the action is cancel
    self.item:setJobDelta(0)
    ISBaseTimedAction.stop(self);
end

function BatteryJumpstarter_JumpstarterTimedAction:perform() -- Trigger when the action is complete
	local chance = ZombRand(100) --Generate a random number between 0 and 99
	local ui = getPlayerMechanicsUI(self.character:getPlayerNum());
    self.item:Use()
    if chance < 75 then
    	ui:startFlashGreen()
        local vehicleId = self.part:getVehicle():getId()
        sendClientCommand('BatteryJumpstarter', 'increaseUsedDelta', {vehicleId})
    else
    	ui:startFlashRed()
    end
    ISBaseTimedAction.perform(self);
end

function BatteryJumpstarter_JumpstarterTimedAction:new(character, part, item) -- What to call in you code
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
    o.vehicle = part:getVehicle()
    o.part = part;
    o.item = item;
    o.maxTime = 200; -- Time take by the action
    o.jobType = getText("Tooltip_attempt")
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end