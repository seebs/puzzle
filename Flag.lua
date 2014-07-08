-- flags an element slot might have, like protagonist or antagonist

local Flag = {}

Flag.flags = {
  'narrator',
  'character',
  'protagonist',
  'antagonist',
  'support',
}

function Flag.iterate()
  return Util.iterator(Flag.flags)
end

return Flag
