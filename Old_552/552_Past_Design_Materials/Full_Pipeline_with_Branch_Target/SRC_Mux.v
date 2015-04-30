//This module chooses whether src1 should come from the register file 
// or be sign extended immediate

module SRC_Mux(src1, src1sel, immediate, regSRC);
	input wire [15:0] regSRC;
	input wire [7:0] immediate;
	input wire src1sel;
	output wire [15:0] src1;
	
	assign src1 = src1sel ? {{8{immediate[7]}}, immediate} : regSRC ;  //choose between sign extended immediate or register source

endmodule
