module instr_mem(
		input clk,
		input rst_n,
		input re,
		input [21:0] addr,
		output reg [31:0] instr
		);
	
	
	
	reg [31:0] memory [0:2**22-1];
		
	initial begin
		$readmemb("instr_mem.hex", memory);
	end
	
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			instr <= 32'h0;
		else if(re)
			instr <= memory[addr];
	
	
endmodule