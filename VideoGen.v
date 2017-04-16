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

	reg [0:0]  buffer0_we = 0;
	reg [0:0]  buffer0_in = 0;
	reg [12:0] buffer0_addr;
	wire [3:0] buffer0_out;

	reg [0:0]  buffer1_we = 0;
	reg [0:0]  buffer1_in = 0;
	reg [12:0] buffer1_addr;
	wire [3:0] buffer1_out;

	reg [0:0] frame = 0;
	reg [0:0] frame_flip = 0;


	//wire [7:0] RxD_data;
	//wire RxD_data_ready;
	//reg [0:0] TxD_data_ready = 0;

	//reg [7:0] data = 0;
	
	// first frame buffer
	sp_bram frame_buffer0 (
	  .clka(clk), // input clka
	  .wea(),
	  .addra(buffer0_addr), // input [12 : 0] addra
	  .dina(),  
	  .douta(buffer0_out) // output [3 : 0] douta
	);

	// second frame buffer
	sp_bram1 frame_buffer1 (
	  .clka(clk), // input clka
	  .wea(),
	  .addra(buffer1_addr), // input [12 : 0] addra
	  .dina(),  
	  .douta(buffer1_out) // output [3 : 0] douta
	);

	// UART Receiver
	/*async_receiver RX(
		.clk(clk),
		.RxD(RxD),
		.RxD_data_ready(RxD_data_ready),
		.RxD_data(RxD_data),
		.RxD_idle(),
		.RxD_endofpacket()
	);*/

	// UART Transmitter
	/*async_transmitter TX(
		.clk(clk),
		.TxD(TxD),
		.TxD_start(frame_flip),
		.TxD_data(data),
		.TxD_busy()
	);*/

	always @(posedge clk) begin

		if (CounterX==hFrameSize-1) begin

			CounterX <= 12'd0;
			x_count <= 4'd0;
			pixel_x <= 8'd0;

		end else begin

			CounterX <= CounterX+12'd1;

			if (x_count >= 9) begin
				x_count <= 4'd0;
				pixel_x <= pixel_x+8'd1; //Increase current pixel X value
			end else begin
				x_count <= x_count+4'd1; // Increase counter that we use to increase current X pixel  value
			end

		end

	end // always

	always @(posedge clk) begin

		//if (RxD_data_ready) begin
			
			//data <= RxD_data;

			//if (RxD_data == "F") frame_flip <= 1;
			//frame_flip <= 1;

		//end	
		
		if (CounterX==hFrameSize-1) begin

			if (CounterY==vFrameSize-1) begin

				CounterY <= 12'd0;
				y_count <= 4'd0;
				pixel_y <= 6'd0;
			
				if (frame_flip == 1) begin

					if (frame == 0)
						frame <=1;
					else
						frame <=0;
				
					frame_flip <= 0;

				end
				
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
		 
	end //always

	always @(posedge clk) DrawArea <= (CounterX<hDrawArea) && (CounterY<vDrawArea);
	always @(posedge clk) hSync <= (CounterX>=hDrawArea+hSyncPorch) && (CounterX<hDrawArea+hSyncPorch+hSyncLen);
	always @(posedge clk) vSync <= (CounterY>=vDrawArea+vSyncPorch) && (CounterY<vDrawArea+vSyncPorch+vSyncLen);


	// generate ram address based on current pixel pos
	always @* begin

		if (frame == 0)
			buffer0_addr = (pixel_x) + (pixel_y * 128);
		else
			buffer1_addr = (pixel_x) + (pixel_y * 128);		

	end // always

	
	always @(posedge clk) begin

		// return black color for the 2px border around every 8x8 pixels
		if (x_count == 0 || x_count == 9 || y_count == 0 || y_count == 9) begin

			R <= 0;
			G <= 0;
			B <= 0;

		// return current pixel color based on the brightness stored in bram buffer
		// Todo: Fix algorythm to get an orange color
		end else begin

			if (frame == 0) begin

				R <= 50 + (buffer0_out[3:0] * 13);
				G <= 50 + (buffer0_out[3:0] * 13);
				B <= 50 + (buffer0_out[3:0] * 13);

			end else begin

				R <= 50 + (buffer1_out[3:0] * 13);
				G <= 50 + (buffer1_out[3:0] * 13);
				B <= 50 + (buffer1_out[3:0] * 13);

			end

		end
		
	end // always

	assign red = R;
	assign green = G;
	assign blue = B;

endmodule
// End