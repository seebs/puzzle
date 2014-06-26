local Board = {}

Board.shape = { x = 112, y = 128 }

local atan2 = math.atan2
local pi = math.pi
local sqrt = math.sqrt
local floor = math.floor
local ceil = math.ceil
local random = math.random
local printf = Util.printf
local abs = math.abs

local rawset = rawset
local rawget = rawget

Board.texture_deck = MOAITileDeck2D.new()
Board.texture_deck:setTexture("texture.png")
Board.texture_deck:setSize(2, 3,
120/256, 144/512,
8/256, 8/512,
112/256, 128/512
)

local function texload(name)
  local t = MOAITexture.new()
  t:load(name)
  return t
end
Board.gem_multitex = MOAIMultiTexture.new()
Board.gem_multitex:reserve(3)
Board.gem_multitex:setTexture(1, texload("gems.png"))
Board.gem_multitex:setTexture(2, texload("gloss.png"))
Board.gem_multitex:setTexture(3, texload("sheen.png"))

Board.gem_deck = MOAITileDeck2D.new()
Board.gem_deck:setTexture(gem_multitex)
Board.gem_deck:setSize(2, 3,
120/256, 144/512,
0/256, 8/512,
128/256, 128/512
)

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

local directions = {
  nw = { x = 0, y = 1 },
  ne = { x  = 1, y = 1 },
  w = { x = -1, y = 0 },
  e = { x = 1, y = 0 },
  sw = { x = -1, y = -1 },
  se = { x = 0, y = -1 },
}

function Board.neighbor(hex, dir)
  if not directions[dir] then
    return nil
  end
  local x, y = hex.location.x, hex.location.y
  x, y = x + directions[dir].x, y + directions[dir].y
  return hex.parent.b[x] and hex.parent.b[x][y] or nil
end

local memberhash = {
  tile = '_tile',
  color = '_color',
  alpha = '_alpha',
  scale = '_scale',
  ttile = '_ttile',
  tcolor = '_tcolor',
  talpha = '_talpha',
  tscale = '_tscale',
  neighbor = Board.neighbor
}

local gemberhash = {
  setAlpha = function(self, alpha)
    self._a = alpha or 1.0
    self.prop:setColor(self._r, self._g, self._b, self._a)
  end,
  pulse = function(self, pulsing)
    if pulsing then
      -- self.gloss:setAttrLink(MOAIColor.INHERIT_COLOR, self.board.pulse_color_neg, MOAIColor.COLOR_TRAIT)
      -- self.sheen:setAttrLink(MOAIColor.ADD_COLOR, self.board.pulse_color_pos, MOAIColor.COLOR_TRAIT)
    else
      -- self.gloss:clearAttrLink(MOAIColor.INHERIT_COLOR)
      -- self.sheen:clearAttrLink(MOAIColor.ADD_COLOR)
    end
  end,
  setColor = function(self, r, g, b)
    self._r = r or 1.0
    self._g = g or r
    self._b = b or r
    self._a = self._a or 1.0
    self.prop:setColor(self._r, self._g, self._b, self._a)
  end,
  setLoc = function(self, x, y)
    self.prop:setLoc(x + self.hex.parent.x_offset, y + self.hex.parent.y_offset)
  end,
  drop = function(self)
    self:setLoc(self.hex.sx, self.hex.sy)
    self:setAlpha(1.0)
    self:pulse(false)
  end
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
    if type(memberhash[k]) == 'function' then
      return memberhash[k]
    else
      return rawget(t, memberhash[k] or k)
    end
  end
}

local gembits = {
  -- also stash values in the grid for real
  __index = function(t, k)
    if type(gemberhash[k]) == 'function' then
      return gemberhash[k]
    else
      return rawget(t, gemberhash[k] or k)
    end
  end

}

