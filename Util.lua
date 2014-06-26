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

function Util.dump(obj, name, prefix, seen)
  seen = seen or {}
  name = name or 'object'
  prefix = prefix or ''
  if type(obj) == 'table' then
    if #prefix > 4 then
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
