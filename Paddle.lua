Paddle=Class{}
PADDLE_SPEED=200
PADDLE_WIDTH=5
PADDLE_HEIGHT=20
function Paddle:init (pos,x,y,c1,c2,ai)
    self.pos=pos
    self.x=x
    self.y=y
    self.keyup=c1
    self.keydown=c2
    self.ai=ai
    self.score=0
    self:setOffset();       
    --make paddle move up and down (only needed it is ai-enabled otherwise it would be controlled by player)
    self.dir=math.random(2)==1 and -1 or 1
end

function Paddle:render()
    love.graphics.rectangle('fill',self.x,self.y,PADDLE_WIDTH,PADDLE_HEIGHT)
end

function Paddle:update(dt,defend)
    if self.ai==false then
        if (love.keyboard.isDown(self.keyup)) then
            self.y=math.max(0,self.y-PADDLE_SPEED*dt)
        elseif (love.keyboard.isDown(self.keydown)) then
            self.y=math.min(VIRTUAL_HEIGHT-20,self.y+PADDLE_SPEED*dt)
        end
    else
        --if the ball is moving towards self then defend otherwise just move up and down
        if defend==false then
            self.y=self.y+PADDLE_SPEED*self.dir*dt;
        elseif gamestate=='play' then
            if self.pos>0 and ball.x+BALL_WIDTH+self.offset>=self.x then
                ball.predicty=ball.y
            elseif self.pos<0 and ball.x-self.offset<=self.x then
                ball.predicty=ball.y
            end
            if not (ball.predicty>=self.y and ball.predicty<=self.y+PADDLE_HEIGHT) then
                if ball.predicty<self.y then
                    self.dir=-1 --move up
                elseif ball.predicty>self.y+PADDLE_HEIGHT then
                    self.dir=1 --move down
                end
                self.y=self.y+PADDLE_SPEED*self.dir*dt;
            end
        end
        if self.y<0 or self.y+PADDLE_HEIGHT>VIRTUAL_HEIGHT then
            self.dir=-self.dir
        end
    end
end

function Paddle:setOffset()
    if GAME_DIFFICULTY=='HARD' then
        self.offset=math.random(200,300)
    elseif GAME_DIFFICULTY=='MEDIUM' then
        self.offset=math.random(100,200)  
    else
        self.offset=math.random(60,100)
    end 
end