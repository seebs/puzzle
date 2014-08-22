local Dungeon = {}

local templates = {
	{
	  name = "Demo Dungeon",
	  rooms = {
	    {
	      monsters = {
	        { id = 2, level = 5 },
	        { id = 2, level = 5 },
	      }
	    },
	    {
	      monsters = {
	        { id = 2, level = 3 },
	        { id = 2, level = 7 },
	        { id = 2, level = 3 },
	      }
	    }
	  }
	},
}

function Dungeon.new(id)
  local o = Util.deepcopy(templates[id])
  
  setmetatable(o, {__index = Dungeon.memberhash})
  return o
end

return Dungeon
