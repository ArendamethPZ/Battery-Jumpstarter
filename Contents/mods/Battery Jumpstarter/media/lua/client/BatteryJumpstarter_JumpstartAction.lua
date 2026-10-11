require "Vehicles/ISUI/ISVehicleMechanics"

local old_ISVehicleMechanics_doPartContextMenu = ISVehicleMechanics.doPartContextMenu

function ISVehicleMechanics:doPartContextMenu(part, x, y)
    if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then return; end

    local playerObj = getSpecificPlayer(self.playerNum);
    local option;
    local invent = playerObj:getInventory()

    old_ISVehicleMechanics_doPartContextMenu(self, part, x, y);

    -- Conditions to jumpstart the Battery:
    -- 1. Battery exists
    -- 2. Player has Jumpstarter
    -- 3. Jumpstarter is not empty
    -- 4. Battery charge is 0%

    if part:getId() == "Battery" then --If player right clicks on battery
        if part:getInventoryItem() then
            local jumpstarter
            local jumpstarters = invent:getItemsFromType("Jumpstarter")
            for i = 0, jumpstarters:size() - 1 do
                if jumpstarters:size() == 1 then
                    jumpstarter = invent:getItemFromType("Jumpstarter")
                else
                    local jumpstarter_item = jumpstarters:get(i)
                    if jumpstarter_item:getUsedDelta() > 0 then
                        jumpstarter = jumpstarter_item
                    end
                end
            end
            local JumpstartOption = self.context:addOption(getText("ContextMenu_BatteryJumpstarter"), playerObj,
                ISVehicleMechanics.onBatteryJumpstart, part, jumpstarter);
            local item = InventoryItemFactory.CreateItem("Jumpstarter")
            local usedDelta
            local remainingUses

            if jumpstarter then
                usedDelta = jumpstarter:getUsedDelta()
                remainingUses = 0

                if usedDelta > 0 then
                    remainingUses = usedDelta * 5
                end
            end

            local description = "<RGB:0,255,0>" .. getText("Tooltip_chanceOfSuccess") .. ": 75% <LINE> <LINE>"

            if jumpstarter then
                description = description .. " <RGB:1,1,1>" .. getText("Tooltip_chargedJumpstarter") .. " 1/1 <LINE>";
            else
                JumpstartOption.notAvailable = true;
                description = description .. " <RED>" .. getText("Tooltip_chargedJumpstarter") .. " 0/1 <LINE>";
            end

            if jumpstarter then
                if remainingUses > 0 then
                    description = description ..
                        " <RGB:1,1,1> " ..
                        getText("Tooltip_remainingUses") .. " " .. math.floor(remainingUses) .. "/5 <LINE>";
                else
                    JumpstartOption.notAvailable = true;
                    description = description .. " <RED>" .. getText("Tooltip_remainingUses") .. " 0/5 <LINE>";
                end
            end

            if part:getInventoryItem():getUsedDelta() <= 0.1 then
                description = description .. " <RGB:1,1,1>" .. getText("Tooltip_depBattery") .. " <LINE>";
            else
                JumpstartOption.notAvailable = true;
                description = description .. " <RED>" .. getText("Tooltip_depBattery") .. " <LINE>";
                --RechargeOption = self.context:addOption("Set charge to 0", playerObj, ISVehicleMechanics.ZeroCondition, part);
            end

            local tooltip = ISToolTip:new();
            tooltip:initialise();
            tooltip:setVisible(false);
            tooltip.description = description
            JumpstartOption.toolTip = tooltip
        end
    end
end

function ISVehicleMechanics.onBatteryJumpstart(playerObj, part, jumpstarter)
    ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, jumpstarter, 50, true))
    ISTimedActionQueue.add(BatteryJumpstarter_JumpstarterTimedAction:new(playerObj, part, jumpstarter))
end

--function ISVehicleMechanics.ZeroCondition(playerObj, part)
--    part:getInventoryItem():setUsedDelta(0);
--end
