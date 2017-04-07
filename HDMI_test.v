// (c) KNJN LLC 2013

////////////////////////////////////////////////////////////////////////
module HDMI_test(
	input clk25,
	output [2:0] TMDSp, TMDSn,
	output clk35,clk1x,LED,TMDSp_clock, TMDSn_clock
);

wire hSync, vSync, DrawArea;
wire [7:0] red, green, blue;

dcm_35 instance_name (
    .CLKIN_IN(clk25), 
    .RST_IN(1'b0), 
    .CLKFX_OUT(clk35), 
    .CLKIN_IBUFG_OUT(), 
    .CLK0_OUT(clk1x), 
    .LOCKED_OUT(LED)
);

reg [31:0] cnt;
always @(posedge clk1x) cnt <= cnt + 1;

//assign LED = ~cnt[22] & ~cnt[20];


VideoGen myVideoGen(
	.clk(clk35),
	.hSync(hSync), .vSync(vSync), .DrawArea(DrawArea),
	.red(red), .green(green), .blue(blue)
);

HDMI myHDMI(
	.pixclk(clk35),
	.hSync(hSync), .vSync(vSync), .DrawArea(DrawArea),
	.red(red), .green(green), .blue(blue),
	.TMDSp(TMDSp), .TMDSn(TMDSn),
	.TMDSp_clock(TMDSp_clock), .TMDSn_clock(TMDSn_clock)
);
endmodule

////////////////////////////////////////////////////////////////////////
