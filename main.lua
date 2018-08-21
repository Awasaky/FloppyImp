display.setStatusBar(display.HiddenStatusBar) -- hide status bar on mobile devices
local composer = require "composer" -- add composer library support 

math.randomseed(os.time())
audio.reserveChannels( 1 )

--composer.setVariable( "lastScore", 0 )
composer.gotoScene "menu"