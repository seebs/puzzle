local Board = {}

Board.shape = { x = 112, y = 128 }

local floor = math.floor
local ceil = math.ceil
local random = math.random
local printf = Util.printf
local abs = math.abs

local rawset = rawset
local rawget = rawget

local fnhash = {
  tile = function(t, k, v) t.parent.grid:setTile(t.x, t.y, v); rawset(t, '_tile', v) end,
  ttile = function(t, k, v) t.parent.texture_grid:setTile(t.x, t.y, v); rawset(t, '_ttile', v) end,
  color = function(t, k, v) t.parent.grid:setColor(t.x, t.y, v); rawset(t, '_color', v) end,
  tcolor = function(t, k, v) t.parent.texture_grid:setColor(t.x, t.y, v); rawset(t, '_tcolor', v) end,
  alpha = function(t, k, v) t.parent.grid:setAlpha(t.x, t.y, v); rawset(t, '_alpha', v) end,
  talpha = function(t, k, v) t.parent.texture_grid:setAlpha(t.x, t.y, v); rawset(t, '_talpha', v) end,
  scale = function(t, k, v) t.parent.grid:setScale(t.x, t.y, v); rawset(t, '_scale', v) end,
  tscale = function(t, k, v) t.parent.texture_grid:setScale(t.x, t.y, v); rawset(t, '_tscale', v) end,
}

