local composer = require"composer"
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local backgroundMusic = audio.loadStream"music/game.mp3"

-- Initialize variables
local json = require"json"
local scoresTable = {}
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

local screen = require"libs.screenBounds"
local colorName = require"libs.colorsPalette"
local fireAnimation = require"libs.fireAnim"

local lastScore

local function gotoGame(event)
	if event.phase == "ended" then
		composer.gotoScene( "game" ) -- change back to menu!
	end
end

local function gotoMenu(event)
	if event.phase == "ended" then
		composer.gotoScene( "menu" ) -- change back to menu!
	end
end

local resetScores

local function loadScores()
	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( contents )
	end

	if ( scoresTable == nil or #scoresTable == 0 ) then
		resetScores()
	end
end

local function saveScores()
	for i = #scoresTable, 11, -1 do
		table.remove( scoresTable, i )
	end

	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( scoresTable ) )
		io.close( file )
	end
end

function resetScores( returnMenu )
	scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	if returnMenu then
		saveScores()
		gotoMenu()
	end		
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Load the previous scores
    loadScores()

    -- Insert the saved score from the last game into the table, then reset it
    lastScore = composer.getVariable( "lastScore" )
    table.insert( scoresTable, lastScore )
    composer.setVariable( "lastScore", 0 )

    -- Sort the table entries from highest to lowest
    local function compare( a, b )
        return a > b
    end
    table.sort( scoresTable, compare )

    -- Save the scores
    saveScores()

    local backScale = 1.77
		local background = display.newImageRect( sceneGroup, "images/background.png", 1280*backScale, 720*backScale )
		background.x, background.y = screen.midX, screen.midY

		fireAnimation:prepare(sceneGroup)

		local	scoresBackScale = 1.5
		local scoresBack = display.newImageRect( sceneGroup, "images/highscores.png", 441*scoresBackScale, 538*scoresBackScale )
		scoresBack.x, scoresBack.y = screen.midX, screen.midY

    local fontName = "images/think.otf"
		local fontColor = { colorName"yellow" }
		local lastScoreText = display.newText( sceneGroup, "LAST SCORE " .. lastScore, screen.midX + 25, screen.midY - 195, fontName, 45 )
		lastScoreText.alpha = 0.7

		local names = { "1ST", "2ND", "3RD", "4TH", "5TH", "6TH", "7TH", "8TH", "9TH", "10TH" }
    for i = 1, 10 do
      if scoresTable[i] > 0 then
        local yPos = screen.midY - 195 + ( i * 46 )

        local rankNum = display.newText( sceneGroup, names[i], screen.midX+15, yPos, fontName, 45 )
        rankNum.anchorX = 1
        rankNum.alpha = 0.7

        local thisScore = display.newText( sceneGroup, scoresTable[i], screen.midX+35, yPos, fontName, 45 )
        thisScore.anchorX = 0
        thisScore.alpha = 0.7
      end
    end

    local blinkTime = 5000
    local restartCircle = display.newCircle( sceneGroup, screen.midX-200, screen.midY, 80 )
    restartCircle:setFillColor( colorName"tan" )
    transition.blink( restartCircle, { time = blinkTime } )
    local restartButton = display.newImageRect( sceneGroup, "images/buttonRestart.png", 104*1.5, 102*1.5 )
    restartButton.x, restartButton.y = screen.midX-200, screen.midY
    restartButton:addEventListener( "touch", gotoGame )
    
		local menuCircle = display.newCircle( sceneGroup, screen.midX+200, screen.midY+150, 80 )
    menuCircle:setFillColor( colorName"tan" )
    menuCircle.alpha = 0
    timer.performWithDelay( 500, function()
    	menuCircle.alpha = 1
    	transition.blink( menuCircle, { time = blinkTime } )
    end)
    
    local menuButton = display.newImageRect( sceneGroup, "images/buttonMain.png", 104*1.5, 102*1.5 )
    menuButton.x, menuButton.y = screen.midX+200, screen.midY+150
    menuButton:addEventListener( "touch", gotoMenu )

		local resetButton = display.newImageRect( sceneGroup, "images/buttonReset.png", 150*1.5, 58*1.5 )
    resetButton.x, resetButton.y = screen.midX-100, screen.maxY - 100
    resetButton:addEventListener( "touch", function(event)
    	if event.phase == "ended" then
    		resetScores(true)
    	end
    end)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		--audio.play( backgroundMusic, { channel=1, loops=-1 } )
		fireAnimation:start()

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		audio.stop( 1 )
		fireAnimation:stop()
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "scores" )
	end
end


-- destroy()
function scene:destroy( event )

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
