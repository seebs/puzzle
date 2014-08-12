-- UI_Tabs is a partial to provide scene-selection tabs for a given scene.

local printf = Util.printf
local sprintf = Util.sprintf

local UI_Tabs = {}

-- args = { height = n }
-- tablist = { { "name", "scene name" }, ... }
function UI_Tabs.new(layer, args, tablist)
  local self = {}
  self.layer = layer
  self.height = args and args.height or 100
  self.width = args and args.width or flower.screenWidth
  self.padding = args and args.padding or 5
  self.group = flower.Group(layer, self.width, self.height)
  printf("New tabs: layer %s", tostring(layer))

  self.tabdefs = Util.deepcopy(tablist or {})

  local padded_width = self.width - (self.padding * (#self.tabdefs - 1))

  if #self.tabdefs > 0 then
    self.tabwidth = padded_width / #self.tabdefs
  else
    self.tabwidth = self.width
  end
  self.tabheight = self.height - self.padding

  self.group:setColor(1, 1, 1, 1)

  self.tabs = {}
  self.callbacks = {}

  for i = 1, #self.tabdefs do
    local tab = self.tabdefs[i]
    Util.dump(tab)
    local t
    t = UI_Button.new(tab[1], self.tabwidth, self.tabheight, UI_Tabs.callback, self, tab[1])
    self.group:addChild(t)
    t:setLoc((i - 1) * (self.tabwidth + self.padding), 0)
    local x, y = t:getLoc()
    self.tabs[i] = t
    self.callbacks[tab[1]] = tab[2]
  end

  setmetatable(self, {__index = UI_Tabs.memberhash})

  return self
end

function UI_Tabs:callback(tab)
  if self.callbacks[tab] then
    if type(self.callbacks[tab]) == 'function' then
      self.callbacks[tab]()
    elseif type(self.callbacks[tab]) == 'string' then
      flower.openScene(self.callbacks[tab])
    else
      printf("Unknown callback (%s, type %s) for tab %s.",
      	tostring(self.callbacks[tab]), type(self.callbacks[tab]), tab)
    end
  end
end

function UI_Tabs:hide()
  MOAICoroutine.blockOnAction(self.group:seekColor(1, 1, 1, 0, 0.3))
end

function UI_Tabs:setVisible(flag)
  self.group:setColor(1, 1, 1, 1)
end

UI_Tabs.memberhash = {
  setVisible = UI_Tabs.setVisible,
  hide = UI_Tabs.hide,
}

Util.makepassthrough(UI_Tabs.memberhash, 'group')


return UI_Tabs
