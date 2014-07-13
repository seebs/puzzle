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

Board.fall_time = 0.10

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
    if idx then
      self.index = idx
      self.prop:setIndex(idx)
    end
    self:setColor(self.board.color(self.index))
    self:setGlow(0.0, 0)
    self.prop:setScl(self.board.gem_size)
    self.prop:setVisible(true)
    self.visited = false
    self.locked = false
    self.matched = {}
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
    self.prop:setPriority(20)
  end,
  drop = function(self)
    self:seekLoc(self.hex.sx, self.hex.sy, 0.1)
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
uniform vec4 penColor;
uniform sampler2D rune;
uniform sampler2D gloss;
uniform sampler2D sheen;

void main() {
	vec4 gtext = texture2D(gloss, uvVaryingEffects);
	vec4 tile = texture2D(rune, uvVaryingTile);
	vec4 fakeColor = vec4(1.0, 1.0, 1.0, 1.0);
	float gscale = (1.0 - (gtext.a * (1.0 - glow)));
	vec4 gcolor = vec4(color.r * gscale, color.g * gscale, color.b * gscale, color.a);
        vec4 sum = (tile * gcolor) + texture2D(sheen, uvVaryingEffects) * ((glow * 0.5) + 0.5);
        gl_FragColor = sum * penColor.a;
}
]]

Board.text_fsh = [[
// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

varying LOWP vec4 colorVarying;
varying MEDP vec2 uvVarying;
varying MEDP vec2 uvVaryingA;
varying MEDP vec2 uvVaryingB;
varying MEDP vec2 uvVaryingC;
varying MEDP vec2 uvVaryingD;

uniform sampler2D sampler;

void main() { 
	vec4 sample = texture2D(sampler, uvVarying);
	vec4 black1 = texture2D(sampler, uvVaryingA);
	vec4 black2 = texture2D(sampler, uvVaryingB);
	vec4 black3 = texture2D(sampler, uvVaryingC);
	vec4 black4 = texture2D(sampler, uvVaryingD);
	float black = min(min(black1.a, black2.a), min(black3.a, black4.a));
	vec4 color = colorVarying;
	color = vec4(color.r * sample.a * black, color.g * sample.a * black, color.b * sample.a * black, sample.a * color.a);
	gl_FragColor = color;
}
]]
Board.text_vsh = [[
// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

attribute vec4 position;
attribute vec2 uv;
attribute vec4 color;

varying vec4 colorVarying;
varying vec2 uvVarying;
varying vec2 uvVaryingA;
varying vec2 uvVaryingB;
varying vec2 uvVaryingC;
varying vec2 uvVaryingD;

void main () {
    gl_Position = position; 
    uvVarying = uv;
    uvVaryingA = uv + vec2(0.0007, 0.0);
    uvVaryingB = uv + vec2(0.0, 0.0007);
    uvVaryingC = uv + vec2(0.0, -0.0007);
    uvVaryingD = uv + vec2(-0.0007, 0.0);
    colorVarying = color;
}
]]

Board.text_shader = MOAIShader.new()
Board.text_shader:load(Board.text_vsh, Board.text_fsh)
Board.text_shader:reserveUniforms ( 1 )
Board.text_shader:declareUniformSampler ( 1, 'sampler', 1)
Board.text_shader:setVertexAttribute ( 1, 'position' )
Board.text_shader:setVertexAttribute ( 2, 'uv' )
Board.text_shader:setVertexAttribute ( 3, 'color' )

Board.funcs = {}

function Board:script_processing()
  if true then
    return
  end
  MOAIGfxDevice.setPenColor(1, 1, 1, 1)
  local p0 = { x = self.lower_left_bound.x, y = self.lower_left_bound.y }
  local p1 = { x = self.upper_right_bound.x, y = self.upper_right_bound.y }
  p0.x = p0.x + self.offsets.x
  p1.x = p1.x + self.offsets.x
  p0.y = p0.y + self.offsets.y
  p1.y = p1.y + self.offsets.y
  MOAIDraw.drawLine(p0.x, p0.y,
  	p1.x, p0.y,
	p1.x, p1.y,
	p0.x, p1.y,
	p0.x, p0.y,
	p1.x, p1.y)
  p0 = { x = self.lower_left.x, y = self.lower_left.y }
  p1 = { x = self.upper_right.x, y = self.upper_right.y }
  p0.x = p0.x + self.offsets.x
  p1.x = p1.x + self.offsets.x
  p0.y = p0.y + self.offsets.y
  p1.y = p1.y + self.offsets.y
  MOAIGfxDevice.setPenColor(0, 1, 0, 1)
  MOAIDraw.drawLine(p0.x, p0.y,
  	p1.x, p0.y,
	p1.x, p1.y,
	p0.x, p1.y,
	p0.x, p0.y,
	p1.x, p1.y)
