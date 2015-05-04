
module reg_file(clk,regS,regT,p0,p1,reS,reT,dst_reg_WB,dst_reg_data_WB,we,hlt);
//////////////////////////////////////////////////////////////////
// Triple ported register file.  Two read ports (p0 & p1), and //
// one write port (dst).  Data is written on clock high, and  //
// read on clock low //////////////////////////////////////////
//////////////////////

input clk;
input [4:0] regS, regT;			// two read port addresses
input reS,reT;							// read enables (power not functionality)
input [4:0] dst_reg_WB;					// write address
input [31:0] dst_reg_data_WB;						// dst bus
input we;								// write enable
input hlt;								// not a functional input.  Used to dump register contents when
										// test is halted.

output reg [31:0] p0,p1;  				//output read ports

integer indx;

reg [31:0]mem[0:31];

/*
reg [3:0] dst_addr_lat;					// have to capture dst_addr from previous cycle
reg [15:0] dst_lat;						// have to capture write data from previous cycle
reg we_lat;								// have to capture we from previous cycle
*/

//////////////////////////////////////////////////////////
// Register file will come up uninitialized except for //
// register zero which is hardwired to be zero.       //
///////////////////////////////////////////////////////
initial begin
  mem[0] = 32'd0;					// reg0 is always 0,
end

/*
//////////////////////////////////////////////////
// dst_addr, dst, & we all need to be latched  //
// on clock low of previous cycle to maintain //
// in clock high write of next cycle.        //
//////////////////////////////////////////////
always @(clk,dst_addr,dst,we)
  if (~clk)
    begin
	  dst_addr_lat <= dst_addr;
	  dst_lat      <= dst;
	  we_lat       <= we;
	end
*/

//////////////////////////////////
// RF is written on clock high //
////////////////////////////////
always @(clk,we,dst_reg_WB,dst_reg_data_WB)
  if (clk && we && |dst_reg_WB)
    mem[dst_reg_WB] <= dst_reg_data_WB;
	
//////////////////////////////
// RF is read on clock low //
////////////////////////////
always @(clk,reS,regS)
  if (~clk && reS)
    p0 <= mem[regS];
	
//////////////////////////////
// RF is read on clock low //
////////////////////////////
always @(clk,reT,regT)
  if (~clk && reT)
    p1 <= mem[regT];
	
////////////////////////////////////////
// Dump register contents at program //
// halt for debug purposes          //
/////////////////////////////////////
always @(posedge hlt)
  for(indx=1; indx<31; indx = indx+1)
    $display("R%1h = %h",indx,mem[indx]);
	
endmodule
