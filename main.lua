WINDOW_HEIGHT=404
WINDOW_WIDTH=720
VIRTUAL_HEIGHT=243
VIRTUAL_WIDTH=432
GAME_DIFFICULTY='HARD'
push=require 'push'
gamestate='main_menu'
servingPlayer=2
timer=0
Class=require 'class'
require 'Ball'
require 'Paddle'

function love.load()
    back=love.graphics.newImage("images/bck.jpg")
    back2=love.graphics.newImage("images/bck2.jpg")
    text=love.graphics.newImage("images/text.png")
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(640,480)    
    smallfont=love.graphics.newFont("fonts/font.ttf", 8)
    love.window.setTitle('Ping Pong')
    math.randomseed(os.time())   
    largefont=love.graphics.newFont("fonts/Orbitron Medium.otf",30)
    medfont=love.graphics.newFont("fonts/Orbitron Medium.otf",15)
    player1=Paddle(-1,10,20,'w','s',true)
    player2=Paddle(1,VIRTUAL_WIDTH-15,VIRTUAL_HEIGHT-50,'up','down',true)
    ball=Ball(VIRTUAL_WIDTH/2-4,VIRTUAL_HEIGHT/2-4)
    sounds={
        ['paddle']=love.audio.newSource("sounds/paddle_hit.wav", 'static'),
        ['score']=love.audio.newSource("sounds/score.wav", 'static'),
        ['wall']=love.audio.newSource("sounds/wall_hit.wav", 'static'),
        ['music']=love.audio.newSource("sounds/music.wav",'static')
    }
end

function love.keyreleased(key)
    if key=='enter' or key=='return' then
        if gamestate=='start' then
            gamestate='serve'
        elseif gamestate=='serve' then
            gamestate='play'
        elseif gamestate=='victory' then
            gamestate='serve'
            player1.score=0;
            player2.score=0;          
        end
    elseif key=='space' then
        print(ball.y)
        print(ball.predicty,player2.y)
    end
end

function love.update(dt)
    timer=timer+dt
    if timer>1 then
        timer=0
    end
    if gamestate=='play' or gamestate=='serve' then
        player1:update(dt,ball.dx<0 and true or false)
        player2:update(dt,ball.dx>0 and true or false)
    end
    if gamestate=='play' then
        if (ball:collides(player1)) then
            ball.dx=-ball.dx*1.05
            sounds.paddle:play()
            ball.x=player1.x+PADDLE_WIDTH
            if ball.dy<0 then
                ball.dy=-math.random(10,50)
            else 
                ball.dy=math.random(10,50)
            end
            ball.predicty=ball:predictPosition(player2,1)   
            player2:setOffset()         
        end
        if (ball:collides(player2)) then
            ball.dx=-ball.dx*1.05
            sounds.paddle:play()            
            ball.x=player2.x-ball.width
            if ball.dy<0 then
                ball.dy=-math.random(10,50)
            else 
                ball.dy=math.random(10,50)
            end
            ball.predicty=ball:predictPosition(player1,-1)                        
            player1:setOffset()                     
        end

        ball:update(dt)
       --if ball crosses the vertical boundaries i.e. hits the wall
        if (ball.y<0) then
            ball.dy=-ball.dy*1.02           
            sounds.wall:play()
            ball.y=0
        elseif ball.y>VIRTUAL_HEIGHT-5 then
            ball.y=VIRTUAL_HEIGHT-5
            ball.dy=-ball.dy*1.02
            sounds.wall:play()
        end
       --if ball crosses the horizontal boundaries
        if ball.x<0 then
            player2.score=player2.score+1
            gamestate='serve'
            sounds.score:play()
            servingPlayer=1
            ball=Ball(VIRTUAL_WIDTH/2-4,VIRTUAL_HEIGHT/2-4)            
        elseif ball.x>VIRTUAL_WIDTH then
            player1.score=player1.score+1
            sounds.score:play()            
            gamestate='serve'
            servingPlayer=2            
            ball=Ball(VIRTUAL_WIDTH/2-4,VIRTUAL_HEIGHT/2-4)                        
        end
    elseif gamestate=='serve' then
        if servingPlayer==1 then
            ball.dx=math.random(150,200)
        else
            ball.dx=-math.random(150,200)            
        end
    end
