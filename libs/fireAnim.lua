local screen = require"libs.screenBounds"

return {
	time = 1000, -- speed of animation
	prevSprite = 1, -- counter of previous sprite
	nextSprite = 2, -- counter of next sprite
	start = function(self) -- play's animation
		self[self.nextSprite]:toFront()
		self.nextTrans = transition.to(self[self.nextSprite], {
			alpha = 1,
			time = self.time,
			onComplete = function()
				-- set new prev and next sprite
				--self[self.prevSprite].alpha = 0
				self.prevTrans = transition.to(self[self.prevSprite], { alpha = 0, time = self.time} )
				self.prevSprite = ( self.prevSprite >= #self ) and 1 or self.prevSprite + 1
				self.nextSprite = ( self.nextSprite >= #self ) and 1 or self.nextSprite + 1
				self:start()
			end
		})
	end,
	stop = function(self) -- cancel all animations
		transition.cancel(self.prevTrans)
		transition.cancel(self.nextTrans)
	end,
	prepare = function(self, scrGroup, doBack) -- set sprites to starting positions
		local width = screen.sizeX < 840 and 840 or screen.sizeX
		for i = 1, 3 do
			self[i] = display.newImageRect( scrGroup, "images/fire0" .. i .. ".png", width, 254 )
			self[i].alpha = 0
			self[i].x = screen.midX
			self[i].y = screen.maxY - self[i].height*0.5
			if doBack then self[i]:toBack() end
		end
		self[self.prevSprite].alpha = 1 -- set 1st sprite visible
	end
}