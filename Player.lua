local Player = {}

local printf = Util.printf
local sprintf = Util.sprintf

function Player.new()
  local p = {}
  setmetatable(p, {__index = Player.memberhash})
  return p
end

function Player.inspect()
  printf("yes, it's a player")
end

Player.memberhash = {
  inspect = Player.inspect
}

return Player
