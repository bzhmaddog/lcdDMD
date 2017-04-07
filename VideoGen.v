// (c) KNJN LLC 2013

//`define PONG   // use that to get a pong game instead of a static display

////////////////////////////////////////////////////////////////////////
module VideoGen(
	input clk,
	output reg DrawArea, hSync, vSync,
	output [7:0] red, green, blue
);

////////////////////////////////////////////////////////////////////////
//parameter hDrawArea = 640;
//parameter hSyncPorch = 16;
//parameter hSyncLen = 96;
//parameter hFrameSize = 800;

parameter hDrawArea = 1280;
parameter hSyncPorch = 32;
parameter hSyncLen = 96;
parameter hFrameSize = 1440;


//parameter vDrawArea = 480;
//parameter vSyncPorch = 10;
//parameter vSyncLen = 2;
//parameter vFrameSize = 525;

parameter vDrawArea = 390;
parameter vSyncPorch = 1;
parameter vSyncLen = 24;
parameter vFrameSize = 442;

/*
wire pxSp,clk35;

DCM_SP #(
      .CLKFX_DIVIDE(2),   // Can be any integer from 1 to 32
      .CLKFX_MULTIPLY(3) // Can be any integer from 2 to 32
   ) DCM_SP_inst (
      .CLKFX(pxSp),   // DCM CLK synthesis out (M/D)
      .CLKIN(clk),   // Clock input (from IBUFG, BUFG or DCM)
		.RST(1'b0)
   );
BUFG BUFG_pxSp(.I(pxSp), .O(clk35));  // 250MHz
*/

reg [11:0] CounterX, CounterY;
always @(posedge clk) CounterX <= (CounterX==hFrameSize-1) ? 12'd0 : CounterX+12'd1;
always @(posedge clk) if(CounterX==hFrameSize-1) CounterY <= (CounterY==vFrameSize-1) ? 12'd0 : CounterY+12'd1;

always @(posedge clk) DrawArea <= (CounterX<hDrawArea) && (CounterY<vDrawArea);
always @(posedge clk) hSync <= (CounterX>=hDrawArea+hSyncPorch) && (CounterX<hDrawArea+hSyncPorch+hSyncLen);
always @(posedge clk) vSync <= (CounterY>=vDrawArea+vSyncPorch) && (CounterY<vDrawArea+vSyncPorch+vSyncLen);

////////////////////////////////////////////////////////////////////////
	reg [7:0] R, G, B;
	always @(posedge clk) R <= 255;
	always @(posedge clk) G <= 0;
	always @(posedge clk) B <= 0;
	assign red = R;
	assign green = G;
	assign blue = B;

endmodule

////////////////////////////////////////////////////////////////////////