end

function Board.new(scene, args)
  args = args or {}
  local bd = {}
  bd.layer = flower.Layer()
  -- bd.layer:setClearColor(0.5, 0.5, 0.5, 1.0)
  scene:addChild(bd.layer)
  -- built around 768 as a baseline
  bd.base_scale = (flower.viewWidth / 768)
  -- printf("base scale: %.2f", bd.base_scale)
  bd.color_multiplier = args.color_multiplier or 1
  bd.highlights = args.highlights or 0
  bd.color_funcs = Rainbow.funcs_for(bd.color_multiplier)
  bd.color = bd.color_funcs.smooth
  bd.columns = args.columns or 12
  bd.size = { x = args.size and args.size.x or (flower.viewWidth / (bd.columns + 1)) }
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
  bd.grid:initAxialHexGrid(bd.columns, bd.rows, bd.size.x, bd.size.y, 2, 2)
  -- an additional grid to live in front of the other
  bd.texture_grid = MOAIGridFancy.new()
  bd.texture_grid:initAxialHexGrid(bd.columns, bd.rows, bd.size.x, bd.size.y, 2, 2)
  local rx, ry = bd.grid:getTileLoc(1, 1, MOAIGridSpace.TILE_LEFT_TOP)
  bd.lower_left = { x = rx, y = ry }
  bd.lower_left_bound = { x = rx, y = ry }
  rx, ry = bd.grid:getTileLoc(1, floor((bd.rows + 1) / 2), MOAIGridSpace.TILE_LEFT_TOP)
  bd.lower_left_bound.x = rx
  rx, ry = bd.grid:getTileLoc(bd.columns, bd.rows, MOAIGridSpace.TILE_RIGHT_BOTTOM)
  bd.upper_right = { x = rx, y = ry }
  bd.upper_right_bound = { x = rx, y = ry }
  rx, ry = bd.grid:getTileLoc(bd.columns, floor((bd.rows + 1) / 2), MOAIGridSpace.TILE_RIGHT_BOTTOM)
  bd.upper_right_bound.x = rx
  bd.grid_size = { x = bd.upper_right_bound.x - bd.lower_left_bound.x, y = bd.upper_right_bound.y - bd.lower_left_bound.y }
  --[[
    the computed size of the grid should be pretty exact -- if I
    draw lines at those coordinates, they are exactly at the edges
    of the hex grid. But if I set the location based on that, it
    is off-center. I think the grid itself is slightly off-center
    from its nominal location, thus the fudge factors.
    ]]--
  bd.offsets = {
  x = (flower.viewWidth - bd.grid_size.x) / 2 - bd.lower_left_bound.x,
  y = (flower.viewHeight - bd.grid_size.y) / 2 - bd.lower_left_bound.y + (bd.size.y / 12)
  }
  -- printf("screen size: %dx%d", flower.viewWidth, flower.viewHeight)
  -- printf("offsets:")
  -- Util.dump(bd.offsets)

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
  bd.texture_prop:setLoc(bd.offsets.x, bd.offsets.y)

  bd.texture_prop:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
  bd.layer:insertProp(bd.texture_prop)

  bd.border_prop = MOAIProp2D.new()
  bd.border_quad = MOAIGfxQuad2D.new()
  bd.border_texture = MOAITexture.new()
  bd.border_texture:load("border.png")
  bd.border_quad:setTexture(bd.border_texture)
  bd.border_prop:setDeck(bd.border_quad)
  bd.border_prop:setPriority(10)
  -- bd.border_prop:setColor(0.3, 0.3, 0.3, 0.3)
  bd.border_prop:setScl(bd.base_scale)
  local border_size = 1024 * bd.base_scale
  local xdiff = border_size - bd.grid_size.x
  local ydiff = border_size - bd.grid_size.y
  -- printf("border: %dpx tall, grid %dx%d, diff %dx%d", border_size, bd.grid_size.x, bd.grid_size.y, xdiff, ydiff)
  bd.border_quad:setRect(0, 0, 1024, 1024)
  bd.border_prop:setLoc(-(xdiff / 2) - (bd.lower_left.x - bd.lower_left_bound.x), -(ydiff / 2))
  bd.layer:insertProp(bd.border_prop)
  bd.border_prop:setAttrLink(MOAITransform.INHERIT_LOC, bd.texture_prop, MOAIProp2D.TRANSFORM_TRAIT)

  local foo = flower.Label("Foo", 140, 40, nil, 15)
  foo:setColor(1, 1, 1)
  foo:setPriority(30)
  bd.layer:insertProp(foo)

  bd.combo_meters = {}
  for i = 1, 6 do
    bd.combo_meters[i] = flower.Label("Match:", 140, 30, nil, 12)
    bd.combo_meters[i]:setPriority(11)
    Rainbow.color_styles(bd.combo_meters[i])
    bd.combo_meters[i]:setStyle(bd.combo_meters[i]:getStyle(Rainbow.name(i)))
    bd.combo_meters[i]:setYFlip(true)
    bd.combo_meters[i]:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
    bd.combo_meters[i]:setLoc(3 - bd.offsets.x, bd.upper_right.y - (12 * (i - 1)))
    bd.layer:insertProp(bd.combo_meters[i])
    bd.combo_meters[i]:setAttrLink(MOAITransform.INHERIT_LOC, bd.texture_prop, MOAIProp2D.TRANSFORM_TRAIT)
  end

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
        hex.ttile = random(6)
	hex.textbox = MOAITextBox.new()
	hex.textbox:setAttrLink(MOAITransform.INHERIT_LOC, bd.texture_prop, MOAIProp2D.TRANSFORM_TRAIT)
	hex.textbox:setLoc(hex.sx, hex.sy)
	hex.textbox:setStyle(Board.text_style)
	hex.textbox:setRect(-70, -70, 70, 70)
	hex.textbox:setYFlip(true)
	hex.textbox:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
	hex.textbox:setString("HEY")
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
    gem.prop:setAttrLink(MOAITransform.INHERIT_LOC, bd.texture_prop, MOAIProp2D.TRANSFORM_TRAIT)
    local other_deck = MOAIGfxQuad2D.new()
    other_deck:setTexture(Board.gem_multitex)
    other_deck:setRect(1, -1, -1, 1, 1)
    other_deck:setUVRect(0, 1, 1, 0)
    gem.prop:setDeck(Board.gem_deck)
    gem.prop:setTexture(Board.gem_multitex)
    local shader = MOAIShader.new()
    shader:reserveUniforms(6)
    shader:declareUniform(1, 'color', MOAIShader.UNIFORM_COLOR)
    shader:declareUniform(2, 'glow', MOAIShader.UNIFORM_FLOAT)
    shader:declareUniform(3, 'penColor', MOAIShader.UNIFORM_PEN_COLOR)
    shader:setAttrLink(1, gem.prop, MOAIColor.COLOR_TRAIT)
    shader:setAttr(2, 0)
    shader:declareUniformSampler(4, 'rune', 1)
    shader:declareUniformSampler(5, 'gloss', 2)
    shader:declareUniformSampler(6, 'sheen', 3)
    shader:setVertexAttribute(1, 'position')
    shader:setVertexAttribute(2, 'uv')
    shader:setVertexAttribute(3, 'color')
    shader:load(Board.vsh, Board.fsh)
    gem.shader = shader
    gem.prop:setShader(gem.shader)
    gem:reset(random(6))

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

  bd.scriptdeck = MOAIScriptDeck.new()
  bd.scriptdeck:setRect(bd.lower_left_bound.x, bd.lower_left_bound.y, bd.upper_right_bound.x, bd.upper_right_bound.y)
  bd.scriptdeck:setDrawCallback(function() Board.script_processing(bd) end)
  bd.scriptprop = MOAIProp2D.new()
  bd.scriptprop:setDeck(bd.scriptdeck)
  bd.scriptprop:setPriority(10)
  bd.layer:insertProp(bd.scriptprop)

  bd:find_and_break_matches()
  printf("bd: %s", tostring(bd))

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
  x, y = x - self.offsets.x, y - self.offsets.y
  -- printf("from_screen %d, %d: %d, %d => %d, %d", x, y, nx, ny, nx - self.offsets.x, ny - self.offsets.y)
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
  local nx, ny = sx + self.offsets.x, sy + self.offsets.y
  -- printf("to_screen(%d, %d): %d, %d => %d, %d => %d, %d", x, y, sx, sy, sx + self.offsets.x, sy + self.offsets.y, nx, ny)
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
    -- printf("Found a match: color %d, gems %s.", gem.index, table.concat(diag, "; "))
  end
