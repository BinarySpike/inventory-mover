function findLargestInventory(array)
  local maxFirst = nil
  local maxSecond = -math.huge -- Start with a very low number

  for _, pair in ipairs(array) do
    local first, second = pair[1], pair[2]
    if second > maxSecond then
      maxSecond = second
      maxFirst = first
    end
  end

  return maxFirst
end

function updated_find(luacontrol)
  local maxIndex = luacontrol.get_max_inventory_index()

  local foundInventories = {}

  for i = 1, maxIndex do
    local test = luacontrol.get_inventory(i)
    if test ~= nil then table.insert(foundInventories, { test, #test }) end
  end

  return findLargestInventory(foundInventories)
end

function find_inventory(luacontrol)
  local supported_inventories = {
    defines.inventory.car_trunk -- look for this prior to chest.  chest seems the fuel inventory for cars
    , defines.inventory.chest
  , defines.inventory.character_main
  , defines.inventory.cargo_wagon
  , defines.inventory.spider_trunk
  }
  local output = nil

  for key, value in pairs(supported_inventories) do
    output = luacontrol.get_main_inventory()
    game.print(serpent.block(output))
    if output ~= nil then return output, "Found " .. key end
  end
  return nil
end

local function flying_text(player, text, position)
  return player.create_local_flying_text { text = text, position = position }
end

local function dflying_text(player, text, position)
  flying_text(player, text, position)
end

local function eflying_text(player, text, position)
  flying_text(player, text, position)
  player.surface.play_sound { path = 'utility/cannot_build' }
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

  checkGlobal(event.player_index)

  storage.selected_object[event.player_index].entity = player.selected
  player.play_sound { path = 'cut_activated' }
  updateSelectedObjectDraw(event.player_index)
end)

function checkGlobal(playerIndex)
  if not storage.selected_object then storage.selected_object = {} end
  if storage.selected_object.valid ~= nil then storage.selected_object = {} end
  if storage.selected_object.active ~= nil then storage.selected_object = {} end

  if storage.selected_object[playerIndex] == nil then storage.selected_object[playerIndex] = {} end
end

function offsetVector(first, second)
  local result = {}
  result.x = first.x + second[1]
  result.y = first.y + second[2]
  return result
end

function updateSelectedObjectDraw(playerIndex)
  rendering.clear('inventory-mover')

  checkGlobal(playerIndex)

  local selected = storage.selected_object[playerIndex].entity

  if selected == nil then return end

  -- TOP LEFT

  storage.selected_object[playerIndex].draw_id1 = rendering.draw_line {
    color = { 0, 0.35, 1, 0.9 }, width = 4,
    from = offsetVector(selected.position, { -selected.tile_width / 2 - 0.00, -selected.tile_height / 2 - 0.00 }),
    to = offsetVector(selected.position, { -selected.tile_width / 2 - 0.00, -selected.tile_height / 2 - 0.35 }),
    surface = selected.surface,
    players = { player },
    only_in_alt_mode = true
  }

  storage.selected_object[playerIndex].draw_id2 = rendering.draw_line {
    color = { 0, 0.35, 1, 0.9 }, width = 4,
    from = offsetVector(selected.position, { -selected.tile_width / 2 - 0.00, -selected.tile_height / 2 - 0.00 }),
    to = offsetVector(selected.position, { -selected.tile_width / 2 - 0.35, -selected.tile_height / 2 - 0.00 }),
    surface = selected.surface,
    players = { player },
    only_in_alt_mode = true
  }

  -- TOP RIGHT

  storage.selected_object[playerIndex].draw_id3 = rendering.draw_line {
    color = { 0, 0.35, 1, 0.9 }, width = 4,
    from = offsetVector(selected.position, { selected.tile_width / 2 - 0.00, -selected.tile_height / 2 - 0.00 }),
    to = offsetVector(selected.position, { selected.tile_width / 2 + 0.00, -selected.tile_height / 2 - 0.35 }),
    surface = selected.surface,
    players = { player },
    only_in_alt_mode = true
  }

  storage.selected_object[playerIndex].draw_id4 = rendering.draw_line {
    color = { 0, 0.35, 1, 0.9 }, width = 4,
    from = offsetVector(selected.position, { selected.tile_width / 2 - 0.00, -selected.tile_height / 2 - 0.00 }),
    to = offsetVector(selected.position, { selected.tile_width / 2 + 0.35, -selected.tile_height / 2 - 0.00 }),
    surface = selected.surface,
    players = { player },
    only_in_alt_mode = true
  }

  -- BOTTOM RIGHT

  storage.selected_object[playerIndex].draw_id3 = rendering.draw_line {
    color = { 0, 0.35, 1, 0.9 }, width = 4,
    from = offsetVector(selected.position, { selected.tile_width / 2 - 0.00, selected.tile_height / 2 - 0.00 }),
    to = offsetVector(selected.position, { selected.tile_width / 2 + 0.35, selected.tile_height / 2 + 0.00 }),
    surface = selected.surface,
    players = { player },
    only_in_alt_mode = true
  }

  storage.selected_object[playerIndex].draw_id4 = rendering.draw_line {
    color = { 0, 0.35, 1, 0.9 }, width = 4,
    from = offsetVector(selected.position, { selected.tile_width / 2 - 0.00, selected.tile_height / 2 - 0.00 }),
    to = offsetVector(selected.position, { selected.tile_width / 2 + 0.00, selected.tile_height / 2 + 0.35 }),
    surface = selected.surface,
    players = { player },
    only_in_alt_mode = true
  }

  -- BOTTOM LEFT

  storage.selected_object[playerIndex].draw_id3 = rendering.draw_line {
    color = { 0, 0.35, 1, 0.9 }, width = 4,
    from = offsetVector(selected.position, { -selected.tile_width / 2 - 0.00, selected.tile_height / 2 - 0.00 }),
    to = offsetVector(selected.position, { -selected.tile_width / 2 + 0.00, selected.tile_height / 2 + 0.35 }),
    surface = selected.surface,
    players = { player },
    only_in_alt_mode = true
  }

  storage.selected_object[playerIndex].draw_id4 = rendering.draw_line {
    color = { 0, 0.35, 1, 0.9 }, width = 4,
    from = offsetVector(selected.position, { -selected.tile_width / 2 - 0.00, selected.tile_height / 2 - 0.00 }),
    to = offsetVector(selected.position, { -selected.tile_width / 2 - 0.35, selected.tile_height / 2 + 0.00 }),
    surface = selected.surface,
    players = { player },
    only_in_alt_mode = true
  }
end

script.on_event('transfer-to-destination', function(event)
  local player = game.get_player(event.player_index)
  local destination = player.selected

  checkGlobal(event.player_index)

  local source = storage.selected_object[event.player_index].entity
  local cursorStack = nil

  if player.cursor_stack ~= nil and player.cursor_stack.valid_for_read then cursorStack = player.cursor_stack end

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

  if player.physical_surface ~= source.surface then
    eflying_text(player, "Source not on same surface as player", destination.position)
    return
  elseif player.physical_surface ~= destination.surface then
    eflying_text(player, "Destination not on same surface as player", destination.position)
    return
  elseif source.surface ~= destination.surface then
    eflying_text(player, "Source and Destination not on the same surface ... How did you get this error message??",
      destination.position)
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



  local dInv, dMsg = updated_find(destination)
  local sInv, sMsg = updated_find(source)

  --game.print(serpent.block(defines.inventory))
  --dflying_text(player, sMsg, source.position)

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
      if cursorStack ~= nil and cursorStack.name ~= stack.name then goto continue end
      if dInv.can_insert(stack) then
        didInsert = true
        local count = dInv.insert(stack)
        stack.count = stack.count - count
        if sInv == dInv then dInv.sort_and_merge() end
      end
    end
    ::continue::
  end

  if cursorStack ~= nil and dInv.can_insert(cursorStack) then
    didInsert = true
    local count = dInv.insert(cursorStack)
    cursorStack.count = cursorStack.count - count
  end

  if not didInsert then
    eflying_text(player, "Destination is full", destination.position)
  else -- inserted
    player.play_sound { path = 'utility/inventory_move' }
  end

  checkGlobal(event.player_index)

  -- we didn't insert everything, let's keep our source
  -- -or- (else)
  -- we inserted everything, let's move our source to the destination
  if sInv.get_item_count() > 0 then
    storage.selected_object[event.player_index].entity = source
  else
    storage.selected_object[event.player_index].entity = destination
    updateSelectedObjectDraw(event.player_index)
  end
end)
