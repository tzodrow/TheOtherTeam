module mov_mux(
		input [1:0] byte_sel,
		input [7:0] byte_data,
		input [31:0] reg_data,
		output [31:0] mov_data);
	
	always @ (*) begin
		case(byte_sel)
			2'b00 : assign mov_data = {reg_data[31:8], byte_data};
			2'b01 : assign mov_data = {reg_data[31:16], byte_data, reg_data[7:0]};
			2'b10 : assign mov_data = {reg_data[31:24], byte_data, reg_data[15:0]};
			2'b11 : assign mov_data = {byte_data, reg_data[23:0]};
			default : assign mov_data = 0;
		endcase
	end
	
endmodule