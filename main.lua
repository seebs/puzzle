Util = require 'Util'
Settings = require 'Settings'

local printf = Util.printf

flower = require 'flower'
config = require 'config'

-- basic utilities
Input = require 'Input'
Rainbow = require 'Rainbow'
Sound = require 'Sound'

-- data structures
Genre = require 'Genre'
Flag = require 'Flag'
Stat = require 'Stat'
Trope = require 'Trope'
Element = require 'Element'
Formation = require 'Formation'
Player = require 'Player'
Dungeon = require 'Dungeon'

-- base UI elements
Portrait = require 'Portrait'
Board = require 'Board'

-- higher-level UI elements
UI_Bar = require 'UI_Bar'
UI_Button = require 'UI_Button'
Card = require 'Card'
UI_Scrolllist = require 'UI_Scrolllist'
UI_Formation = require 'UI_Formation'
UI_Tabs = require 'UI_Tabs'

local Rainbow = Rainbow
local Settings = Settings
local Util = Util

-- *not* local, mind.
player = Player.new()
player:save()

flower.openWindow('Tropes')
flower.openScene('main_ui')

