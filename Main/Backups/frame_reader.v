`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:04:55 04/19/2015 
// Design Name: 
// Module Name:    frame_reader 
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
module frame_reader(
	input clk,
	input rst_n,
	input full,
	input [23:0] frame_data,
	output reg [16:0] frame_addr,
	output reg frame_re,
	output [23:0] data_out,
	output reg we
    );


	localparam WAIT = 2'b00;
	localparam READ = 2'b01;
	
	localparam HEX_640 = 10'h27F;
	localparam HEX_480 = 9'h1DF;
	
	reg [16:0] start_addr;
	reg ld_start_addr, rst_start_addr;
	reg rst_frame_addr, ld_frame_addr, inc_frame_addr;
	reg [9:0] x_count;
	reg inc_x_count, rst_x_count;
	reg [8:0] y_count;
	reg inc_y_count, rst_y_count;
	reg [1:0] state, nxt_state;
	reg [10:0] backdoor;

	assign data_out = frame_data;
	
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			state <= 0;
		else
			state <= nxt_state;
		
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			frame_addr <= 0;
		else if(rst_frame_addr)
			frame_addr <= 0;
		else if(ld_frame_addr)
			frame_addr <= start_addr;
		else if(inc_frame_addr)
			frame_addr <= frame_addr + 1;
			
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			start_addr <= 0;
		else if(rst_start_addr)
			start_addr <= 0;
		else if(ld_start_addr)
			start_addr <= frame_addr + 1;
			
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			x_count <= 0;
		else if(rst_x_count)
			x_count <= 0;
		else if(inc_x_count)
			x_count <= x_count + 1;
			
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			y_count <= 0;
		else if(rst_y_count)
			y_count <= 0;
		else if(inc_y_count)
			y_count <= y_count + 1;
			
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			backdoor <= 0;
		else
			backdoor <= backdoor + 1;
			
	always @ (*) begin
		ld_start_addr = 0;
		we = 0;
		frame_re = 0;
		rst_frame_addr = 0;
		ld_frame_addr = 0;
		inc_frame_addr = 0;
		inc_x_count = 0;
		rst_x_count = 0;
		inc_y_count = 0;
		rst_y_count = 0;
		rst_start_addr = 0;
		nxt_state = WAIT;
		
		case(state)
			WAIT : begin
				nxt_state = READ;
				if(&backdoor) begin
					nxt_state = READ;
					rst_start_addr = 1;
					rst_frame_addr = 1;
				end
			end
			READ : begin
				nxt_state = READ;
				if(~full) begin
					frame_re = 1; // Always read
					we = 1; // Always write
					inc_x_count = 1; // Always increment
					
					// Read Every Address Twice
					if(x_count[0]) begin
						inc_frame_addr = 1;
					end

					// Increment at the end of Row
					if(x_count[0] & (x_count == HEX_640)) begin
						inc_y_count = 1;
						rst_x_count = 1;
					end
					
					// Read Every Row Twice
					if(~y_count[0] & (x_count == HEX_640)) begin
						ld_frame_addr = 1;
					end
						
					// Reset at the end of Row
					if(x_count[0] & y_count[0] & (x_count == HEX_640)) begin
						rst_x_count = 1;
						ld_start_addr = 1;
					end
					
					// Reset at  the end of the Frame
					if((x_count == HEX_640) & (y_count == HEX_480)) begin
						rst_x_count = 1;
						rst_y_count = 1;
						rst_frame_addr = 1;
						rst_start_addr = 1;
					end
				end
			end
		endcase
	end
		
		
endmodule
