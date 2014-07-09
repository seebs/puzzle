local main_ui = {}

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

function main_ui.go_to_scene(scene)
  if flower.SceneMgr.transitioning then
    return
  end
  flower.openScene(scene)
end

function main_ui.onCreate()
  local layer = flower.Layer()
  main_ui.scene:addChild(layer)
  layer:setTouchEnabled(true)
  
  local board_button = flower.Group(layer)
  local label = flower.Label("Board", 120, 30)
  board_button:addChild(label)
  board_button:addEventListener("touchDown", function() main_ui.go_to_scene('gem_board') end)
end

function main_ui.onOpen()
end

function main_ui.onClose()
end

return main_ui