local gem_board = {}

local pi = math.pi
local fmod = math.fmod
local random = math.random
local pi = math.pi
local sin = math.sin
local min = math.min
local max = math.max
local cos = math.cos
local sqrt = math.sqrt
local atan2 = math.atan2
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local printf = Util.printf
local sprintf = Util.sprintf
local tremove = table.remove

local board
local input_handler
local accepting_input = false
local next_action = nil
local keep_running = false

function gem_board.logic_loop()
  accepting_input = true
  while keep_running do
    if next_action then
      next_action = next_action()
    end
    coroutine.yield()
  end
  flower.closeScene({animation = 'fade'})
  return
end

function gem_board.check_monsters()
  if gem_board.monsters then
    local remove = {}
    printf("Checking monsters:")
    for i = 1, #gem_board.monsters do
      local mon = gem_board.monsters[i]
      printf("%d: %s [%d/%d]", i, mon.name, mon.inspiration, mon.max_inspiration)
      if mon.status.inspiration <= 0 then
        remove[#remove + 1] = i
      end
    end
    for i = #remove, 1, -1 do
      tremove(gem_board.monsters, remove[i])
    end
  end
  if not gem_board.monsters or #gem_board.monsters < 1 then
    gem_board.room_number = gem_board.room_number + 1
    gem_board.room = gem_board.dungeon.rooms[gem_board.room_number]
    if not gem_board.room then
      gem_board.done()
      return
    end
    gem_board.monsters = {}
    for i = 1, #gem_board.room.monsters do
      local e = Element.new(gem_board.room.monsters[i])
      e.max_inspiration = e.status.inspiration
      e.inspiration = e.status.inspiration
      e.idx = i
      printf("Adding monster (%s, level %d, health %d)", e.name, e.level, e.inspiration)
      gem_board.monsters[i] = e
      gem_board.ui.bars[i]:setVisible(true)
      gem_board.ui.bars[i]:setColor(Genre.rgb(e.genre))
      gem_board.ui.bars[i]:display_value(e.inspiration, 0, e.max_inspiration)
      gem_board.ui.monster_portraits[i]:display_element(e)
    end
  end
end

function gem_board.done()
  keep_running = false
end

function gem_board.onCreate()
  -- printf("onCreate: board is %s.", tostring(board))
  if not board then
    local approx_size = flower.viewWidth / 8
    board = Board.new(gem_board.scene, { texture = 1, color_multiplier = 1, rows = 7, columns = 7, size = { x = approx_size } })
  else
    board:populate()
  end
  gem_board.ui = {}
  gem_board.ui.layer = flower.Layer()
  gem_board.scene:addChild(gem_board.ui.layer)
  gem_board.ui.bars = {}
  gem_board.ui.player_portraits = {}
  gem_board.ui.monster_portraits = {}
  for i = 1, 5 do
    gem_board.ui.bars[i] = UI_Bar.new()
    gem_board.ui.bars[i]:setVisible(false)
    gem_board.ui.bars[i]:setLoc(150 * i, 875)
    gem_board.ui.bars[i]:setLayer(gem_board.ui.layer)
    gem_board.ui.monster_portraits[i] = Portrait.new()
    gem_board.ui.monster_portraits[i]:setLayer(gem_board.ui.layer)
    gem_board.ui.monster_portraits[i]:setVisible(false)
    gem_board.ui.monster_portraits[i]:setLoc((150 * i) + 65, 950)
    gem_board.ui.monster_portraits[i]:setScl(0.8)
  end
  gem_board.dungeon = Dungeon.new(1)
  gem_board.room_number = 0
end

function gem_board.onOpen()
  flower.InputMgr:addEventListener('touchDown', input_handler)
  flower.InputMgr:addEventListener('touchUp', input_handler)
  flower.InputMgr:addEventListener('touchMove', input_handler)
  flower.InputMgr:addEventListener('mouseClick', input_handler)
  flower.InputMgr:addEventListener('mouseMove', input_handler)
  keep_running = true
  gem_board.logic_coroutine = MOAICoroutine.new()
  gem_board.logic_coroutine:run(gem_board.logic_loop)
  -- initial setup: grab the first room
  player.formation.inspiration = player.formation.max_inspiration
  gem_board.check_monsters()
end

function gem_board.onClose()
  flower.InputMgr:removeEventListener('touchDown', input_handler)
  flower.InputMgr:removeEventListener('touchUp', input_handler)
  flower.InputMgr:removeEventListener('touchMove', input_handler)
  flower.InputMgr:removeEventListener('mouseClick', input_handler)
  flower.InputMgr:removeEventListener('mouseMove', input_handler)
  keep_running = false
  accepting_input = false
  board = nil
end

local this_gem = nil
local this_hex = nil
local other_gem = nil
local other_hex = nil
local effective_drag_start = nil

local function resume_input()
  accepting_input = true
  return nil
end

local function handle_matches()
  -- printf("handle_matches")
  local results = board:find_and_process_matches()
  local total = 0
  local combos = 0
  local totals = Genre.list(0)
  for i = 1, 6 do
    if results[i] then
      local g = Genre.genre(i)
      local subtotal = 0
      combos = combos + #results[i]
      for j = 1, #results[i] do
        subtotal = subtotal + results[i][j]
      end
      totals[g] = subtotal
      total = total + subtotal
    end
  end
  local damage = Genre.list(0)
  for g, v in pairs(totals) do
    local wc = player.formation.stats.wordcount[g] or 0
    damage[g] = wc * v / 3
    damage[g] = damage[g] * (1 + (.1 * combos))
  end
  if true then
    printf("Total %d combo.", combos)
    for i = 1, 6 do
      local g = Genre.genre(i)
      if damage[g] then
        printf("%s: %d", g, damage[g])
	if gem_board.monsters and gem_board.monsters[1] then
	  gem_board.monsters[1].inspiration = gem_board.monsters[1].inspiration - damage[g]
	  if gem_board.monsters[1].inspiration < 0 then
	    local idx = gem_board.monsters[1].idx
	    printf("Monster killed.")
            gem_board.ui.bars[idx]:setVisible(false)
            gem_board.ui.monster_portraits[idx]:setVisible(false)
	    tremove(gem_board.monsters, 1)
	  else
	    gem_board.ui.bars[1]:display_value(gem_board.monsters[1].inspiration, 0, gem_board.monsters[1].max_inspiration)
	  end
	end
      end
    end
    printf("returning resume_input")
  end
  gem_board.check_monsters()
  return resume_input
end

local gem_swap_sound_toggle = false

local button_down = false
local drag_start = { x = 0, y = 0 }

input_handler = function(e)
  if not accepting_input then
    return
  end
  e.x, e.y = board.layer:wndToWorld(e.x, e.y)
  if e.type == 'mouseClick' then
    if e.down then
      button_down = true
      drag_start.x = e.x
      drag_start.y = e.y
      e.state = 'press'
    else
      button_down = false
      e.state = 'release'
    end
  elseif e.type == 'mouseMove' then
    if e.down and button_down then
      e.state = 'drag'
    else
      return
    end
  else
    return
  end
  -- Util.dump(e)
  if e.down then
    if e.state == 'press' then
      local hex = board:from_screen(e.x, e.y)
      -- Util.dump(hex)
      if hex then
        local gem = hex.gem
	this_hex = hex
	local nx, ny = board:to_screen(hex.x, hex.y)
	-- printf("hex: from_screen(%d, %d), coords %d, %d, to_screen(%d, %d)", e.x, e.y, hex.x, hex.y, nx, ny)
	effective_drag_start = { x = drag_start.x, y = drag_start.y }
	if gem then
	  this_gem = gem
	  this_gem:pickup()
	end
      end
    elseif e.state == 'drag' then
      if this_gem then
	local dx, dy
	dx = e.x - effective_drag_start.x
	dy = e.y - effective_drag_start.y
	if dx ~=0 or dy ~= 0 then
	  local angle = atan2(dx, dy)
	  if angle < 0 then
	    angle = angle + (pi * 2)
	  end
	  local distance = sqrt(dx * dx + dy * dy)
	  local closest_dir = nil
	  local closest_angle = 99999
	  local distance_scale = 0
	  local inverse_scale = 0

	  for dir, offsets in pairs(board.directions) do
	    local diff = abs(offsets.angle - angle)
	    if diff < closest_angle then
	      closest_dir = dir
	      closest_angle = diff
	      distance_scale = distance / offsets.dist
	    end
	  end

	  -- printf("best angle: %s [angle diff %.1f deg], scale %.1f", closest_dir, closest_angle * 180 / pi, distance_scale)
	  local next_hex = this_hex:neighbor(closest_dir)
	  local this_side, that_side
	  inverse_scale = 1 - distance_scale
	  if next_hex then
	    if other_gem and other_gem ~= next_hex.gem then
	      other_gem:drop()
	    end
	    other_hex = next_hex
	    other_gem = other_hex.gem
	    this_side = { x = (other_hex.sx * distance_scale) + (this_hex.sx * inverse_scale),
	                  y = (other_hex.sy * distance_scale) + (this_hex.sy * inverse_scale) }
	    that_side = { x = (other_hex.sx * inverse_scale) + (this_hex.sx * distance_scale),
	                  y = (other_hex.sy * inverse_scale) + (this_hex.sy * distance_scale) }
	  else
	    if other_gem then
	      other_gem:drop()
	      other_gem = nil
	      other_hex = nil
	    end
	  end
	  if other_gem then
	    if not distance_scale or distance_scale < 0.3 then
	      other_gem:drop()
	      other_gem = nil
	    elseif distance_scale > 0.75 then
	      -- swap the gems
	      other_hex, this_hex = this_hex, other_hex
	      -- swap location/gem bindings (since the this_hex/other_hex references changed)
	      this_gem.hex, other_gem.hex = this_hex, other_hex
	      this_hex.gem, other_hex.gem = this_gem, other_gem
	      -- these don't seem to need to change.
	      -- this_side, that_side = that_side, this_side
	      -- distance_scale, inverse_scale = inverse_scale, distance_scale
	      local nx, ny = board:to_screen(this_hex.x, this_hex.y)
	      effective_drag_start = { x = nx, y = ny }
	      other_gem:drop()
	      other_gem = nil
	      if gem_swap_sound_toggle then
	        Sound.play('key')
	      else
	        Sound.play('space')
	      end
	    elseif distance_scale > 0.3 then
	      other_gem:pulse(true)
	    end
	  end
	  if this_side then
	    this_gem:setLoc(this_side.x, this_side.y)
	  else
	    this_gem:setLoc(this_hex.sx + dx, this_hex.sy + dy)
	  end
	end
      end
    end
  else
    if e.state == 'release' then
      if this_gem then
	Sound.play('return')
	this_gem:drop()
	if other_gem then
	  other_gem:drop()
	end
	this_gem = nil
	this_hex = nil
	other_gem = nil
	other_hex = nil
	accepting_input = false
	-- printf("released button, but not checking for matches")
	next_action = handle_matches
      end
    end
  end
end

return gem_board
