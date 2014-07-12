local Player = {}

local printf = Util.printf
local sprintf = Util.sprintf

require 'luasql'

local sqlite = luasql.sqlite3()
local db = sqlite:connect("player.db")

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
