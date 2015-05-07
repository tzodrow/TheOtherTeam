module MEM_WB_pipeline(
		input clk,
		input rst,
		input MEM_wb_mem_sel,
		input MEM_wb_pc_sel,
		input MEM_wb_we,
		input MEM_wb_mov_sel,
		input MEM_hlt,
		input [4:0] MEM_dst_reg,
		input [31:0] MEM_mov_data,
		input [31:0] MEM_alu_data,
		input [31:0] MEM_rd_data,
		input [21:0] MEM_wb_pc_data,
		output reg WB_wb_mem_sel,
		output reg WB_wb_pc_sel,
		output reg WB_wb_we,
		output reg WB_wb_mov_sel,
		output reg WB_hlt,
		output reg [4:0] WB_dst_reg,
		output reg [31:0] WB_mov_data,
		output reg [31:0] WB_alu_data, 
		output reg [31:0] WB_rd_data,
		output reg [21:0] WB_wb_pc_data);
	
	always @ (posedge clk, posedge rst)
		if(rst) begin
			WB_wb_mem_sel <= 0;
			WB_wb_pc_sel <= 0;
			WB_wb_we <= 0;
			WB_wb_mov_sel <= 0;
			WB_hlt <= 0;
			WB_dst_reg <= 0;
			WB_mov_data <= 0;
			WB_alu_data	<= 0;
			WB_rd_data <= 0;
			WB_wb_pc_data <= 0;
		end
		else begin
			WB_wb_mem_sel <= MEM_wb_mem_sel;
			WB_wb_pc_sel <= MEM_wb_pc_sel;
			WB_wb_we <= MEM_wb_we;
			WB_wb_mov_sel <= MEM_wb_mov_sel;
			WB_hlt <= MEM_hlt;
			WB_dst_reg <= MEM_dst_reg;
			WB_mov_data <= MEM_mov_data;
			WB_alu_data	<= MEM_alu_data;
			WB_rd_data <= MEM_rd_data;
			WB_wb_pc_data <= MEM_wb_pc_data;
		end
		
endmodule