module IF_ID_pipeline_reg(clk, rst_n, hlt, stall, flush, IF_instr, ID_instr, IF_PC, ID_PC);

input clk, rst_n, stall, flush, hlt;
input [31:0]IF_instr;
input [21:0]IF_PC;

output reg [31:0]ID_instr;
output reg [21:0]ID_PC;

always @(posedge clk, negedge rst_n)
	if (!rst_n)
	  ID_instr <= 0;
	else if (flush)
	  ID_instr <= 0;
	else if (!stall & !hlt)
	  ID_instr <= IF_instr;

always @(posedge clk, negedge rst_n)
	if (!rst_n)
	  ID_PC <= 0;
	else if (flush)
	  ID_PC <= 0;
	else if (!stall & !hlt)
	  ID_PC <= IF_PC;

endmodule 
