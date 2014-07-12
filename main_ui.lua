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
  main_ui.ui = main_ui.ui or {}
  if not main_ui.ui.layer then
    main_ui.ui.layer = flower.Layer()
    main_ui.ui.layer:setClearColor(0.3, 0.2, 0.1)
    -- layer:setClearColor(1.0, 0, 0.7)
  end
  main_ui.scene:addChild(main_ui.ui.layer)

  if not main_ui.card then
    local c = Card.new(main_ui.ui.layer)
    c:setLoc(212, 284)
    c:setRot(0, 0, 0)
    main_ui.card = c
  end

  local board_button = UI_Button.new("board")
  board_button.group:setLoc(100, 100)
  board_button.group:setLayer(main_ui.ui.layer)
  board_button.group:addEventListener("touchDown", function() main_ui.go_to_scene('gem_board') end)
end

function main_ui.onOpen()
  main_ui.card:setVisible(false)
  main_ui.ui.layer:setTouchEnabled(true)
end

function main_ui.onClose()
  main_ui.ui.layer:setTouchEnabled(false)
end

return main_ui
