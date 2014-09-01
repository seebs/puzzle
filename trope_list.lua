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

local trope_list = {}

function trope_list.makeitem(g, o, w, h)
  o.bg = flower.NineImage("ninepatch.9.png", w, h)
  o.bg:setPriority(-10)
  g:addChild(o.bg)
  o.name = flower.Label("", w - 20, h)
  Rainbow.color_styles(o.name)
  o.name:setLoc(10, 0)
  g:addChild(o.name)
  o.name:setPriority(1)
  o.level = flower.Label("", 20, h, nil, 12)
  Rainbow.color_styles(o.level)
  o.level:setLoc(10, -25)
  g:addChild(o.level)
  o.level:setPriority(1)

  o.portrait = Portrait.new()
  g:addChild(o.portrait.group)
  o.portrait:setVisible(false)
  o.portrait:setScl(0.6)
  o.portrait:setLoc(w - 30, 50)
end

function trope_list.displayitem(g, o, i, w, h)
  o.name:setString(sprintf("<%s>%s</>", Genre.color_name(i.genre), i.name))
  o.level:setString(sprintf("%d", i.level or 1))
  o.portrait:display_trope(i)
end

function trope_list.clickitem(item)
  printf("item clicked: %s", item.name)
end

function trope_list.onCreate()
  trope_list.ui = trope_list.ui or {}
  trope_list.viewport = MOAIViewport.new()
  trope_list.viewport:setSize(flower.screenWidth, flower.screenHeight - 100)
  trope_list.viewport:setScale(flower.viewWidth, flower.viewHeight - 100)
  trope_list.viewport:setOffset(-1, -1)
  if not trope_list.ui.layer then
    trope_list.ui.layer = flower.Layer(trope_list.viewport)
    trope_list.ui.layer:setClearColor(0.1, 0.2, 0.4)
  end
  trope_list.scene:addChild(trope_list.ui.layer)

  if not trope_list.ui.back_button then
    trope_list.ui.back_button = UI_Button.new('back', 70, 35, function() flower.closeScene() end)
    trope_list.ui.back_button:setLoc(10, 10)
    trope_list.ui.back_button:setLayer(trope_list.ui.layer)
  end

  if not trope_list.ui.scrolllist then
    trope_list.ui.scrolllist = UI_Scrolllist.new(748, 350, 300, 120, trope_list.makeitem, trope_list.displayitem, trope_list.clickitem, player.tropes)
  end
  trope_list.ui.scrolllist:setLayer(trope_list.ui.layer)
  trope_list.ui.scrolllist:setLoc(10, 100)
end

function trope_list.onOpen()
  trope_list.ui.layer:setTouchEnabled(true)
end

function trope_list.onClose()
  trope_list.ui.layer:setTouchEnabled(false)
end

return trope_list
