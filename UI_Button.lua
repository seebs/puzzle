local UI_Button = {}

function UI_Button.new(text, width, height)
  local b = {}
  b.width = width or 150
  b.height = height or 45

  b.group = flower.Group()
  setmetatable(b, {__index = UI_Button.memberhash})
  b.nine = flower.NineImage("ninepatch.9.png", b.width, b.height)
  b.group:addChild(b.nine)
  b.nine:setLoc(0, 0)
  b.label = flower.Label(text or "", b.width, b.height)
  b.group:addChild(b.label)
  b.label:setLoc(0, 0)
  b.label:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)

  return b
end

UI_Button.memberhash = {}

Util.makepassthrough(UI_Button.memberhash, 'group')

return UI_Button
