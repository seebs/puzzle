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
  o.r = flower.Rect(w, h)
  o.r:setColor(1, .7, .7)
  g:addChild(o.r)
  o.name = flower.Label("", w - 20, h)
  Rainbow.color_styles(o.name)
  o.name:setLoc(10, 0)
  g:addChild(o.name)
  o.level = flower.Label("", 20, h, nil, 12)
  Rainbow.color_styles(o.level)
  o.level:setLoc(w - 20, 0)
  g:addChild(o.level)
end

function element_list.displayitem(g, o, i, w, h)
  o.name:setString(sprintf("<%s>%s</>", Genre.color_name(i.genre), i.name))
  o.level:setString(sprintf("%d", i.level or 1))
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
  printf("back.group: %s", tostring(element_list.ui.back_button.group))

  if not element_list.ui.scrolllist then
    element_list.ui.scrolllist = UI_Scrolllist.new(300, 200, 130, 40, element_list.makeitem, element_list.displayitem, element_list.clickitem, player.elements)
  end
  element_list.ui.scrolllist:setLayer(element_list.ui.layer)
  element_list.ui.scrolllist:setLoc(20, 100)
  printf("scrollist.group: %s", tostring(element_list.ui.scrolllist.group))

end

function element_list.onOpen()
  element_list.ui.layer:setTouchEnabled(true)
end

function element_list.onClose()
  element_list.ui.layer:setTouchEnabled(false)
end

return element_list
