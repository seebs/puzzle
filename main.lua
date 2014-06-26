Util = require('Util')
Settings = require('Settings')

Input = require('Input')
Rainbow = require('Rainbow')
Sound = require('Sound')

Board = require('Board')

local Rainbow = Rainbow
local Settings = Settings
local Util = Util

local printf = Util.printf

MOAISim.openWindow("test", Settings.screen.width, Settings.screen.height)

local viewport = MOAIViewport.new()
viewport:setSize(Settings.screen.width, Settings.screen.height)
viewport:setScale(Settings.screen.width, Settings.screen.height)

local layer = MOAILayer2D.new()
layer:setViewport(viewport)
layer.viewport = viewport
MOAIRenderMgr.setRenderTable( { layer } )

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

-- settings and the Screen object
local rfuncs
local colorfor
local colorize

local total_colors = #Rainbow.hues * 1
local rfuncs = Rainbow.funcs_for(1)
local colorfor = rfuncs.smooth
local colorize = rfuncs.smoothobj

local function setup()
  lines = {}
  board = Board.new(Settings.screen, layer, { texture = 1, color_multiplier = 1, rows = 7, columns = 7, size = { x = 64 } })
end

local sim_cycles = 0
local draw_rate = 2
local draw_cycles = draw_rate
local alternate_frames = 0

function every_frame()
  while true do
    coroutine.yield()
    sim_cycles = sim_cycles + 1
    if draw_cycles >= draw_rate then
      draw_cycles = 0
    end
  end
end

frames = MOAICoroutine.new()
frames:run(every_frame)

local stable_frames = 0
local count = 0
local max_count = nil

function do_draw()
  local fps = MOAISim.getPerformance()

  if sim_cycles ~= 1 or fps < 50 or fps > 62 or stable_frames > 100 then
    -- printf("%d cycles, %.1f fps (%d stable)", sim_cycles, fps, stable_frames)
    stable_frames = 0
  else
    stable_frames = stable_frames + 1
  end
  sim_cycles = 0
  draw_cycles = draw_cycles + 1
  count = count + 1
  if max_count and (count > max_count) then
    os.exit(0)
  end
end

local sd = MOAIScriptDeck.new()
sd:setDrawCallback(do_draw)
sd:setRect(-64, -64, 64, 64)
local sdp = MOAIProp2D.new()
sdp:setDeck(sd)
layer:insertProp(sdp)

setup()

local this_gem = nil
local this_hex = nil
local other_gem = nil
local other_hex = nil
local effective_drag_start = nil

-- for now, only handle events[1]
local function input_handler(events)
  local e = events and events[1] or nil
  if not e then
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
	effective_drag_start = { x = e.start_x, y = e.start_y }
	if gem then
	  this_gem = gem
	  this_gem:pulse(true)
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
	this_gem:drop()
	if other_gem then
	  other_gem:drop()
	end
	this_gem = nil
	this_hex = nil
	other_gem = nil
	other_hex = nil
      end
    end
  end
end

Input.list()
Input.set_layer(layer)

Input.set_handler(input_handler)
