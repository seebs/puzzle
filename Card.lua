local Card = {}

function Card.new(layer, heading, text)
  local c = flower.Group(layer, 512, 256)
  local img = flower.Image("3x5.png")
  c:addChild(img)
  img.texture:setFilter(MOAITexture.GL_LINEAR)

  local l = flower.Label(heading, 390, 30)
  l:setColor(0, 0, 0, 1)
  c:addChild(l)
  l:setLoc(10, 205)
  l:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
  local lines = Util.split(text, "\n")
  for i = 1, #lines do
    l = flower.Label(lines[i], 390, 20, nil, 15)
    c:addChild(l)
    l:setColor(0, 0, 0, 1)
    l:setLoc(10, 205 - (18 * i))
  end
  c:setScl(0.5)
  c:moveRot(0, 0, 3.0, 10.0)

  return c
end

return Card
