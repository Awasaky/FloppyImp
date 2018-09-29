display.setStatusBar(display.HiddenStatusBar) -- hide status bar on mobile devices
math.randomseed(os.time())

local composer = require "composer" -- add composer library support 
local appodeal = require "plugin.appodeal"

local function adListener( event )
	local eventPhase = event.phase
	local eventType = event.type

	if eventPhase == "init" then
		appodeal.load 'banner' 
		appodeal.show( "banner", { yAlign = "bottom" } )
	elseif eventPhase == "playbackEnded" and eventType == "rewardedVideo" then
		--fire success rewardedVideo event
		Runtime:dispatchEvent{ name = "rewardedVideoSuccess" }
	end
end

appodeal.init(adListener, {
	appKey = "bb1f2e24080bb755d18d41274c024522c19d1f7a9f623327",
	supportedAdTypes = { "banner", "rewardedVideo" },
	testMode = true
})
composer.setVariable( "appodeal", appodeal )

audio.reserveChannels( 1 )
audio.setVolume( 0.5, { channel=1 } )

--composer.setVariable( "lastScore", 0 )
composer.gotoScene "menu"