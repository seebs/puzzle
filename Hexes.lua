local Hexes = {}

Hexes.shape = { x = 112, y = 128 }

local floor = math.floor
local ceil = math.ceil
local random = math.random
local printf = Util.printf

local rawset = rawset
local rawget = rawget

local fnhash = {
  tile = function(t, k, v) t.parent.grid:setTile(t.x, t.y, v); rawset(t, '_tile', v) end,
  color = function(t, k, v) t.parent.grid:setColor(t.x, t.y, v); rawset(t, '_color', v) end,
  alpha = function(t, k, v) t.parent.grid:setAlpha(t.x, t.y, v); rawset(t, '_alpha', v) end,
  scale = function(t, k, v) t.parent.grid:setScale(t.x, t.y, v); rawset(t, '_scale', v) end,
}

local memberhash = {
  tile = '_tile',
  color = '_color',
  alpha = '_alpha',
  scale = '_scale',
}

local hexbits = {
  -- also stash values in the grid for real
  __newindex = function(t, k, v)
    if fnhash[k] then
      fnhash[k](t, k, v)
    else
      rawset(t, k, v)
    end
  end,
  __index = function(t, k)
    return rawget(t, memberhash[k] or k)
  end

}

function Hexes.new(screen, layer, args)
  args = args or {}
  local hx = {}
  hx.screen = screen
  hx.layer = layer
  hx.color_multiplier = args.color_multiplier or 1
  hx.highlights = args.highlights or 0
  hx.color_funcs = Rainbow.funcs_for(hx.color_multiplier)
  hx.color = hx.color_funcs.smooth
  hx.columns = args.columns or 12
  hx.size = { x = args.size and args.size.x or (hx.screen.width / (hx.columns + 1)) }
  hx.size.y = args.size and args.size.y or ((hx.size.x * Hexes.shape.y) / (Hexes.shape.x))
  hx.rows = args.rows or floor(((hx.screen.height * 4) / (hx.size.y * 3)) - 0.5)
  printf("Screen height %d, size.x/y %d/%d, so we can fit %.1f hexes vertically, using %d rows.",
    hx.screen.height, hx.size.x, hx.size.y, (hx.screen.height / hx.size.y), hx.rows)

  printf("Base size %dx%d px => %dx%d grid.", hx.size.x, hx.size.y, hx.columns, hx.rows)
  hx.grid = MOAIGridFancy.new()
  hx.grid:initAxialHexGrid(hx.columns, hx.rows, hx.size.x, hx.size.y)
  rx, ry = hx.grid:getTileLoc(1, 1, MOAIGridSpace.TILE_LEFT_TOP)
  hx.lower_left = { x = rx, y = ry }
  printf("tile 1, 1: %.1fx%.1f", rx, ry)
  rx, ry = hx.grid:getTileLoc(hx.columns, hx.rows, MOAIGridSpace.TILE_RIGHT_BOTTOM)
  -- if we have an odd number of rows, the top row will not extend
  -- as far right as the one below it.
  if hx.rows % 2 == 1 then
    rx = rx + hx.size.x / 2
  end
  hx.upper_right = { x = rx, y = ry }
  printf("tile %d, %d: %.1fx%.1f", hx.columns, hx.rows, rx, ry)
  hx.grid_size = { x = hx.upper_right.x - hx.lower_left.x, y = hx.upper_right.y - hx.lower_left.y }
  printf("grid_size: %dx%d", hx.grid_size.x, hx.grid_size.y)
  --[[
    the computed size of the grid should be pretty exact -- if I
    draw lines at those coordinates, they are exactly at the edges
    of the hex grid. But if I set the location based on that, it
    is off-center. I think the grid itself is slightly off-center
    from its nominal location, thus the fudge factors.
    ]]--
  hx.x_offset = (hx.screen.width - hx.grid_size.x) / 2 + hx.screen.left
  hx.y_offset = (hx.screen.height - hx.grid_size.y) / 2 + hx.screen.bottom + (hx.size.y / 12)

  printf("offsets: %d, %d => %d, %d", hx.screen.left, hx.screen.bottom, hx.x_offset, hx.y_offset)
  hx.grid:fillColor(1)
  hx.total_colors = hx.color_multiplier * 6
  for i = 1, hx.total_colors do
    hx.grid:setPalette(i, hx.color(i))
    hx.grid:setPalette(hx.total_colors + 1, 1.0, 1.0, 1.0, 1)
  end
  hx.r = {}
  hx.c = {}
  for y = 1, hx.rows do
    hx.r[y] = {}
  end
  for x = 1, hx.columns do
    hx.c[x] = {}
    for y = 1, hx.rows do
      local s = { parent = hx, x = x, y = y }
      hx.c[x][y] = s
      hx.r[y][x] = s
      setmetatable(s, hexbits)
      s.color = 7
      -- s.tile = ((x + y) % 6) + 1
      s.tile = 0
      s.alpha = 1
      s.scale = 1
    end
  end
  -- drawing primitives
  hx.prop = MOAIProp2D.new()
  hx.prop:setDeck(Hexes.tile_deck)
  hx.prop:setGrid(hx.grid)
  hx.prop:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE)
  hx.prop:setLoc(hx.x_offset, hx.y_offset)
  hx.prop:setGridScale(Hexes.shape.x / hx.size.x, Hexes.shape.y / hx.size.y)
  -- hx.prop:setLoc(hx.screen.left, hx.screen.bottom)
  hx.layer:insertProp(hx.prop)
  hx.from_screen = Hexes.from_screen
  return hx
end

function Hexes:from_screen(x, y)
  x = x - self.x_offset
  y = y - self.y_offset
  local cx, cy = self.grid:locToCoord(x, y)
  if self.c[cx] then
    return self.c[cx][cy], cx, cy
  end
end

Hexes.tile_deck = MOAITileDeck2D.new()
Hexes.tile_deck:setTexture("hexes.png")
Hexes.tile_deck:setSize(2, 3,
120/256, 144/512,
8/256, 8/512,
112/256, 128/512
)

return Hexes
