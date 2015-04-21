//`timescale 1ns / 1ps
module simple_rom(clk, addr, rdata);
  parameter ADDR_WIDTH = 8;
  parameter DATA_WIDTH = 24;
  parameter ROM_DATA_FILE = "numbers.mem";
    input clk;
    input [ADDR_WIDTH-1:0] addr;
    output reg [DATA_WIDTH-1:0] rdata;

    reg [DATA_WIDTH-1:0] MY_ROM [0:2**ADDR_WIDTH-1];
    initial $readmemh(ROM_DATA_FILE, MY_ROM);
    always@(posedge clk) rdata <= MY_ROM[addr];

endmodule