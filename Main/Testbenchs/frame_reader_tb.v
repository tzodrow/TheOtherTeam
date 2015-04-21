`timescale 1ns / 1ps
module frame_reader_tb();

reg [23:0] stm_frame_data;
reg stm_clk, stm_rst_n, stm_full;

wire [23:0] data_out_mon;
wire [16:0] frame_addr_mon;
wire frame_re_mon, we_mon;

frame_reader fr0(
	.clk(stm_clk),
	.rst_n(stm_rst_n),
	.full(stm_full),
	.frame_data(stm_frame_data),
	.frame_addr(frame_addr_mon),
	.frame_re(frame_re_mon),
	.data_out(data_out_mon),
	.we(we_mon)
    );

always
	#5 stm_clk <= ~stm_clk;

initial begin
	stm_clk = 0;
	stm_rst_n = 0;
	stm_full = 0;
	stm_frame_data = 24'h0;

	@(posedge stm_clk);
	stm_rst_n = 1;

	repeat(76850) @ (posedge stm_clk);

	$stop();
end

endmodule