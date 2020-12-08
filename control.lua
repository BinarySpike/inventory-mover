function find_inventory(luacontrol)
    local supported_inventories = {
        defines.inventory.car_trunk -- look for this prior to chest.  chest seems the fuel inventory for cars
       ,defines.inventory.chest
       ,defines.inventory.character_main
       ,defines.inventory.cargo_wagon
       ,defines.inventory.spider_trunk
    }
    local output = nil
    
    for key,value in pairs(supported_inventories) do
        output = luacontrol.get_inventory(value)
        if output ~= nil then return output, "Found "..key end
    end
    return nil
end

local function flying_text(player, text, position)
    return player.create_local_flying_text{text = text, position = position}
end

local function dflying_text(player, text, position)
    flying_text(player, text, position)
end

local function eflying_text(player, text, position)
    flying_text(player, text, position)
    player.surface.play_sound{path='utility/cannot_build'}
end

local function check_accessible(player, entity)
    -- accessible if:
    -- player force and entity force are the same (what?? not friends??)
    -- player force is friends with entity force
    -- entity force is neutral
    if not (player.force.name == entity.force.name or player.force.get_friend(entity.force) or entity.force.name == 'neutral') then
        return false
    end
    return true
end

script.on_event('select-transfer-source', function(event)
    local player = game.get_player(event.player_index)
    local selected = player.selected
    
    if not selected then return end

    global.selected_object = player.selected
    player.surface.play_sound{path='utility/cut_activated'}
end)

script.on_event('transfer-to-destination', function(event)
    local player = game.get_player(event.player_index)
    local destination = player.selected
    local source = global.selected_object
    
    
    -- valid objects?

    if source == nil then
        dflying_text(player, "Source not valid (nil)", event.cursor_position)
        return
    end

    if not source.valid then
        dflying_text(player, "Source not valid", event.cursor_position)
        return
    end

    if destination == nil then
        dflying_text(player, "Destination not valid (nil)", event.cursor_position)
        return
    end

    if not destination.valid then
        dflying_text(player, "Destination not valid", event.cursor_position)
        return
    end

    if (not player.can_reach_entity(source) and not player.can_reach_entity(destination)) then
        eflying_text(player, "Cannot reach source and destination", destination.position)
        return
    elseif not player.can_reach_entity(source) then
        eflying_text(player, "Cannot reach source", destination.position)
        return
    elseif not player.can_reach_entity(destination) then
        eflying_text(player, "Cannot reach destination", destination.position)
        return
    end

    -- do we have permission to access it?
    if not check_accessible(player, source) then
        eflying_text(player, "Source not accessible", destination.position)
        return
    end

    if not check_accessible(player, destination) then
        eflying_text(player, "Destination not accessible", destination.position)
        return
    end



    local dInv, dMsg = find_inventory(destination)
    local sInv, sMsg = find_inventory(source)

    if dInv == nil or not dInv.valid then
        dflying_text(player, "Destination inventory not supported or invalid", event.cursor_position)
        return
    end

    if sInv == nil or not sInv.valid then
        dflying_text(player, "Source inventory not supported or invalid", event.cursor_position)
        return
    end

    if sInv.is_empty() then
        eflying_text(player, "Source is empty", destination.position)
        return
    end

    -- we're gonna do "something" so clear the tracked source

    local didInsert = false

    for i = 1, #sInv do
        local stack = sInv[i]
        if stack.valid_for_read then
            if dInv.can_insert(stack) then
                didInsert = true
                local count = dInv.insert(stack)
                if count < stack.count then stack.count = stack.count - count end
                if count == stack.count then stack.clear() end
            end
        end
    end

    if not didInsert then
        eflying_text(player, "Destination is full", destination.position)
    else -- inserted
        destination.surface.play_sound{path='utility/inventory_move'}
    end

    -- we didn't insert everything, let's keep our source
    -- -or- (else)
    -- we inserted everything, let's move our source to the destination
    if sInv.get_item_count() > 0 then
        global.selected_object = source
    else
        global.selected_object = destination
    end
end)
