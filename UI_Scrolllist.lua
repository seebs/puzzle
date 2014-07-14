local UI_Scrolllist = {}

local printf = Util.printf
local sprintf = Util.sprintf
local floor = math.floor
local ceil = math.ceil
local sqrt = math.sqrt

function UI_Scrolllist.new(width, height, itemwidth, itemheight, createfunc, displayfunc, clickfunc, list, spacing)
  if itemheight < 1 then
    return nil
  end

  if not createfunc or not displayfunc or not clickfunc then
    return nil
  end

  local o = {}

  setmetatable(o, {__index = UI_Scrolllist.memberhash})
  o.width = width
  o.height = height
  o.itemwidth = itemwidth
  o.itemheight = itemheight
  o.spacing = spacing or 5
  o.rowheight = (o.itemheight + o.spacing)
  o.createfunc = createfunc
  o.displayfunc = displayfunc
  o.clickfunc = clickfunc
  o.list = list
  o.row_offset = 0
  o.pixel_offset = 0
  o.position = 0

  o.group = flower.Group()

  o.scissor = MOAIScissorRect.new()
  o.scissor:setRect(0, 0, o.width, o.height)

  o.group:setScissorRect(o.scissor)

  o.scissor:setAttrLink(MOAITransform.INHERIT_LOC, o.group, MOAITransform.TRANSFORM_TRAIT)

  o.visible_items = (o.height / (o.itemheight + o.spacing)) + 2

  if true then
    o.debuggy = flower.Rect(1000, 1000)
    o.group:addChild(o.debuggy)
    o.debuggy:setLoc(-100, -100)
    o.debuggy:setColor(0, 0.5, 0, 0.3)
  end

  o.items = {}
  o.scratch = {}
  for i = 1, o.visible_items do
    local props = {}
    local g = flower.Group()
    g.list = o
    g:addEventListener("touchUp", function(...) UI_Scrolllist.item_event(g, ...) end)
    g:addEventListener("touchMove", function(...) UI_Scrolllist.item_event(g, ...) end)
    g:addEventListener("touchDown", function(...) UI_Scrolllist.item_event(g, ...) end)
    g:addEventListener("touchCancel", function(...) UI_Scrolllist.item_event(g, ...) end)
    o.scratch[i] = { idx = i }
    o.createfunc(g, o.scratch[i], o.itemwidth, o.itemheight)
    -- assume that all props are stored in the scratch space
    for k, v in pairs(o.scratch[i]) do
      props[v] = true
    end
    g.props = props
    g:setScissorRect(o.scissor)
    o.group:addChild(g)
    g:setLoc(0, o.height - (o.rowheight * i) + o.spacing)
    o.items[i] = g
  end

  o:display()

  o.group:addEventListener("touchUp", function(...) UI_Scrolllist.event(o, ...) end)
  o.group:addEventListener("touchMove", function(...) UI_Scrolllist.event(o, ...) end)
  o.group:addEventListener("touchDown", function(...) UI_Scrolllist.event(o, ...) end)
  o.group:addEventListener("touchCancel", function(...) UI_Scrolllist.event(o, ...) end)

  return o
end

function UI_Scrolllist:event(e)
  local layer = self.group.layer
  if not layer then
    return
  end
  local x0, y0, x1, y1 = self.scissor:getRect()
  local x, y = self.scissor:worldToModel(layer:wndToWorld(e.x, e.y))
  local for_me = x > x0 and x < x1 and y > y0 and y < y1
  -- printf("event: main list, event %s [for_me %s]", e.type, for_me)
  if not for_me then
    self.drag_start = nil
    return
  end
  if e.type == 'touchDown' and for_me then
    self.drag_start = y
    e:stop()
  elseif e.type == 'touchMove' then
    if self.drag_start then
      self:scroll(y - self.drag_start)
    end
    self.drag_start = y
    e:stop()
  else
    self.drag_start = nil
  end
end

function UI_Scrolllist:item_event(e)
  local for_me = e.active_prop and self.props[e.active_prop] or false
  -- printf("item_event: item %s, event %s [for_me %s].", tostring(self.item), e.type, for_me)
  if e.type == 'touchDown' then
    -- look clicked
    if for_me then
      self.down = true
      self.drag_start = { x = e.x, y = e.y }
    end
  elseif e.type == 'touchCancel' then
    self.down = false
  elseif e.type == 'touchMove' then
    if self.down and self.drag_start then
      local dx, dy = e.x - self.drag_start.x, e.y - self.drag_start.y
      -- if you've moved more than a little, you probably aren't clicking.
      if (dx * dx + dy + dy) > 9 then
        self.down = false
	self.drag_start = nil
      else
        e:stop()
      end
    end
  elseif e.type == 'touchUp' then
    if self.down and for_me then
      e:stop()
      if self.list.clickfunc then
        self.list.clickfunc(self.item)
      end
    end
    self.down = false
    self.drag_start = nil
  end
end

function UI_Scrolllist:display()
  for i = 1, self.visible_items do
    local j = i + self.row_offset
    local g = self.items[i]
    g:setLoc(0, self.height - (self.rowheight * i) + self.spacing + self.pixel_offset)
    if self.list and self.list[j] then
      g.item = self.list[j]
      self.displayfunc(g, self.scratch[i], self.list[j], self.itemwidth, self.itemheight)
      g:setVisible(true)
    else
      g.item = nil
      g:setVisible(false)
    end
  end
end

function UI_Scrolllist:onClick()
end

function UI_Scrolllist:scroll(offset)
  return self:setScroll(self.position + offset)
end

function UI_Scrolllist:setScroll(position)
  local max = #self.list * self.rowheight - self.spacing - self.height
  if position < 0 then
    position = 0
  end
  if position > max then
    position = max
  end
  if position == self.position then
    return false
  end
  self.position = position
  self.row_offset = floor((position - self.spacing) / self.rowheight)
  self.pixel_offset = self.position - (self.row_offset * self.rowheight)
  self:display()
  return true
end

function UI_Scrolllist:setList(list)
  printf("unimplemented")
end

UI_Scrolllist.memberhash = {
  setRect = function(self, ...) self.scissor:setRect(...) end,
  setList = UI_Scrolllist.setList,
  scroll = UI_Scrolllist.scroll,
  setScroll = UI_Scrolllist.setScroll,
  display = UI_Scrolllist.display,
}

Util.makepassthrough(UI_Scrolllist.memberhash, 'group')

return UI_Scrolllist
