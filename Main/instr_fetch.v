module instr_fetch(
		input clk,
		input rst_n,
		input re,
		input [21:0] addr,
		output [31:0] instr
		);
	
	//instr_mem im0(clk, rst_n, re, addr, instr);
	instr_mem16 your_instance_name (
  .clka(clk), // input clka
  .addra(addr[6:0]), // input [6 : 0] addra
  .douta(instr) // output [31 : 0] douta
	);
	

endmodule
