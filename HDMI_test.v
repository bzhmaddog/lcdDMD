// (c) KNJN LLC 2013

////////////////////////////////////////////////////////////////////////
module HDMI_test(
	input clk25,
	output [2:0] TMDSp, TMDSn,
	output clk35,clk180,ram_clk,TMDSp_clock, TMDSn_clock
	//input RxD,
	//output TxD
);

wire hSync, vSync, DrawArea;
wire [7:0] red, green, blue;

dcm_35 pixel_clock (
    .CLKIN_IN(clk25), 
    .RST_IN(1'b0), 
    .CLKFX_OUT(clk35),
	 .CLKDV_OUT(ram_clk),
	 .CLK180_OUT(clk180)
    //.CLKIN_IBUFG_OUT(), 
    //.CLK0_OUT(clk1x)
    //.LOCKED_OUT(LED)
);

// RxD
/*wire [7:0] RxD_data;
wire RxD_data_ready;
reg [7:0] frame1;

async_receiver RX(
	.clk(clk35),
	.RxD(RxD),
	.RxD_data_ready(RxD_data_ready),
	.RxD_data(RxD_data),
	.RxD_idle(),
	.RxD_endofpacket()
);

always @(posedge clk35) begin
 if(RxD_data_ready) begin 
	assign frame1 = RxD_data;
 end else begin
	assign frame1 = 8'd0;
 end
end*/

//reg [31:0] cnt;
//always @(posedge clk1x) cnt <= cnt + 1;

//assign LED = ~cnt[22] & ~cnt[20];

VideoGen myVideoGen(
	.clk(clk35),
	.rclk(ram_clk),
	.clk180(clk180),
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