end

function love.draw()
    if gamestate=='main_menu' then
        main_menu();
    elseif gamestate=='select_combination' then
        select_combination();
    elseif gamestate=='select_difficulty_level' then
        select_difficulty_level();
    else
        push:apply('start')
        love.graphics.clear(0.1,0.1,0.1)
        ball:render()
        player1:render()
        player2:render()
        love.graphics.setFont(smallfont)
        drawDottedLine(20,11)
        --displayFPS()
        if player1.score==10 then
            love.graphics.setFont(medfont)
            love.graphics.setColor(0,1,0)        
            love.graphics.printf("Player 1 Is Victorious",0,15,VIRTUAL_WIDTH,'center')
            gamestate='victory'
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1,1,1)        
            love.graphics.printf("Hit ENTER to start another game",0,35,VIRTUAL_WIDTH,'center')        
        elseif player2.score==10 then
            love.graphics.setFont(medfont)
            love.graphics.setColor(0,1,0)        
            love.graphics.printf("Player 2 Is Victorious",0,15,VIRTUAL_WIDTH,'center')
            love.graphics.setColor(255,255,255)
            love.graphics.setFont(smallfont)
            love.graphics.printf("Hit ENTER to start another game",0,35,VIRTUAL_WIDTH,'center')        
            gamestate='victory'
        end
        if gamestate=='start' then
            love.graphics.setFont(medfont)
            love.graphics.setColor(0,1,0);
            love.graphics.printf("Welcome to Pong!",0,15,VIRTUAL_WIDTH,'center')
            love.graphics.setColor(255,255,255)
            love.graphics.setFont(smallfont)
            love.graphics.printf("Press ENTER to start the game",0,35,VIRTUAL_WIDTH,'center')
        elseif gamestate=='serve' then
            love.graphics.setFont(medfont)
            love.graphics.setColor(1,1,0);        
            love.graphics.printf("Player "..servingPlayer.."'s serve",0,15,VIRTUAL_WIDTH,'center')
            love.graphics.setFont(smallfont)
            love.graphics.setColor(255,255,255)        
            love.graphics.printf("Press ENTER to serve!",0,35,VIRTUAL_WIDTH,'center')
        end
        love.graphics.setFont(largefont)
        love.graphics.print(tostring(player1.score),VIRTUAL_WIDTH/2-60,VIRTUAL_HEIGHT/2-50)
        love.graphics.print(tostring(player2.score),VIRTUAL_WIDTH/2+50,VIRTUAL_HEIGHT/2-50)
    push:apply('end')
    
    end
end

function displayFPS()
    love.graphics.setColor(0,255,0);
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()),20,10)
    love.graphics.setColor(255,255,255)
end

function drawDottedLine(line_height,gap_height)
    for y=0,VIRTUAL_HEIGHT,line_height+gap_height do
        love.graphics.line(VIRTUAL_WIDTH/2-2,y,VIRTUAL_WIDTH/2-2,y+line_height)
    end
end

function love.resize(w, h)
    push:resize(w,h)
end

function main_menu()
    sounds.music:play()
    sounds.music:setLooping(true)
    draw_background() 
    love.graphics.setColor(0.2,0.2,0.2)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line",40,180,280,162)
    love.graphics.line(40, 215, 320, 215)    
    love.graphics.draw(text,20,30,0,0.6,0.6)      
    love.graphics.setNewFont("fonts/Orbitron Medium.otf",14)   
    if timer>0.5 and timer<1 then 
        love.graphics.print("Click to start the game ",230,480-70); 
    end
    love.graphics.print("Game Objectives:",42,188);
    love.graphics.setNewFont("fonts/arial.ttf",15)
    love.graphics.printf("Control the two paddles using WASD and arrow keys and prevent tht ball from crossing the boundary. The next player would score a point if ball crosses your boundary and vice-versa. The fastest",42,230,278,'justify')   
    love.graphics.print("one to score 10 points win",42,315)
    love.graphics.setColor(0.7,0.7,0.7)    
    love.graphics.print("(C) Copyright Okra Softmakers",12,455)
