local Stat = {}
local printf = Util.printf
local sprintf = Util.sprintf

local sfind = string.find

local conv = {
	F = 0,
	E = 1,
	D = 2,
	C = 3,
	B = 4,
	A = 5,
	S = 6,
	[0] = 'F',
	[1] = 'E',
	[2] = 'D',
	[3] = 'C',
	[4] = 'B',
	[5] = 'A',
	[6] = 'S',
}

setmetatable(conv, {__index = function() return 0 end})

-- 
function Stat.new(rank, fixed_value, tier, level)
  local base_rank, progression_rank, _
  if rank == nil then
    base_rank = 0
    progression_rank = 0
  else
    _, _, base_rank, progression_rank = sfind(tostring(rank), "(%a)/?(%a?)")
    -- default to treating A as A/A.
    if not progression_rank or progression_rank == "" then
      progression_rank = base_rank
    end
    base_rank = conv[base_rank]
    progression_rank = conv[progression_rank]
  end
  local s = { fixed_value = fixed_value or 0, base_rank = base_rank, progression_rank = progression_rank, tier = tier or 1, level = level or 1 }
  setmetatable(s, {__index = Stat.memberhash})
  return s
end

function Stat:inspect(name)
  name = name or "stat"
  return sprintf("%s: Base %s, progression %s, tier %d, level %d, fixed %d, final value %d.",
    name, conv[self.base_rank], conv[self.progression_rank], self.tier, self.level,
    self.fixed_value, self:value())
end

function Stat:value(level)
  level = level or self.level
  return ((self.base_rank + self.tier - 1) * 100) + ((self.progression_rank + self.tier) * (level - 1)) + self.fixed_value
end

Stat.memberhash = {
  inspect = Stat.inspect,
  value = Stat.value,
}

return Stat
