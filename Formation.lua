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
  f.slots = Util.deepcopy(prototypes[type])
  setmetatable(f, {__index = Formation.memberhash})
  for i = 1, #elements do
    if f.slots[i] then
      f.slots[i].element = Element.new(elements[i])
    end
  end
  return f
end

function Formation:stats()
  local totals = {}
  for _, slot in pairs(self.slots) do
    if slot.element then
      local stats = slot.element:stats(slot.flags)
      for stat, details in pairs(stats) do
        totals[stat] = totals[stat] or Genre.list(0)
	for i = 1, #Genre.genres do
	  local genre = Genre.genres[i]
	  totals[stat][genre] = totals[stat][genre] + (details[genre] or 0)
	end
      end
    end
  end
  return totals
end

function Formation:inspect()
  local stats = self:stats()
  printf("Elements:")
  for i = 1, #self.slots do
    if self.slots[i].element then
      self.slots[i].element:inspect("  ")
    else
      printf("  empty (%s)", self.slots[i].flags)
    end
  end
  printf("Total stats:")
  for stat, details in pairs(stats) do
    printf("  %s:", stat)
    for genre, value in pairs(details) do
      printf("    %s: %d", genre, value)
    end
  end
end

Formation.memberhash = {
  stats = Formation.stats,
  inspect = Formation.inspect,
}

return Formation
