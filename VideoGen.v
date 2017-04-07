// (c) KNJN LLC 2013

//`define PONG   // use that to get a pong game instead of a static display

////////////////////////////////////////////////////////////////////////
module VideoGen(
	input clk,
	output reg DrawArea, hSync, vSync,
	output [7:0] red, green, blue
);

////////////////////////////////////////////////////////////////////////
parameter hDrawArea = 640;
parameter hSyncPorch = 16;
parameter hSyncLen = 96;
parameter hFrameSize = 800;

parameter vDrawArea = 480;
parameter vSyncPorch = 10;
parameter vSyncLen = 2;
parameter vFrameSize = 525;

reg [11:0] CounterX, CounterY;
always @(posedge clk) CounterX <= (CounterX==hFrameSize-1) ? 12'd0 : CounterX+12'd1;
always @(posedge clk) if(CounterX==hFrameSize-1) CounterY <= (CounterY==vFrameSize-1) ? 12'd0 : CounterY+12'd1;

always @(posedge clk) DrawArea <= (CounterX<hDrawArea) && (CounterY<vDrawArea);
always @(posedge clk) hSync <= (CounterX>=hDrawArea+hSyncPorch) && (CounterX<hDrawArea+hSyncPorch+hSyncLen);
always @(posedge clk) vSync <= (CounterY>=vDrawArea+vSyncPorch) && (CounterY<vDrawArea+vSyncPorch+vSyncLen);

////////////////////////////////////////////////////////////////////////
`ifdef PONG
	Pong #(hDrawArea, vDrawArea) game(
		.clk(clk),
		.PaddlePosition(12'd200),
		.CounterX(CounterX), .CounterY(CounterY),
		.red(red), .green(green), .blue(blue)
	);
`else
	wire [7:0] W = {8{CounterX[7:0]==CounterY[7:0]}};
	wire [7:0] A = {8{CounterX[7:5]==3'h2 && CounterY[7:5]==3'h2}};
	reg [7:0] R, G, B;
	always @(posedge clk) R <= ({CounterX[5:0] & {6{CounterY[4:3]==~CounterX[4:3]}}, 2'b00} | W) & ~A;
	always @(posedge clk) G <= (CounterX[7:0] & {8{CounterY[6]}} | W) & ~A;
	always @(posedge clk) B <= CounterY[7:0] | W | A;
	assign red = R;
	assign green = G;
	assign blue = B;
`endif

endmodule

////////////////////////////////////////////////////////////////////////
