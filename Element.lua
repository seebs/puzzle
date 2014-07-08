-- elements, the basic "characters" of the game
local printf = Util.printf
local sprintf = Util.sprintf

local Element = {}

Element.internal = {
  {
    name = "sword",
    genre = "fantasy",
    statistics = {
      character = {
        inspiration = 'C',
	wordcount = 'D',
      },
      protagonist = {
        wordcount = 'D',
      }
    }
  },
  {
    name = "orc",
    genre = "fantasy",
    statistics = {
      character = {
        inspiration = 20,
	wordcount = 100,
      },
      antagonist = {
        inspiration = 100,
      }
    }
  }
}

Element.statistics = { 'inspiration', 'wordcount' }

local function make_stat(tab, key)
  local s = tab[key]
  if type(s) == 'number' then
    tab[key] = Stat.new(nil, s)
  elseif type(s) == 'string' then
    tab[key] = Stat.new(s, nil)
  end
end

function Element.new(id)
  local e = Util.deepcopy(Element.internal[id])
  Util.traverse(e.statistics, make_stat)
  setmetatable(e, {__index = Element.memberhash})
  return e
end

function Element:stats(flags)
  local stats = {}
  for i = 1, #Element.statistics do
    stats[Element.statistics[i]] = Genre.list(0)
  end
  flags = Util.flags(flags or "")
  if self.statistics then
    for flag, details in pairs(self.statistics) do
      if flags[flag] then
        for stat, values in pairs(details) do
	  if stats[stat] then
	    if type(values) == 'table' then
	      if values.value then
	        stats[stat][self.genre] = stats[stat][self.genre] + values:value()
	      else
	        for genre, value in pairs(values) do
		  printf("stats[%s][%s] = %s", stat, genre, tostring(value))
	          stats[stat][genre] = stats[stat][genre] + value:value()
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

Element.memberhash = {
  stats = Element.stats,
  inspect = Element.inspect
}

return Element
