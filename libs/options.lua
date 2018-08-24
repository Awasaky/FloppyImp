--[[
1) use in root namespace
	local options = require"libs.options"

2) ise in scene:create:
	options:prepare(screen Group, position of X, position of X )

3) ise in scene:show:
	options:start(
		function()
			--code that enable option - start music for example
		end,
		function()
			--code that disable option - stop music for example
		end )

4) use in scene:hide:
	options:stop()
--]]

local M = {
	prepare, start, stop
}

local json = require"json"
local filePath = system.pathForFile( "options.json", system.DocumentsDirectory )
local optionsTable -- table to read data from file
local musicEnable, musicDisable -- buttons
local saveData, loadData -- internal functions
local disabler --exchange callBackDisable to stop function

function M:prepare( screenGroup, posX, posY )
	musicEnable = display.newImageRect( screenGroup, "images/soundDisabled.png", 104, 102 )
	musicDisable = display.newImageRect( screenGroup, "images/soundEnabled.png", 104, 102 )
	musicEnable.x, musicEnable.y = posX, posY
	musicDisable.x, musicDisable.y = posX, posY
	musicEnable.isVisible, musicDisable.isVisible = false, false
end

function M:start( callBackEnable, callBackDisable )
	function musicEnable:touch(event)
		if event.phase == "ended" then
			callBackEnable()
			M.musicEnabled = true
			musicDisable.isVisible = true
			musicEnable.isVisible = false
			saveData()
		end
		return true
	end

	function musicDisable:touch(event)
		if event.phase == "ended" then
			callBackDisable()
			M.musicEnabled = false
			musicEnable.isVisible = true
			musicDisable.isVisible = false
			saveData()
		end
		return true
	end

	musicEnable:addEventListener( "touch" )
	musicDisable:addEventListener( "touch" )

	loadData()
	if M.musicEnabled then
		callBackEnable()
		musicDisable.isVisible = true
	else
		callBackDisable()
		musicEnable.isVisible = true
	end
	disabler = callBackDisable
end

function M:stop()
	disabler()
	musicEnable:removeEventListener( "touch" )
	musicDisable:removeEventListener( "touch" )
end

function saveData()
	local file = io.open( filePath, "w" )

	if file then
		optionsTable.musicEnabled = M.musicEnabled -- save in options data from M
		file:write( json.encode( optionsTable ) )
		io.close( file )
	end
end

function loadData()
	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		optionsTable = json.decode( contents )
	end

	if ( optionsTable == nil ) then -- reset state
		M.musicEnabled = true
		optionsTable = { musicEnabled = true }
		saveData()
	else
		M.musicEnabled = optionsTable.musicEnabled -- load from options data to M
	end
end

return M