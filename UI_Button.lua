local UI_Button = {}

local printf = Util.printf
local sprintf = Util.sprintf

function UI_Button.new(text, width, height, func, ...)
  local b = {}
  b.width = width or 150
  b.height = height or 45
  b.down = false

  b.group = flower.Group()
  -- printf("Button (%s): prop %s", text, tostring(b.group))
  setmetatable(b, {__index = UI_Button.memberhash})
  b.nine = flower.NineImage("ninepatch.9.png", b.width, b.height)
  b.group:addChild(b.nine)
  b.nine:setLoc(0, 0)
  b.super = flower.NineImage("ninepatch.9.png", b.width - 4, b.height - 4)
  b.group:addChild(b.super)
  b.super:setLoc(2, 2)
  b.super:setVisible(b.down)
  b.super:setColor(0.8, 0.8, 0.8, 1)
  b.label = flower.Label(text or "", b.width, b.height)
  Rainbow.color_styles(b.label)
  b.group:addChild(b.label)
  b.label:setLoc(0, 0)
  b.label:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
  if func then
    local args = { ... }
    b.callback = function() return func(unpack(args)) end
  end
  b.group:addEventListener("touchUp", function(...) UI_Button.event(b, ...) end)
  b.group:addEventListener("touchMove", function(...) UI_Button.event(b, ...) end)
  b.group:addEventListener("touchDown", function(...) UI_Button.event(b, ...) end)
  b.group:addEventListener("touchCancel", function(...) UI_Button.event(b, ...) end)
  b.props = {
    [b.group] = true,
    [b.label] = true,
    [b.nine] = true,
    [b.super] = true,
  }

  return b
end

function UI_Button:display_down(down)
  self.down = down
  self.super:setVisible(self.down)
end

function UI_Button:event(e)
  local for_me = e.active_prop and self.props[e.active_prop] or false
  -- printf("UI_Button: event, type %s, active_prop %s, index %d, x/y %d/%d, tapCount %d", e.type, tostring(e.active_prop), e.idx, e.x, e.y, e.tapCount)
  if e.type == 'touchDown' then
    -- look clicked
    if for_me then
      self:display_down(true)
    end
  elseif e.type == 'touchCancel' then
    self:display_down(false)
  elseif e.type == 'touchMove' then
    self:display_down(for_me)
  elseif e.type == 'touchUp' then
    if self.down and for_me then
      self.callback()
    end
    self:display_down(false)
  end
end

UI_Button.memberhash = {
  display_down = UI_Button.display_down,
}

Util.makepassthrough(UI_Button.memberhash, 'group')

return UI_Button
