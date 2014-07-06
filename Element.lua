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
        inspiration = 100,
	wordcount = 50,
      },
      protagonist = {
        wordcount = 50,
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

Element.flags = { 'protagonist', 'character', 'antagonist', 'narrator', 'support' }
Element.statistics = { 'inspiration', 'wordcount' }

function Element.new(id)
  local e = Util.deepcopy(Element.internal[id])
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
	      for genre, value in pairs(values) do
	        stats[stat][genre] = stats[stat][genre] + value
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

function Element:inspect()
  for i = 1, #Element.flags do
    local flag = Element.flags[i]
    local stats, has_stats = self:stats(flag)
    if has_stats then
      printf("%s:", flag)
      for i = 1, #Element.statistics do
	local s = Element.statistics[i]
	if stats[s].total and stats[s].total > 0 then
	  local stat = stats[s]
          printf("  %s:", s)
	  for j = 1, #Genre.genres do
	    local g = Genre.genres[j]
	    if stat[g] and stat[g] > 0 then
	      printf("    %s: %d", g, stat[g])
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
