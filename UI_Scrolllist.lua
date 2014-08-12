local UI_Scrolllist = {}

local printf = Util.printf
local sprintf = Util.sprintf
local floor = math.floor
local ceil = math.ceil
local sqrt = math.sqrt

local SCROLLBAR_WIDTH = 10

--[[

We reserve 10ish pixels for a scrollbar on the right. Everything is indented by spacing.
So we start with

	sssss
	sIIIs
	s   s
	sssss

The number of horizontal items is floor((width - spacing - 10) / (itemheight + spacing))

If that number is below zero, it's an error; otherwise, each row gets multiple items. If
there's multiple items, horizontal spacing between them may be larger. The net result is:
	inner_width = width - (spacing * 2)
	inner_spacing = (inner_width - (nitems * itemwidth)) / (nitems - 1)
Horizontal spacing won't be less than the base spacing.

]]--

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
  o.items_per_row = floor((o.width - o.spacing) / (o.itemwidth + o.spacing))
  if o.items_per_row < 1 then
    return nil
  end
  o.inner_width = o.width - (o.spacing * 2) - SCROLLBAR_WIDTH
  o.inner_height = o.height - (o.spacing * 2)
  if o.items_per_row > 1 then
    o.inner_spacing = (o.inner_width - (o.itemwidth * o.items_per_row)) / (o.items_per_row - 1)
  else
    o.inner_spacing = 0
  end
  o.rowheight = (o.itemheight + o.spacing)
  o.createfunc = createfunc
  o.displayfunc = displayfunc
  o.clickfunc = clickfunc
  o.list = list

  o.group = flower.Group()

  o.scissor = MOAIScissorRect.new()
  o.scissor:setRect(0, 0, o.width, o.height)
  o.group:setBounds(0, 0, 0, o.width, o.height, 0)

  o.group:setScissorRect(o.scissor)

  o.scissor:setAttrLink(MOAITransform.INHERIT_LOC, o.group, MOAITransform.TRANSFORM_TRAIT)

  o.visible_rows = ceil((o.inner_height - o.itemheight) / o.rowheight) + 1
  o.visible_items = o.visible_rows * o.items_per_row
  o.partial_row = o.inner_height - (o.rowheight * (o.visible_rows - 1))
  -- printf("list height: %d pix inner, %d per row, %d rows, %d px left over",
  --   o.inner_height, o.rowheight, o.visible_rows - 1, o.partial_row)

  if false then
    o.debuggy = flower.Rect(1000, 1000)
    o.group:addChild(o.debuggy)
    -- printf("debuggy: %s", tostring(o.debuggy))
    o.debuggy:setLoc(-100, -100)
    o.debuggy:setColor(0, 0.5, 0, 0.3)
  end

  o.rows = {}
  o.items = {}
  o.scratch = {}
  local item_count = 0
  for i = 1, o.visible_rows do
    o.rows[i] = flower.Group()
    o.rows[i].items = {}
    for j = 1, o.items_per_row do
      item_count = item_count + 1
      local props = {}
      local g = flower.Group()
      g.list = o
      g:addEventListener("touchUp", function(...) UI_Scrolllist.item_event(g, ...) end)
      g:addEventListener("touchMove", function(...) UI_Scrolllist.item_event(g, ...) end)
      g:addEventListener("touchDown", function(...) UI_Scrolllist.item_event(g, ...) end)
      g:addEventListener("touchCancel", function(...) UI_Scrolllist.item_event(g, ...) end)
      o.scratch[item_count] = { }
      o.createfunc(g, o.scratch[item_count], o.itemwidth, o.itemheight)
      -- assume that all props are stored in the scratch space
      for k, v in pairs(o.scratch[item_count]) do
        props[v] = true
      end
      g.props = props
      g:setScissorRect(o.scissor)
      o.group:addChild(g)
      g.xoffset = ((j - 1) * (o.itemwidth + o.inner_spacing)) + o.spacing
      -- actual computation will happen in :display
      g:setLoc(g.xoffset, 0)
      o.rows[i].items[j] = g
      o.items[item_count] = g
    end
  end

  o.border = flower.NineImage("outer.9.png", o.width, o.height)
  o.group:addChild(o.border)
  o.border:setLoc(0, 0)

  o.scrollbar_height = o.height - (o.spacing * 2) - 2
  o.scrollbar_y_offset = o.spacing + 1
  o.scrollbar_x_offset = o.width - SCROLLBAR_WIDTH - o.spacing + 1
  o.scrollbar = flower.NineImage("thumb.9.png", SCROLLBAR_WIDTH - 2, o.scrollbar_height)
  o.scrollbar:setLoc(o.scrollbar_x_offset, o.scrollbar_y_offset)
  o.scrollbar:setColor(0.5, 0.5, 0.5, 1.0)
  o.group:addChild(o.scrollbar)

  o.thumb = flower.NineImage("thumb.9.png", SCROLLBAR_WIDTH - 2, 20)
  o.scrollbar:setLoc(o.scrollbar_x_offset, o.scrollbar_y_offset)
  o.thumb:setColor(0.8, 0.8, 0.8, 1.0)
  o.group:addChild(o.thumb)

  o:setScroll(0)

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
  -- printf("event: main list, event %s [for_me %s]", e.type, tostring(for_me))
  if not for_me then
    self.drag_start = nil
    return
  end
  if e.type == 'touchDown' and for_me then
    self.drag_start = y
    self.down = true
    e:stop()
  elseif e.type == 'touchMove' then
    if self.drag_start and self.down then
      self:scroll(y - self.drag_start)
    end
    self.drag_start = y
    e:stop()
  else
    self.drag_start = nil
    self.down = false
  end
