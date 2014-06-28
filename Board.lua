local Board = {}

Board.shape = { x = 112, y = 128 }

local atan2 = math.atan2
local pi = math.pi
local sqrt = math.sqrt
local floor = math.floor
local ceil = math.ceil
local random = math.random
local printf = Util.printf
local sprintf = Util.sprintf
local abs = math.abs
local tremove = table.remove

local rawset = rawset
local rawget = rawget

Board.font = MOAIFont.new()
Board.font:load("verdana.ttf")
Board.text_style = MOAITextStyle.new()
Board.text_style:setFont(Board.font)
Board.text_style:setSize(16)

Board.texture_deck = MOAITileDeck2D.new()
Board.texture_deck:setTexture("texture.png")
Board.texture_deck:setSize(2, 3,
120/256, 144/512,
8/256, 8/512,
112/256, 128/512
)

local function texload(name, wrap)
  local t = MOAITexture.new()
  t:load(name)
  t:setWrap(wrap)
  return t
end
Board.gem_multitex = MOAIMultiTexture.new()
Board.gem_multitex:reserve(3)
Board.gem_multitex:setTexture(1, texload("gems.png", false))
Board.gem_multitex:setTexture(2, texload("gloss.png", true))
Board.gem_multitex:setTexture(3, texload("sheen.png", true))

Board.gem_deck = MOAITileDeck2D.new()
Board.gem_deck:setTexture(gem_multitex)
Board.gem_deck:setSize(2, 3,
128/256, 128/512,
1/256, 1/512,
126/256, 126/512
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
  nw = { x = 0, y = 1, opposite = 'se' },
  ne = { x  = 1, y = 1, opposite = 'sw' },
  w = { x = -1, y = 0, opposite = 'e' },
  e = { x = 1, y = 0, opposite = 'w' },
  sw = { x = -1, y = -1, opposite = 'ne' },
  se = { x = 0, y = -1, opposite = 'nw' },
}

local direction_idx = {
  "sw", "w", "nw", "ne", "e", "se"
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
  setGlow = function(self, value, time)
    if self.glow_anim then
      self.glow_anim:stop()
    end
    self.glow_anim = self.shader:seekAttr(2, value, time or 0.1)
  end,
  pulse = function(self, pulsing)
    if pulsing then
      self.shader:setAttrLink(2, self.board.pulse_color_pos, MOAIColor.ATTR_A_COL)
    else
      self.shader:clearAttrLink(2)
      if self.glow_anim then
        self.glow_anim:stop()
      end
      self.glow_anim = self.shader:seekAttr(2, 0, 0.15)
    end
  end,
  reset = function(self, idx)
    self.index = idx
    self.prop:setIndex(idx)
    self:setColor(self.board.color(self.index))
    self:setGlow(0.0, 0)
  end,
  setColor = function(self, r, g, b)
    self._r = r or 1.0
    self._g = g or r
    self._b = b or r
    self._a = self._a or 1.0
    self.prop:setColor(self._r, self._g, self._b, self._a)
  end,
  seekLoc = function(self, x, y, ...)
    if self.loc_anim then
      self.loc_anim:stop()
    end
    self.loc_anim = self.prop:seekLoc(x, y, ...)
    return self.loc_anim
  end,
  setLoc = function(self, x, y)
    self.prop:setLoc(x, y)
  end,
  pickup = function(self)
    self:pulse(true)
    self.prop:setPriority(3)
  end,
  drop = function(self)
    self:seekLoc(self.hex.sx, self.hex.sy, 0.15)
    self:setAlpha(1.0)
    self:pulse(false)
    self.prop:setPriority(1)
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
	vec2 scale = vec2(256.0 / 128.0, 512.0 / 128.0);
	vec2 offset = vec2(-1.0 / 256.0, -1.0 / 512.0);
	// vec2 effects = (uv + offset) * scale;
	vec2 effects = (uv * scale) + offset;
	
	uvVaryingTile = uv;
	uvVaryingEffects = effects;
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
	vec4 tile = texture2D(rune, uvVaryingTile);
	// vec4 fakeColor = vec4(1.0, 1.0, 1.0, 1.0);
	float gscale = (1.0 - (gtext.a * 1.0 - glow));
	vec4 gcolor = vec4(color.r * gscale, color.g * gscale, color.b * gscale, color.a);
        gl_FragColor = (tile * gcolor) + texture2D(sheen, uvVaryingEffects) * ((glow * 0.5) + 0.5);
}
]]

Board.funcs = {}