end

function draw_background()
    love.graphics.setColor(0.7,0.7,0.7)        
    love.graphics.draw(back,0,100,0,0.12,0.12,0,0,0,0);   
    for y=0,90,10 do
    love.graphics.draw(back2,0,y,0,0.12,0.12)   
    end   
end
function select_combination()
    draw_background()
    love.graphics.line(0,90,640,90)   
    love.graphics.setNewFont("fonts/Orbitron Medium.otf",18)        
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle('fill',0,50,640,40)    
    love.graphics.rectangle('fill',20,433,210,30)    
    love.graphics.rectangle('fill',60,160,300,195)
    highlightOnHover("Human Vs Human",80,190,256)
    highlightOnHover("Human Vs Computer",80,250,285)
    highlightOnHover("Computer Vs Computer",80,310,315)
    highlightOnHover("Back to Main Menu",30,440,225)
    love.graphics.setNewFont("fonts/Orbitron Medium.otf",24)        
    love.graphics.setColor(1,1,0)
    love.graphics.print("Select the mode of gameplay:-",30,60)    
end

function select_difficulty_level()
    draw_background()
    love.graphics.line(0,90,640,90)   
    love.graphics.setNewFont("fonts/Orbitron Medium.otf",18)        
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle('fill',0,50,640,40)    
    love.graphics.rectangle('fill',20,433,210,30)    
    love.graphics.rectangle('fill',60,160,300,195)
    highlightOnHover("Easy : Walk in the park",80,190,295)
    highlightOnHover("Medium : For the average",80,250,320)
    highlightOnHover("Hard : Next to Impossible",80,310,315)
    highlightOnHover("Back to Main Menu",30,440,225)
    love.graphics.setNewFont("fonts/Orbitron Medium.otf",24)        
    love.graphics.setColor(1,1,0)
    love.graphics.print("Select the difficulty level:-",30,60)    
end

function highlightOnHover(str,posx,posy,posx2)
    if checkHover(str,posx,posy,posx2)==true then
        love.graphics.setColor(1,1,0)
    else
        love.graphics.setColor(1,1,1,0.8)
    end
    love.graphics.print(str,posx,posy)
end
function checkHover(str,posx,posy,posx2)
    local x=love.mouse.getX()
    local y=love.mouse.getY()
    if x>=posx and x<=posx2 and y>=posy and y<=posy+18 then
        return true
    else
        return false
    end
end
function love.mousereleased(x,y,btn)
    if btn==1 then
        if gamestate=='main_menu' then
            gamestate='select_combination';
        elseif gamestate=='select_combination' then
            if x>=80 and x<=256 and y>=190 and y<=208 then
                player1.ai,player2.ai=false,false
                gamestate='start'
                push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT)
            elseif x>=80 and x<=285 and y>=250 and y<=268 then
                player1.ai,player2.ai=false,true
                gamestate='select_difficulty_level'
            elseif x>=80 and x<=315 and y>=310 and y<=328 then
                player1.ai,player2.ai=true,true   
                gamestate='select_difficulty_level'            
            elseif x>=30 and x<=225 and y>=440 and y<=468 then
                gamestate='main_menu'
            end
        elseif gamestate=='select_difficulty_level' then
            if x>=80 and x<=295 and y>=190 and y<=208 then
                GAME_DIFFICULTY='EASY'
                gamestate='start'
                push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT)
            elseif x>=80 and x<=320 and y>=250 and y<=268 then
                GAME_DIFFICULTY='MEDIUM'
                gamestate='start'
                push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT)
            elseif x>=80 and x<=315 and y>=310 and y<=328 then
                GAME_DIFFICULTY='HARD'
                gamestate='start'            
                push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT)
            elseif x>=30 and x<=225 and y>=440 and y<=468 then
                gamestate='main_menu'
            end
        end

    end
end
    
