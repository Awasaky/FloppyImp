local composer = require"composer"
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require"physics"
physics.start()
--physics.setDrawMode( "hybrid" )

local screen = require"libs.screenBounds"
local colorName = require"libs.colorsPalette"
local options = require"libs.options"

local backGroup, gameGroup, uiGroup
local background, background2, player, cpu
local fireAnimation = require"libs.fireAnim"
local obstacles, lastStartedObstacleUp, lastStartedObstacleDown = {}
local pillarsMedium = 0
local scoreCount = 0
local scoreText, readyText, goText
local backgroundMusic = audio.loadStream"music/game.mp3"
local gameover

local gameplay = {
	deltaX = 1.8,
	obstaclesNext = 350, -- distance between pillars in pixels
	holeMin = 200, -- minimal hole betweeen pllars
	holeDiff = 21, -- maximal hole betweeen pllars = min + diff
	holeOffseMax = 250, -- offset from center both directions
	holeOffseMin = 50,
	maxVel = 400,
	kick = 550, -- up orientation
	gravity = 15, -- gravity oriented down
	startPause = 2000, -- pause before start play,
	backSpeed = 30000
}

local function moveCpu()
	if cpu.x < screen.minX - cpu.width*0.5 then
		Runtime:removeEventListener( "enterFrame", moveCpu )
		cpu:removeSelf()
	end
	cpu.x = cpu.x - gameplay.deltaX
end

