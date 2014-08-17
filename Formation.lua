local Formation = {}

local printf = Util.printf
local sprintf = Util.sprintf

local prototypes = {
  anecdote = {
    { flags = "narrator protagonist character" },
  },
  novel = {
    { flags = "protagonist character" },
    { flags = "antagonist character" },
  },
}

function Formation.new(type, ...)
  local f = {}
  local elements = { ... }
  f.type = type
  f.slots = Util.deepcopy(prototypes[type])
  setmetatable(f, {__index = Formation.memberhash})
  for i = 1, #elements do
    if f.slots[i] then
      f.slots[i].element = elements[i]
      f.slots[i].element:set_flags(f.slots[i].flags)
    end
  end
  f.stats = f:compute_stats()
  f.inspiration = f.stats.inspiration.total
  f.max_inspiration = f.stats.inspiration.total
  return f
end

function Formation:compute_stats()
  local totals = {}
  for _, slot in pairs(self.slots) do
    if slot.element then
      local stats = slot.element:stats(slot.flags)
      for stat, details in pairs(stats) do
        totals[stat] = totals[stat] or Genre.list(0)
	for genre in Genre.iterate() do
	  totals[stat][genre] = totals[stat][genre] + (details[genre] or 0)
	end
      end
    end
  end
  for k, v in pairs(totals) do
    Util.tsum(v)
  end
  return totals
end

function Formation:inspect()
  printf("Total inspiration: %d/%d", self.inspiration, self.max_inspiration)
  printf("Elements:")
  for i = 1, #self.slots do
    if self.slots[i].element then
      self.slots[i].element:inspect("  ")
    else
      printf("  empty (%s)", self.slots[i].flags)
    end
  end
  printf("Total stats:")
  for stat, details in pairs(self.stats) do
    printf("  %s:", stat)
    for genre, value in pairs(details) do
      printf("    %s: %d", genre, value)
    end
  end
end

Formation.memberhash = {
  compute_stats = Formation.compute_stats,
  inspect = Formation.inspect,
}

return Formation
