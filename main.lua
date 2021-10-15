--[[
    GD50 2018
    Pong Remake

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]
push = require 'push'

Class = require 'class'
require 'Ball'
require 'Paddle'

WINDOW_WIDTH=1280
WINDOW_HEIGHT=720

PADDLE_S=230

VIRTUAL_WIDTH =432
VIRTUAL_HEIGHT=243
--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')

    love.window.setTitle('Pong2D')
    
    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf',8)
    scoreFont = love.graphics.newFont('font.ttf',32)
    largeFont = love.graphics.newFont('font.ttf', 16)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['amangoos'] = love.audio.newSource('sounds/amangus.mp3', 'static'),
        ['shocked'] = love.audio.newSource('sounds/shocked.mp3', 'static'),
        ['bass'] = love.audio.newSource('sounds/bass-boosted.mp3', 'static'),
        ['intro'] = love.audio.newSource('sounds/inception.mp3', 'static')
    }

    push:setupScreen( VIRTUAL_WIDTH,  VIRTUAL_HEIGHT, WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = true,
        vsync = true
    })
    P1SCORE =0
    P2SCORE =0
    servingP = 1

    P1= Paddle(10,30,5,20)
    P2= Paddle(VIRTUAL_WIDTH-15,VIRTUAL_HEIGHT-30,5,20)
    ball = Ball(VIRTUAL_WIDTH/2 -2,VIRTUAL_HEIGHT/2 -2,4,4)

    -- the and/or pattern here is Lua's way of accomplishing a ternary operation
    -- in other programming languages like C
    gameState = 'start'
    sounds.intro:play()

end

function love.resize(w,h)
    push:resize(w,h)
end

function love.update(dt)

    if gameState == 'serve' then

        ball.dy = math.random(-50, 50)

        if servingP ==1 then
            ball.dx = math.random(140,200)
        else
            ball.dx = -math.random(140,200)
        end
   

    elseif gameState== 'play' then

        if ball:collides(P1) then
            ball.dx = -ball.dx * 1.03
            ball.x = P1.x+5

            if ball.dy < 0 then
                ball.dy=-math.random(10,150)
            else
                ball.dy=math.random(10,150)
            end
            sounds.paddle_hit:play()
        end

        if ball:collides(P2) then
            ball.dx = -ball.dx * 1.03
            ball.x = P2.x-4

            if ball.dy < 0 then
                ball.dy=-math.random(10,150)
            else
                ball.dy=math.random(10,150)
            end
            
            sounds.paddle_hit:play()
        end

        if ball.y <=0 then
            ball.y =0
            ball.dy=-ball.dy
            
            sounds.wall_hit:play()
        end

        if ball.y >=VIRTUAL_HEIGHT -4 then
            ball.y = VIRTUAL_HEIGHT-4
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end
    

        if ball.x < 0 then
            servingP=1
            P2SCORE=P2SCORE+1
            -- sounds.score:play()
            sounds.shocked:play()
            
            if P2SCORE == 7 then
                winningP = 2
                gameState = 'done'
                sounds.amangoos:play()
            else
                ball:reset()
                gameState = 'serve'
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingP=2
            P1SCORE=P1SCORE+1
            -- sounds.score:play()
            sounds.shocked:play()
            if P1SCORE == 7 then
                winningP = 1
                sounds.amangoos:play()
                gameState = 'done'
            else
                
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    if love.keyboard.isDown('w') then
        P1.dy= -PADDLE_S
    elseif love.keyboard.isDown('s') then
        P1.dy= PADDLE_S
    else
        P1.dy= 0  

    end

    if love.keyboard.isDown('down') then
        P2.dy= PADDLE_S
            
    elseif love.keyboard.isDown('up') then
        P2.dy= -PADDLE_S
    else
        P2.dy=0  
    end

    if gameState=='play' then
        ball:update(dt)
    end
    P1:update(dt)
    P2:update(dt)
end
--[[
    Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    
    elseif key=='enter' or key == 'return' then
        if gameState=='start' then
            gameState= 'serve'
        
        elseif gameState =='serve' then
            gameState='play'

        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()

            P1SCORE=0
            P2SCORE=0

            if winningP==1 then
                servingP=2
            else
                servingP=1
            end

        end

    elseif key == 'r' then
        love.event.quit('restart')
    end
end


function love.draw()
    push:apply('start')

    love.graphics.clear(40/255,45/255,52/255,255/255)

    
    displayScore()
    love.graphics.setFont(smallFont)

    if gameState=='start' then
        love.graphics.printf('Welcome to Pong!',0,10, VIRTUAL_WIDTH,"center")
        love.graphics.printf('Press Enter to begin!',0,20, VIRTUAL_WIDTH,"center")
    
    elseif gameState=='serve' then
        love.graphics.printf('Player '.. tostring(servingP)..'\'s serve',0,10, VIRTUAL_WIDTH,"center")
        love.graphics.printf('Press Enter to Serve!',0,20, VIRTUAL_WIDTH,"center")
    elseif gameState=='play' then

    elseif gameState=='done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('#1 Victory royale!!',0,10, VIRTUAL_WIDTH,"center")
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(winningP) .. ' wins!',0,38, VIRTUAL_WIDTH,"center")
        love.graphics.printf('Press Enter to restart!',0,48, VIRTUAL_WIDTH,"center")
    end     

   --paddles and ball
    P1:render()
    P2:render()
    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0,255,0,255)
    love.graphics.print('FPS: '.. tostring(love.timer.getFPS()),10,10)
end

function displayScore()

    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(P1SCORE), VIRTUAL_WIDTH/2-50, VIRTUAL_HEIGHT/4)
    love.graphics.print(tostring(P2SCORE), VIRTUAL_WIDTH/2+30, VIRTUAL_HEIGHT/4)
end