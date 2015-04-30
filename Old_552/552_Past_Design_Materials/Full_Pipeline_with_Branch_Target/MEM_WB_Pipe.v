//PIPELINE MODULE, just a bunch of flops

module MEM_WB_Pipe(clk, rst_n, MEM_reg_write_addr, MEM_cntrl_reg_write, MEM_cntrl_mem_to_reg, MEM_mem_output, MEM_alu_result, MEM_hlt, stall,	//INPUTS
                  WB_reg_write_addr, WB_cntrl_reg_write, WB_cntrl_mem_to_reg, WB_mem_output, WB_alu_output, hlt); //OUTPUTS
                            
  input clk, rst_n, MEM_cntrl_reg_write, MEM_cntrl_mem_to_reg, MEM_hlt, stall;
  input [3:0] MEM_reg_write_addr;
  input [15:0] MEM_mem_output, MEM_alu_result;
  
  output reg WB_cntrl_reg_write, WB_cntrl_mem_to_reg, hlt;
  output reg [3:0] WB_reg_write_addr;
  output reg [15:0] WB_mem_output, WB_alu_output;
  
  always @(posedge clk or negedge rst_n) begin
    		//flush all pipes on reset
	if(~rst_n) begin
      WB_reg_write_addr <= 0;
      WB_cntrl_reg_write <= 0;
      WB_cntrl_mem_to_reg <= 0;
      WB_mem_output <= 0;
      WB_alu_output <= 0;
      hlt <= 0;
		//retain previous values on a stall
    end else if(stall) begin
      WB_reg_write_addr <= WB_reg_write_addr;
      WB_cntrl_reg_write <= WB_cntrl_reg_write;
      WB_cntrl_mem_to_reg <= WB_cntrl_mem_to_reg;
      WB_mem_output <= WB_mem_output;
      WB_alu_output <= WB_alu_output;
      hlt <= hlt;
    end else begin
		//otherwise just keep passing values down pipe
      WB_reg_write_addr <= MEM_reg_write_addr;
      WB_cntrl_reg_write <= MEM_cntrl_reg_write;
      WB_cntrl_mem_to_reg <= MEM_cntrl_mem_to_reg;
      WB_mem_output <= MEM_mem_output;
      WB_alu_output <= MEM_alu_result;
      hlt <= MEM_hlt;
    end
  end


endmodule
