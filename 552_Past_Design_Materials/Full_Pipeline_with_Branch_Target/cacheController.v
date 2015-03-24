//takes in values from outside caches and uses FSM to interact between caches and memory
module cacheController(clk, rst_n, i_rdy, i_re, i_addr, d_addr, d_re, d_sw_we, d_tag_out, d_hit, d_dirty, d_rd_data,
                             i_we, u_rd_data, d_controlled_we, d_controlled_re, cache_write_stall, prefetch_addr);
                             
  input clk, rst_n, i_rdy, d_re, d_sw_we, d_hit, d_dirty, i_re;
  input [7:0] d_tag_out;
  input [15:0] i_addr, d_addr;
  input [63:0] d_rd_data;
  
  output i_we, d_controlled_we, d_controlled_re, cache_write_stall;
  output [63:0] u_rd_data;
  
  wire u_re, u_we;
  wire u_rdy;
  wire [13:0] u_addr;
  wire [63:0] u_rd_data;
  
  reg rst_n_u_mem;
  reg [1:0] current_u_mem_cycle;
  reg [2:0] state, next_state;
  output reg [13:0] prefetch_addr;
  wire [63:0] u_wdata;
  
    //states for cache FSM
  localparam IDLE = 3'b000;
  localparam INSTR_RD = 3'b001;
  localparam DATA_READ_EVICT = 3'b010;
  localparam DATA_READ_RD = 3'b011;
  localparam DATA_WRITE_EVICT = 3'b100;
  localparam DATA_WRITE_RD = 3'b101;
  
    //declare unified mem
  unified_mem memory(clk, rst_n_u_mem, u_addr, u_re, u_we, u_wdata, u_rd_data, u_rdy);
  
  always@(posedge clk or negedge clk or negedge rst_n) begin
    if(!rst_n)
      rst_n_u_mem <= 1'b0;
    else if(((state == IDLE) && (d_hit == 0) && ((d_sw_we == 1) || (d_re == 1))) && clk)
      rst_n_u_mem <= 1'b0;
    else
      rst_n_u_mem <= rst_n;
  end    
  
    //unified memory address depends on the state and a slew of inputs
  assign u_addr = ((state == IDLE) && (d_hit == 0) && (d_dirty == 1) && ((d_sw_we == 1) || (d_re == 1))) ? {d_tag_out, d_addr[7:2]} :
                  (((state == DATA_WRITE_EVICT) || (state == DATA_READ_EVICT)) && (u_rdy == 0)) ? {d_tag_out, d_addr[7:2]} :
                  ((state == IDLE) && (d_hit == 0) && (d_dirty == 0) && ((d_sw_we == 1) || (d_re == 1))) ? d_addr[15:2] :
                  (((state == DATA_WRITE_EVICT) || (state == DATA_READ_EVICT)) && (u_rdy == 1)) ? d_addr[15:2] :
                  (((state == DATA_WRITE_RD) || (state == DATA_READ_RD)) && (u_rdy == 0)) ? d_addr[15:2] :
                  ((state == IDLE) && (i_rdy == 1)) ? prefetch_addr :
                  i_addr[15:2]; //Might be wrong defaulting to this, but it shouldn't matter.
      
    //read enable for unified mem depends on mainly the state, but also a few inputs            
  assign u_re = ((state == IDLE) && (d_hit == 0) && (d_dirty == 0) && ((d_sw_we == 1) || (d_re == 1))) ? 1 :
                ((state == IDLE) && (i_rdy == 0)) ? 1 :
                (state == DATA_WRITE_RD) ? 1 :
                (state == DATA_READ_RD) ? 1 :
                (state == INSTR_RD) ? 1 :
                ((state == IDLE) && (d_hit == 0) && ((d_sw_we == 1) || (d_re == 1))) ? 1'b0 :
                (state == IDLE) ? 1 :
                0;
    
    //write enable for unified mem is only high when we have a write evict where the dirty bit is high on dcache
  assign u_we = ((state == IDLE) && (d_hit == 0) && (d_dirty == 1) && ((d_sw_we == 1) || (d_re == 1))) ? 1 :
                (((state == DATA_WRITE_EVICT) || (state == DATA_READ_EVICT)) && (u_rdy == 0)) ? 1 :
                0; //Defs good
         
    //when we write data to unified mem, it is always the data we read from the dcache on an evict       
  assign u_wdata = d_rd_data;
  
  assign i_we = ((u_rdy == 1) && (((state == IDLE) && (i_addr[15:2] == prefetch_addr)) || (state == INSTR_RD))) ? 1 : 0;  //Only write when in last cycle of INSTR_RD
  
  assign cache_write_stall = 0;//((u_rdy == 1) && (state == IDLE) && (i_addr[15:2] != prefetch_addr));
        
        //default to 1 always
  assign d_controlled_re = 1;
    
        //write to dcache only when unified mem is done reading the data or the user is writing to memory (d_sw_we)
  assign d_controlled_we = (((state == DATA_WRITE_RD) || (state == DATA_READ_RD)) && u_rdy == 1) ? 1 :
                           (((state == DATA_WRITE_RD) || (state == DATA_READ_RD)) && u_rdy == 0) ? 0 :
                           (((d_hit == 1) && (state == IDLE)) || ((i_we == 1) && (state == INSTR_RD))) ? d_sw_we :
                           0;
  
    //Determine the next_state 
  always@(*) begin
    
    if(state == IDLE) begin
      if(!d_hit) begin  //dcache has priority
        if(d_sw_we) begin
          if(d_dirty) begin //if dcache didn't hit AND we are writing AND data is dirty, we need to write back to unified mem
            next_state = DATA_WRITE_EVICT;
          end else begin    //if data isn't dirty, just write
            next_state = DATA_WRITE_RD;
          end
        end else if(d_re) begin
          if(d_dirty) begin //if no hit and we need to read but data is dirty, need to write back to unified mem
            next_state = DATA_READ_EVICT;
          end else begin    //if data wasn't dirty, can overwrite data in cache from unified mem
            next_state = DATA_READ_RD;
          end
        end else begin  //dcache isn't being read, so if icache didn't hit and we are reading, need to go to unified mem and grab data
          if(!i_rdy && i_re && (i_addr[15:2] != prefetch_addr)) begin  
            next_state = INSTR_RD;
          end else begin    //else icache hit and we can continue with our business
            next_state = IDLE;
          end
        end         //dcache hit, now check icache. If no hit and we are reading, need to go to unified mem and grab data
      end else if(!i_rdy && i_re && (i_addr[15:2] != prefetch_addr)) begin
        next_state = INSTR_RD;
      end else begin    //otherwise it was a hit and we continue on our way
        next_state = IDLE;
      end
    end
    
    else if(state == DATA_WRITE_EVICT) begin
      if(!u_rdy) begin  //wait until mem is ready (4 cycles)
        next_state = DATA_WRITE_EVICT;
      end else begin    //then write back to cache
        next_state = DATA_WRITE_RD;
      end
    end
    
    else if(state == DATA_WRITE_RD) begin
      if(!u_rdy) begin      //is mem isn't ready, stay in this state
        next_state = DATA_WRITE_RD;
      end else begin    
        if(!i_rdy && i_re) begin    //otherwise check if icache didn't hit so we can start getting that data from unified mem right away
          next_state = INSTR_RD;
        end else begin          //otherwise go back to starting state
          next_state = IDLE;
        end
      end
    end
    
    else if(state == DATA_READ_EVICT) begin
      if(!u_rdy) begin      //wait until unified mem is ready
        next_state = DATA_READ_EVICT;
      end else begin        //then can read data properly
        next_state = DATA_READ_RD;
      end
    end
    
    else if(state == DATA_READ_RD) begin
      if(!u_rdy) begin      //stay in this state if unified mem isn't ready
        next_state = DATA_READ_RD;
      end else begin    // when ready, dcache will hit, now check icache and see if that can be serviced right away
        if(!i_rdy && i_re) begin
          next_state = INSTR_RD;
        end else begin  //otherwise go back to starting state
          next_state = IDLE;
        end
      end
    end
    
    else if(state == INSTR_RD) begin
      if(!u_rdy && i_re) begin  //wait in this state until unified mem is ready (also check if still reading instruction mem)
        next_state = INSTR_RD;
      end else begin        //when unified mem is ready, go back to starting state, 
        // no need to check dcache because it would have been serviced first anyway
        prefetch_addr = i_addr[15:2] + 1;                    
        next_state = IDLE;
      end
    end
    
    else
      next_state = IDLE; //IF OUTERSPACE MESSED UP THE BITS
  end
  
  
  //Prefetching logic
  always@(posedge clk or negedge rst_n) begin
      if(!rst_n) prefetch_addr <= 0;
        
      if((state == IDLE) && u_rdy)
        prefetch_addr <= prefetch_addr + 1;
  end
  
    //on reset go back to starting state, 
    // otherwise just give state the next_state determined above
  always@(posedge clk or negedge rst_n) begin
      if(!rst_n) state <= IDLE;     
      else state <= next_state;
  end
  
endmodule