local function placeObstacles() -- place obstacles at right side of screen
	local function getObstacle() -- return next obstacle outside of screen
		local nextObstacle = math.random(#obstacles)
		while obstacles[nextObstacle].x > screen.minX - obstacles[1].width*0.5 do
			nextObstacle = math.random(#obstacles)
		end
		return obstacles[nextObstacle]
	end

	local holeOffset = math.random(gameplay.holeOffseMin, gameplay.holeOffseMax)
	holeOffset = pillarsMedium > 0 and holeOffset or -holeOffset
	local holeSize = gameplay.holeMin + math.random(0, gameplay.holeDiff)
	lastStartedObstacleUp = getObstacle()
	lastStartedObstacleUp.x = screen.maxX + lastStartedObstacleUp.width*0.5
	lastStartedObstacleUp.y = screen.midY - holeSize + holeOffset
	lastStartedObstacleUp.rotation = 180
	lastStartedObstacleDown = getObstacle()
	lastStartedObstacleDown.x = screen.maxX + lastStartedObstacleDown.width*0.5
	lastStartedObstacleDown.y = screen.midY + holeSize + holeOffset
	lastStartedObstacleDown.rotation = 0
	pillarsMedium = screen.midY - (lastStartedObstacleUp.y + lastStartedObstacleDown.y) * 0.5
end

local function updateObstacles(event)
	for i = 1, #obstacles do
		obstacles[i].x = obstacles[i].x - gameplay.deltaX
	end
	if player.y > screen.maxY or player.y < screen.minY then
		gameover()
	end
	if lastStartedObstacleUp.x < screen.maxX - gameplay.obstaclesNext then
		placeObstacles()
	end
end

local function kickPlayer(event)
	if event.phase == "ended" then
		local velX, velY = player:getLinearVelocity()
		local newVelocityY = velY - gameplay.kick
		if newVelocityY < -gameplay.maxVel then
			newVelocityY = -gameplay.maxVel
		end
		--local newVelocityY = velY < 0 and -gameplay.kick or velY-gameplay.kick
		player:setLinearVelocity( 0, newVelocityY )
		scoreCount = scoreCount + 1
		scoreText.text = scoreCount
	end
	return true
end

function gameover(event)
	player:removeEventListener( "collision", gameover )
	composer.setVariable( "lastScore", scoreCount )
	--check previos restart
	local rewardRestart = composer.getVariable "rewardRestart"
	if rewardRestart then
		composer.gotoScene "scores"
	else
		composer.gotoScene "restart"
	end
	composer.setVariable( "rewardRestart", false )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view;

	physics.pause()
	backGroup, gameGroup, uiGroup = display.newGroup(), display.newGroup(), display.newGroup()
	sceneGroup:insert(backGroup)
	sceneGroup:insert(gameGroup)
	sceneGroup:insert(uiGroup)

	local backName = "images/background.png"
	local backScale = screen.sizeY/720
	background = display.newImageRect( backGroup, backName, 1280*backScale, 720*backScale )
	background.x, background.y = screen.midX, screen.midY
	background2 = display.newImageRect( backGroup, backName, background.width, background.height )
	background2.x, background2.y = screen.midX+background.width, screen.midY

	cpu = display.newImageRect(gameGroup, "images/cpu.png", 550, 403)
	cpu.x, cpu.y = screen.midX - 100, screen.midY

	local obstaclesNames = {
		"block01.png",
		"block02.png",
		"block03.png",
		"block04.png",
		"block05.png",
		"block06.png",
		"block07.png",
		"block08.png",
		"block09.png",
	}
	for i = 1, #obstaclesNames do
		local newObstacle = display.newImageRect(gameGroup, "images/" .. obstaclesNames[i], 172, 1024 )
		newObstacle.anchorY = 0
		physics.addBody(newObstacle, "static")
		newObstacle.x, newObstacle.y = -screen.maxX, screen.midY
		obstacles[#obstacles + 1] = newObstacle
	end

	fireAnimation:prepare(gameGroup, true)

  player = display.newImageRect( gameGroup, "images/imp.png", 318, 196 )
	player.x, player.y = screen.midX, screen.midY
	physics.addBody( player, "dynamic",
		--{ shape={-150,-70, -83,-98, -24,-89, -100,10, -159,-2} }, -- wings
		{ shape={-90,10, -44,-70, -14,-70, -4,-29, -35,34, -60,44} }, --body
		--{ shape={9,21, 9,-5, 60,-20, 60,0} }, -- hands
		{ shape={ -60,44, -35,34, -45,75, -70,85 } } -- legs
	)
	player.isSensor = true

	local scoreSprite = display.newImageRect(uiGroup, "images/score.png", 166*1.5, 89*1.5)
	scoreSprite.x, scoreSprite.y = screen.midX - 100, screen.minY + 125

	local fontName = "images/think.otf"
	local fontColor = { colorName("return webColor", "#d75f12" ) }

	scoreText = display.newText( uiGroup,
		"", screen.midX + 40, screen.minY + 150, fontName, 100 )
	scoreText.anchorX = 0
	scoreText:setFillColor( 0 )
	scoreText.alpha = 0.8

	readyText = display.newText( uiGroup,
		"Ready", screen.midX, screen.midY-100, fontName, 120 )
	readyText:setFillColor( 0 )
	goText = display.newText( uiGroup,
		"GO", screen.midX, screen.midY-100, fontName, 120 )
	goText:setFillColor( 0 )
	goText.alpha = 0

	options:prepare(uiGroup, screen.maxX-60, screen.minY+120 )
end


-- show()
function scene:show( event )
	local sceneGroup = self.view;
	local phase = event.phase;

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		player:addEventListener( "collision", gameover )
		fireAnimation:start()
		options:start(
			function()
				audio.play( backgroundMusic, { channel=1, loops=-1 } )
			end,
			function()
				audio.stop(1)
			end )

		local rewardRestart = composer.getVariable "rewardRestart"
		if rewardRestart then
			scoreCount = composer.getVariable "lastScore"
		else
			scoreCount = 0
		end
		scoreText.text = scoreCount

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.setGravity(0, gameplay.gravity)
		transition.to(readyText, { time=gameplay.startPause,
			y = 10, alpha = 0, onComplete=function()
				goText.alpha=1
				transition.to(goText, { time=gameplay.startPause,
						y = 10, alpha = 0
					})
			end})
		timer.performWithDelay(gameplay.startPause, function()
			physics.start()
			Runtime:addEventListener( "enterFrame", moveCpu )
			placeObstacles()
			Runtime:addEventListener( "enterFrame", updateObstacles )
			Runtime:addEventListener( "touch", kickPlayer )
		end)
		transition.to(backGroup, { time=gameplay.backSpeed, x=-background.width, iterations=0 })
		--audio.play( backgroundMusic, { channel=1, loops=-1 } )
	end;
end;


-- hide()
function scene:hide( event )
	local sceneGroup = self.view;
	local phase = event.phase;

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		fireAnimation:stop()
		Runtime:removeEventListener( "enterFrame", moveCpu )
		Runtime:removeEventListener( "enterFrame", updateObstacles )
		Runtime:removeEventListener( "touch", kickPlayer )
		player:removeEventListener( "collision", gameover )
		physics.pause()
		--audio.stop(1)
		options:stop()
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "game" )
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

return scene;
