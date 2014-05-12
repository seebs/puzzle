Util = require('Util')
Settings = require('Settings')

Input = require('Input')
Rainbow = require('Rainbow')
Sound = require('Sound')

Hexes = require('Hexes')

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
MOAIRenderMgr.setRenderTable( { layer } )

local pi = math.pi
local fmod = math.fmod
local random = math.random
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

local board = {}

local function setup()
  lines = {}
  board.grid = Hexes.new(Settings.screen, layer, { texture = 1, color_multiplier = 1, rows = 7, columns = 7, size = { x = 64 } })
  for i = -3, 3 do
    board[i] = {}
    local base = (i > 0) and (i - 3) or -3
    local range = 6 - abs(i)
    for j = base, base + range do
      if board.grid.c[j + 4] then
        board[i][j] = board.grid.c[j + 4][i + 4]
      end
      if board[i][j] then
        board[i][j].tile = i + 4
        board[i][j].color = j + 4
      end
    end
  end
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
local max_count = 3000

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
  if count > max_count then
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

