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

local element_list = {}

function element_list.makeitem(g, o, w, h)
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

function element_list.displayitem(g, o, i, w, h)
  o.name:setString(sprintf("<%s>%s</>", Genre.color_name(i.genre), i.name))
  o.level:setString(sprintf("%d", i.level or 1))
  o.portrait:display_element(i)
end

function element_list.clickitem(item)
  printf("item clicked: %s", item.name)
end

function element_list.onCreate()
  element_list.ui = element_list.ui or {}
  element_list.viewport = MOAIViewport.new()
  element_list.viewport:setSize(flower.screenWidth, flower.screenHeight - 100)
  element_list.viewport:setScale(flower.viewWidth, flower.viewHeight - 100)
  element_list.viewport:setOffset(-1, -1)
  if not element_list.ui.layer then
    element_list.ui.layer = flower.Layer(element_list.viewport)
    element_list.ui.layer:setClearColor(0.1, 0.2, 0.4)
  end
  element_list.scene:addChild(element_list.ui.layer)

  if not element_list.ui.back_button then
    element_list.ui.back_button = UI_Button.new('back', 70, 35, function() flower.closeScene() end)
    element_list.ui.back_button:setLoc(10, 10)
    element_list.ui.back_button:setLayer(element_list.ui.layer)
  end

  if not element_list.ui.scrolllist then
    element_list.ui.scrolllist = UI_Scrolllist.new(748, 350, 300, 120, element_list.makeitem, element_list.displayitem, element_list.clickitem, player.elements)
  end
  element_list.ui.scrolllist:setLayer(element_list.ui.layer)
  element_list.ui.scrolllist:setLoc(10, 100)
end

function element_list.onOpen()
  element_list.ui.layer:setTouchEnabled(true)
end

function element_list.onClose()
  element_list.ui.layer:setTouchEnabled(false)
end

return element_list
