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
module display_pane(clk, rst, fifo_full, fifo_wr_en, fifo_in);
    input clk;
    input rst;
	 input fifo_full;
	 
	 output fifo_wr_en;
	 output [23:0] fifo_in;
	 wire[16:0] addr; 
	 
	 reg[9:0] col;
	 reg[8:0] row;
	 
	 wire[9:0] next_col;
	 wire[8:0] next_row; 
	 
	 assign fifo_wr_en = ~(fifo_full); //always write unless fifo is full
	 
	 assign next_col = ((col == 10'd639) ? 0 : col + 1); //when at end of column, reset to 0
	 assign next_row = ((row == 9'd479) && (col == 10'd639)) ? 0 : //when at end of frame, reset to 0 
								((col == 10'd639) ? row + 1 : row);  //end of column, increment row
	 
	 always@(posedge clk, posedge rst) begin
		if(rst) begin
			col <= 0;
			row <= 0;
		end
		else if(fifo_wr_en) begin
			col <= next_col;	//only grab next value when writing to FIFO
			row <= next_row;
		end
		else begin
			col <= col;
			row <= row; 
		end
	 end
	 
	 assign addr = ((row >> 1) * 320) + (col >> 1); //scaling by +8 factor, reads into ROM linearly 
	 
		ROM rom(
		  .clka(clk), // 100 MHz clock
		  .addra(addr),	  // input [12 : 0] addra
		  .douta(fifo_in) // output [23 : 0] douta
		);
	 
endmodule