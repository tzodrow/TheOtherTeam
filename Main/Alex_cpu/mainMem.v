module main_mem3(
  input clka, // input clka
  input rsta,
  input ena, // input ena
  input wea, // input [0 : 0] wea
  input [4:0] addra,//addr[4:0]), // input [4 : 0] addra
  input [31:0] dina, // input [31 : 0] dina
  output reg [31:0] douta // output [31 : 0] douta
);

/////////////////////////////////////////////////////////
// Data memory.  Single ported, can read or write but //
// not both in a single cycle.  Precharge on clock   //
// high, read/write on clock low.                   //
/////////////////////////////////////////////////////

reg [31:0]data_mem[0:65535];

///////////////////////////////////////////////
// Model read, data is latched on clock low //
/////////////////////////////////////////////
always @(addra,ena,clka)
  if (~clka && ena && ~wea)
    douta <= data_mem[addra];
	
////////////////////////////////////////////////
// Model write, data is written on clock low //
//////////////////////////////////////////////
always @(addra,wea,clka, ena)
  if (~clka && wea && ena)
    data_mem[addra] <= dina;

endmodule