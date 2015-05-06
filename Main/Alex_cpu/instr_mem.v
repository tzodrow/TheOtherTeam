module instr_mem20(
	  input clka, // input clka
	  input ena, 
	  input [5:0] addra, // input [5 : 0] addra
	  output reg [31:0] douta // output [31 : 0] douta
	);
	
	
	
	reg [31:0] memory [0:2**22-1];
		
	initial begin
		$readmemb("instr_mem.hex", memory);
	end
	
	always @ (posedge clka)
		if(ena)
			douta <= memory[addra];
	
	
endmodule