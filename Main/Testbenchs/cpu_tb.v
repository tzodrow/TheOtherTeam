`timescale 1ns / 1ps
module cpu_tb();

       reg clk, rst;

    wire[31:0] IF_instr;
    wire[21:0] IF_PC, IF_next_PC;
    wire stall, flush, hlt;
    wire rst_n;

    reg re_hlt;
    reg [7:0] instr_counter;
    wire [21:0] instr_addr;
    wire [21:0] EX_PC, EX_PC_out;

    // Register File
    wire [31:0] regS_data, regT_data;

    //ID Stage Wire Declarations
    wire ID_hlt, ID_use_imm, ID_use_dst_reg, ID_is_branch;
    wire ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero;
    wire[2:0] ID_alu_opcode, ID_branch_conditions;
    wire[4:0] ID_dst_reg, ID_regS_addr, ID_regT_addr;
    wire[16:0] ID_imm;
    wire[21:0] ID_PC, ID_PC_out, ID_branch_addr;
    wire[31:0] ID_instr;
    wire ID_mem_alu_select, ID_mem_we, ID_mem_re, ID_use_sprite_mem;
    wire[21:0] ID_return_PC_addr_reg;

    //sprite wires
    wire ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, ID_sprite_use_dst_reg;
    wire[3:0] ID_sprite_action;
    wire[7:0] ID_sprite_addr;
    wire[13:0] ID_sprite_imm;

    wire IOR;

    wire EX_use_imm;
    wire EX_update_ov, EX_update_neg, EX_update_carry, EX_update_zero;
    wire EX_ov, EX_neg, EX_zero, EX_carry;
    wire [2:0] EX_alu_opcode, EX_branch_conditions;
    wire [16:0] EX_imm;
    wire [31:0] EX_s_data, EX_t_data, EX_ALU_result;
    wire [4:0] EX_dst_reg;
    // sprite wires
    wire EX_sprite_use_imm, EX_sprite_re, EX_sprite_we, EX_sprite_use_dst_reg, EX_mem_alu_select;
    wire [3:0] EX_sprite_action;
    wire [7:0] EX_sprite_addr;
    wire [13:0] EX_sprite_imm;
    wire [31:0] EX_sprite_data;

    wire MEM_sprite_ALU_select, MEM_mem_ALU_select, MEM_flag_ov, MEM_flag_neg, MEM_flag_zero, MEM_re, MEM_we, MEM_use_dst_reg, MEM_use_sprite_mem;
    wire [2:0] MEM_branch_cond;
    wire [4:0] MEM_addr, MEM_dst_reg;
    wire [21:0] MEM_PC, MEM_PC_out;
    wire [31:0] MEM_data, MEM_sprite_data, MEM_instr, MEM_sprite_ALU_result, MEM_mem_result, MEM_ALU_result, MEM_t_data;

    wire [21:0] WB_PC, WB_PC_out;
    wire [31:0] WB_mem_result, WB_sprite_ALU_result, WB_instr;
    wire WB_we;
    wire [4:0] WB_dst_reg;
    wire [31:0] WB_dst_reg_data_WB;
    wire [31:0] reg_WB_data;

    assign stall = ((MEM_dst_reg == ID_regS_addr || MEM_dst_reg == ID_regT_addr) && (MEM_dst_reg != 5'h00)) ? 1 :
        ((EX_dst_reg == ID_regS_addr || EX_dst_reg == ID_regT_addr) && (EX_dst_reg != 5'h00)) ? 1 :
        ((WB_dst_reg == ID_regS_addr || WB_dst_reg == ID_regT_addr) && (WB_dst_reg != 5'h00)) ? 1 : 0;

    assign instr_addr = {{14{1'b0}}, instr_counter};
    assign dst_reg_EX_MEM_ascii = ({3'b000, MEM_dst_reg} + 8'h30);

    assign rst_n = ~rst;
    assign dst_reg_ID_EX_ascii = ({3'b000, EX_dst_reg} + 8'h30);

    pc PC(
        .clk(clk),
        .rst_n(rst_n),
        .nxt_pc(IF_next_PC),
        .curr_pc(IF_PC));

    PC_MUX PC_MUX(
        .pc(IF_PC),
        .br_pc(ID_branch_addr),
        .taken(ID_is_branch),
        .halt(hlt),
        .stall(stall),
        .nxt_pc(IF_next_PC),
        .flush(flush));

	instr_fetch INSTR_FETCH(
		.clk(clk), 
		.rst_n(rst_n),
		.hlt(hlt),
		.stall(stall),
		.addr(IF_PC), 
		.instr(IF_instr));
    //////////////////
    //PIPE: Instruction Fetch - Instruction Decode
    //////////////////
    IF_ID_pipeline_reg IF_ID_pipeline_Test(
        .clk(clk),
        .rst_n(rst_n),
        .hlt(hlt),
        .stall(stall),
        .flush(flush),
        .IF_instr(IF_instr),
        .IF_PC(IF_PC),
        .ID_instr(ID_instr),
        .ID_PC(ID_PC));

    //ID Module Declaration
    instr_decode inst_decTest(
        .clk(clk),
        .rst_n(rst_n),
        .instr(IF_instr),
        .alu_opcode(ID_alu_opcode),
        .imm(ID_imm),
        //.regS_data_ID(ID_s_data),
        //.regT_data_ID(ID_t_data),
        .use_imm(ID_use_imm),
        .use_dst_reg(ID_use_dst_reg),
        .is_branch_instr(ID_is_branch),
        .update_neg(ID_update_neg),
        .update_carry(ID_update_carry),
        .update_overflow(ID_update_ov),
        .update_zero(ID_update_zero),
        .sprite_addr(ID_sprite_addr),
        .sprite_action(ID_sprite_action),
        .sprite_use_imm(ID_sprite_use_imm),
        .sprite_imm(ID_sprite_imm),
        .sprite_re(ID_sprite_re),
        .sprite_we(ID_sprite_we),
        .sprite_use_dst_reg(ID_sprite_use_dst_reg),
        .IOR(IOR),
        .dst_reg(ID_dst_reg),
        .hlt(hlt),
        .PC_in(IF_PC),
        .PC_out(ID_PC_out),
        .dst_reg_WB(WB_dst_reg),
        .dst_reg_data_WB(reg_WB_data),
        .we(WB_use_dst_reg),
        .branch_addr(ID_branch_addr),
        .branch_conditions(ID_branch_conditions),
        .mem_alu_select(ID_mem_alu_select),
        .mem_we(ID_mem_we),
        .mem_re(ID_mem_re),
        .use_sprite_mem(ID_use_sprite_mem),
        .return_PC_addr_reg(ID_return_PC_addr_reg),
        .next_PC(EX_PC_out),
        .re_hlt(re_hlt),
        .addr_hlt(instr_counter[4:0]),
        .regS_addr(ID_regS_addr),
        .regT_addr(ID_regT_addr),
        .EX_ov(EX_ov),
        .EX_neg(EX_neg),
        .EX_zero(EX_zero));

    reg_interface REG_FILE(
       .clk(clk),
        .rst(rst),
        .we(WB_use_dst_reg),
        .regS_addr(ID_regS_addr),
        .regT_addr(ID_regT_addr),
        .regD_addr(WB_dst_reg),
        .regD_data(reg_WB_data),
        .regS_data(regS_data),
        .regT_data(regT_data));

    //////////////////
    //PIPE: Instruction Decode - Execute
    //////////////////
    ID_EX_pipeline_reg ID_EX_pipeline_Test(
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .hlt(hlt),
        .flush(flush),
        .ID_PC(ID_PC),
        .ID_PC_out(ID_PC_out),
        //.ID_s_data(ID_s_data), Remove These (Timing)
        //.ID_t_data(ID_t_data), Remove These (Timing)
        .ID_use_imm(ID_use_imm),
        .ID_use_dst_reg(ID_use_dst_reg),
        .ID_update_neg(ID_update_neg),
        .ID_update_carry(ID_update_carry),
        .ID_update_ov(ID_update_ov),
        .ID_update_zero(ID_update_zero),
        .ID_alu_opcode(ID_alu_opcode),
        .ID_branch_conditions(ID_branch_conditions),
        .ID_imm(ID_imm),
        .ID_dst_reg(ID_dst_reg),
        .ID_sprite_addr(ID_sprite_addr),
        .ID_sprite_action(ID_sprite_action),
        .ID_sprite_use_imm(ID_sprite_use_imm),
        .ID_sprite_re(ID_sprite_re),
        .ID_sprite_we(ID_sprite_we),
        .ID_sprite_use_dst_reg(ID_sprite_use_dst_reg),
        .ID_sprite_imm(ID_sprite_imm),
        .ID_mem_alu_select(ID_mem_alu_select),
        .ID_mem_we(ID_mem_we),
        .ID_mem_re(ID_mem_re),
        .ID_use_sprite_mem(ID_use_sprite_mem),
        .EX_PC(EX_PC),
        .EX_PC_out(EX_PC_out),
        //.EX_s_data(EX_s_data), Remove These (Timing)
        //.EX_t_data(EX_t_data), Remove These (Timing)
        .EX_use_imm(EX_use_imm),
        .EX_use_dst_reg(EX_use_dst_reg),
        .EX_update_neg(EX_update_neg),
        .EX_update_carry(EX_update_carry),
        .EX_update_ov(EX_update_ov),
        .EX_update_zero(EX_update_zero),
        .EX_alu_opcode(EX_alu_opcode),
        .EX_branch_conditions(EX_branch_conditions),
        .EX_imm(EX_imm),
        .EX_dst_reg(EX_dst_reg),
        .EX_sprite_addr(EX_sprite_addr),
        .EX_sprite_action(EX_sprite_action),
        .EX_sprite_use_imm(EX_sprite_use_imm),
        .EX_sprite_re(EX_sprite_re),
        .EX_sprite_we(EX_sprite_we),
        .EX_sprite_use_dst_reg(EX_sprite_use_dst_reg),
        .EX_sprite_imm(EX_sprite_imm),
        .EX_mem_alu_select(EX_mem_alu_select),
        .EX_mem_we(EX_mem_we),
        .EX_mem_re(EX_mem_re),
        .EX_use_sprite_mem(EX_use_sprite_mem));

    //EX Module Declaration
    EX EX(
        .clk(clk),
        .rst_n(rst_n),
        .alu_opcode(EX_alu_opcode),
        .update_flag_ov(EX_update_ov),
        .update_flag_neg(EX_update_neg),
        .update_flag_zero(EX_update_zero),
        .t_data(regT_data),
        .s_data(regS_data),
        .imm(EX_imm),
        .use_imm(EX_use_imm),
        .sprite_action(EX_sprite_action),
        .sprite_imm(EX_sprite_imm),
        .sprite_use_imm(EX_sprite_use_imm),
        .sprite_addr(EX_sprite_addr),
        .sprite_re(EX_sprite_re),
        .sprite_we(EX_sprite_we),
        .sprite_use_dst_reg(EX_sprite_use_dst_reg),
        .ALU_result(EX_ALU_result),
        .sprite_data(EX_sprite_data),
        .flag_ov(EX_ov),
        .flag_neg(EX_neg),
        .flag_zero(EX_zero));

    //////////////////
    //PIPE: Execute - Memory
    //////////////////

    EX_MEM_pipeline_reg ex_mem_pipe_Test(
        .clk(clk),
        .rst_n(rst_n),
        .hlt(hlt),
        .stall(stall),
        .flush(flush),
        .EX_ov(EX_ov),
        .EX_neg(EX_neg),
        .EX_zero(EX_zero),
        .EX_use_dst_reg(EX_use_dst_reg),
        .EX_branch_conditions(EX_branch_conditions),
        .EX_dst_reg(EX_dst_reg),
        .EX_PC(EX_PC),
        .EX_PC_out(EX_PC_out),
        .EX_ALU_result(EX_ALU_result),
        .EX_sprite_data(EX_sprite_data),
        .EX_s_data(EX_s_data),
        .EX_re(EX_mem_re),
        .EX_we(EX_mem_we),
        .EX_mem_ALU_select(EX_mem_alu_select),
        .EX_use_sprite_mem(EX_use_sprite_mem),
        .EX_t_data(EX_t_data),
        .MEM_sprite_ALU_select(MEM_sprite_ALU_select),
        .MEM_mem_ALU_select(MEM_mem_ALU_select),
        .MEM_flag_ov(MEM_flag_ov),
        .MEM_flag_neg(MEM_flag_neg),
        .MEM_flag_zero(MEM_flag_zero),
        .MEM_re(ME_re),
        .MEM_we(MEM_we),
        .MEM_addr(MEM_addr),
        .MEM_PC(MEM_PC),
        .MEM_PC_out(MEM_PC_out),
        .MEM_data(MEM_data),
        .MEM_sprite_data(MEM_sprite_data),
        .MEM_branch_cond(MEM_branch_cond),
        .MEM_use_dst_reg(MEM_use_dst_reg),
        .MEM_use_sprite_mem(MEM_use_sprite_mem),
        .MEM_dst_reg(MEM_dst_reg),
        .MEM_ALU_result(MEM_ALU_result),
        .MEM_t_data(MEM_t_data));

    //////////////////
    //Memory
    //////////////////

    MEM mem_Test(
        .clk(clk),
        .rst_n(rst_n),
        .mem_data(MEM_t_data),
        .addr(EX_ALU_result[21:0]),
        .re(MEM_re),
        .we(MEM_we),
        .ALU_result(MEM_ALU_result),
        .sprite_data(MEM_sprite_data),
        .sprite_ALU_select(MEM_sprite_ALU_select),
        .mem_ALU_select(mem_ALU_select),
        .flag_ov(flag_ov),
        .flag_neg(MEM_flag_neg),
        .flag_zero(MEM_flag_zero),
        .branch_condition(MEM_branch_cond),
       .cache_hit(cache_hit),
        .sprite_ALU_result(MEM_sprite_ALU_result),
        .mem_result(MEM_mem_result),
        .branch_taken(MEM_branch_taken));

    //////////////////
    //PIPE: Memory - Writeback
    //////////////////

    MEM_WB_pipeline_reg mem_wb_reg_testing(
        .clk(clk),
        .rst_n(rst_n),
        .hlt(hlt),
        .stall(stall),
        .flush(flush),
        .MEM_mem_ALU_select(MEM_mem_ALU_select),
        .MEM_PC(MEM_PC),
        .MEM_PC_out(MEM_PC_out),
        .MEM_ALU_result(MEM_sprite_ALU_result),  //TODO: Check the datapath for MEM_ALU_result
        .MEM_sprite_ALU_result(MEM_sprite_ALU_result),
        .MEM_instr(MEM_instr),
        .MEM_use_dst_reg(MEM_use_dst_reg),
        .MEM_dst_reg(MEM_dst_reg),
        .MEM_mem_result(MEM_mem_result),
        .WB_mem_ALU_select(WB_mem_ALU_select),
        .WB_PC(WB_PC),
        .WB_PC_out(WB_PC_out),
        .WB_mem_result(WB_mem_result),
        .WB_sprite_ALU_result(WB_sprite_ALU_result),
        .WB_instr(WB_instr),
        .WB_use_dst_reg(WB_use_dst_reg),
        .WB_dst_reg(WB_dst_reg));

    //////////////////
    //Writeback
    //////////////////

    WB wb_Test(
        .clk(clk),
        .rst_n(rst_n),
        .mem_result(WB_mem_result),
        .sprite_ALU_result(WB_sprite_ALU_result),
        .mem_ALU_select(WB_mem_ALU_select), //Inputs
        .reg_WB_data(reg_WB_data)); //Outputs

        always
              #5 clk <= ~clk;

        initial begin
                clk = 0;
                rst = 1;
		re_hlt = 0;

                @(posedge clk);
                rst = 0;

                repeat(50) @ (posedge clk);
                $stop();
        end
endmodule