local memberhash = {
  tile = '_tile',
  color = '_color',
  alpha = '_alpha',
  scale = '_scale',
  ttile = '_ttile',
  tcolor = '_tcolor',
  talpha = '_talpha',
  tscale = '_tscale',
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

function Board.new(screen, layer, args)
  args = args or {}
  local bd = {}
  bd.screen = screen
  bd.layer = layer
  bd.color_multiplier = args.color_multiplier or 1
  bd.highlights = args.highlights or 0
  bd.color_funcs = Rainbow.funcs_for(bd.color_multiplier)
  bd.color = bd.color_funcs.smooth
  bd.columns = args.columns or 12
  bd.size = { x = args.size and args.size.x or (bd.screen.width / (bd.columns + 1)) }
  bd.size.y = args.size and args.size.y or ((bd.size.x * Board.shape.y) / (Board.shape.x))
  bd.gem_size = bd.size.x * 1.0
  bd.rows = args.rows or floor(((bd.screen.height * 4) / (bd.size.y * 3)) - 0.5)

  printf("Base size %dx%d px => %dx%d grid.", bd.size.x, bd.size.y, bd.columns, bd.rows)
  bd.grid = MOAIGridFancy.new()
  bd.grid:initAxialHexGrid(bd.columns, bd.rows, bd.size.x, bd.size.y, 3, 3)
  -- an additional grid to live in front of the other
  bd.texture_grid = MOAIGridFancy.new()
  bd.texture_grid:initAxialHexGrid(bd.columns, bd.rows, bd.size.x, bd.size.y, 3, 3)
  rx, ry = bd.grid:getTileLoc(1, 1, MOAIGridSpace.TILE_LEFT_TOP)
  bd.lower_left = { x = rx, y = ry }
  rx, ry = bd.grid:getTileLoc(bd.columns, bd.rows, MOAIGridSpace.TILE_RIGHT_BOTTOM)
  -- if we have an odd number of rows, the top row will not extend
  -- as far right as the one below it.
  if bd.rows % 2 == 1 then
    rx = rx + bd.size.x / 2
  end
  bd.upper_right = { x = rx, y = ry }
  bd.grid_size = { x = bd.upper_right.x - bd.lower_left.x, y = bd.upper_right.y - bd.lower_left.y }
  --[[
    the computed size of the grid should be pretty exact -- if I
    draw lines at those coordinates, they are exactly at the edges
    of the hex grid. But if I set the location based on that, it
    is off-center. I think the grid itself is slightly off-center
    from its nominal location, thus the fudge factors.
    ]]--
  bd.x_offset = (bd.screen.width - bd.grid_size.x) / 2 + bd.screen.left
  bd.y_offset = (bd.screen.height - bd.grid_size.y) / 2 + bd.screen.bottom + (bd.size.y / 12)

  bd.grid:fillColor(1)
  bd.texture_grid:fillColor(1)
  bd.total_colors = bd.color_multiplier * 6
  bd.texture_grid:setPalette(1, 1.0, 1.0, 1.0, 1)
  for i = 1, bd.total_colors do
    bd.grid:setPalette(i, bd.color(i))
    bd.grid:setPalette(bd.total_colors + 1, 1.0, 1.0, 1.0, 1)
  end
  bd.r = {}
  bd.c = {}
  for y = 1, bd.rows do
    bd.r[y] = {}
  end

  bd.grid:fill(0)
  bd.texture_grid:fill(0)

  for x = 1, bd.columns do
    bd.c[x] = {}
    for y = 1, bd.rows do
      local s = { parent = bd, x = x, y = y }
      bd.c[x][y] = s
      bd.r[y][x] = s
      setmetatable(s, hexbits)
      s.color = 7
      -- s.tile = ((x + y) % 6) + 1
      s.tile = 0
      s.alpha = 0
      s.scale = 1
    end
  end

  bd.b = {}

  bd.hex_count = 0

  local hex_locations = {}

  for i = -3, 3 do
    bd.b[i] = {}
    local base = (i > 0) and (i - 3) or -3
    local range = 6 - abs(i)
    for j = base, base + range do
      bd.b[i][j] = bd.c[j + 4][i + 4]
      if bd.b[i][j] then
        bd.hex_count = bd.hex_count + 1
	hex_locations[#hex_locations + 1] = { i, j }
        bd.b[i][j].tile = 1
        bd.b[i][j].ttile = ((i + j) % 6) + 1
        bd.b[i][j].color = j + 4
      end
    end
  end

  -- drawing primitives
  bd.board_prop = MOAIProp2D.new()
  bd.board_prop:setDeck(Board.board_deck)
  bd.board_prop:setGrid(bd.grid)
  bd.board_prop:setLoc(bd.x_offset, bd.y_offset)
  bd.board_prop:setGridScale(Board.shape.x / bd.size.x, Board.shape.y / bd.size.y)

  bd.texture_prop = MOAIProp2D.new()
  bd.texture_prop:setDeck(Board.texture_deck)
  bd.texture_prop:setGrid(bd.texture_grid)
  bd.texture_prop:setLoc(bd.x_offset, bd.y_offset)
  bd.texture_prop:setGridScale(Board.shape.x / bd.size.x, Board.shape.y / bd.size.y)

  bd.texture_prop:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
  bd.board_prop:setBlendMode(MOAIProp2D.GL_DST_COLOR, MOAIProp2D.GL_ONE)

  bd.layer:insertProp(bd.texture_prop)
  bd.layer:insertProp(bd.board_prop)

  bd.gems = {}

  for i = 1, #hex_locations do
    local gem = {}
    gem.location = hex_locations[i]
    gem.prop = MOAIProp2D.new()
    gem.prop:setDeck(Board.gem_deck)
    gem.index = math.random(6)
    gem.prop:setIndex(gem.index)
    gem.prop:setColor(bd.color(gem.index))
    gem.sheen = MOAIProp2D.new()
    gem.sheen:setDeck(Board.gloss_deck)
    gem.sheen:setIndex(2)
    gem.sheen:setAttrLink(MOAITransform.ATTR_X_LOC, gem.prop, MOAITransform.ATTR_X_LOC)
    gem.sheen:setAttrLink(MOAITransform.ATTR_Y_LOC, gem.prop, MOAITransform.ATTR_Y_LOC)
    gem.sheen:setAttrLink(MOAITransform.ATTR_X_SCL, gem.prop, MOAITransform.ATTR_X_SCL)
    gem.sheen:setAttrLink(MOAITransform.ATTR_Y_SCL, gem.prop, MOAITransform.ATTR_Y_SCL)
    gem.sheen:setAttrLink(MOAITransform.ATTR_X_PIV, gem.prop, MOAITransform.ATTR_X_PIV)
    gem.sheen:setAttrLink(MOAITransform.ATTR_Y_PIV, gem.prop, MOAITransform.ATTR_Y_PIV)
    gem.sheen:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE)
    gem.gloss = MOAIProp2D.new()
    gem.gloss:setDeck(Board.gloss_deck)
    gem.gloss:setIndex(1)
    gem.gloss:setAttrLink(MOAITransform.ATTR_X_LOC, gem.prop, MOAITransform.ATTR_X_LOC)
    gem.gloss:setAttrLink(MOAITransform.ATTR_Y_LOC, gem.prop, MOAITransform.ATTR_Y_LOC)
    gem.gloss:setAttrLink(MOAITransform.ATTR_X_SCL, gem.prop, MOAITransform.ATTR_X_SCL)
    gem.gloss:setAttrLink(MOAITransform.ATTR_Y_SCL, gem.prop, MOAITransform.ATTR_Y_SCL)
    gem.gloss:setAttrLink(MOAITransform.ATTR_X_PIV, gem.prop, MOAITransform.ATTR_X_PIV)
    gem.gloss:setAttrLink(MOAITransform.ATTR_Y_PIV, gem.prop, MOAITransform.ATTR_Y_PIV)
    gem.gloss:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
    gem.prop:setPiv(0.22, -0.4)
    gem.prop:setLoc(bd.grid:getTileLoc(gem.location[1], gem.location[2], MOAIGridSpace.TILE_CENTER))
    gem.prop:setScl(bd.gem_size)
    bd.layer:insertProp(gem.prop)
    bd.layer:insertProp(gem.gloss)
    bd.layer:insertProp(gem.sheen)
  end

  bd.from_screen = Board.from_screen
  return bd
end

function Board:from_screen(x, y)
  x = x - self.x_offset
  y = y - self.y_offset
  local cx, cy = self.grid:locToCoord(x, y)
  if self.c[cx] then
    return self.c[cx][cy], cx, cy
  end
end

Board.board_deck = MOAITileDeck2D.new()
Board.board_deck:setTexture("hexes.png")
Board.board_deck:setSize(2, 3,
120/256, 144/512,
8/256, 8/512,
112/256, 128/512
)

Board.texture_deck = MOAITileDeck2D.new()
Board.texture_deck:setTexture("texture.png")
Board.texture_deck:setSize(2, 3,
120/256, 144/512,
8/256, 8/512,
112/256, 128/512
)

Board.gem_deck = MOAITileDeck2D.new()
Board.gem_deck:setTexture("gems.png")
Board.gem_deck:setSize(2, 3,
120/256, 144/512,
0/256, 8/512,
128/256, 128/512
)

Board.gloss_deck = MOAITileDeck2D.new()
Board.gloss_deck:setTexture("gloss.png")
Board.gloss_deck:setSize(2, 3,
120/256, 144/512,
0/256, 8/512,
128/256, 128/512
)

return Board
