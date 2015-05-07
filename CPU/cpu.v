module cpu(
		input clk,
		input rst,
		output hlt);
	
	// Program Counter Wires
	wire [21:0] nxt_pc, pc;
	
	// Instruction Decode Wires
	wire ID_pc_reg_sel, ID_pc_immd_sel, ID_alu_immd_sel;
	wire ID_mem_we, ID_wb_mem_sel, ID_wb_pc_sel, ID_wb_we, ID_wb_mov_sel, ID_hlt;
	wire [1:0] ID_move_byte_sel;
	wire [7:0] ID_move_byte;
	wire [2:0] ID_alu_op;
	wire [16:0] ID_alu_immd;
	wire [21:0] ID_pc_immd, ID_wb_pc_data;
	wire [4:0] ID_dst_reg;
	
	// Register Wires
	wire [4:0] reg1_addr, reg2_addr;
	wire [31:0] reg1_data, reg2_data;
	wire [31:0] reg_data;
	
	// Execute Wires
	wire [31:0] EX_mov_data, EX_alu_data;
	wire EX_alu_immd_sel, EX_pc_immd_sel, EX_pc_reg_sel;
	wire EX_mem_we, EX_wb_mem_sel, EX_wb_pc_sel, EX_wb_we, EX_wb_mov_sel, EX_hlt;
	wire [16:0] EX_alu_immd;
	wire [2:0] EX_alu_op;
	wire [1:0] EX_move_byte_sel;
	wire [7:0] EX_move_byte;
	wire [21:0] EX_pc_immd, EX_wb_pc_data;
	wire [4:0] EX_dst_reg;
	
	// Memory Wires
	wire [31:0] MEM_alu_data, MEM_sw_data, MEM_rd_data, MEM_mov_data;
	wire MEM_mem_we, MEM_wb_mem_sel, MEM_wb_pc_sel, MEM_wb_we, MEM_wb_mov_sel;
	wire MEM_hlt;
	wire [4:0] MEM_dst_reg;
	wire [21:0] MEM_wb_pc_data;
	
	// Writeback Wires
	wire WB_wb_mem_sel, WB_wb_pc_sel, WB_wb_we, WB_wb_mov_sel;
	wire [4:0] WB_dst_reg;
	wire [31:0] WB_mov_data, WB_alu_data, WB_rd_data, WB_dst_data;
	wire [21:0] WB_wb_pc_data;
	
	pc PC(
		.clk(clk),
		.rst(rst),
		.nxt_pc(nxt_pc),
		.pc(pc));
	
	pc_mux PC_MUX(
		.curr_pc(pc),
		.immd(EX_pc_immd),
		.reg_data(reg1_data[21:0]),
		.reg_sel(EX_pc_reg_sel),
		.immd_sel(EX_pc_immd_sel),
		.nxt_pc(nxt_pc));
	
	instruction_fetch IF(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.instr(IF_instr));
	
	IF_ID_pipeline IF_ID_PIPE(
		.clk(clk),
		.rst(rst),
		.IF_wb_pc_data(pc),
		.ID_wb_pc_data(ID_wb_pc_data));
	
	id ID(
		.clk(clk),
		.rst(rst),
		.instr(IF_instr),
		.reg1_addr(reg1_addr),
		.reg2_addr(reg2_addr),
		.dst_reg(ID_dst_reg),
		.pc_reg_sel(ID_pc_reg_sel), // Select the Register data as the PC
		.pc_immd_sel(ID_pc_immd_sel), // Select the Immediate data as the PC
		.alu_immd_sel(ID_alu_immd_sel), // Select the Immediate Value in the ALU
		.mem_we(ID_mem_we), // Write Enable signal for the write to Memory
		.wb_mem_sel(ID_wb_mem_sel), // Select to write back the data from the Memory instead of ALU
		.wb_pc_sel(ID_wb_pc_sel), // Select to write back the data from the PC instead of ALU
		.wb_we(ID_wb_we), // Write Enable signal for the WB to Register File
		.wb_mov_sel(ID_wb_mov_sel), // Select to write back the data from move instructions
		.hlt_out(ID_hlt),
		.mov_byte_sel(ID_move_byte_sel), // Select for which byte is written on a MOVi
		.mov_byte(ID_move_byte),
		.alu_op(ID_alu_op),
		.alu_immd(ID_alu_immd),
		.pc_immd(ID_pc_immd));
	
	reg_data_mux REG_MUX(
		.mem_sel(WB_wb_mem_sel),
		.pc_sel(WB_wb_pc_sel),
		.mov_sel(WB_wb_mov_sel),
		.mem_data(WB_rd_data),
		.pc_data({{10{1'b0}},WB_wb_pc_data}),
		.mov_data(WB_mov_data),
		.alu_data(WB_alu_data),
		.reg_data(WB_dst_data));
	
	// Simulation Register File
	rf RF(
		.clk(clk),
		.p0_addr(reg1_addr),
		.p1_addr(reg2_addr),
		.p0(reg1_data),
		.p1(reg2_data),
		.dst_addr(WB_dst_reg),
		.dst(WB_dst_data),
		.we(WB_wb_we));
	
	ID_EX_pipeline ID_EX_PIPE(
		.clk(clk),
		.rst(rst),
		.ID_pc_reg_sel(ID_pc_reg_sel),
		.ID_pc_immd_sel(ID_pc_immd_sel),
		.ID_alu_immd_sel(ID_alu_immd_sel),
		.ID_mem_we(ID_mem_we),
		.ID_wb_mem_sel(ID_wb_mem_sel),
		.ID_wb_pc_sel(ID_wb_pc_sel),
		.ID_wb_we(ID_wb_we),
		.ID_wb_mov_sel(ID_wb_mov_sel),
		.ID_hlt(ID_hlt),
		.ID_move_byte_sel(ID_move_byte_sel),
		.ID_move_byte(ID_move_byte),
		.ID_alu_op(ID_alu_op),
		.ID_alu_immd(ID_alu_immd),
		.ID_pc_immd(ID_pc_immd),
		.ID_dst_reg(ID_dst_reg),
		.ID_wb_pc_data(ID_wb_pc_data),
		.EX_pc_reg_sel(EX_pc_reg_sel),
		.EX_pc_immd_sel(EX_pc_immd_sel),
		.EX_alu_immd_sel(EX_alu_immd_sel),
		.EX_mem_we(EX_mem_we),
		.EX_wb_mem_sel(EX_wb_mem_sel),
		.EX_wb_pc_sel(EX_wb_pc_sel),
		.EX_wb_we(EX_wb_we),
		.EX_wb_mov_sel(EX_wb_mov_sel),
		.EX_hlt(EX_hlt),
		.EX_move_byte_sel(EX_move_byte_sel),
		.EX_move_byte(EX_move_byte),
		.EX_alu_op(EX_alu_op),
		.EX_alu_immd(EX_alu_immd),
		.EX_pc_immd(EX_pc_immd),
		.EX_dst_reg(EX_dst_reg),
		.EX_wb_pc_data(EX_wb_pc_data));
		
	mov_mux MOV_MUX(
		.byte_sel(EX_move_byte_sel),
		.byte_data(EX_move_byte),
		.reg_data(reg1_data),
		.mov_data(EX_mov_data));

	
	alu ALU(
		.clk(clk),
		.rst(rst),
		.immd_sel(EX_alu_immd_sel),
		.reg1_data(reg1_data),
		.reg2_data(reg2_data),
		.immd(EX_alu_immd),
		.op(EX_alu_op),
		.data_out(EX_alu_data));
	
	EX_MEM_pipeline EX_MEM_PIPE(
		.clk(clk),
		.rst(rst),
		.EX_mem_we(EX_mem_we),
		.EX_wb_mem_sel(EX_wb_mem_sel),
		.EX_wb_pc_sel(EX_wb_pc_sel),
		.EX_wb_we(EX_wb_we),
		.EX_wb_mov_sel(EX_wb_mov_sel),
		.EX_hlt(EX_hlt),
		.EX_dst_reg(EX_dst_reg),
		.EX_mov_data(EX_mov_data),
		.EX_alu_data(EX_alu_data),
		.EX_sw_data(reg2_data),
		.EX_wb_pc_data(EX_wb_pc_data),
		.MEM_mem_we(MEM_mem_we),
		.MEM_wb_mem_sel(MEM_wb_mem_sel),
		.MEM_wb_pc_sel(MEM_wb_pc_sel),
		.MEM_wb_we(MEM_wb_we),
		.MEM_wb_mov_sel(MEM_wb_mov_sel),
		.MEM_hlt(MEM_hlt),
		.MEM_dst_reg(MEM_dst_reg),
		.MEM_mov_data(MEM_mov_data),
		.MEM_alu_data(MEM_alu_data),
		.MEM_sw_data(MEM_sw_data),
		.MEM_wb_pc_data(MEM_wb_pc_data));
		
	main_mem MAIN_MEM(
		.clk(clk),
		.rst(rst),
		.addr(MEM_alu_data[21:0]),
		.we(MEM_mem_we),
		.wdata(MEM_sw_data),
		.rd_data(MEM_rd_data));
	
	MEM_WB_pipeline MEM_WB_PIPE(
		.clk(clk),
		.rst(rst),
		.MEM_wb_mem_sel(MEM_wb_mem_sel),
		.MEM_wb_pc_sel(MEM_wb_pc_sel),
		.MEM_wb_we(MEM_wb_we),
		.MEM_wb_mov_sel(MEM_wb_mov_sel),
		.MEM_hlt(MEM_hlt),
		.MEM_dst_reg(MEM_dst_reg),
		.MEM_mov_data(MEM_mov_data),
		.MEM_alu_data(MEM_alu_data),
		.MEM_rd_data(MEM_rd_data),
		.MEM_wb_pc_data(MEM_wb_pc_data),
		.WB_wb_mem_sel(WB_wb_mem_sel),
		.WB_wb_pc_sel(WB_wb_pc_sel),
		.WB_wb_we(WB_wb_we),
		.WB_wb_mov_sel(WB_wb_mov_sel),
		.WB_hlt(hlt),
		.WB_dst_reg(WB_dst_reg),
		.WB_mov_data(WB_mov_data),
		.WB_alu_data(WB_alu_data),
		.WB_rd_data(WB_rd_data),
		.WB_wb_pc_data(WB_wb_pc_data));
		
endmodule