local Portrait = {}

local printf = Util.printf
local sprintf = Util.sprintf

function Portrait.new(layer)
  local p = {}

  p.group = flower.Group()

  if layer then
    p.group:setLayer(layer)
  end

  p.frame = flower.Image("picframe.png")
  p.frame.texture:setFilter(MOAITexture.GL_LINEAR)
  p.frame:setScl(0.5)
  p.frame:setLoc(0, 0)
  p.frame:setPriority(3)

  p.snapshot = flower.Image("blank.png")
  p.snapshot.texture:setFilter(MOAITexture.GL_LINEAR)
  p.snapshot:setScl(0.87)
  p.snapshot:setLoc(125, 131)
  p.snapshot:setPriority(2)

  p.snapshot_background = flower.SheetImage('genre_backgrounds.png')
  p.snapshot_background:setSheetSize(2, 4)
  p.snapshot_background:setIndex(1)
  p.snapshot_background:setScl(1.71)
  p.snapshot_background:setLoc(16, 22)
  p.snapshot_background:setPriority(1)
  
  p.group:addChild(p.snapshot_background)
  p.group:addChild(p.snapshot)
  p.group:addChild(p.frame)

  p.snapshot_background:setParent(p.frame)
  p.snapshot:setParent(p.frame)

  p.snapshot:clearAttrLink(MOAIColor.INHERIT_COLOR)
  p.snapshot_background:clearAttrLink(MOAIColor.INHERIT_COLOR)

  p.group:setVisible(false)

  setmetatable(p, {__index = Portrait.memberhash})
  return p
end

function Portrait:display_element(element)
  if element then
	self.snapshot:setTexture(sprintf("elements/%s.png", element.name))
	self.snapshot_background:setIndex(Genre.color(element.genre) or 7)
	self:setVisible(true)
  else
	self.snapshot:setTexture(sprintf("elements/blank.png"))
	self.snapshot_background:setIndex(7)
	self:setVisible(true)
  end
end

Portrait.memberhash = {
  display_element = Portrait.display_element,
}

Util.makepassthrough(Portrait.memberhash, 'group')

return Portrait
