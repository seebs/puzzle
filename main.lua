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

-- base UI elements
Portrait = require 'Portrait'
Board = require 'Board'

-- higher-level UI elements
Card = require 'Card'

local Rainbow = Rainbow
local Settings = Settings
local Util = Util

player = Player.new()

flower.openWindow('Tropes')
flower.openScene('main_ui')

