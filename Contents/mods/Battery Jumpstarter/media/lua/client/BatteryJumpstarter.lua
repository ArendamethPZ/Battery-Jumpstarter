require 'ISUI/ISWorldObjectContextMenu'

local BatteryJumpstarter = {}

Events.OnFillWorldObjectContextMenu.Add(function(player, context, worldobjects)
    local generator

    for gen,worldObject in ipairs(worldobjects) do
        if instanceof(worldObject, 'IsoGenerator') then
            generator = worldObject
        end
    end

    if generator then
        if generator:isActivated() then
            local playerObj = getSpecificPlayer(player)
            local invent = playerObj:getInventory()
            local jumpstarter
            local jumpstarters = invent:getItemsFromType("Jumpstarter")
            for i = 0, jumpstarters:size()-1 do
                if jumpstarters:size() == 1 then
                    jumpstarter = invent:getItemFromType("Jumpstarter")
                else
                    local jumpstarter_item = jumpstarters:get(i)
                    if jumpstarter_item:getUsedDelta() < 1 then
                        jumpstarter = jumpstarter_item
                    end
                end
            end
            local item = InventoryItemFactory.CreateItem("Jumpstarter")
            local usedDelta
            local remainingUses
            local fuel
            local description = "<RGB:0,255,0> " .. getText("Tooltip_generator_disc") .. " <LINE> <LINE>"

            if jumpstarter then
                usedDelta = jumpstarter:getUsedDelta()
                remainingUses = 0

                if usedDelta > 0 then
                    remainingUses = usedDelta*5
                end
            end

            fuel = generator:getFuel()
            local option = context:addOption(getText("ContextMenu_rechargeOption"), worldobjects, BatteryJumpstarter.onJumpstarterRecharge, generator, player, jumpstarter, remainingUses, fuel);
        
            if jumpstarter then
                description = description .. " <RGB:1,1,1>" .. item:getDisplayName() .. " 1/1 <LINE>";
            else
                option.notAvailable = true;
                description = description .. " <RED>" .. item:getDisplayName() .. " 0/1 <LINE>";
            end

            if fuel > 1 then
                description = description .. " <RGB:1,1,1>" .. getText("Tooltip_fuelUnit") .. " <LINE>";
            else
                option.notAvailable = true;
                description = description .. " <RED>" .. getText("Tooltip_fuelUnit") .. " <LINE>";
            end

            if jumpstarter then
                if jumpstarter:getUsedDelta() >= 0.99 then
                    option.notAvailable = true;
                    description = "<RED>" .. getText("Tooltip_fullyCharged") .. " <LINE>";
                end
            end

            local tooltip = ISToolTip:new();
            tooltip:initialise();
            tooltip:setVisible(false);
            tooltip.description = description
            option.toolTip = tooltip
        end
    end
end)

function BatteryJumpstarter.onJumpstarterRecharge(worldobjects, generator, player, item, remainingUses, fuel)
    local playerObj = getSpecificPlayer(player);
    if luautils.walkAdj(playerObj, generator:getSquare()) then
        ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, item, 50, true))
        for i=1,5-math.floor(remainingUses) do
            ISTimedActionQueue.add(BatteryJumpstarter_GeneratorTimedAction:new(playerObj, generator, item))
        end
    end
end

return BatteryJumpstarter