end

function Board:populate()
  local f = function(hex, gem)
    if not gem then
      gem = tremove(self.gempool)
    end
    gem:reset(random(6))
  end
  self:iterate(f)
  self:find_and_break_matches()
end

function Board:match_one_gem(gem)
  if not gem or not gem.hex then
    return
  end
  local dirs = { "nw", "ne", "e" }
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
  self.results = {}
  self.displayed = {}
  -- printf("find_and_process matches starting, setting meters to empty")
  for i = 1, 6 do
    self.combo_meters[i]:setString("Match: ")
  end
  while #self.matches > 0 do
    local this_color = {}
    local found_any = false
    local inner_count = 0
    while not found_any and inner_count < 6 do
      for i = #self.matches, 1, -1 do
        if self.matches[i].color == self.active_match_color then
	  found_any = true
	  -- printf("found match: color %d (direction %s)", self.active_match_color, direction_idx[self.active_match_color])
          local match = tremove(self.matches, i)
	  Util.wait(0.1)
	  action = self:clear_match(match) or action
        end
      end
      inner_count = inner_count + 1
      if not found_any then
        self.active_match_color = (self.active_match_color % 6) + 1
      end
    end
    if action then
      Util.wait(0.1)
    end
    -- printf("starting skyfall, color %d (dir %s)", self.active_match_color, direction_idx[self.active_match_color])
    local any_missing = self:skyfall(self.active_match_color)
    self:find_matches()
    if any_missing > 0 and #self.matches < 1 then
      printf("Uh-oh, %d missing gem(s), no matches.", any_missing)
    end
    self.active_match_color = (self.active_match_color % 6) + 1
    count = count + 1
  end
  -- printf("finishing matches:")
  -- Util.dump(self.displayed)
  for i = 1, 6 do
    self.combo_meters[i]:setString(sprintf("Match: %d", self.displayed[i] or 0))
  end
  if action then
    -- printf("blocking on an action")
    MOAICoroutine.blockOnAction(action)
  end
  return self.results
