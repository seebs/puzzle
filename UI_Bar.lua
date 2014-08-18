local UI_Bar = {}

local printf = Util.printf
local sprintf = Util.sprintf

function UI_Bar.new(width, height, min, max)
  local o = {}
  o.width = width or 150
  o.height = height or 15
  o.min = min or 0
  o.max = max or 100

  o.group = flower.Group()
  -- printf("Button (%s): prop %s", text, tostring(o.group))
  setmetatable(o, {__index = UI_Bar.memberhash})
  o.nine = flower.NineImage("ninepatch.9.png", o.width, o.height)
  o.group:addChild(o.nine)
  o.nine:setLoc(0, 0)

  o.label = flower.Label("", o.width, o.height, nil, o.height - 2)
  Rainbow.color_styles(o.label)
  o.group:addChild(o.label)
  o.label:setLoc(0, 0)
  o.label:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)

  return o
end

function UI_Bar:display_value(value, min, max)
  self.min = min or self.min
  self.max = max or self.max
  local scale = (value - self.min) / (self.max - self.min)
  self.nine:setSize(self.width * scale, self.height)
  self.label:setString(sprintf("%d/%d", value, max))
end

UI_Bar.memberhash = {
  display_value = UI_Bar.display_value
}

Util.makepassthrough(UI_Bar.memberhash, 'group')

return UI_Bar
