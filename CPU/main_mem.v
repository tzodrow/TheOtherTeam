module main_mem(
		input clk,
		input rst,
		input [21:0] addr,
		input we,
		input [31:0] wdata,
		output reg [31:0] rd_data);

reg [31:0]mem[0:2**22-1];			// entire memory space at 16-bits wide

////////////////////////////////
// initial load of instr.hex //
//////////////////////////////
initial
  $readmemh("instr.hex",mem);

//////////////////////////
// Model memory writes //
////////////////////////
always @(clk, we)
  if (clk & we)				// write occurs on clock high during 4th clock cycle
    begin
      mem[addr] <= wdata;
	end
	
/////////////////////////
// Model memory reads //
///////////////////////
always @(clk)
  if (clk)				// reads occur on clock high during 4th clock cycle
    rd_data = mem[addr];

endmodule
			   
			   
		
	