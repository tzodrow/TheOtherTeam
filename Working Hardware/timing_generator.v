`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:39:06 02/10/2014 
// Design Name: 
// Module Name:    main_logic 
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
module timing_generator(clk, rst, fifo_out, fifo_rd_en, pixel_r, pixel_g, pixel_b, hsync, vsync);
    input clk;
    input rst;
    input [23:0] fifo_out;
	 output fifo_rd_en; 
    output [7:0] pixel_r;
    output [7:0] pixel_g;
    output [7:0] pixel_b;
	 output hsync;
	 output vsync;
	 
	 reg hor_state;
	 reg ver_state; 
	 
	 

endmodule