end

function UI_Scrolllist:item_event(e)
  local for_me = e.active_prop and self.props[e.active_prop] or false
  -- printf("item_event: item %s, event %s [for_me %s].", tostring(self.item), e.type, tostring(for_me))
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
  local row_index = 1
  local last_item = false
  for i = 1, self.visible_items do
    local j = i + (self.row_offset * self.items_per_row)
    if j == #self.list then
      last_item = true
    end
    local g = self.items[i]
    local y = self.height - (self.rowheight * row_index) + self.pixel_offset
    -- printf("box %d: item %s", i, tostring(self.list[j]))
    g:setLoc(g.xoffset, y)
    if self.list and self.list[j] then
      g.item = self.list[j]
      self.displayfunc(g, self.scratch[i], self.list[j], self.itemwidth, self.itemheight)
      g:setVisible(true)
    else
      g.item = nil
      g:setVisible(false)
    end
    if i % self.items_per_row == 0 then
      row_index = row_index + 1
    end
  end
  if self.row_offset == 0 and last_item then
    self.scrollbar:setVisible(false)
    self.thumb:setVisible(false)
  else
    local ox, oy = self.scrollbar:getLoc()
    local maxrows = ceil(#self.list / self.items_per_row)
    local thumb_scale = self.inner_height / ((maxrows * self.rowheight) - self.spacing)
    local thumb_height = self.scrollbar_height * thumb_scale
    local thumb_position = 1 - (self.position / self.max_position)
    self.thumb:setSize(SCROLLBAR_WIDTH - 2, thumb_height)
    local thumb_range = self.scrollbar_height - thumb_height
    self.thumb:setLoc(self.scrollbar_x_offset, self.scrollbar_y_offset + (thumb_range * thumb_position))
    self.scrollbar:setVisible(true)
    self.thumb:setVisible(true)
  end
end

function UI_Scrolllist:onClick()
end

function UI_Scrolllist:scroll(offset)
  return self:setScroll(self.position + offset)
end

function UI_Scrolllist:setScroll(position)
  self.total_rows = ceil(#self.list / self.items_per_row)
  self.total_height = (self.total_rows * self.rowheight) - self.spacing
  self.max_position = self.total_height - self.inner_height
  if position > self.max_position then
    position = self.max_position
  end
  if position < 0 then
    position = 0
  end
  if position == self.position then
    return false
  end
  self.position = position
  self.row_offset = floor(self.position / self.rowheight)
  self.pixel_offset = self.position - (self.row_offset * self.rowheight)
  -- printf("setScroll: position %d/%d, row_offset %d, pixel_offset %d",
    -- self.position, self.max_position, self.row_offset, self.pixel_offset)
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
