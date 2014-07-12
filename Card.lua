local Card = {}
local printf = Util.printf
local sprintf = Util.sprintf

function Card.new(layer, heading, text)
  local c = {}
  c.group = flower.Group(layer, 400, 360)
  local img = flower.Image("3x5.png")
  c.group:addChild(img)
  img.texture:setFilter(MOAITexture.GL_LINEAR)
  printf("%s", tostring(img))
  printf("%s", tostring(img.getDeck))
  img:getDeck():setUVRect(8/512, 1, 416/512, 8/512)
  img:getDeck():setRect(0, 0, 408, 246)
  img:setPriority(0)
  -- img:setColor(0, 1, 0)

  c.portrait = Portrait.new()
  c.group:addChild(c.portrait.group)
  c.portrait:setVisible(false)
  c.portrait:setLoc(350, 220)

  local l = flower.Label(heading or "", 390, 30)
  c.group:addChild(l)
  l:setLoc(3, 195)
  l:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
  Rainbow.color_styles(l)
  c.header = l
  c.header:setPriority(10)
  local lines = Util.split(text or "", "\n")
  c.lines = {}
  for i = 1, 10 do
    l = flower.Label(lines[i] or "", 390, 20, nil, 15)
    Rainbow.color_styles(l)
    c.group:addChild(l)
    l:setLoc(3, 200 - (18 * i))
    c.lines[i] = l
    c.lines[i]:setPriority(10)
  end
  c.group:setScl(0.6)

  c.icon = MOAIProp2D.new()
  c.icon:setDeck(Genre.symbol_deck)
  c.icon:setVisible(false)
  c.icon:setLoc(20, 240)
  c.icon:setPriority(4)
  c.icon:setScl(30, 30)
  c.icon:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
  c.group:addChild(c.icon)

  c.group:setColor(1, 1, 1, 0)

  setmetatable(c, {__index = Card.memberhash})

  return c
end

function Card:display_element(element)
  local h = sprintf("<%s>%s</>", Genre.color_name(element.genre), element.name)
  -- printf("header %s", h)
  self.header:setString(h)
  self.portrait:display_element(element)

  local color = Genre.color(element.genre)
  self.icon:setIndex(color)
  self.icon:setColor(Genre.rgb(color))
  self.icon:setVisible(true)

  MOAICoroutine.blockOnAction(self.group:seekColor(1, 1, 1, 1, 0.3))
end

function Card:display_formation(formation)
  local stats = formation:stats()
  self.icon:setVisible(false)
  self.portrait:setVisible(false)
  self.header:setString(formation.type)
  MOAICoroutine.blockOnAction(self.group:seekColor(1, 1, 1, 1, 0.3))
end

function Card:hide()
  MOAICoroutine.blockOnAction(self.group:seekColor(1, 1, 1, 0, 0.3))
end

Card.memberhash = {
  display_element = Card.display_element,
  display_formation = Card.display_formation,
}

Util.makepassthrough(Card.memberhash, 'group')

return Card