end

function Board:find_and_break_matches()
  self.active_match_color = 1
  self:find_matches()
  local count = 0
  while #self.matches > 0 do
    local this_color = {}
    local found_any = false
    local inner_count = 0
    while not found_any and inner_count < 6 do
      local broke = 0
      for i = #self.matches, 1, -1 do
        if self.matches[i].color == self.active_match_color then
	  found_any = true
	  -- printf("found match: color %d (direction %s)", self.active_match_color, direction_idx[self.active_match_color])
          local match = tremove(self.matches, i)
	  local c = match.gems[2].index
	  c = (((c - 1) + random(5)) % 6) + 1
	  broke = broke + 1
	  match.gems[2]:reset(c)
        end
      end
      printf("broke %d %s matches", broke, Rainbow.name(self.active_match_color))
      inner_count = inner_count + 1
      if not found_any then
        self.active_match_color = (self.active_match_color % 6) + 1
      end
    end
    self:find_matches()
    self.active_match_color = (self.active_match_color % 6) + 1
    count = count + 1
  end
  self:iterate(function(hex, gem) if gem then gem:reset() end end)
  printf("broke matches: %d passes.", count)
  self.matches = {}
end


function Board:find_matches()
  self.matches = {}
  -- printf("Checking for matches...")
  self:iterate(function(hex, gem) if gem then gem.visited = false; gem.locked = false; gem.matched = {} end end)
  self:iterate(function(hex, gem) if gem then self:match_one_gem(gem) end end)
end

