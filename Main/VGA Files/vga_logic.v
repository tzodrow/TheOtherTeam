`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:37:45 02/10/2014 
// Design Name: 
// Module Name:    vga_logic 
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
module vga_logic(clk, rst, blank, comp_sync, hsync, vsync, pixel_x, pixel_y, fifo_out, fifo_rd_en, fifo_empty, pixel_r, pixel_g, pixel_b);
    input clk;
    input rst;
	 input [23:0] fifo_out;
	 input fifo_empty;
	 output fifo_rd_en; 
    output [7:0] pixel_r;
    output [7:0] pixel_g;
    output [7:0] pixel_b;
	 output blank;
	 output comp_sync;
    output hsync;
    output vsync;
    output [9:0] pixel_x;
    output [9:0] pixel_y;
	 
	 reg [9:0] pixel_x;
	 reg [9:0] pixel_y;
	 
	 // pixel_count logic
	 wire [9:0] next_pixel_x;
	 wire [9:0] next_pixel_y;
	 assign next_pixel_x = (pixel_x == 10'd799)? 0 : pixel_x+1;
	 assign next_pixel_y = (pixel_x == 10'd799)?
	                             ((pixel_y == 10'd520) ? 0 : pixel_y+1)
										  : pixel_y;
	 
	 always@(posedge clk, posedge rst)
	   if(rst) begin
		  pixel_x <= 10'h0;
		  pixel_y <= 10'h0;
		end else begin
		  pixel_x <= next_pixel_x;
		  pixel_y <= next_pixel_y;
		end
		
		assign pixel_r = (~blank) ? 0 : fifo_out[23:16]; //only put on pixel-lines when blank is high
		assign pixel_g = (~blank) ? 0 : fifo_out[15:8]; 
		assign pixel_b = (~blank) ? 0 : fifo_out[7:0]; 
		assign fifo_rd_en = (fifo_empty) ? 0 : blank; 	//check if FIFO empty, otherwise read when blank is high	
		assign hsync = (pixel_x < 10'd656) || (pixel_x > 10'd751); // 96 cycle pulse
		assign vsync = (pixel_y < 10'd490) || (pixel_y > 10'd491); // 2 cycle pulse
		assign blank = ~((pixel_x > 10'd639) || (pixel_y > 10'd479)); //pixel out of range
		assign comp_sync = 1'b0; // don't know, dont use
	 
endmodule