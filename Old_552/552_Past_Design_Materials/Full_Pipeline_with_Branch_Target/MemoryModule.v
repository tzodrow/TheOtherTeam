//ALL MEMORY OPERATIONS ARE PERFORMED THROUGH THIS MODULE
//Contains: Both the I and D caches, and a cache controller that contains 
//          unified memory

module MemoryModule(clk, rst_n, i_addr, i_re, d_addr, d_re, d_sw_we, d_write_data,  //INPUTS
                            i_instr, i_rdy_out, d_rd_word, d_rdy_out);      //OUTPUTS
  
  input clk, rst_n, d_re, d_sw_we, i_re;    
  input [15:0] i_addr, d_addr, d_write_data;
  
  output i_rdy_out, d_rdy_out;
  output [15:0] i_instr, d_rd_word;
  
  wire i_we, i_dirty, d_dirty, d_hit, i_hit, i_rdy, d_controlled_we, d_controlled_re, d_rdy, cache_write_stall;
  wire [7:0] i_tag_out, d_tag_out;
  wire [13:0] prefetch_addr, i_addr_input;
  wire [15:0] i_cache_rd_data, i_u_mem_rd_data, d_cache_rd_data, d_u_mem_rd_data;
  wire [63:0] i_rd_data, u_rd_data, d_rd_data, d_wr_data, d_writeback, d_load_write;
  
    //cache controller contains unified memory
  cacheController controller(clk, rst_n, i_rdy, i_re, i_addr, d_addr, d_re, d_sw_we, d_tag_out, d_hit, d_dirty, d_rd_data,
                             i_we, u_rd_data, d_controlled_we, d_controlled_re, cache_write_stall, prefetch_addr);
                             

    //Icache can never write dirty data, so we default dirty-bit to 0
  cache I_Cache(clk, rst_n, i_addr_input, u_rd_data, 1'b0, i_we, i_re, i_rd_data, i_tag_out, i_hit, i_dirty);
                   
  cache D_Cache(clk, rst_n, d_addr[15:2], d_wr_data, d_sw_we, d_controlled_we, d_controlled_re, d_rd_data, d_tag_out, d_hit, d_dirty);
  
  assign i_addr_input = (cache_write_stall) ? prefetch_addr : i_addr[15:2];
  
  assign i_rdy = (!i_re) ? 1'b1 : i_hit;     //when reading, icache is only ready when icache hits
  
  assign i_rdy_out = (cache_write_stall) ? 1'b0 :
                     (i_we) ? 1'b1 : i_rdy;
  
  assign d_rdy_out =  (d_controlled_we) ? 1'b1 : d_rdy;
  
  assign d_rdy = (d_re || d_sw_we) ? d_hit : 1'b1; //when reading or writing, dcache is only ready when dcache hits
  
  
  //i_instr gets correct word value (chosen below) based on either 
  assign i_instr = i_we ? i_u_mem_rd_data : i_cache_rd_data; 
  
  //mux that outputs correct word using index from 4-word long i_rd_data
  assign i_cache_rd_data = (i_addr[1:0] == 2'b00) ? i_rd_data[15:0] :   
                           (i_addr[1:0] == 2'b01) ? i_rd_data[31:16] :
                           (i_addr[1:0] == 2'b10) ? i_rd_data[47:32] :
                            i_rd_data[63:48];
  
  //mux used for when data is being retrieved from main memory               
  assign i_u_mem_rd_data = (i_addr[1:0] == 2'b00) ? u_rd_data[15:0] :   
                           (i_addr[1:0] == 2'b01) ? u_rd_data[31:16] :
                           (i_addr[1:0] == 2'b10) ? u_rd_data[47:32] :
                            u_rd_data[63:48];
  

  //mux that outputs correct word using index from 4-word long d_rd_data
  assign d_rd_word = (d_controlled_we) ? d_u_mem_rd_data : d_cache_rd_data;
  
  assign d_u_mem_rd_data = (d_addr[1:0] == 2'b00) ? d_wr_data[15:0] :
                           (d_addr[1:0] == 2'b01) ? d_wr_data[31:16] :
                           (d_addr[1:0] == 2'b10) ? d_wr_data[47:32] :
                            d_wr_data[63:48];
    
  assign d_cache_rd_data = (d_addr[1:0] == 2'b00) ? d_rd_data[15:0] :
                           (d_addr[1:0] == 2'b01) ? d_rd_data[31:16] :
                           (d_addr[1:0] == 2'b10) ? d_rd_data[47:32] :
                            d_rd_data[63:48];
                 
  //CHANGED --  mux that inserts the word of data to write into the correct spot of d_rd_data using index                     
  assign d_load_write = (d_addr[1:0] == 2'b00) ? {u_rd_data[63:16], d_write_data} :
                        (d_addr[1:0] == 2'b01) ? {u_rd_data[63:32], d_write_data, u_rd_data[15:0]} :
                        (d_addr[1:0] == 2'b10) ? {u_rd_data[63:48], d_write_data, u_rd_data[31:0]} : 
                        {d_write_data, u_rd_data[47:0]};  
    
  assign d_writeback = (d_addr[1:0] == 2'b00) ? {d_rd_data[63:16], d_write_data} :
                       (d_addr[1:0] == 2'b01) ? {d_rd_data[63:32], d_write_data, d_rd_data[15:0]} :
                       (d_addr[1:0] == 2'b10) ? {d_rd_data[63:48], d_write_data, d_rd_data[31:0]} : 
                       {d_write_data, d_rd_data[47:0]};                                    
                                     
  //CHANGED  --  only use writeback value created above when we have a dcache hit, otherwise use data from unified memory     
  assign d_wr_data = (d_hit) ? d_writeback :
                     (d_sw_we) ? d_load_write :
                      u_rd_data;

endmodule
