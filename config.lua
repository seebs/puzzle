-- module
local M = {}

--------------------------------------------------------------------------------
-- Flower
--------------------------------------------------------------------------------

local screenWidth = MOAIEnvironment.horizontalResolution or 768
local screenHeight = MOAIEnvironment.verticalResolution or 1024
local viewScale = math.floor(math.max(math.min(screenWidth / 768, screenHeight / 1024), 1))

-- Resources setting
flower.Resources.addResourceDirectory("assets")

-- Set the screen size
flower.DEFAULT_SCREEN_WIDTH = screenWidth
flower.DEFAULT_SCREEN_HEIGHT = screenHeight

-- Set the scale of the Viewport
flower.DEFAULT_VIEWPORT_SCALE = viewScale
flower.DEFAULT_VIEWPORT_YFLIP = true

-- I prefer alpha=0 to be invisible
flower.DEFAULT_BLEND_MODE = { MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA }

-- High quality rendering of Label
-- When enabled, it may take a long time to display the label.
flower.Label.HIGH_QUALITY_ENABLED = true

-- Set the default font
flower.Font.DEFAULT_FONT = "TTWPGOTT.ttf"

-- Set the default font charcodes
-- Optimized by setting the loadable string in advance.
flower.Font.DEFAULT_CHARCODES = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-"

-- Default font points
flower.Font.DEFAULT_POINTS = 24

-- Set the texture filter of default
-- flower.Texture.DEFAULT_FILTER = MOAITexture.GL_LINEAR
flower.Texture.DEFAULT_FILTER = MOAITexture.GL_NEAREST

-- Setting of the behavior of the InputMgr
-- Whether to fire a touch event on the desktop environment
flower.InputMgr.TOUCH_EVENT_ENABLED = true

-- Whether to fire a mouse event on the desktop environment
flower.InputMgr.MOUSE_EVENT_ENABLED = true

--------------------------------------------------------------------------------
-- MOAI SDK
--------------------------------------------------------------------------------

-- Setting the FPS
MOAISim.setStep(1 / 60)

-- Setting of the operation of the Loop.
MOAISim.clearLoopFlags()
MOAISim.setLoopFlags(MOAISim.SIM_LOOP_ALLOW_BOOST)
MOAISim.setLoopFlags(MOAISim.SIM_LOOP_LONG_DELAY)

-- Sets the boost threshold
MOAISim.setBoostThreshold(0)

--------------------------------------------------------------------------------
-- Debugging
--------------------------------------------------------------------------------

-- Show bounds of MOAIProp
--[[
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 1, 1, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_LAYOUT, 1, 0, 0, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_BASELINES, 1, 1, 0, 0, 1 )

MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 1, 0.75, 0.75 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_MODEL_BOUNDS, 2, 0.75, 1, 1 )
]]

-- 
MOAISim.setHistogramEnabled(true)

-- Performance measurement.
local timer = MOAITimer.new()
timer:setMode(MOAITimer.LOOP)
timer:setSpan(5)
timer:setListener(MOAITimer.EVENT_TIMER_LOOP,
    function()
        print("-------------------------------------------")
        print("FPS:", MOAISim.getPerformance())
        print("Draw:", MOAIRenderMgr.getPerformanceDrawCount())
        MOAISim.reportHistogram()
        MOAISim.reportLeaks()
    end)
-- timer:start()

return M
