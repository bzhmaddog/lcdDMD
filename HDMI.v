// (c) KNJN LLC 2013

////////////////////////////////////////////////////////////////////////
module HDMI(
	input pixclk,
	input hSync, vSync, DrawArea,
	input [7:0] red, green, blue,
	output [2:0] TMDSp, TMDSn,
	output TMDSp_clock, TMDSn_clock
);

////////////////////////////////////////////////////////////////////////
wire [9:0] TMDS_red, TMDS_green, TMDS_blue;
TMDS_encoder #(0) encode_R(.clk(pixclk), .VDE(DrawArea), .VD(red  ), .CD(2'b00)        , .TMDS(TMDS_red));
TMDS_encoder #(1) encode_G(.clk(pixclk), .VDE(DrawArea), .VD(green), .CD(2'b00)        , .TMDS(TMDS_green));
TMDS_encoder #(1) encode_B(.clk(pixclk), .VDE(DrawArea), .VD(blue ), .CD({vSync,hSync}), .TMDS(TMDS_blue));

////////////////////////////////////////////////////////////////////////
wire DCM_TMDSp, clk_TMDS;
DCM_SP #(.CLKFX_MULTIPLY(10), .STARTUP_WAIT("TRUE")) DCM_TMDS_inst(.CLKIN(pixclk), .CLKFX(DCM_TMDSp), .RST(1'b0));
BUFG BUFG_TMDSp(.I(DCM_TMDSp), .O(clk_TMDS));  // 250MHz

////////////////////////////////////////////////////////////////////////
reg TMDS_shift_load=0;
reg [9:0] TMDS_shift_red=0, TMDS_shift_green=0, TMDS_shift_blue=0;
reg [3:0] TMDS_cnt=0;  // modulus 10 counter
always @(posedge clk_TMDS) TMDS_shift_load <= (TMDS_cnt==4'd9);

always @(posedge clk_TMDS)
begin
	TMDS_shift_red   <= TMDS_shift_load ? TMDS_red   : TMDS_shift_red[9:1];
	TMDS_shift_green <= TMDS_shift_load ? TMDS_green : TMDS_shift_green[9:1];
	TMDS_shift_blue  <= TMDS_shift_load ? TMDS_blue  : TMDS_shift_blue[9:1];	
	TMDS_cnt <= (TMDS_cnt==4'd9) ? 4'd0 : TMDS_cnt+4'd1;
end

OBUFDS OBUFDS_red  (.O(TMDSp[2]), .OB(TMDSn[2]), .I(TMDS_shift_red[0]));
OBUFDS OBUFDS_green(.O(TMDSp[1]), .OB(TMDSn[1]), .I(TMDS_shift_green[0]));
OBUFDS OBUFDS_blue (.O(TMDSp[0]), .OB(TMDSn[0]), .I(TMDS_shift_blue[0]));

ODDR2 #(.DDR_ALIGNMENT("NONE")) ODDR2_clock(.Q(OBUF_TMDS_clock), .C0(pixclk), .C1(~pixclk), .CE(1'b1), .D0(1'b1), .D1(1'b0));//, .R(), .S()
OBUFDS OBUFDS_clock(.O(TMDSp_clock), .OB(TMDSn_clock), .I(OBUF_TMDS_clock));
endmodule


////////////////////////////////////////////////////////////////////////
module TMDS_encoder(
	input clk,
	input [1:0] CD,  // control data
	input [7:0] VD,  // video data (red, green or blue)
	input VDE,  // video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
	output reg [9:0] TMDS = 0
);
parameter invert_TMDS_output = 0;  // set to 1 when the FPGA board TMDS diff outputs are swapped

wire [3:0] Nb1s = VD[0] + VD[1] + VD[2] + VD[3] + VD[4] + VD[5] + VD[6] + VD[7];
wire XNOR = (Nb1s>4'd4) || (Nb1s==4'd4 && VD[0]==1'b0);
wire [8:0] q_m = {~XNOR, q_m[6:0] ^ VD[7:1] ^ {7{XNOR}}, VD[0]};

reg [3:0] balance_acc = 0;
wire [3:0] balance = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4'd4;
wire balance_sign_eq = (balance[3] == balance_acc[3]);
wire invert_q_m = (balance==0 || balance_acc==0) ? ~q_m[8] : balance_sign_eq;
wire [3:0] balance_acc_inc = balance - ({q_m[8] ^ ~balance_sign_eq} & ~(balance==0 || balance_acc==0));
wire [3:0] balance_acc_new = invert_q_m ? balance_acc-balance_acc_inc : balance_acc+balance_acc_inc;
wire [9:0] TMDS_data = {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};
wire [9:0] TMDS_code = CD[1] ? (CD[0] ? 10'b1010101011 : 10'b0101010100) : (CD[0] ? 10'b0010101011 : 10'b1101010100);

always @(posedge clk) TMDS <= (VDE ? TMDS_data : TMDS_code) ^ {10{invert_TMDS_output[0]}};
always @(posedge clk) balance_acc <= VDE ? balance_acc_new : 4'h0;
endmodule


////////////////////////////////////////////////////////////////////////
