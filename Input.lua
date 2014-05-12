local Input = {}

local printf = Util.printf

local known_devices = { "keyboard", "pointer", "touch", "mouseLeft", "mouseRight", "mouseMiddle" }

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
  Util.dump(devices, "device list")
  return devices
end

return Input
