module instr_fetch(
		input clk,
		input rst_n,
		input re,
		input [21:0] addr,
		output [31:0] instr
		);
	
	//instr_mem im0(clk, rst_n, re, addr, instr);
	instr_mem20 your_instance_name (
  .clka(clk), // input clka
  .ena(re), 
  .addra(addr[5:0]), // input [5 : 0] addra
  .douta(instr) // output [31 : 0] douta
	);
	

endmodule
