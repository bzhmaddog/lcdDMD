// (c) KNJN LLC 2013

////////////////////////////////////////////////////////////////////////
module HDMI_test(
	input clk,
	output [2:0] TMDSp, TMDSn,
	output TMDSp_clock, TMDSn_clock
);

wire hSync, vSync, DrawArea;
wire [7:0] red, green, blue;
VideoGen myVideoGen(
	.clk(clk),
	.hSync(hSync), .vSync(vSync), .DrawArea(DrawArea),
	.red(red), .green(green), .blue(blue)
);

HDMI myHDMI(
	.pixclk(clk),
	.hSync(hSync), .vSync(vSync), .DrawArea(DrawArea),
	.red(red), .green(green), .blue(blue),
	.TMDSp(TMDSp), .TMDSn(TMDSn),
	.TMDSp_clock(TMDSp_clock), .TMDSn_clock(TMDSn_clock)
);
endmodule

////////////////////////////////////////////////////////////////////////
