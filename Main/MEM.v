module MEM(clk, rst_n, mem_data, addr, cmd, sprite_data, sprite_ALU_select, mem_ALU_select, flag_ov, flag_neg, flag_zero, branch_condition, //Inputs
		   cache_hit, mem_ALU_WB_select, sprite_ALU_result, mem_result, branch_taken); //Outputs
		   
	input clk ,rst_n, cmd, sprite_ALU_select, mem_ALU_select, flag_ov, flag_neg, flag_zero;
	input [2:0] branch_condition;
	input [31:0] mem_data, sprite_data;
	input [21:0] addr;
	output cache_hit, mem_ALU_WB_select, branch_taken;
	output [31:0] sprite_ALU_result, mem_result;
	
	//cmd 1 = write enable, 0 = read enable
	wire re;
	wire we;
	
	//branch opcodes
	localparam NEQ = 3'b000;
	localparam EQ = 3'b001;
	localparam GT = 3'b010;
	localparam LT = 3'b011;
	localparam GTE = 3'b100;
	localparam LTE = 3'b101;
	localparam OVFL = 3'b110;
	localparam UNCOND = 3'b111;
	
	always @(*) begin
		if(cmd) begin
			re = 0;
			we = 1;
		end
		else begin
			re = 1;
			we = 0;
		end
	end 
	//Simple memory 
	mainMem(.clk(clk),.addr(addr),.re(re),.we(we),.wrt_data(mem_data),.rd_data(mem_result);
	
	
	//This will be for the memory with cache	
	/*mainMemory mainMem(.clk(clk),.rst_n(rst_n),.data(mem_data),.addr(addr),.cmd(cmd), //Inputs
					 .result(mem_result),.cache_hit(cache_hit)); //Outputs*/
	
	assign sprite_ALU_result = (sprite_ALU_select) ? mem_data : sprite_data;
	
	assign mem_ALU_WB_select = mem_ALU_select;
	
	//Flag Check
	assign branch_taken = (branch_condition == NEQ) ? !flag_zero :
							(branch_condition == EQ) ? flag_zero :
							(branch_condition == GT) ? ({flag_zero, flag_neg} == 2'b00) :
							(branch_condition == LT) ? flag_neg :
							(branch_condition == GTE) ? !flag_neg :
							(branch_condition == LTE) ? (flag_neg | flag_zero) :
							(branch_condition == OVFL) ? flag_ov :
							(branch_condition == UNCOND) ? 1 : 
							0;
endmodule
