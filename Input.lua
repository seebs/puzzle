local Input = {}

local printf = Util.printf

local known_devices = { "keyboard", "pointer", "touch", "mouseLeft", "mouseRight", "mouseMiddle" }

Input.callbacks = {}

Input.is_live = false

Input.layer = nil

function Input.list()
  local devices = {}
  if not MOAIInputMgr or not MOAIInputMgr.device then
    printf("No valid input device(s)?")
    return devices
  end
  for i = 1, #known_devices do
    local device = known_devices[i]
    if MOAIInputMgr.device[device] then
      devices[device] = MOAIInputMgr.device[device]
    end
  end
  return devices
end

function Input.go_live()
  if Input.is_live then
    return
  end
  local inputs = Input.list()
  for k, v in pairs(inputs) do
    if Input.known_handlers[k] then
      v:setCallback(Input.known_handlers[k])
    end
  end
  Input.states[1] = { x = nil, y = nil, down = false }
  Input.is_live = true
end

Input.states = {}

function Input.handlers()
  for i = 1, #Input.callbacks do
    local status, value = pcall(Input.callbacks[i], Input.states)
    if not status then
      print(value)
    end
  end
end

function Input.mouse_left_handler(down)
  Input.states[1].down = down
  if down then
    Input.states[1].state = 'press'
    Input.states[1].start_x = Input.states[1].x
    Input.states[1].start_y = Input.states[1].y
  else
    Input.states[1].state = 'release'
  end
  Input.handlers()
end

function Input.pointer_handler(x, y)
  printf("pointer_handler: %d, %d", x, y)
  if Input.layer then
    local nx, ny = Input.layer:wndToWorld(x, y)
    x, y = nx, ny
  end
  Input.states[1].x = x
  Input.states[1].y = y
  if Input.states[1].state == 'release' then
    Input.states[1].state = 'idle'
  elseif Input.states[1].state == 'press' then
    Input.states[1].state = 'drag'
  end
  Input.handlers()
end

function Input.set_handler(callback)
  Input.callbacks[#Input.callbacks + 1] = callback
  Input.go_live()
end

function Input.set_layer(layer)
  Input.layer = layer
end

Input.known_handlers = {
  mouseLeft = Input.mouse_left_handler,
  mouseRight = Input.mouse_right_handler,
  pointer = Input.pointer_handler,
}

return Input