function Board.new(screen, layer, args)
  args = args or {}
  local bd = {}
  bd.screen = screen
  bd.parent_layer = layer
  bd.layer = MOAILayer2D.new()
  -- bd.layer:setClearColor(0.5, 0.5, 0.5, 1.0)
  bd.rotation = args.rotation or 0
  bd.rotation_rad = bd.rotation * pi / 180
  local viewport = MOAIViewport.new()
  viewport:setSize(Settings.screen.width, Settings.screen.height)
  viewport:setScale(Settings.screen.width, Settings.screen.height)
  viewport:setOffset(-0.2, -0.2)
  viewport:setRotation(bd.rotation)
  bd.layer:setViewport(viewport)
  bd.parent_layer:insertProp(bd.layer)
  bd.color_multiplier = args.color_multiplier or 1
  bd.highlights = args.highlights or 0
  bd.color_funcs = Rainbow.funcs_for(bd.color_multiplier)
  bd.color = bd.color_funcs.smooth
  bd.columns = args.columns or 12
  bd.size = { x = args.size and args.size.x or (bd.screen.width / (bd.columns + 1)) }
  bd.size.y = args.size and args.size.y or ((bd.size.x * Board.shape.y) / (Board.shape.x))
  -- 128px gems were intended to fit within 112px hexes, so they were about 100px originally.
  bd.gem_size = bd.size.x * (110 / 128)
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

  bd.texture_prop = MOAIProp2D.new()
  bd.texture_prop:setDeck(Board.texture_deck)
  bd.texture_prop:setGrid(bd.texture_grid)
  bd.texture_prop:setLoc(0, 0)
  bd.texture_prop:setPiv(0.5, 0.5)
  bd.layer:setLoc(bd.x_offset, 0)
  bd.texture_prop:setGridScale(Board.shape.x / bd.size.x, Board.shape.y / bd.size.y)

  bd.texture_prop:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

  bd.layer:insertProp(bd.texture_prop)

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

  bd.idx = {}
  bd.subidx = {}
  for i = -3, 3 do
    bd.b[i] = {}
    bd.idx[#bd.idx + 1] = i
    local subidx = {}
    bd.subidx[i] = subidx
    local base = (i > 0) and (i - 3) or -3
    local range = 6 - abs(i)
    for j = base, base + range do
      subidx[#subidx + 1] = j
      local hex = bd.c[i + 4][j + 4]
      bd.b[i][j] = hex
      if bd.b[i][j] then
	hex.grids = {}
	hex.location = { x = i, y = j }
	hex.grids.nw = hex.location
	hex.grid_location = { x = i + 4, y = j + 4 }
        bd.hex_count = bd.hex_count + 1
	hex_locations[#hex_locations + 1] = { x = i, y = j, hex = hex }
        hex.tile = 1
        hex.ttile = 1
	hex.textbox = MOAITextBox.new()
	hex.textbox:setAttrLink(MOAITransform.INHERIT_LOC, bd.texture_prop, MOAIProp2D.TRANSFORM_TRAIT)
	hex.textbox:setLoc(hex.sx, hex.sy)
	hex.textbox:setStyle(Board.text_style)
	hex.textbox:setRect(-60, -60, 60, 60)
	hex.textbox:setYFlip(true)
	hex.textbox:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
	hex.textbox:setString("")
	bd.layer:insertProp(hex.textbox)
	hex.textbox:setPriority(2)
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
    offsets.dx = dx
    offsets.dy = dy
    local angle = atan2(dx, dy)
    angle = (angle < 0) and (angle + (pi * 2)) or angle
    offsets.angle = angle
    offsets.dist = sqrt(dx * dx + dy * dy)
    -- printf("%s: dx, dy %.1f, %.1f. angle %.1f deg, dist %.1f",
      -- dir, dx, dy, offsets.angle * 180 / pi, offsets.dist)
  end


  setmetatable(bd, { __index = Board.funcs })

  bd.gems = {}
  -- gems available for skyfall
  bd.gempool = {}

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
    gem.prop:setPriority(1)
    gem.prop:setRot(bd.rotation)
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
    shader:setAttr(2, 0)
    shader:declareUniformSampler(3, 'rune', 1)
    shader:declareUniformSampler(4, 'gloss', 2)
    shader:declareUniformSampler(5, 'sheen', 3)
    shader:setVertexAttribute(1, 'position')
    shader:setVertexAttribute(2, 'uv')
    shader:setVertexAttribute(3, 'color')
    shader:load(Board.vsh, Board.fsh)
    gem.shader = shader
    gem.prop:setShader(gem.shader)
    gem:reset(math.random(6))
    -- for marking matches and falling
    gem.visited = false
    gem.locked = false
    gem.matched = {}

    gem.prop:setScl(bd.gem_size)
    gem:setAlpha(1.0)

    bd.layer:insertProp(gem.prop)

    gem:setLoc(gem.hex.sx, gem.hex.sy)
  end

  local dir_order = { "w", "sw", "se", "e", "ne" }

  -- make it possible to iterate the board as a series of lines in a
  -- given direction
  bd.dirs = { nw = bd.b }
  local prev = bd.dirs.nw
  for i = 1, #dir_order do
    local dir = dir_order[i]
    local tab = {}
    bd.dirs[dir] = tab
    -- fill in tab from prev
    for x = 1, #bd.idx do
      x = bd.idx[x]
      tab[x] = {}
      for y = 1, #bd.subidx[x] do
	yprime = bd.subidx[x][#bd.subidx[x] - y + 1]
        y = bd.subidx[x][y]
	local hex = prev[yprime][x]
	tab[x][y] = hex
	hex.grids[dir] = { x = x, y = y }
      end
    end
    prev = tab
  end

  return bd
end

function Board:label_dir(dir)
  self:iterate(function(hex, gem)
	  hex.textbox:setString(sprintf("e%d,%d\n%s%d,%d",
		hex.grids.e.x,
		hex.grids.e.y,
		dir,
		hex.grids[dir].x,
		hex.grids[dir].y))
  end)
end

function Board:from_screen(x, y)
  local nx, ny = self.layer:wndToWorld(self.parent_layer:worldToWnd(x, y))
  -- printf("from_screen %d, %d: %d, %d", x, y, nx, ny)
  local cx, cy = self.grid:locToCoord(nx, ny)
  local sx, sy = self:to_screen(cx, cy)
  -- printf("grid:locToCoord(%d, %d) => %s, %s (center %s, %s)", nx, ny, tostring(cx), tostring(cy), tostring(sx), tostring(sy))
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
  local nx, ny = self.parent_layer:wndToWorld(self.layer:worldToWnd(sx, sy))
  -- printf("to_screen(%d, %d): %d, %d => %d, %d", x, y, sx, sy, nx, ny)
  return nx, ny
end

function Board:iterate(func, ...)
  for i = 1, #self.idx do
    local idx = self.idx[i]
    for j = 1, #self.subidx[idx] do
      local subidx = self.subidx[idx][j]
      local hex = self.b[idx][subidx]
      local gem = hex and hex.gem
      func(hex, gem, ...)
    end
  end
end

function Board:match_gem_direction(gem, dir)
  local hex = gem.hex
  local gems = { gem }
  local count = 1
  local next_hex = hex:neighbor(dir)
  while next_hex do
    if next_hex.gem and next_hex.gem.index == gem.index then
      count = count + 1
      gems[#gems + 1] = next_hex.gem
      next_hex = next_hex:neighbor(dir)
    else
      next_hex = nil
    end
  end
  if count >= 3 then
    local match = {
      color = gem.index,
      count = count,
      gems = gems,
    }
    self.matches[#self.matches + 1] = match
    local diag = {}
    for i = 1, #gems do
      gems[i].matched[dir] = true
      gems[i].locked = true
      gems[i]:setGlow(1.0, 0.1)
      gems[i].match = match
      diag[#diag + 1] = sprintf("%d, %d", gems[i].hex.location.x, gems[i].hex.location.y)
    end
    printf("Found a match: color %d, gems %s.", gem.index, table.concat(diag, "; "))
  end
end

function Board:match_one_gem(gem)
  if not gem or not gem.hex then
    return
  end
  local dirs = { 'e', 'ne', 'se' }
  for i = 1, #dirs do
    local dir = dirs[i]
    if not gem.matched[dir] then
      self:match_gem_direction(gem, dir)
    end
  end
end

function Board:find_and_process_matches()
  self.active_match_color = 1
  self:find_matches()
  local count = 0
  local action = nil
  while #self.matches > 0 do
    local this_color = {}
    local matches_to_clear
    local found_any = false
    local inner_count = 0
    while not found_any and inner_count < 6 do
      for i = #self.matches, 1, -1 do
        if self.matches[i].color == self.active_match_color then
	  found_any = true
	  printf("found match: color %d (direction %s)", self.active_match_color, direction_idx[self.active_match_color])
          local match = tremove(self.matches, i)
	  -- wait a little before processing another match
	  if action then
	    local slight_delay = MOAITimer.new()
	    slight_delay:setSpan(0.1)
	    slight_delay:start()
	    printf("blocking on a timer")
	    MOAICoroutine.blockOnAction(slight_delay)
	  end
	  action = self:clear_match(match) or action
        end
      end
      inner_count = inner_count + 1
      if not found_any then
        self.active_match_color = (self.active_match_color % 6) + 1
      end
    end
    if action then
      printf("blocking on an action")
      MOAICoroutine.blockOnAction(action)
    end
    printf("starting skyfall, color %d (dir %s)", self.active_match_color, direction_idx[self.active_match_color])
    local any_missing = self:skyfall(self.active_match_color)
    self:find_matches()
    if any_missing > 0 and #self.matches < 1 then
      printf("Uh-oh, %d missing gem(s), no matches.", any_missing)
    end
    self.active_match_color = (self.active_match_color % 6) + 1
    count = count + 1
  end
end

function Board:find_matches()
  self.matches = {}
  printf("Checking for matches...")
  self:iterate(function(hex, gem) if gem then gem.visited = false; gem.locked = false; gem.matched = {} end end)
  self:iterate(function(hex, gem) if gem then self:match_one_gem(gem) end end)
end

function Board:clear_match(match)
  printf("Clearing %d gems.", #match.gems)
  local action = nil
  for i = 1, #match.gems do
    local gem = match.gems[i]
    local hex = gem.hex
    -- if this gem was in a match we already did, ignore it.
    if hex and hex.gem == gem and gem.match == match then
      self.gempool[#self.gempool + 1] = gem
      -- break the connection between them
      gem.hex = nil
      gem.locked = false
      hex.gem = nil
      if gem.glow_anim then
        gem.glow_anim:stop()
      end
      gem.glow_anim = gem.shader:seekAttr(2, 0.5, 0.2)
      if gem.shrink_anim then
        gem.shrink_anim:stop()
      end
      gem.shrink_anim = gem.prop:seekScl(0.1, 0.1, 0.2)
      action = gem.shrink_anim
    end
  end
  return action
end

function Board:skyfall(color)
  local dir = direction_idx[color] or 'e'
  local any_falling = true
  local action = nil
  local any_missing = 0
  printf("skyfall, direction %s", dir)
  -- self:label_dir(dir)

  while any_falling do
    any_missing = 0
    any_falling = false
    for i = 1, #self.idx do
      local falling = false
      local idx = self.idx[i]
      local prevhex = nil
      local missing_row = 0
      for j = 1, #self.subidx[idx] do
        local subidx = self.subidx[idx][j]
        local hex = self.dirs[dir][idx][subidx]
        local gem = hex and hex.gem
        if not hex.gem then
	  -- printf("%d,%d missing, things will fall", idx, subidx)
          falling = true
	  any_missing = any_missing + 1
        elseif falling then
	  if not gem.locked then
            gem.hex = prevhex
	    hex.gem = nil
	    prevhex.gem = gem
	    -- printf("%d,%d falling to previous hex", idx, subidx)
            action = gem:seekLoc(gem.hex.sx, gem.hex.sy, 0.15, MOAIEaseType.LINEAR)
	    any_falling = true
	  else
	    -- gems above this one shouldn't fall
	    falling = false
	  end
        end
        prevhex = hex
      end
      if falling then
	-- printf("adding a new gem for row %d (%d missing), dir %s, dx/dy %d/%d", idx, missing_row, dir, directions[dir].dx, directions[dir].dy)
        local newgem = table.remove(self.gempool)
	newgem:reset(math.random(6))
	newgem.hex = prevhex
	newgem:setLoc(newgem.hex.sx + directions[dir].dx, newgem.hex.sy + directions[dir].dy)
	newgem.prop:setScl(self.gem_size)
	newgem.prop:setVisible(true)
	newgem:pulse(false)
	prevhex.gem = newgem
	action = newgem:seekLoc(newgem.hex.sx, newgem.hex.sy, 0.15, MOAIEaseType.LINEAR)
	any_falling = true
      end
    end
    if action then
      MOAICoroutine.blockOnAction(action)
    end
  end
  return any_missing
end

Board.funcs = {
  from_screen = Board.from_screen,
  to_screen = Board.to_screen,
  find_matches = Board.find_matches,
  find_and_process_matches = Board.find_and_process_matches,
  match_one_gem = Board.match_one_gem,
  match_gem_direction = Board.match_gem_direction,
  iterate = Board.iterate,
  label_dir = Board.label_dir,
  clear_match = Board.clear_match,
  skyfall = Board.skyfall
}

return Board
