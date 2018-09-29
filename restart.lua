local composer = require"composer"
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local screen = require "libs.screenBounds"
local colorName = require "libs.colorsPalette"
local fireAnimation = require "libs.fireAnim"
local options = require "libs.options"
local appodeal = require "plugin.appodeal"

local backgroundMusic = audio.loadStream"music/game.mp3"
local losesScreen, scoreCircle, adCircle, adCircleTimer
local scoreCount, scoreText

local function gotoScore(event)
	if event.phase == "ended" then
		composer.gotoScene"scores"
	end
	return true
end

local function restartGame(event)
	composer.setVariable( "rewardRestart", true )
	composer.gotoScene "game"
end

local function showVideo(event)
	if event.phase == "ended" then
		timer.cancel(adCircleTimer)
		adCircle.isVisible = false
		adCircle:removeEventListener( "touch", showVideo )
		if appodeal.isLoaded "rewardedVideo" then
			appodeal.show "rewardedVideo"
		else
			composer.gotoScene"scores"
		end
	end
	return true
end
--composer.gotoScene"game"

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local backScale = screen.sizeY/720
	local background = display.newImageRect( sceneGroup, "images/background.png", 1280*backScale, 720*backScale )
	background.x, background.y = screen.midX, screen.midY

	fireAnimation:prepare(sceneGroup)

	options:prepare(sceneGroup, screen.maxX-60, screen.minY+120 )

	scoreCircle = display.newCircle( sceneGroup, screen.midX - 142, screen.midY+146, 110 )
	scoreCircle:setFillColor( 0 )
	adCircle =  display.newCircle( sceneGroup, screen.midX + 136, screen.midY+146, 110 )
	adCircle:setFillColor( 0 )
	scoreCircle.isHitTestable = true
	adCircle.isHitTestable = true

	losesScreen = display.newImageRect(sceneGroup, "images/losescreen.png", 390*1.5, 343*1.5)
	losesScreen.x, losesScreen.y = screen.midX, screen.midY

	local scoreSprite = display.newImageRect(sceneGroup, "images/score.png", 166*1.5, 89*1.5)
	scoreSprite.x, scoreSprite.y = screen.midX - 100, screen.minY + 125

	scoreText = display.newText( sceneGroup,
		"", screen.midX + 40, screen.minY + 150, "images/think.otf", 100 )
	scoreText.anchorX = 0
	scoreText:setFillColor( 0 )
	scoreText.alpha = 0.8
end


-- show()
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		fireAnimation:start()
		options:start(
			function()
				audio.play( backgroundMusic, { channel=1, loops=-1 } )
			end,
			function()
				audio.stop(1)
			end )

	local blinkTime = 5000
	transition.blink(scoreCircle, { time = blinkTime })
	adCircleTimer = timer.performWithDelay( 500, function()
   	adCircle.alpha = 1
   	transition.blink(adCircle, { time = blinkTime })
  end)

	scoreCircle:addEventListener("touch", gotoScore)
	adCircle:addEventListener( "touch", showVideo )
	Runtime:addEventListener( "rewardedVideoSuccess", restartGame )

	scoreCount = composer.getVariable( "lastScore" )
	scoreText.text = scoreCount

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		fireAnimation:stop()
		options:stop()
		transition.cancel(scoreCircle)
		timer.cancel(adCircleTimer)
		scoreCircle:removeEventListener("touch", gotoScore)
		adCircle:removeEventListener( "touch", showVideo )
		Runtime:removeEventListener( "rewardedVideoSuccess", restartGame )
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene"restart"
	end
end


-- destroy()
function scene:destroy(event)
	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
