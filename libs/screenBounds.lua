--[[
screen.
.minX .minY - minimal coordinates on devices screen
.maxX .maxY - maximal coordinates on devices screen
.midX .midY - short names to display.contentCenterX, display.contentCenterY
.sizeX .sizeX - return actual size of screen in coordinates
--]]

local base = {}

do
	local sideFieldX = ( display.actualContentWidth - display.contentWidth ) * 0.5
	base.minX = 0 - sideFieldX
	base.maxX = display.contentWidth + sideFieldX

	local sideFieldY = ( display.actualContentHeight - display.contentHeight ) * 0.5
	base.minY = 0 - sideFieldY
	base.maxY = display.contentHeight + sideFieldY
end

base.midX = display.contentCenterX
base.midY = display.contentCenterY
base.sizeX = base.maxX - base.minX
base.sizeY = base.maxY - base.minY

-- next code does screen table like constants - readable, but not changeable
local mt, screen = {}, {}
mt.__index = base
mt.__newindex = function() end
setmetatable(screen, mt)

return screen