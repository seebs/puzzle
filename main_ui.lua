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
  flower.openScene(scene)
end

function main_ui.show_overlay(scene)
  flower.openScene(scene, { animation = 'overlay' })
end

function main_ui.onCreate()
  main_ui.ui = main_ui.ui or {}
  if not main_ui.ui.layer then
    main_ui.ui.layer = flower.Layer()
    main_ui.ui.layer:setClearColor(0.3, 0.2, 0.1)
  end
  main_ui.scene:addChild(main_ui.ui.layer)

  if not main_ui.ui.board_button then
    main_ui.ui.board_button = UI_Button.new("board", 150, 35, function() main_ui.go_to_scene('gem_board') end)
    main_ui.ui.board_button.group:setLoc(100, 50)
    main_ui.ui.board_button.group:setLayer(main_ui.ui.layer)
  end

  if not main_ui.ui.list_button then
    main_ui.ui.list_button = UI_Button.new("list", 150, 35, function() main_ui.show_overlay('element_list') end)
    main_ui.ui.list_button.group:setLoc(100, 10)
    main_ui.ui.list_button.group:setLayer(main_ui.ui.layer)
  end
end

function main_ui.onOpen()
  main_ui.ui.layer:setTouchEnabled(true)
end

function main_ui.onClose()
  main_ui.ui.layer:setTouchEnabled(false)
end

function main_ui.onStop()
  main_ui.scene:setColor(0.5, 0.5, 0.5)
end

function main_ui.onStart()
  main_ui.scene:setColor(1, 1, 1, 1)
end

return main_ui
