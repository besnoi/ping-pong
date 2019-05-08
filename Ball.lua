Ball=Class {}

BALL_WIDTH,BALL_HEIGHT=4,4

function Ball:init(x,y)
    self.x=x
    self.y=y
    self.width=4
    self.height=4
    self.dx=(math.random(0,1)==1) and 100 or -100
    self.dy=math.random(-50,50)
    if self.dx<0 then
        self.predicty=self:predictPosition(player1,-1)
    else
        self.predicty=self:predictPosition(player2,1)
    end
end

function Ball:update(dt)
    self.x=self.x + self.dx*dt;
    self.y=self.y + self.dy*dt;
end

function Ball:render()
    love.graphics.rectangle('fill',self.x,self.y,self.width,self.height)
end

function Ball:collides(paddle)
    if self.x>paddle.x+PADDLE_WIDTH or self.y>paddle.y+PADDLE_HEIGHT or paddle.x>self.x+self.width or paddle.y>self.y+self.height then
        return false
    else
        return true
    end
end 

function Ball:predictPosition(paddle)
    --[[This function will predict the y position of the ball 
      when it's x co-ordinate will be equal to the x co-ordinate of the paddle
    ]]
    if paddle.pos<0 then
        return math.abs(((self.x-paddle.x-PADDLE_WIDTH)/self.dx)*self.dy)
    else
        return math.abs(((paddle.x-self.x-BALL_WIDTH)/self.dx)*self.dy)
    end
    --[[
        And one very important note here- this is just a prediction, it is
        possible to find the exact location where the ball is going to land
        after t second seconds has passed but we donot want the game to be a
        no fun. If a paddle already knew where the ball is going to land
        it would just stand still on that position and wait for the ball.
        In that way the paddle would never lose, we want some challenge.
        And for that I propose we use a predicty variable and we store in it
        the 'supposed' value of ball.y when it will enter the arena of the paddle
        The prediction may or may not be correct. The paddle would stand still on that
        position for some time and wait for the ball to be at 'offset' distance from it
        (see Paddle class) and when that happens the predicty variable would be replaced
        by the y co-ordinate of the ball (which we know is a variable). So if our prediction
        was close to the actual value of ball.y when it's x is the same as the paddle's x
        then the paddle would be able to hit it otherwise not. (because even though now the
        paddle knows where the ball is going to land if the distance is large then the
        paddle wouldn't be able to make it.0 All depends on the value of 'offset', it would
        be more fun if offset were a random value.

    ]]
end        