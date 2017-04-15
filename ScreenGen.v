`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:53:51 04/09/2017 
// Design Name: 
// Module Name:    ScreenGen 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module RamScreenGen(
	input clk,
   input [7:0]  x, //horizontal counter from video timing generator
   input [5:0]  y, //vertical counter from video timing generator
   output [7:0]  o_r,
   output [7:0]  o_g,
   output [7:0]  o_b    
);

localparam STEP =  (255 - 50) / 16;

reg [12: 0] addra = 0;
reg [12: 0] pixel_addr = 0;
wire [3:0] buffer_out = 0;
//reg [3:0] pix_brightness = 0;

//synthesis attribute box_type <screen_buffer> "dp_bram"
/*dp_bram screen_buffer (
  .clka(clk), // input clka
  .wea(), // input [0 : 0] wea
  .addra(), // input [12 : 0] addra
  .dina(), // input [3 : 0] dina
  .clkb(clk), // input clkb
  .addrb(pixel_addr), // input [12 : 0] addrb
  .doutb(buffer_out) // output [3 : 0] doutb
);*/

/*sp_bram screen_buffer (
  .clka(clk), // input clka
  .addra(pixel_addr), // input [12 : 0] addra
  .douta(buffer_out) // output [3 : 0] douta
);*/

//reg [7:0] R,G,B;

//always @* beginra
//	pix_brightness <= buffer_out;
//end

always @(posedge clk) begin
	pixel_addr = (x * 4) + (y * 128 * 4);
	//pixel_addr = (x * 4);

	//if (x == 0 || y == 0 ||	 y == 38 || x == 127) begin
		
		//R <= 50 + (pix_brightness * STEP); // 255
		//G <= 50 + (pix_brightness * STEP); // 132
		//B <= 50 + (pix_brightness * STEP); // 10
		
	//end else begin
	//	R <= 50;
	//	G <= 50;
	//	B <= 50;
	//end
end

assign o_r = 50 + (buffer_out[3:0] * 13);
assign o_g = 50 + (buffer_out[3:0] * 13);
assign o_b = 50 + (buffer_out[3:0] * 13);

endmodule
