module instr_mem(
		input clk,
		input rst,
		input [21:0] addr,
		input [31:0] instr);

/////////////////////////////////////////////////////////////////////
// Unified memory with 4-clock access times for reads & writes.   //
// Organized as 16384 64-bit words (i.e. same width a cache line //
//////////////////////////////////////////////////////////////////

reg [31:0]mem[0:2**22-1];

////////////////////////////////
// initial load of instr.hex //
//////////////////////////////
initial
  $readmemh("instr.hex",mem);
	
/////////////////////////
// Model memory reads //
///////////////////////
always @(posedge clk)
  if (clk)				// reads occur on clock high during 4th clock cycle
    instr = mem[addr];

endmodule
			   
			   
		
	