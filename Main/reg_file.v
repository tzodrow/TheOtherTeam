`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:38:08 05/05/2015 
// Design Name: 
// Module Name:    reg_file 
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
module reg_interface(
    input clk,
    input rst,
    input we,
    input [4:0] regS_addr,
    input [4:0] regT_addr,
    input [4:0] regD_addr,
    input [31:0] regD_data,
    output [31:0] regS_data,
    output [31:0] regT_data
    );
	
	localparam R0 = 5'h00;
	
	// Hold R0 at 0
	wire [31:0] data_in;
	assign data_in = (regD_addr == R0) ? 0 : regD_data;
	
	REG_FILE RegS_File (
		.clka(clk), // input clka
		.wea(we), // input [0 : 0] wea
		.addra(regD_addr), // input [4 : 0] addra
		.dina(data_in), // input [31 : 0] dina
		.clkb(clk), // input clkb
		.rstb(rst), // input rstb
		.addrb(regS_addr), // input [4 : 0] addrb
		.doutb(regS_data) // output [31 : 0] doutb
	);

	REG_FILE RegT_File (
		.clka(clk), // input clka
		.wea(we), // input [0 : 0] wea
		.addra(regD_addr), // input [4 : 0] addra
		.dina(data_in), // input [31 : 0] dina
		.clkb(clk), // input clkb
		.rstb(rst), // input rstb
		.addrb(regT_addr), // input [4 : 0] addrb
		.doutb(regT_data) // output [31 : 0] doutb
	);


endmodule
