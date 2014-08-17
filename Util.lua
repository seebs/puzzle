local Util = {}

io.output():setvbuf('no')

function Util.sprintf(fmt, ...)
  local foo = function(...) return string.format(fmt or 'nil', ...) end
  local status, value = pcall(foo, ...)
  if status then
    return value
  else
    return 'Format "' .. (fmt or 'nil') .. '": ' .. value
  end
end

local sprintf = Util.sprintf

function Util.printf(fmt, ...)
  print(sprintf(fmt, ...))
end

local printf = Util.printf

local passverbs = { 'get', 'set', 'move', 'seek' }
local passnouns = { 'Loc', 'Rot', 'Scl', 'Color' }
local passthrough = { 'setParent', 'setLayer', 'setVisible', 'setPriority', 'setScissorRect' }
function Util.makepassthrough(memberhash, target)
  for i = 1, #passthrough do
    local name = passthrough[i]
    if not memberhash[name] then
      memberhash[name] = function(self, ...) return self[target][name](self[target], ...) end
    end
  end
  for i = 1, #passverbs do
    for j = 1, #passnouns do
      local name = passverbs[i] .. passnouns[j]
      if not memberhash[name] then
        memberhash[name] = function(self, ...) return self[target][name](self[target], ...) end
      end
    end
  end
end

function Util.iterator(tab)
  local idx = 0
  return function()
    idx = idx + 1
    return tab[idx]
  end
end

function Util.after(time, func, ...)
  local t = MOAITimer.new()
  local args = { ... }
  t:setSpan(time)
  t:setMode(MOAITimer.NORMAL)
  t:setListener(MOAIAction.EVENT_STOP, function() func(unpack(args)) end)
  t:start()
  return t
end

function Util.flags(obj)
  local t = {}
  if type(obj) == 'table' then
    return obj
  end
  if type(obj) == 'string' then
    obj = Util.split(obj)
  end
  for i = 1, #obj do
    t[obj[i]] = true
  end
  return t
end

-- iterate over a table
function Util.traverse(tab, func, seen)
  if seen and seen[tab] then
    return
  end
  seen = seen or {}
  seen[tab] = true
  for k, v in pairs(tab) do
    if type(v) == 'table' then
      Util.traverse(v, func, seen)
    else
      func(tab, k)
    end
  end
end

function Util.generic_cmp(a, b)
  local ta, tb = type(a), type(b)
  if ta ~= tb then
    return ta < tb
  end
  if ta == 'boolean' then
    return a
  elseif ta == 'string' or ta == 'number' then
    return a < b
  else
    return tostring(a) < tostring(b)
  end
end

function Util.inorder(tab, idxtab, func)
  local metaidx = 0
  if not idxtab then
    idxtab = {}
    for k, v in pairs(tab) do
      idxtab[#idxtab + 1] = k
    end
    table.sort(idxtab, func)
  end
  return function()
    metaidx = metaidx + 1
    return idxtab[metaidx], tab[idxtab[metaidx]]
  end
end

function Util.deepcopy(item, seen)
  local ret = {}
  if seen and seen[item] then
    return ret
  end
  seen = seen or { }
  seen[item] = true
  for k, v in pairs(item) do
    if type(v) == 'table' then
      ret[k] = Util.deepcopy(v, seen)
    else
      ret[k] = v
    end
  end
  return ret
end

function Util.split(str, sep)
  -- I don't want to have to do this test everywhere
  if type(str) == 'table' then
    return str
  end
  sep = sep or " +"
  local first, last = str:find(sep)
  local t = {}
  while first do
    if first > 1 then
      t[#t + 1] = str:sub(1, first - 1)
    end
    str = str:sub(last + 1)
    first, last = str:find(sep)
  end
  if #str > 0 then
    t[#t + 1] = str
  end
  return t
end

-- 
function Util.tsum(tab, force)
  local total = 0
  local found_any = false
  if force then
    tab.total = nil
  end
  if tab.total then
    return tab.total
  end
  for k, v in pairs(tab) do
    if k ~= 'total' then
      if type(v) == 'table' then
	local t, f = Util.tsum(v, force)
	found_any = found_any or f
	total = total + t
      else
        total = total + v
	found_any = found_any or (v ~= 0)
      end
    end
  end
  tab.total = total
  return total, found_any
end

function Util.wait(time)
  local slight_delay = MOAITimer.new()
  slight_delay:setSpan(time or 0.1)
  slight_delay:start()
  -- printf("blocking on a timer")
  MOAICoroutine.blockOnAction(slight_delay)
end

function Util.dump(obj, name, prefix, seen)
  seen = seen or {}
  name = name or 'object'
  prefix = prefix or ''
  if type(obj) == 'table' then
    if #prefix > 6 then
      seen[obj] = true
      printf("%s%s = { [%s, too deep] } ", prefix, name, tostring(obj))
      return
    end
    printf("%s%s = { [%s]", prefix, name, tostring(obj))
    if seen[obj] then
      printf("%s  [already seen]", prefix)
      printf("%s}", prefix)
      return
    end
    seen[obj] = true
    local lookup = {}
    local keynames = {}
    for k, v in pairs(obj) do
      local name = tostring(k)
      lookup[name] = v
      keynames[#keynames + 1] = name
    end
    table.sort(keynames)
    for i = 1, #keynames do
      local name = keynames[i]
      Util.dump(lookup[name], name, prefix .. "  ", seen)
    end
    printf("%s}", prefix)
  else
    printf("%s%s = %s", prefix, name, tostring(obj))
    if obj ~= nil then
      seen[obj] = true
    end
  end
end


return Util
