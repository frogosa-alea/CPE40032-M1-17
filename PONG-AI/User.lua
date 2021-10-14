User = Class{}

function User:init(paddle, ball)
  self.paddle = paddle
  self.ball = ball
end

function User:move()
  if love.keyboard.isDown(self.paddle.pad[1]) then
    self.paddle.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown(self.paddle.pad[2]) then
    self.paddle.dy = PADDLE_SPEED
  else
      self.paddle.dy = 0
  end
end

