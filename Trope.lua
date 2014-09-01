-- tropes, the "powers" of the game

local Trope = {}

function Trope.new()
  local self = {}

  setmetatable(self, {__index = Trope.memberhash})

  return self
end

Trope.memberhash = {
}

return Trope
