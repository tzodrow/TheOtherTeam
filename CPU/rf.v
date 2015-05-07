module rf(
		input clk,
		input [4:0] p0_addr,
		input [4:0] p1_addr,
		output reg [31:0] p0,
		output reg [31:0] p1,
		input [4:0] dst_addr,
		input [31:0] dst,
		input we);
//////////////////////////////////////////////////////////////////
// Triple ported register file.  Two read ports (p0 & p1), and //
// one write port (dst).  Data is written on clock high, and  //
// read on clock low //////////////////////////////////////////
//////////////////////

reg [31:0]mem[0:31];

//////////////////////////////////////////////////////////
// Register file will come up uninitialized except for //
// register zero which is hardwired to be zero.       //
///////////////////////////////////////////////////////
initial begin
  mem[0] = 32'h00000000;					// reg0 is always 0,
end

//////////////////////////////////
// RF is written on clock high //
////////////////////////////////
always @(clk,we,dst_addr,dst)
  if (clk && we && |dst_addr)
    mem[dst_addr] <= dst;
	
//////////////////////////////
// RF is read on clock low //
////////////////////////////
always @(clk,p0_addr)
  if (~clk)
    p0 <= mem[p0_addr];
	
//////////////////////////////
// RF is read on clock low //
////////////////////////////
always @(clk,p1_addr)
  if (~clk)
    p1 <= mem[p1_addr];
	
endmodule
  

