-- elements, the basic "characters" of the game
local printf = Util.printf
local sprintf = Util.sprintf

local sqrt = math.sqrt
local floor = math.floor
local pow = math.pow

local Element = {}

Element.internal = {
  {
    name = "sword",
    genre = "fantasy",
    statistics = {
      character = {
        inspiration = 'C',
	wordcount = 'D',
	defense = 'E',
      },
      protagonist = {
        wordcount = 'E',
      }
    }
  },
  {
    name = "orc",
    genre = "fantasy",
    statistics = {
      character = {
        inspiration = 'D',
	wordcount = 100,
	defense = 'C',
      },
      antagonist = {
        inspiration = 100,
	defense = 'D',
      }
    }
  },
}

Element.statistics = { 'inspiration', 'wordcount', 'defense' }

local function make_stat(tab, key, tier)
  local s = tab[key]
  if type(s) == 'number' then
    tab[key] = Stat.new(nil, s, tier, key)
  elseif type(s) == 'string' then
    tab[key] = Stat.new(s, nil, tier, key)
  end
end

function Element.new(spec, flags)
  if type(spec) == 'number' then
    spec = { id = spec, level = 1, flags = flags or 'character' }
  elseif type(spec) == 'table' then
    spec.flags = spec.flags or 'character'
  end
  local e = Util.deepcopy(Element.internal[spec.id])
  Util.traverse(e.statistics, make_stat, nil, e.tier or 1)
  e.id = spec.id
  e.flags = spec.flags
  e.xp = 0
  e.level = spec.level or 1
  setmetatable(e, {__index = Element.memberhash})
  -- default values?
  local stats = e:stats()
  e.status = {}
  for i = 1, #Element.statistics do
    local s = Element.statistics[i]
    if stats[s].total and stats[s].total > 0 then
      e.status[s] = stats[s].total
    end
  end
  return e
end

function Element:set_flags(flags)
  self.flags = flags
  local stats = self:stats()
  self.status = {}
  for i = 1, #Element.statistics do
    local s = Element.statistics[i]
    if stats[s].total and stats[s].total > 0 then
      self.status[s] = stats[s].total
    end
  end
end

function Element:gain_experience(xp)
  self.xp = self.xp + xp
  return self:maybe_level()
end

function Element:maybe_level()
  local oldlevel = self.level
  self.level = floor(sqrt(self.xp / 1000)) + 1

  if self.level > oldlevel then
    return true
  end
end

function Element:stats(flags)
  local stats = {}
  for i = 1, #Element.statistics do
    stats[Element.statistics[i]] = Genre.list(0)
  end
  flags = Util.flags(flags or self.flags or "")
  if self.statistics then
    for flag, details in pairs(self.statistics) do
      if flags[flag] then
        for stat, values in pairs(details) do
	  if stats[stat] then
	    if type(values) == 'table' then
	      if values.value then
	        stats[stat][self.genre] = stats[stat][self.genre] + values:value(self.level)
		-- printf("stats[%s][implicit %s] = %s (%d)", stat, self.genre, tostring(values), values:value(self.level))
	      else
	        for genre, value in pairs(values) do
	          stats[stat][genre] = stats[stat][genre] + value:value(self.level)
		  -- printf("stats[%s][%s] = %s (%d)", stat, genre, tostring(value), value:value(self.level))
	        end
	      end
	    else
	      stats[stat][self.genre] = stats[stat][self.genre] + values
	    end
	  end
	end
      end
    end
  end
  local found_any = false
  for stat, values in pairs(stats) do
    local t, f = Util.tsum(values)
    found_any = found_any or f
  end
  return stats, found_any
end

function Element:inspect(prefix)
  prefix = prefix or ""
  printf("%s%s", prefix, self.name or "unnamed")
  for flag in Flag.iterate() do
    local stats, has_stats = self:stats(flag)
    if has_stats then
      printf("%s%s:", prefix, flag)
      for i = 1, #Element.statistics do
	local s = Element.statistics[i]
	if stats[s].total and stats[s].total > 0 then
	  local stat = stats[s]
          printf("%s  %s:", prefix, s)
	  for g in Genre.iterate() do
	    if stat[g] and stat[g] ~= 0 then
	      local details
	      if self.statistics[flag][s].value then
	        details = self.statistics[flag][s]:inspect(self.genre)
	      else
	        details = self.statistics[flag][s][g]:inspect(g)
	      end
	      printf("%s    %s", prefix, details)
	    end
	  end
	end
      end
    end
  end
end

function Element:damage_from(genre, damage)
  local defense = self.status.defense or 0
  local odamage = damage
  damage = Util.damage(damage, defense)
  return damage, defense
end

function Element:take_damage(genre, damage)
  local ndamage, defense = self:damage_from(genre, damage)
  printf("%s taking damage: %s, %d. Defense %d, final %d.", self.name, genre, damage, defense, ndamage)
  if self.inspiration then
    self.inspiration = self.inspiration - ndamage
  end
  return ndamage
end

Element.memberhash = {
  stats = Element.stats,
  gain_experience = Element.gain_experience,
  inspect = Element.inspect,
  set_flags = Element.set_flags,
  maybe_level = Element.maybe_level,
  take_damage = Element.take_damage,
  damage_from = Element.damage_from,
}

return Element
