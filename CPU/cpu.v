module cpu(
		input clk,
		input rst);
	
	// Program Counter Wires
	wire [21:0] nxt_pc, pc;
	
	// Instruction Decode Wires
	wire ID_pc_reg_sel, ID_pc_immd_sel, ID_alu_immd_sel, ID_mem_addr_sel, ID_mem_data_sel;
	wire ID_mem_we, ID_wb_mem_sel, ID_wb_pc_sel, ID_wb_we, ID_wb_mov_sel, ID_hlt;
	wire [1:0] ID_move_byte_sel;
	wire [7:0] ID_move_byte;
	wire [2:0] ID_alu_op;
	wire [16:0] ID_alu_immd;
	wire [21:0] ID_pc_immd;
	wire [4:0] ID_dst_reg;
	
	// Execute Wires
	wire [31:0] alu_data_out;
	wire EX_alu_immd_sel, EX_pc_immd_sel, EX_pc_reg_sel;
	wire [16:0] EX_alu_immd;
	wire [2:0] EX_alu_op;
	wire [1:0] EX_move_byte_sel;
	wire [7:0] EX_move_byte;
	wire [21:0] EX_pc_immd;
	
	// ALU Wires
	
	pc PC(
		.clk(clk),
		.rst(rst),
		.nxt_pc(nxt_pc),
		.pc(pc));
	
	pc_mux PC_MUX(
		.curr_pc(pc),
		.immd(EX_pc_immd),
		input [21:0] reg_data,
		.reg_sel(EX_pc_reg_sel),
		.immd_sel(EX_pc_immd_sel),
		.nxt_pc(nxt_pc));
	
	instruction_fetch IF(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.instr(IF_instr));
	
	id ID(
			.clk(clk),
			.rst(rst),
			.instr(IF_instr),
			output [4:0] reg1_addr,
			output [4:0] reg2_addr,
			.dst_reg(ID_dst_reg),
			.pc_reg_sel(ID_pc_reg_sel), // Select the Register data as the PC
			.pc_immd_sel(ID_pc_immd_sel), // Select the Immediate data as the PC
			.alu_immd_sel(ID_alu_immd_sel), // Select the Immediate Value in the ALU
			.mem_addr_sel(ID_mem_addr_sel), // Select the ALU result as the mem addresss
			.mem_data_sel(ID_mem_data_sel), // Select the Register data as the mem data
			.mem_we(ID_mem_we), // Write Enable signal for the write to Memory
			.wb_mem_sel(ID_wb_mem_sel), // Select to write back the data from the Memory instead of ALU
			.wb_pc_sel(ID_wb_pc_sel), // Select to write back the data from the PC instead of ALU
			.wb_we(ID_wb_we), // Write Enable signal for the WB to Register File
			.wb_mov_sel(ID_wb_mov_sel), // Select to write back the data from move instructions
			.mov_immd_sel(ID_mov_immd_sel), // Select to write back a byte of data to a Register
			.hlt_out(ID_hlt),
			.mov_byte_sel(ID_move_byte_sel), // Select for which byte is written on a MOVi
			.mov_byte(ID_move_byte),
			.alu_op(ID_alu_op),
			.alu_immd(ID_alu_immd),
			.pc_immd(ID_pc_immd));
	
	module ID_EX_pipeline(
		.clk(clk),
		.rst(rst),
		.ID_pc_reg_sel(ID_pc_reg_sel),
		.ID_pc_immd_sel(ID_pc_immd_sel),
		.ID_alu_immd_sel(ID_alu_immd_sel),
		.ID_mem_addr_sel(ID_mem_addr_sel),
		.ID_mem_data_sel(ID_mem_data_sel),
		.ID_mem_we(ID_mem_we),
		.ID_wb_mem_sel(ID_wb_mem_sel),
		.ID_wb_pc_sel(ID_wb_pc_sel),
		.ID_wb_we(ID_wb_we),
		.ID_wb_mov_sel(ID_wb_mov_sel),
		.ID_mov_immd_sel(ID_mov_immd_sel),
		.ID_hlt(ID_hlt),
		.ID_move_byte_sel(ID_move_byte_sel),
		.ID_move_byte(ID_move_byte),
		.ID_alu_op(ID_alu_op),
		.ID_alu_immd(ID_alu_immd),
		.ID_pc_immd(ID_pc_immd),
		.ID_dst_reg(ID_dst_reg),
		.EX_pc_reg_sel(EX_pc_reg_sel),
		.EX_pc_immd_sel(EX_pc_immd_sel),
		.EX_alu_immd_sel(EX_alu_immd_sel),
		output reg EX_mem_addr_sel,
		output reg EX_mem_data_sel,
		output reg EX_mem_we,
		output reg EX_wb_mem_sel,
		output reg EX_wb_pc_sel,
		output reg EX_wb_we,
		output reg EX_wb_mov_sel,
		output reg EX_mov_immd_sel,
		output reg EX_hlt,
		.EX_move_byte_sel(EX_move_byte_sel),
		.EX_move_byte(EX_move_byte),
		.EX_alu_op(EX_alu_op),
		.EX_alu_immd(EX_alu_immd),
		.EX_pc_immd(EX_pc_immd),
		output reg [4:0] EX_dst_reg);
		
		mov_mux MOV_MUX(
		.byte_sel(EX_move_byte_sel),
		.byte_data(EX_move_byte),
		input [31:0] reg_data,
		output [31:0] mov_data);

	
		alu ALU(
				.clk(clk),
				.rst(rst),
				.immd_sel(EX_alu_immd_sel),
				input [31:0] reg1_data,
				input [31:0] reg2_data,
				.immd(EX_alu_immd),
				.op(EX_alu_op),
				output [31:0] data_out);

	
endmodule