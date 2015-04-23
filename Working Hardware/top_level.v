`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    top_level 
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
module top_level(
    input rst,         // Asynchronous reset, tied to dip switch 0
    output txd,        // RS232 Transmit Data
    input rxd,         // RS232 Recieve Data
    input [1:0] br_cfg, // Baud Rate Configuration, Tied to dip switches 2 and 3
	 input clk_100mhz,
	 output [7:0] pixel_r, 
	 output [7:0] pixel_g, 
	 output [7:0] pixel_b,
	 output hsync, 
	 output vsync, 
	 output blank,
	 output clk,
	 output clk_n, 
	 output [11:0] D, 
	 output dvi_rst, 
	 inout scl_tri, 
	 inout sda_tri
    );
	
	wire iocs;
	wire iorw;
	wire rda;
	wire tbr;
	wire [1:0] ioaddr;
	wire [7:0] databus;
	
	wire clk_100mhz_buf;
	wire [23:0] data2output;
	
	// Instantiate your SPART here
	spart spart0( .clk(clk_100mhz_buf),
                 .rst(rst),
					  .iocs(iocs),
					  .iorw(iorw),
					  .rda(rda),
					  .tbr(tbr),
					  .ioaddr(ioaddr),
					  .databus(databus),
					  .txd(txd),
					  .rxd(rxd)
					);

	// Instantiate your driver here
	driver driver0( .clk(clk_100mhz_buf),
	                .rst(rst),
						 .br_cfg(br_cfg),
						 .iocs(iocs),
						 .iorw(iorw),
						 .rda(rda),
						 .tbr(tbr),
						 .ioaddr(ioaddr),
						 .databus(databus),
						 .data2output(data2output)
					 );
					 
	vga vga0(	.clk_100mhz(clk_100mhz),  
					.rst(rst), 
					.pixel_r(pixel_r), 
					.pixel_g(pixel_g), 
					.pixel_b(pixel_b), 
					.hsync(hsync), 
					.vsync(vsync), 
					.blank(blank), 
					.clk(clk), 
					.clk_n(clk_n), 
					.D(D), 
					.dvi_rst(dvi_rst), 
					.scl_tri(scl_tri), 
					.sda_tri(sda_tri),
					.clk_100mhz_buf(clk_100mhz_buf),
					.data2output(data2output)
				);
					 
endmodule
