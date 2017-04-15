// (c) KNJN LLC 2013

////////////////////////////////////////////////////////////////////////
module VideoGen(
	input clk,
	input rclk,
	input RxD,
	output TxD,
	output reg DrawArea, hSync, vSync,
	output [7:0] red, green, blue
);

//h
parameter hDrawArea = 1280;
parameter hSyncPorch = 32;
parameter hSyncLen = 96;
parameter hFrameSize = 1440;

//v
parameter vDrawArea = 390;
parameter vSyncPorch = 1;
parameter vSyncLen = 24;
parameter vFrameSize = 442;

reg [11:0] CounterX, CounterY;
reg [7:0] R = 0;
reg [7:0] G = 0;
reg [7:0] B = 0;
reg [3:0] x_count = 0;
reg [3:0] y_count = 0;
reg [7:0] pixel_x = 0;
reg [5:0] pixel_y = 0;

reg [12: 0] pixel_addr;
wire [3:0] buffer_out;


wire [7:0] RxD_data;
wire RxD_data_ready;
reg [0:0] TxD_data_ready = 0;



sp_bram frame_buffer (
  .clka(clk), // input clka
  .addra(pixel_addr), // input [12 : 0] addra
  .douta(buffer_out) // output [3 : 0] douta
);

async_receiver RX(
	.clk(clk),
	.RxD(RxD),
	.RxD_data_ready(RxD_data_ready),
	.RxD_data(RxD_data),
	.RxD_idle(),
	.RxD_endofpacket()
);

/*async_transmitter TX(
	.clk(clk),
	.TxD(TxD),
	.TxD_start(TxD_data_ready),
	.TxD_data(RxD_data),
	.TxD_busy()
);*/

/*always @(posedge clk) begin
	if (RxD_data_ready) begin
			buffer_we <= 1;
	end

	if (buffer_we == 1) begin
			buffer_in <= RxD_data[0];
			ram_addr = ram_addr + 1;
			
			if (porta_addr > 2495) begin
				porta_addr = 0;
				buffer_we <= 0;
			end
	end
	
end*/



	always @(posedge clk) begin

	 if (CounterX==hFrameSize-1) begin
		CounterX <= 12'd0;
		x_count <= 4'd0;
		pixel_x <= 8'd0;
	 end else begin
		CounterX <= CounterX+12'd1;
	  
		if (x_count >= 9) begin
			x_count <= 4'd0;
			pixel_x <= pixel_x+8'd1;
		end else begin
			x_count <= x_count+4'd1;
		end
		
	 end
	end

	always @(posedge clk) begin
	 if (CounterX==hFrameSize-1) begin
		if (CounterY==vFrameSize-1) begin
			CounterY <= 12'd0;
			y_count <= 4'd0;
			pixel_y <= 6'd0;
		end else begin
			CounterY <= CounterY+12'd1;
			
			if (y_count >= 9) begin
				y_count <= 4'd0;
				pixel_y <= pixel_y+6'd1;
			end else begin
				y_count <= y_count+4'd1;
			end
		
		end
	 end
	end

	always @(posedge clk) DrawArea <= (CounterX<hDrawArea) && (CounterY<vDrawArea);
	always @(posedge clk) hSync <= (CounterX>=hDrawArea+hSyncPorch) && (CounterX<hDrawArea+hSyncPorch+hSyncLen);
	always @(posedge clk) vSync <= (CounterY>=vDrawArea+vSyncPorch) && (CounterY<vDrawArea+vSyncPorch+vSyncLen);


	always @* begin
		pixel_addr = (pixel_x) + (pixel_y * 128);
	end

////////////////////////////////////////////////////////////////////////
	
	always @(posedge clk) begin
		// draw 2px black border around every 8x8 pixels
		if (x_count == 0 || x_count == 9 || y_count == 0 || y_count == 9) begin
			R <= 0;
			G <= 0;
			B <= 0;
		end else begin
			R <= 50 + (buffer_out[3:0] * 13);
			G <= 50 + (buffer_out[3:0] * 13);
			B <= 50 + (buffer_out[3:0] * 13);
		end
	end

	assign red = R;
	assign green = G;
	assign blue = B;

endmodule

////////////////////////////////////////////////////////////////////////
