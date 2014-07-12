local Card = {}
local printf = Util.printf
local sprintf = Util.sprintf

function Card.new(layer, heading, text)
  local c = {}
  c.group = flower.Group(layer, 512, 256)
  c.picture = flower.Group(layer, 256, 256)
  local img = flower.Image("3x5.png")
  c.group:addChild(img)
  img.texture:setFilter(MOAITexture.GL_LINEAR)
  img:getDeck():setUVRect(8/512, 1, 416/512, 8/512)
  img:setPriority(0)

  local l = flower.Label(heading, 390, 30)
  c.group:addChild(l)
  l:setLoc(10, 205)
  l:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
  Rainbow.color_styles(l)
  c.header = l
  c.header:setPriority(10)
  local lines = Util.split(text, "\n")
  c.lines = {}
  for i = 1, 10 do
    l = flower.Label(lines[i] or "", 390, 20, nil, 15)
    Rainbow.color_styles(l)
    c.group:addChild(l)
    l:setLoc(10, 205 - (18 * i))
    c.lines[i] = l
    c.lines[i]:setPriority(10)
  end
  c.group:setScl(0.6)
  c.picture:setParent(c.group)

  c.picframe = flower.Image("picframe.png")
  c.picframe.texture:setFilter(MOAITexture.GL_LINEAR)

  c.snapshot = flower.Image("blank.png")
  c.snapshot:setScl(0.9)

  c.snapshot_background = flower.Image("blank.png")
  c.snapshot_background:setScl(0.9)

  c.snapshot_background:setPriority(1)
  c.snapshot:setPriority(2)
  c.picframe:setPriority(3)

  c.picture:addChild(c.snapshot_background)
  c.picture:addChild(c.snapshot)
  c.picture:addChild(c.picframe)

  c.picture:setLoc(425, 200)
  c.picture:setScl(0.5)
  c.picture:setVisible(false)

  setmetatable(c, {__index = Card.memberhash})

  return c
end

function Card:display_element(element)
  local h = sprintf("<%s>%s</>", Genre.color(element.genre), element.name)
  self.header:setString(h)
  self.snapshot:setTexture(sprintf("elements/%s.png", element.name))
  self.picture:setVisible(true)
end

Card.memberhash = {
  display_element = Card.display_element,
}

local passthrough = { 'setLoc', 'moveLoc', 'seekLoc', 'setRot', 'seekRot', 'moveRot' }
for i = 1, #passthrough do
  local name = passthrough[i]
  Card.memberhash[name] = function(self, ...) return self.group[name](self.group, ...) end
end

return Card
