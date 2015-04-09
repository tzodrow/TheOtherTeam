module IF_ID_pipeline_reg(clk, rst_n, hlt, stall, flush, instr_IF, instr_ID, PC_IF, PC_ID);

input clk, rst_n, stall, flush, hlt;
input [31:0]instr_IF;
input [21:0]PC_IF;

output reg [31:0]instr_ID;
output reg [21:0]PC_ID;

always @(posedge clk, negedge rst_n)
	if (!rst_n)
	  instr_ID <= 0;
	else if (flush)
	  instr_ID <= 0;
	else if (!stall & !hlt)
	  instr_ID <= instr_IF;

always @(posedge clk, negedge rst_n)
	if (!rst_n)
	  PC_ID <= 0;
	else if (flush)
	  PC_ID <= 0;
	else if (!stall & !hlt)
	  PC_ID <= PC_IF;

endmodule 
