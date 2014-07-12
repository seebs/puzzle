local Genre = {}

Genre.genres = {
  'romance', 'fantasy', 'action', 'scifi', 'crime', 'gothic',
}

local function texload(name, wrap)
  local t = MOAITexture.new()
  t:load(name)
  t:setWrap(wrap)
  return t
end
Genre.symbol_texture = texload("gems.png", false)
Genre.symbol_texture:setFilter(MOAITexture.GL_LINEAR)

Genre.symbol_deck = MOAITileDeck2D.new()
Genre.symbol_deck:setTexture(Genre.symbol_texture)
Genre.symbol_deck:setSize(2, 3,
128/256, 128/512,
1/256, 1/512,
126/256, 126/512
)

Genre.color_funcs = Rainbow.funcs_for(1)
Genre.color_values = Genre.color_funcs.smooth

Genre.colors = {}

for i = 1, #Genre.genres do
  Genre.colors[Genre.genres[i]] = i
end

function Genre.iterate()
  return Util.iterator(Genre.genres)
end

function Genre.color(g)
  return Genre.colors[g]
end

function Genre.rgb(g)
  return Genre.color_values(Genre.colors[g] or g)
end

function Genre.color_name(g)
  return Rainbow.name(Genre.colors[g])
end

function Genre.list(value)
  local t = {}
  -- "false" would be okay, though.
  if value == nil then
    value = 0
  end
  for i = 1, #Genre.genres do
    t[Genre.genres[i]] = value
  end
  return t
end

return Genre