Board.vsh = [[
attribute vec4 position;
attribute vec2 uv;
attribute vec4 color;

varying vec4 colorVarying;
varying vec2 uvVaryingTile;
varying vec2 uvVaryingEffects;

void main () {
	gl_Position = position;
	vec2 scaled = uv * vec2(256.0 / 112.0, 512.0 / 120.0);
	vec2 effects = scaled - floor(scaled);
	
	uvVaryingTile = uv;
	uvVaryingEffects = uv * effects;
	colorVarying = color;
}
]]
Board.fsh = [[
varying LOWP vec4 colorVarying;
varying MEDP vec2 uvVaryingTile;
varying MEDP vec2 uvVaryingEffects;

uniform float glow;
uniform vec4 color;
uniform sampler2D rune;
uniform sampler2D gloss;
uniform sampler2D sheen;

void main() {
	vec4 gtext = texture2D(gloss, uvVaryingEffects);
	float gscale = gtext.a * (1.0 - glow);
        gl_FragColor = ( texture2D ( rune, uvVaryingTile ) * color * (1.0 - gscale)) + texture2D(sheen, uvVaryingEffects) * ((glow * 0.5) + 0.5);
}
]]

Board.funcs = {}

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
  -- shared pulse value for the whole board
  bd.pulse_pos = MOAIAnimCurve.new()
  bd.pulse_pos:reserveKeys(2)
  bd.pulse_pos:setKey(1, 0, 0.0, MOAIEaseType.LINEAR)
  bd.pulse_pos:setKey(2, 0.5, 0.3, MOAIEaseType.LINEAR)
  bd.pulse_neg = MOAIAnimCurve.new()
  bd.pulse_neg:reserveKeys(2)
  bd.pulse_neg:setKey(1, 0, 1.0, MOAIEaseType.LINEAR)
  bd.pulse_neg:setKey(2, 0.5, 0.7, MOAIEaseType.LINEAR)
  bd.pulse_timer = MOAITimer.new()
  bd.pulse_timer:setSpan(0, bd.pulse_pos:getLength())
  bd.pulse_timer:setMode(MOAITimer.PING_PONG)
  bd.pulse_pos:setAttrLink(MOAIAnimCurve.ATTR_TIME, bd.pulse_timer, MOAITimer.ATTR_TIME)
  bd.pulse_neg:setAttrLink(MOAIAnimCurve.ATTR_TIME, bd.pulse_timer, MOAITimer.ATTR_TIME)
  bd.pulse_timer:start()
  bd.pulse_color_pos = MOAIColor.new()
  bd.pulse_color_pos:setColor(1.0, 1.0, 1.0, 1.0)
  bd.pulse_color_pos:setAttrLink(MOAIColor.ATTR_A_COL, bd.pulse_pos, MOAIAnimCurve.ATTR_VALUE)
  bd.pulse_color_neg = MOAIColor.new()
  bd.pulse_color_neg:setColor(1.0, 1.0, 1.0, 1.0)
  bd.pulse_color_neg:setAttrLink(MOAIColor.ATTR_A_COL, bd.pulse_neg, MOAIAnimCurve.ATTR_VALUE)

  -- printf("Base size %dx%d px => %dx%d grid.", bd.size.x, bd.size.y, bd.columns, bd.rows)
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
      s.sx, s.sy = bd.grid:getTileLoc(x, y, MOAIGridSpace.TILE_CENTER)
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
      bd.b[i][j] = bd.c[i + 4][j + 4]
      if bd.b[i][j] then
	bd.b[i][j].location = { x = i, y = j }
	bd.b[i][j].grid_location = { x = i + 4, y = j + 4 }
        bd.hex_count = bd.hex_count + 1
	hex_locations[#hex_locations + 1] = { x = i, y = j, hex = bd.b[i][j] }
        bd.b[i][j].tile = 1
        bd.b[i][j].ttile = 1
        -- bd.b[i][j].ttile = ((i + j) % 6) + 1
        -- bd.b[i][j].color = j + 4
      end
    end
  end

  bd.directions = directions

  -- compute angles and distances for each direction; these can
  -- vary because you might have hexes that aren't regular
  local center = { x = bd.b[0][0].sx, y = bd.b[0][0].sy }
  for dir, offsets in pairs(directions) do
    local point = { x = bd.b[offsets.x][offsets.y].sx, y = bd.b[offsets.x][offsets.y].sy }
    local dx = point.x - center.x
    local dy = point.y - center.y
    local angle = atan2(dx, dy)
    angle = (angle < 0) and (angle + (pi * 2)) or angle
    offsets.angle = angle
    offsets.dist = sqrt(dx * dx + dy * dy)
    -- printf("%s: dx, dy %.1f, %.1f. angle %.1f deg, dist %.1f",
      -- dir, dx, dy, offsets.angle * 180 / pi, offsets.dist)
  end

  -- drawing primitives
  -- bd.board_prop = MOAIProp2D.new()
  -- bd.board_prop:setDeck(Board.board_deck)
  -- bd.board_prop:setGrid(bd.grid)
  -- bd.board_prop:setLoc(bd.x_offset, bd.y_offset)
  -- bd.board_prop:setGridScale(Board.shape.x / bd.size.x, Board.shape.y / bd.size.y)

  bd.texture_prop = MOAIProp2D.new()
  bd.texture_prop:setDeck(Board.texture_deck)
  bd.texture_prop:setGrid(bd.texture_grid)
  bd.texture_prop:setLoc(bd.x_offset, bd.y_offset)
  bd.texture_prop:setGridScale(Board.shape.x / bd.size.x, Board.shape.y / bd.size.y)

  bd.texture_prop:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
  -- bd.board_prop:setBlendMode(MOAIProp2D.GL_DST_COLOR, MOAIProp2D.GL_ONE)

  bd.layer:insertProp(bd.texture_prop)
  -- bd.layer:insertProp(bd.board_prop)

  setmetatable(bd, { __index = Board.funcs })

  bd.gems = {}

  for i = 1, #hex_locations do
    local gem = {}
    setmetatable(gem, gembits)
    gem.hex = hex_locations[i].hex
    if gem.hex then
      gem.hex.gem = gem
    end
    gem.board = bd
    gem.prop = MOAIProp2D.new()
    gem.prop:setColor(1.0, 1.0, 1.0, 1.0)
    local other_deck = MOAIGfxQuad2D.new()
    other_deck:setTexture(Board.gem_multitex)
    other_deck:setRect(1, -1, -1, 1, 1)
    other_deck:setUVRect(0, 1, 1, 0)
    gem.prop:setDeck(Board.gem_deck)
    gem.prop:setTexture(Board.gem_multitex)
    local shader = MOAIShader.new()
    shader:reserveUniforms(5)
    shader:declareUniform(1, 'color', MOAIShader.UNIFORM_COLOR)
    shader:declareUniform(2, 'glow', MOAIShader.UNIFORM_FLOAT)
    shader:setAttrLink(1, gem.prop, MOAIColor.COLOR_TRAIT)
    shader:setAttr(2, 0.0)
    shader:declareUniformSampler(3, 'rune', 1)
    shader:declareUniformSampler(4, 'gloss', 2)
    shader:declareUniformSampler(5, 'sheen', 3)
    shader:setVertexAttribute(1, 'position')
    shader:setVertexAttribute(2, 'uv')
    shader:setVertexAttribute(3, 'color')
    shader:load(Board.vsh, Board.fsh)
    gem.prop:setShader(shader)
    gem.index = math.random(6)
    gem.prop:setIndex(gem.index)

    -- gem.sheen:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE)
    -- gem.gloss:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
    gem.prop:setScl(bd.gem_size)

    gem:setColor(bd.color(gem.index))
    gem:setAlpha(1.0)

    bd.layer:insertProp(gem.prop)

    gem:setLoc(gem.hex.sx, gem.hex.sy)
  end

  return bd
end

function Board:from_screen(x, y)
  x = x - self.x_offset
  y = y - self.y_offset
  local cx, cy = self.grid:locToCoord(x, y)
  local sx, sy = self:to_screen(cx, cy)
  -- printf("grid:locToCoord(%d, %d) => %s, %s (center %s, %s)", x, y, tostring(cx), tostring(cy), tostring(sx), tostring(sy))
  if self.c[cx] then
    local hex = self.c[cx][cy]
    if hex then
      -- printf("hex at %d, %d is location %d, %d", cx, cy, hex.location.x, hex.location.y)
      return hex, (hex.location and hex.location.x), (hex.location and hex.location.y), sx, sy
    end
  end
end

function Board:to_screen(x, y)
  local sx, sy = self.grid:getTileLoc(x, y, MOAIGridSpace.TILE_CENTER)
  return sx + self.x_offset, sy + self.y_offset
end

function Board:find_matches()
end

Board.funcs = {
  from_screen = Board.from_screen,
  to_screen = Board.to_screen,
  matches = Board.matches,
}

return Board
