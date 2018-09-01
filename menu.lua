local composer = require"composer"
local scene = composer.newScene();

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local screen = require"libs.screenBounds"
local fireAnimation = require"libs.fireAnim"

local backGroup, gameGroup, uiGroup
local background, cpu, impHead

local backgroundMusic = audio.loadStream"music/game.mp3"
local startButton, scoresButton, startBlock, scoresScreen

local options = require"libs.options"

local function impHeadAppear()
	impHead.isVisible = true
	timer.performWithDelay(impHead.time, function()
		impHead.xScale = -1
		timer.performWithDelay(impHead.time, function()
			impHead.xScale = 1
			impHead.isVisible = false
		end)
	end)
end

local function gotoGame(event)
	if event.phase == "ended" then
		composer.gotoScene"game"
	end
	return true
end

local function gotoScores(event)
	if event.phase == "ended" then
		composer.setVariable( "lastScore", 0 )
		composer.gotoScene"scores"
	end
	return true
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	backGroup, gameGroup, uiGroup = display.newGroup(), display.newGroup(), display.newGroup()
	sceneGroup:insert(backGroup)
	sceneGroup:insert(gameGroup)
	sceneGroup:insert(uiGroup)

	local backScale = screen.sizeY/720
	background = display.newImageRect( backGroup, "images/background.png", 1280*backScale, 720*backScale )
	background.x, background.y = screen.midX, screen.midY

	local logo = display.newImageRect( backGroup, "images/logo.png", 744, 377 )
	logo.x, logo.y = screen.midX, screen.midY - 400

	cpu = display.newImageRect(gameGroup, "images/cpu.png", 550, 403)
	cpu.x, cpu.y = screen.midX - 100, screen.midY

	fireAnimation:prepare(gameGroup)

	impHead = display.newImageRect( gameGroup, "images/impHead.png", 95, 77 )
	impHead.x, impHead.y = screen.midX - 185, screen.midY+20
	impHead.anchorX = 0.3
	impHead.isVisible = false
	impHead.time = 1500

	startButton = display.newImageRect( uiGroup, "images/buttonStart.png", 150*1.5, 58*1.5 )
	startButton.x = screen.midX - 200
	startButton.y = screen.maxY - 200

	startBlock = display.newRect(uiGroup, screen.midX-250, screen.midY+55, 220, 270)
	startBlock.isVisible = false
	startBlock.isHitTestable = true

	scoresButton = display.newImageRect( uiGroup, "images/buttonScores.png", 150*1.5, 58*1.5 )
	scoresButton.x = screen.midX + 200
	scoresButton.y = screen.maxY - 200

	scoresScreen = display.newCircle( uiGroup, screen.midX-50, screen.midY-50, 90 )
	scoresScreen.yScale = 1.6
	scoresScreen.rotation = -10
	scoresScreen.isVisible = false
	scoresScreen.isHitTestable = true

	options:prepare(uiGroup, screen.maxX-60, screen.minY+120 )
end


-- show()
function scene:show( event )
	local sceneGroup = self.view;
	local phase = event.phase;

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		options:start(
			function()
				audio.play( backgroundMusic, { channel=1, loops=-1 } )
			end,
			function()
				audio.stop(1)
			end )

		startButton:addEventListener( "touch", gotoGame )
		startBlock:addEventListener( "touch", gotoGame )

		scoresButton:addEventListener( "touch", gotoScores )
		scoresScreen:addEventListener( "touch", gotoScores )

		fireAnimation:start()

		timer.performWithDelay( impHead.time*3, impHeadAppear, 0 )

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end;
end;


-- hide()
function scene:hide( event )
	local sceneGroup = self.view;
	local phase = event.phase;

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		--audio.stop( 1 )
		options:stop()
		
		startButton:removeEventListener( "touch", gotoGame )
		startBlock:removeEventListener( "touch", gotoGame )

		scoresButton:removeEventListener( "touch", gotoScores )
		scoresScreen:removeEventListener( "touch", gotoScores )

		fireAnimation:stop()
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene"menu"
	end;
end;


-- destroy()
function scene:destroy( event )
	local sceneGroup = self.view;
	-- Code here runs prior to the removal of scene's view

end;


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene );
scene:addEventListener( "show", scene );
scene:addEventListener( "hide", scene );
scene:addEventListener( "destroy", scene );
-- -----------------------------------------------------------------------------------

return scene