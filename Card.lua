local Card = {}
local printf = Util.printf
local sprintf = Util.sprintf

function Card.new(layer, heading, text)
  local c = flower.Group(layer, 512, 256)
  local img = flower.Image("3x5.png")
  c:addChild(img)
  img.texture:setFilter(MOAITexture.GL_LINEAR)
  img:getDeck():setUVRect(8/512, 1, 416/512, 8/512)

  local l = flower.Label(heading, 390, 30)
  c:addChild(l)
  l:setLoc(10, 205)
  l:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
  Rainbow.color_styles(l)
  local lines = Util.split(text, "\n")
  for i = 1, #lines do
    l = flower.Label(lines[i], 390, 20, nil, 15)
    Rainbow.color_styles(l)
    c:addChild(l)
    l:setLoc(10, 205 - (18 * i))
  end
  c:setScl(0.6)

  return c
end

return Card
