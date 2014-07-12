local board_scene = {}

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

local board
local input_handler
local accepting_input = false
local next_action = nil
local keep_running = false

function board_scene.logic_loop()
  accepting_input = true
  while keep_running do
    if next_action then
      next_action = next_action()
    end
    coroutine.yield()
  end
  return
end

function board_scene.onCreate()
  lines = {}
  local approx_size = flower.viewWidth / 8
  -- printf("onCreate: board is %s.", tostring(board))
  board = Board.new(board_scene.scene, { texture = 1, color_multiplier = 1, rows = 7, columns = 7, size = { x = approx_size } })
end

function board_scene.onOpen()
  flower.InputMgr:addEventListener('touchDown', input_handler)
  flower.InputMgr:addEventListener('touchUp', input_handler)
  flower.InputMgr:addEventListener('touchMove', input_handler)
  flower.InputMgr:addEventListener('mouseClick', input_handler)
  flower.InputMgr:addEventListener('mouseMove', input_handler)
  keep_running = true
  board_scene.logic_coroutine = MOAICoroutine.new()
  board_scene.logic_coroutine:run(board_scene.logic_loop)
end

function board_scene.onClose()
  flower.InputMgr:removeEventListener('touchDown', input_handler)
  flower.InputMgr:removeEventListener('touchUp', input_handler)
  flower.InputMgr:removeEventListener('touchMove', input_handler)
  flower.InputMgr:removeEventListener('mouseClick', input_handler)
  flower.InputMgr:removeEventListener('mouseMove', input_handler)
  keep_running = false
  accepting_input = false
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
  for i = 1, 6 do
    local subtotal = 0
    if results[i] then
      for j = 1, #results[i] do
        subtotal = subtotal + results[i][j]
      end
      total = total + subtotal
    end
  end
  if total > 30 then
    flower.closeScene({animation = 'fade'})
    return nil
  end
  if false then
    for i = 1, 6 do
      if results[i] then
        printf("Color %d: %s", i, table.concat(results[i], ", "))
      end
    end
    printf("returning resume_input")
  end
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

return board_scene
