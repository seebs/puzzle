local Settings = { screen = {} }

Settings.screen.width = MOAIEnvironment.horizontalResolution or 768
Settings.screen.height = MOAIEnvironment.verticalResolution or 1024
print("width: " .. tostring(Settings.screen.width) .. ", height: " .. tostring(Settings.screen.height))
Settings.screen.dpi = MOAIEnvironment.screenDpi or 100
Settings.screen.left = 0 - Settings.screen.width / 2
Settings.screen.right = 0 + Settings.screen.width / 2
Settings.screen.top = 0 + Settings.screen.height / 2
Settings.screen.bottom = 0 - Settings.screen.height / 2
Settings.screen.center = { x = 0, y = 0 }
Settings.screen.origin = { x = Settings.screen.left, y = Settings.screen.top }
Settings.screen.size = { x = Settings.screen.width, y = Settings.screen.height }
Settings.screen.aspect = Settings.screen.width / Settings.screen.height

return Settings
