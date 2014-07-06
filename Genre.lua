local Genre = {}

Genre.genres = {
  'romance', 'fantasy', 'action', 'scifi', 'crime', 'gothic',
}

function Genre.list(value)
  local t = {}
  -- "false" would be okay, though.
  if value == nil then
    value = 0
  end
  for i = 1, #Genre.genres do
    t[Genre.genres[i]] = value
  end
  return t
end

return Genre
