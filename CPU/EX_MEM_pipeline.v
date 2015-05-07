module EX_MEM_pipeline(
		input clk,
		input rst,
		input EX_mem_we,
		input EX_wb_mem_sel,
		input EX_wb_pc_sel,
		input EX_wb_we,
		input EX_wb_mov_sel,
		input EX_hlt,
		input [4:0] EX_dst_reg,
		input [31:0] EX_mov_data,
		input [31:0] EX_alu_data,
		input [31:0] EX_sw_data,
		input [21:0] EX_wb_pc_data,
		output reg MEM_mem_we,
		output reg MEM_wb_mem_sel,
		output reg MEM_wb_pc_sel,
		output reg MEM_wb_we,
		output reg MEM_wb_mov_sel,
		output reg MEM_hlt,
		output reg [4:0] MEM_dst_reg,
		output reg [31:0] MEM_mov_data,
		output reg [31:0] MEM_alu_data,
		output reg [31:0] MEM_sw_data,
		output reg [21:0] MEM_wb_pc_data);
	
	always @ (posedge clk, posedge rst) begin
		if(rst) begin
			MEM_mem_we <= 0;
			MEM_wb_mem_sel <= 0;
			MEM_wb_pc_sel <= 0;
			MEM_wb_we <= 0;
			MEM_wb_mov_sel <= 0;
			MEM_hlt <= 0;
			MEM_dst_reg <= 0;
			MEM_mov_data <= 0;
			MEM_alu_data <= 0;
			MEM_sw_data <= 0;
			MEM_wb_pc_data <= 0;
		end
		else begin
			MEM_mem_we <= EX_mem_we;
			MEM_wb_mem_sel <= EX_wb_mem_sel;
			MEM_wb_pc_sel <= EX_wb_pc_sel;
			MEM_wb_we <= EX_wb_we;
			MEM_wb_mov_sel <= EX_wb_mov_sel;
			MEM_hlt <= EX_hlt;
			MEM_dst_reg <= EX_dst_reg;
			MEM_mov_data <= EX_mov_data;
			MEM_alu_data <= EX_alu_data;
			MEM_sw_data <= EX_sw_data;
			MEM_wb_pc_data <= EX_wb_pc_data;
		end
	end
endmodule	