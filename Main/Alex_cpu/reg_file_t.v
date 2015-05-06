module register_file_T(
  input clka, // input clka
  input wea, // input [0 : 0] wea
  input [4:0] addra, // input [4 : 0] addra
  input [31:0] dina, // input [31 : 0] dina
  output reg [31:0] douta, // output [31 : 0] douta
  input clkb,// input clkb
  input enb,
  input [4:0] addrb, // input [4 : 0] addrb
  input [31:0] dinb, // input [31 : 0] dinb
  output reg [31:0] doutb // output [31 : 0] doutb
);
//////////////////////////////////////////////////////////////////
// Triple ported register file.  Two read ports (p0 & p1), and //
// one write port (dst).  Data is written on clock high, and  //
// read on clock low //////////////////////////////////////////
//////////////////////

reg [31:0]mem[0:2**5-1]; //32, 32-bit registers in the reg file

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
  //mem[1] = 32'd1;
 // mem[2] = 32'd2;
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
always @(clka,wea,addra,dina)
  if (clka && wea && |addra)
    mem[addra] <= dina;
	
//////////////////////////////
// RF is read on clock low //
////////////////////////////
always @(clkb,enb,addrb)
  if (~clkb && enb)
    doutb <= mem[addrb];
	
//////////////////////////////
// RF is read on clock low //
////////////////////////////
always @(clka,addra)
  if (~clka)
    douta <= mem[addra];
	
////////////////////////////////////////
// Dump register contents at program //
// halt for debug purposes          //
/////////////////////////////////////

/*
always @(posedge hlt)
   for(indx=1; indx<31; indx = indx+1)
     $display("R%1h = %h",indx,mem[indx]);
*/
	
endmodule