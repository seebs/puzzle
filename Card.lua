local Card = {}
local printf = Util.printf
local sprintf = Util.sprintf

function Card.new(layer, heading, text)
  local c = {}
  c.group = flower.Group(layer, 400, 320)
  local img = flower.Image("3x5.png")
  c.group:addChild(img)
  img.texture:setFilter(MOAITexture.GL_LINEAR)
  img:getDeck():setUVRect(8/512, 1, 416/512, 8/512)
  img:setPriority(0)
  -- img:setColor(0, 1, 0)

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

  c.picframe = flower.Image("picframe.png")
  c.picframe.texture:setFilter(MOAITexture.GL_LINEAR)
  c.group:addChild(c.picframe)

  c.snapshot = flower.Image("blank.png")
  c.snapshot:setScl(0.87)
  c.snapshot:setLoc(125, 131)
  layer:insertProp(c.snapshot)

  c.snapshot_background = flower.Image("blank.png")
  c.snapshot_background:setScl(0.87)
  c.snapshot_background:setLoc(125, 131)
  layer:insertProp(c.snapshot_background)

  c.snapshot_background:setPriority(1)
  c.snapshot:setPriority(2)
  c.picframe:setPriority(3)

  c.snapshot_background:setParent(c.picframe)
  c.snapshot:setParent(c.picframe)

  c.snapshot:clearAttrLink(MOAIColor.INHERIT_COLOR)
  c.snapshot_background:clearAttrLink(MOAIColor.INHERIT_COLOR)

  c.picframe:setLoc(425, 200)
  c.picframe:setScl(0.5)
  c.picframe:setVisible(false)

  c.icon = MOAIProp2D.new()
  c.icon:setDeck(Genre.symbol_deck)
  c.icon:setVisible(false)
  c.icon:setLoc(200, 200)
  c.icon:setPriority(4)
  c.icon:setScl(50, 50)
  c.icon:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
  c.group:addChild(c.icon)

  c.group:setColor(1, 1, 1, 0)

  setmetatable(c, {__index = Card.memberhash})

  return c
end

function Card:display_element(element)
  local h = sprintf("<%s>%s</>", Genre.color_name(element.genre), element.name)
  self.header:setString(h)
  self.snapshot:setTexture(sprintf("elements/%s.png", element.name))
  self.picframe:setVisible(true)

  local color = Genre.color(element.genre)
  self.icon:setIndex(color)
  self.icon:setColor(Genre.rgb(color))
  self.icon:setVisible(true)

  self.group:seekColor(1, 1, 1, 1, 0.3)
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
