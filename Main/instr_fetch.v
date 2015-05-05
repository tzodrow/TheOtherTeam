module instr_fetch(
		input clk,
		input rst_n,
		input hlt,
		input [21:0] addr,
		output [31:0] instr
		);
	
	localparam HALT = 32'hf800000000000000;
	
	wire [31:0] mem_instr;
	
	assign instr = (hlt) ? HALT : mem_instr;
	
	instr_mem INSTR_MEM (
		.clka(clk), // input clka
		.addra(addr[6:0]), // input [6 : 0] addra
		.douta(mem_instr) // output [31 : 0] douta
	);
	
endmodule
