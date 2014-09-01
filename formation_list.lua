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

local formation_list = {}

function formation_list.makeitem(g, o, w, h)
  o.bg = flower.NineImage("ninepatch.9.png", w, h)
  o.bg:setPriority(-10)
  g:addChild(o.bg)
  o.name = flower.Label("", w - 20, h)
  Rainbow.color_styles(o.name)
  o.name:setLoc(10, 0)
  g:addChild(o.name)
  o.name:setPriority(1)
  o.portraits = {}
  for i = 1, 5 do
    local p = Portrait.new()
    g:addChild(p.group)
    p:setScl(0.5)
    p:setLoc(200 + (i * 70), 25)
    o.portraits[i] = p
  end
end

function formation_list.displayitem(g, o, item, w, h)
  o.name:setString(sprintf("Formation %d", item.idx or -1))
  for i = 1, 5 do
    if item.slots[i] and item.slots[i].element then
      printf("slot %d: showing element %s", i, item.slots[i].element.name)
      o.portraits[i]:display_element(item.slots[i].element)
    else
      o.portraits[i]:setVisible(false)
    end
  end
end

function formation_list.clickitem(item)
  printf("item clicked: %s", item.name)
end

function formation_list.onCreate()
  formation_list.ui = formation_list.ui or {}
  formation_list.viewport = MOAIViewport.new()
  formation_list.viewport:setSize(flower.screenWidth, flower.screenHeight - 100)
  formation_list.viewport:setScale(flower.viewWidth, flower.viewHeight - 100)
  formation_list.viewport:setOffset(-1, -1)
  if not formation_list.ui.layer then
    formation_list.ui.layer = flower.Layer(formation_list.viewport)
    formation_list.ui.layer:setClearColor(0.1, 0.2, 0.4)
  end
  formation_list.scene:addChild(formation_list.ui.layer)

  if not formation_list.ui.back_button then
    formation_list.ui.back_button = UI_Button.new('back', 70, 35, function() flower.closeScene() end)
    formation_list.ui.back_button:setLoc(10, 10)
    formation_list.ui.back_button:setLayer(formation_list.ui.layer)
  end

  if not formation_list.ui.scrolllist then
    formation_list.ui.scrolllist = UI_Scrolllist.new(748, 350, 720, 120, formation_list.makeitem, formation_list.displayitem, formation_list.clickitem, player.formations)
  end
  formation_list.ui.scrolllist:setLayer(formation_list.ui.layer)
  formation_list.ui.scrolllist:setLoc(10, 100)
end

function formation_list.onOpen()
  formation_list.ui.layer:setTouchEnabled(true)
end

function formation_list.onClose()
  formation_list.ui.layer:setTouchEnabled(false)
end

return formation_list
