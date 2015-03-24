module PC(clk, rst_n, hlt, pc_input, pc_output, stall);
	input hlt, rst_n, clk, stall;
	input [15:0] pc_input;
	output reg [15:0] pc_output;
	wire [15:0] nextInstr;	
	reg halt_encountered;

	always@(posedge clk, negedge rst_n) begin
		if(!rst_n)
			pc_output <= 0; 	//reset pc 
		else if(~stall && ~hlt)
			pc_output <= pc_input;	//normal operation, just take next pc every clk
		else
		  pc_output <= pc_output;  //if halt or stall is asserted, freeze the pc value
	end

	//assign nextInstr = hlt ? pc_output : pc_input;
  
endmodule 
