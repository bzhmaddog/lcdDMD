// Based on HDMI_Test from (c) KNJN LLC 2013
////////////////////////////////////////////////////////////////////////

module dmd(
	input clk25,
	input RxD,
	output TxD,
	output [2:0] TMDSp, TMDSn,
	output clk35,ram_clk,TMDSp_clock, TMDSn_clock
	//input RxD,
	//output TxD
);

wire hSync, vSync, DrawArea;
wire [7:0] red, green, blue;

dcm_pixels pixel_clock (
    .CLKIN_IN(clk25), 
    .RST_IN(1'b0), 
    .CLKFX_OUT(clk35),
	 .CLKDV_OUT(ram_clk)
);

VideoGen myVideoGen(
	.clk(clk35),
	.rclk(ram_clk),
	.RxD(RxD),
	.TxD(TxD),
	.hSync(hSync),
	.vSync(vSync),
	.DrawArea(DrawArea),
	.red(red),
	.green(green),
	.blue(blue)
);

HDMI myHDMI(
	.pixclk(clk35),
	.hSync(hSync),
	.vSync(vSync),
	.DrawArea(DrawArea),
	.red(red),
	.green(green),
	.blue(blue),
	.TMDSp(TMDSp),
	.TMDSn(TMDSn),
	.TMDSp_clock(TMDSp_clock),
	.TMDSn_clock(TMDSn_clock)
);


endmodule

////////////////////////////////////////////////////////////////////////
