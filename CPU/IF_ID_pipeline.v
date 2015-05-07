module IF_ID_pipeline(
		input clk,
		input rst,
		input [21:0] IF_wb_pc_data,
		output reg [21:0] ID_wb_pc_data);
	
	always @ (posedge clk, posedge rst)
		if(rst)
			ID_wb_pc_data <= 0;
		else
			ID_wb_pc_data <= pc + 1;
		
endmodule