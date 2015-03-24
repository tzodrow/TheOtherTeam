//WRITEBACK MODULE
//Takes in the mem and alu outputs from CPU, and chooses which to store to 
// register memory, if any

module WB(clk, rst_n, hlt, WB_mem_output, WB_alu_output, WB_cntrl_mem_to_reg, WB_reg_write_data);
  input clk, rst_n, hlt, WB_cntrl_mem_to_reg;
  input [15:0] WB_mem_output, WB_alu_output;
  output [15:0] WB_reg_write_data;
  
	//choose either mem or alu output as writeback value
  assign WB_reg_write_data = WB_cntrl_mem_to_reg ? WB_mem_output : WB_alu_output; 
  
endmodule
