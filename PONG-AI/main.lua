--[[
    CPE40032
    Pong Remake

    -- Main Program --



    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on
    modern systems.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'
-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'
require 'Ai'
require 'User'

-- size we're trying to emulate with push
SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
-- paddle movement speed
PADDLE_SPEED = 200
--control keys
PADS = {{'w', 's'}, {'up', 'down'}}

function love.load()
   -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
  love.graphics.setDefaultFilter('nearest', 'nearest')
  smallFont = love.graphics.newFont('font.ttf', 8)
  largeFont = love.graphics.newFont('font.ttf', 16)
  scoreFont = love.graphics.newFont('font.ttf', 32)
  love.graphics.setFont(smallFont)
 

  love.window.setTitle('Pong')

  sounds = {
    ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
  }
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT, {
    vsync = true,
    fullscreen = false,
    resizable = true
  })

  player1Score = 0
  player2Score = 0
  -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
  servingPlayer = 1
  -- player who won the game; not set to a proper value until we reach
    -- that state in the game
  winningPlayer = 0
  
  --enables ai mode and setting variables for using the declared classes
  ai = true
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
  player1 = User(Paddle(10, 30, 5, 20, PADS[1]), ball)
  --player1.paddle.setPad(PADS[1])
  tmp = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20, PADS[2])
  if not ai then
    player2 = User(tmp, ball)
    --player2.paddle.setPad(PADS[2])
  else
    player2 = Ai(tmp, ball)
  end
  
    -- the state of our game; can be any of the following:
    -- 1. 'start' (the beginning of the game, before first serve)
    -- 2. 'serve' (waiting on a key press to serve the ball)
    -- 3. 'play' (the ball is in play, bouncing between paddles)
    -- 4. 'done' (the game is over, with a victor, ready for restart)
  gameState = 'start'
end

--[[
    Called whenever we change the dimensions of our window, as by dragging
    out its bottom corner, for example. In this case, we only need to worry
    about calling out to `push` to handle the resizing. Takes in a `w` and
    `h` variable representing width and height, respectively.
]]
function love.resize(w, h)
  push:resize(w, h)
end

--[[
    Called every frame, passing in `dt` since the last frame. `dt`
    is short for `deltaTime` and is measured in seconds. Multiplying
    this by any changes we wish to make in our game will allow our
    game to perform consistently across all hardware; otherwise, any
    changes we make will be applied as fast as possible and will vary
    across system hardware.
]]
function love.update(dt)
  player1:move()
  if not ai then
    player2:move()
  else
    --com here
    player2:move()
  end

  if gameState == 'play' then
    if ball.x < 0 then
      sounds['score']:play()
      player2.paddle.score = player2.paddle.score + 1
      servingPlayer = 1
      if player2.paddle.score == 10 then
        gameState = 'done'
        winningPlayer = 2
      else
      gameState = 'serve1'
      end
      ball:reset(1)
    end

    if ball.x > VIRTUAL_WIDTH then
      sounds['score']:play()
      player1.paddle.score = player1.paddle.score + 1
      servingPlayer = 2
      if player1.paddle.score == 10 then
        gameState = 'done'
        winningPlayer = 1
      else
      gameState = 'serve2'
      end
      ball:reset(2)
    end
    if ball:collides(player1) then
      ball.dx = -ball.dx * 1.03
      ball.x = player1.paddle.x + player1.paddle.w

      if ball.dy < 0 then
          ball.dy = -math.random(10, 150)
      else
          ball.dy = math.random(10, 150)
      end
      sounds['paddle_hit']:play()
    end

    if ball:collides(player2) then
      ball.dx = -ball.dx + 1.03
      ball.x = player2.paddle.x - player2.paddle.w

      if ball.dy < 0 then
          ball.dy = -math.random(10, 150)
      else
          ball.dy = math.random(10, 150)
      end
      sounds['paddle_hit']:play()
    end

    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
      sounds['wall_hit']:play()
    end

    -- -4 to account for the ball's size
    if ball.y >= VIRTUAL_HEIGHT - 4 then
        ball.y = VIRTUAL_HEIGHT - 4
        ball.dy = -ball.dy
        sounds['wall_hit']:play()
    end

    ball:update(dt)
  end

    player1.paddle:update(dt)
    --com or not
  if not ai then
   player2.paddle:update(dt)
    else
    --com here
   player2:update(dt)
  end
  
end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  if key == 'enter' or key == 'return' then
    if gameState == 'start' or gameState == 'serve1' or gameState == 'serve2' then
      gameState = 'play'
    elseif gameState == 'done' then
      gameState = 'serve'

      ball:reset()
    end
  end
end

function love.draw()
  -- body...
  push:apply('start')
    love.graphics.clear(40, 45, 52, 255)
    
    if gameState == 'start' then
      love.graphics.setFont(smallFont)
      love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
      love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve1' then
      love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!",
            0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve2' then
      love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!",
            0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        
    elseif gameState == 'done' then
     
      love.graphics.setFont(largeFont)
      love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
      0, 10, VIRTUAL_WIDTH, 'center')
      love.graphics.setFont(smallFont)
      love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end
    
    
    love.graphics.setFont(scoreFont)
    love.graphics.printf(tostring(player1.paddle.score), 50, VIRTUAL_HEIGHT / 2 - 15, VIRTUAL_WIDTH / 2, 'center')
    love.graphics.printf(tostring(player2.paddle.score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 15, VIRTUAL_WIDTH / 2, 'center')
    love.graphics.setColor(255,255,0,255)
    player1.paddle:render()
    player2.paddle:render()
    ball:render()

    displayFPS()
  push:apply('end')
end

function gameReset()
  winner = 0
  player1.paddle.score = 0
  player2.paddle.score = 0
end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end