function Board:clear_match(match)
  -- printf("Clearing %d gems (%s).", #match.gems, Rainbow.name(match.color))
  local action = nil
  self.results[match.color] = self.results[match.color] or {}
  self.displayed[match.color] = self.displayed[match.color] or 0
  self.combo_meters[match.color]:setString(sprintf("Match: %d+%d", self.displayed[match.color], #match.gems))
  self.combo_meters[match.color]:revealAll()
  self.displayed[match.color] = self.displayed[match.color] + #match.gems
  local tab = self.results[match.color]
  -- Sound.play(match.color)
  Sound.play('up')
  tab[#tab + 1] = #match.gems
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
      gem.glow_anim = gem.shader:seekAttr(2, 0.5, 0.1)
      if gem.shrink_anim then
        gem.shrink_anim:stop()
      end
      gem.shrink_anim = gem.prop:seekScl(0.1, 0.1, 0.1)
      action = gem.shrink_anim
    end
  end
  Util.wait(0.075)
  return action
end

function Board:skyfall(color)
  local dir = direction_idx[color] or 'e'
  local any_falling = true
  local action = nil
  local any_missing = 0
  -- printf("skyfall, direction %s", dir)
  -- self:label_dir(dir)
  local most_falling = 0
  local longest_action = nil
  local lasthex = nil

  for i = 1, #self.idx do
    local falling = 0
    local idx = self.idx[i]
    local needs_gems = {}
    for j = 1, #self.subidx[idx] do
      local subidx = self.subidx[idx][j]
      local hex = self.dirs[dir][idx][subidx]
      lasthex = hex
      local gem = hex and hex.gem
      if not hex.gem then
	-- printf("%d,%d missing, things will fall", idx, subidx)
	falling = falling + 1
	needs_gems[#needs_gems + 1] = hex
	any_missing = any_missing + 1
      elseif falling > 0 then
	if not gem.locked then
	  local target = tremove(needs_gems, 1)
	  needs_gems[#needs_gems + 1] = hex
	  gem.hex = target
	  hex.gem = nil
	  target.gem = gem
	  -- printf("%d, %d falling %d spaces to %d,%d", idx, subidx, falling, target.grids[dir].x, target.grids[dir].y)
	  action = gem:seekLoc(gem.hex.sx, gem.hex.sy, Board.fall_time * falling, MOAIEaseType.LINEAR)
	  any_falling = true
	else
	  -- gems above this one shouldn't fall
	  -- printf("%d spaces below a locked gem, skipping", falling)
	  needs_gems = {}
	  falling = 0
	end
      end
    end
    -- printf("falling: %d needs_gems: %d, available %d", falling, #needs_gems, #self.gempool)
    for i = 1, falling do
      -- printf("adding a new gem for row %d, dir %s, dx/dy %d/%d", idx, dir, directions[dir].dx, directions[dir].dy)
      local newgem = tremove(self.gempool)
      if newgem then
	newgem:reset(random(6))
	newgem.hex = tremove(needs_gems, 1)
	newgem:setLoc(lasthex.sx + directions[dir].dx, lasthex.sy + directions[dir].dy)
	newgem:pulse(false)
	newgem.hex.gem = newgem
	any_missing = any_missing - 1
	if i > 1 then
	  -- printf("new gem, falling %d spaces to %d,%d after %d ticks", (falling + 1 - i), newgem.hex.grids[dir].x, newgem.hex.grids[dir].y, i - 1)
	  Util.after(Board.fall_time * (i - 1), function()
	    newgem:seekLoc(newgem.hex.sx, newgem.hex.sy, (falling + 1 - i) * Board.fall_time, MOAIEaseType.LINEAR)
	  end)
	else
	  -- printf("new gem, falling %d spaces immediately to %d,%d", falling, newgem.hex.grids[dir].x, newgem.hex.grids[dir].y)
	  action = newgem:seekLoc(newgem.hex.sx, newgem.hex.sy, falling * Board.fall_time, MOAIEaseType.LINEAR)
	  if #needs_gems + 1 > most_falling then
	    most_falling = #needs_gems + 1
	    longest_action = action
	  end
	end
	any_falling = true
      else
        printf("No gem available?")
      end
    end
  end
  if longest_action then
    -- printf("waiting on longest action (%d gems)", most_falling)
    MOAICoroutine.blockOnAction(longest_action)
  end
  self.combo_meters[color]:setString(sprintf("Match: %d", self.displayed[color] or 0))
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
  populate = Board.populate,
  label_dir = Board.label_dir,
  clear_match = Board.clear_match,
  find_and_break_matches = Board.find_and_break_matches,
  skyfall = Board.skyfall
}

return Board
