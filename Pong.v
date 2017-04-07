// (c) KNJN LLC 2013

/////////////////////////////////////////////////////////////////
module Pong(
	input clk,
	input [11:0] PaddlePosition, CounterX, CounterY,
	output reg [7:0] red, green, blue
);

parameter hDrawArea = 640;
parameter vDrawArea = 480;
parameter BallSpeed = 3;

///////////////////////////////////
reg [11:0] ballX, ballY;
wire ball = (CounterX>=ballX) && (CounterX<ballX+16) && (CounterY>=ballY) && (CounterY<ballY+16);
wire border = (CounterX[11:2]==0) || (CounterX[11:2]==hDrawArea/4-1) || (CounterY[11:2]==0) || (CounterY[11:2]==vDrawArea/4-1);
wire paddle = (CounterX>=PaddlePosition+8) && (CounterX<=PaddlePosition+120) && (CounterY>=vDrawArea-36) && (CounterY<vDrawArea-20);
wire BounceableObject = border | paddle; // active if the border or paddle is redrawing itself

wire FrameTick = (CounterX==0) && (CounterY==vDrawArea);  // valid once per video frame (but outside the drawing area)
wire ResetCollision = FrameTick;
reg CollisionX1, CollisionX2, CollisionY1, CollisionY2;
always @(posedge clk) if(ResetCollision) CollisionX1<=1'b0; else if(BounceableObject & (CounterX==ballX   ) & (CounterY==ballY+ 8)) CollisionX1<=1'b1;
always @(posedge clk) if(ResetCollision) CollisionX2<=1'b0; else if(BounceableObject & (CounterX==ballX+16) & (CounterY==ballY+ 8)) CollisionX2<=1'b1;
always @(posedge clk) if(ResetCollision) CollisionY1<=1'b0; else if(BounceableObject & (CounterX==ballX+ 8) & (CounterY==ballY   )) CollisionY1<=1'b1;
always @(posedge clk) if(ResetCollision) CollisionY2<=1'b0; else if(BounceableObject & (CounterX==ballX+ 8) & (CounterY==ballY+16)) CollisionY2<=1'b1;

///////////////////////////////////
wire UpdateBallPosition = ResetCollision;  // update the ball position at the same time that we reset the collision detectors
reg ball_dirX, ball_dirY;

always @(posedge clk)
if(UpdateBallPosition)
begin
	if(~(CollisionX1 & CollisionX2))        // if collision on both X-sides, don't move in the X direction
	begin
		if(ball_dirX) ballX <= ballX - BallSpeed; else ballX <= ballX + BallSpeed;
		if(CollisionX2) ball_dirX <= 1'b1; else if(CollisionX1) ball_dirX <= 1'b0;
	end

	if(~(CollisionY1 & CollisionY2))        // if collision on both Y-sides, don't move in the Y direction
	begin
		if(ball_dirY) ballY <= ballY - BallSpeed; else ballY <= ballY + BallSpeed;
		if(CollisionY2) ball_dirY <= 1'b1; else if(CollisionY1) ball_dirY <= 1'b0;
	end
end 

///////////////////////////////////
wire [7:0] white = {8{BounceableObject | ball}};
always @(posedge clk) red <= white | ({CounterX[5:0] & {6{CounterY[4:3]==~CounterX[4:3]}}, 2'b00});
always @(posedge clk) green <= white | (CounterX[7:0] & {8{CounterY[6]}});
always @(posedge clk) blue <= white | CounterY[7:0];
endmodule


/////////////////////////////////////////////////////////////////
