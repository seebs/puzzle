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

function main_ui.makeitem(g, o, w, h)
  o.r = flower.Rect(w, h)
  o.r:setColor(1, .7, .7)
  g:addChild(o.r)
  o.l = flower.Label("", w, h)
  o.l:setLoc(10, 0)
  g:addChild(o.l)
  o.l2 = flower.Label(sprintf("%d", o.idx) , w, h)
  o.l2:setLoc(w - 20, 0)
  g:addChild(o.l2)
end

function main_ui.displayitem(g, o, i, w, h)
  o.l:setString(i.name)
end

function main_ui.clickitem(item)
  printf("item clicked: %s", item.name)
end

local list = {
  { name = "3x5.acorn" },
  { name = "3x5.png" },
  { name = "Board.lua" },
  { name = "Card.lua" },
  { name = "Element.lua" },
  { name = "Flag.lua" },
  { name = "Formation.lua" },
  { name = "Genre.lua" },
  { name = "Hexes.lua" },
  { name = "Input.lua" },
  { name = "Player.lua" },
}

function main_ui.onCreate()
  main_ui.ui = main_ui.ui or {}
  if not main_ui.ui.layer then
    main_ui.ui.layer = flower.Layer()
    main_ui.ui.layer:setClearColor(0.3, 0.2, 0.1)
    -- layer:setClearColor(1.0, 0, 0.7)
  end
  main_ui.scene:addChild(main_ui.ui.layer)

  if not main_ui.ui.scrolllist then
    main_ui.ui.scrolllist = UI_Scrolllist.new(250, 200, 180, 40, main_ui.makeitem, main_ui.displayitem, main_ui.clickitem, list)
  end
  main_ui.ui.scrolllist:setLayer(main_ui.ui.layer)
  main_ui.ui.scrolllist:setLoc(20, 100)
  main_ui.ui.scrolllist:scroll(5)

  if not main_ui.ui.board_button then
    main_ui.ui.board_button = UI_Button.new("board", 150, 35, function() main_ui.go_to_scene('gem_board') end)
    main_ui.ui.board_button.group:setLoc(100, 50)
    main_ui.ui.board_button.group:setLayer(main_ui.ui.layer)
  end
end

function main_ui.onOpen()
  main_ui.ui.layer:setTouchEnabled(true)
end

function main_ui.onClose()
  main_ui.ui.layer:setTouchEnabled(false)
end

return main_ui
