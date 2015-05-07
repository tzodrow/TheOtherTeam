module ID_EX_pipeline(
		input clk,
		input rst,
		input ID_pc_reg_sel,
		input ID_pc_immd_sel,
		input ID_alu_immd_sel,
		input ID_mem_we,
		input ID_wb_mem_sel,
		input ID_wb_pc_sel,
		input ID_wb_we,
		input ID_wb_mov_sel,
		input ID_hlt,
		input [1:0] ID_move_byte_sel,
		input [7:0] ID_move_byte,
		input [2:0] ID_alu_op,
		input [16:0] ID_alu_immd,
		input [21:0] ID_pc_immd,
		input [4:0] ID_dst_reg,
		input [21:0] ID_wb_pc_data,
		output reg EX_pc_reg_sel,
		output reg EX_pc_immd_sel,
		output reg EX_alu_immd_sel,
		output reg EX_mem_we,
		output reg EX_wb_mem_sel,
		output reg EX_wb_pc_sel,
		output reg EX_wb_we,
		output reg EX_wb_mov_sel,
		output reg EX_hlt,
		output reg [1:0] EX_move_byte_sel,
		output reg [7:0] EX_move_byte,
		output reg [2:0] EX_alu_op,
		output reg [16:0] EX_alu_immd,
		output reg [21:0] EX_pc_immd,
		output reg [4:0] EX_dst_reg, 
		output reg [21:0] EX_wb_pc_data);
	
	always @ (posedge clk, posedge rst)
		if(rst) begin
			EX_pc_reg_sel <= 0;
			EX_pc_immd_sel <= 0;
			EX_alu_immd_sel <= 0;
			EX_mem_addr_sel <= 0;
			EX_mem_data_sel <= 0;
			EX_mem_we <= 0;
			EX_wb_mem_sel <= 0;
			EX_wb_pc_sel <= 0;
			EX_wb_we <= 0;
			EX_wb_mov_sel <= 0;
			EX_hlt <= 0;
			EX_move_byte_sel <= 0;
			EX_move_byte <= 0;
			EX_alu_op <= 0;
			EX_alu_immd <= 0;
			EX_pc_immd <= 0;
			EX_dst_reg <= 0;
			EX_wb_pc_data <= 0;
		end
		else begin
			EX_pc_reg_sel <= ID_pc_reg_sel;
			EX_pc_immd_sel <= ID_pc_immd_sel;
			EX_alu_immd_sel <= ID_alu_immd_sel;
			EX_mem_addr_sel <= ID_mem_addr_sel;
			EX_mem_data_sel <= ID_mem_data_sel;
			EX_mem_we <= ID_mem_we;
			EX_wb_mem_sel <= ID_wb_mem_sel;
			EX_wb_pc_sel <= ID_wb_pc_sel;
			EX_wb_we <= ID_wb_we;
			EX_wb_mov_sel <= ID_wb_mov_sel;
			EX_hlt <= ID_hlt;
			EX_move_byte_sel <= ID_move_byte_sel;
			EX_move_byte <= ID_move_byte;
			EX_alu_op <= ID_alu_op;
			EX_alu_immd <= ID_alu_immd;
			EX_pc_immd <= ID_pc_immd;
			EX_dst_reg <= ID_dst_reg;
			EX_wb_pc_data <= ID_wb_pc_data;
		end

			
endmodule