module reg_data_mux(
		input mem_sel,
		input pc_sel,
		input mov_sel,
		input [31:0] mem_data,
		input [31:0] pc_data,
		input [31:0] mov_data,
		input [31:0] alu_data,
		output [31:0] reg_data);
				
		assign reg_data = (mem_sel) ? mem_data :
				(pc_sel) ? pc_data : 
				(mov_sel) ? mov_data : alu_data;
		
endmodule