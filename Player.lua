local Player = {}

local printf = Util.printf
local sprintf = Util.sprintf

function Player.new()
  local p = {}
  setmetatable(p, {__index = Player.memberhash})
  p:load()
  p.elements = p.elements or { Element.new(1) }
  p.tropes = p.tropes or {}
  p.author = p.author or { level = 1, xp = 0 }
  p.formation = Formation.new('anecdote', p.elements[1])
  return p
end

function Player:load()
  local x = loadfile('savedata.lua')
  if x then
    local status, value = pcall(x)
    if status then
      self.elements = {}
      for i = 1, #value.elements do
	local s = Element.new(value.elements[i].id)
	s:gain_experience(value.elements[i].xp)
        self.elements[i] = s
      end
      self.tropes = value.tropes
      self.author = value.author
    end
  end
end

function Player:save()
  local s = MOAISerializer.new()
  s:serialize(self)
  s:exportToFile("savedata.lua")
end

function Player:inspect()
  printf("yes, it's a player")
end

Player.memberhash = {
  inspect = Player.inspect,
  load = Player.load,
  save = Player.save
}

return Player
