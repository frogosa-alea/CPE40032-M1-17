--[[
    CPE40032
    Pong Remake

    -- Paddle Class --



    Represents a paddle that can move up and down. Used in the main
    program to deflect the ball back toward the opponent.
]]

Paddle = Class{}

--[[
    The `init` function on our class is called just once, when the object
    is first created. Used to set up all variables in the class and get it
    ready for use.

    Our Paddle should take an X and a Y, for positioning, as well as a width
    and height for its dimensions.

    Note that `self` is a reference to *this* object, whichever object is
    instantiated at the time this function is called. Different objects can
    have their own x, y, width, and height values, thus serving as containers
    for data. In this sense, they're very similar to structs in C.
]]
function Paddle:init(x, y, w, h, pad)
  self.x = x
  self.y = y

  self.w = w
  self.h = h

  self.dy = 0

  self.score = 0
  --setting control keys
  self.pad = pad
end

function Paddle:setPad(pad)
  self.pad = pad
end

function Paddle:update(dt)
    -- math.max here ensures that we're the greater of 0 or the player's
    -- current calculated Y position when pressing up so that we don't
    -- go into the negatives; the movement calculation is simply our
    -- previously-defined paddle speed scaled by dt
  if self.dy < 0 then
    self.y = math.max(0, self.y + self.dy * dt)
  else
    self.y = math.min(VIRTUAL_HEIGHT - self.h, self.y + self.dy * dt)
  end
end

function Paddle:render()
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end
