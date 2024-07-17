`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KETI
// Engineer: minkyu lee
// 
// Create Date: 08/07/2023 05:01:51 PM
// Design Name: Parameterized FIFO with Register (Not BLock Memory)
// Module Name: sync_fifo_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// ref: https://github.com/pConst/basic_verilog/blob/master/fifo_single_clock_reg_v2.sv
//////////////////////////////////////////////////////////////////////////////////


module sync_fifo_reg#(
    parameter FWFT_MODE  = "TRUE",
    parameter DEPTH      = 8,
    parameter DATA_WIDTH = 16
    ) (
    //Common Signals
    input                           clk, 
    input                           rstn,
    //Inputs 
    input                           i_wr,
    input [DATA_WIDTH-1:0]          i_wr_data,
    input                           i_rd,
    //Outputs
    output wire [DATA_WIDTH-1:0]    o_rd_data,
    // output wire                     o_valid,
    output wire                     o_empty,
    output wire                     o_full
    );

    `include "common_function.vh"
    localparam DEPTH_WIDTH = clogb2(DEPTH);

    //FIFO Data Register
    reg [DATA_WIDTH-1:0] fifo_data [DEPTH-1:0];

    //RD/WR Pointer
    reg [DEPTH_WIDTH-1:0]      w_ptr  ,w_ptr_nxt;
    reg [DEPTH_WIDTH-1:0]      r_ptr  ,r_ptr_nxt;
    reg [DEPTH_WIDTH-1:0]      cnt    ,cnt_nxt;

    // Internal Full and Empty Signals
    reg                  full   ,full_nxt;
    reg                  empty  ,empty_nxt;
    reg                  valid;

    // Data_Out Buf
    reg [DATA_WIDTH-1:0] data_buf,data_buf_nxt;

    // Write Data Signals
    reg en_wr,en_rd;

    integer i;
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            for(i=0;i<DEPTH;i=i+1) 
                fifo_data[i]   <= 0;
        end
        else begin 
            if(!full) begin 
                if(en_wr)
                    fifo_data[w_ptr] <= i_wr_data;
            end
        end    
    end    

    always @(*) begin 
        w_ptr_nxt    = w_ptr; 
        r_ptr_nxt    = r_ptr;
        cnt_nxt      = cnt;
        en_wr        = 0;
        en_rd        = 0;
        data_buf_nxt = data_buf;

        if(i_wr && !full) begin 
            w_ptr_nxt    = w_ptr + 1'b1;
            en_wr        = 1'b1;            
        end

        if(i_rd && !empty) begin 
            r_ptr_nxt    = r_ptr + 1'b1;
            en_rd        = 1'b1;            
        end

        case({i_wr,i_rd}) 
            2'b00:; // Nothing
            2'b01: begin // only reading                 
                if(~empty)    cnt_nxt      = cnt   - 1'b1;
            end
            2'b10: begin // only writing 
                if(~full)     cnt_nxt      = cnt   + 1'b1;
            end
            2'b11: begin // both reading and writing 
                if(empty)     cnt_nxt      = cnt   + 1'b1;
                else if(full) cnt_nxt      = cnt   - 1'b1;
            end
        endcase

        empty_nxt    = (cnt_nxt == 0);
        full_nxt     = (cnt_nxt == (DEPTH-1));     
        if(FWFT_MODE != "TRUE") begin 
            if(en_rd) data_buf_nxt = fifo_data[r_ptr];
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            w_ptr        <= 0;
            r_ptr        <= 0;
            cnt          <= 0;
            data_buf     <= 0;
            full         <= 0;
            empty        <= 1'b1;   
            // valid        <= 0;         
        end else begin 
            if(i_wr || i_rd) begin 
                w_ptr        <= w_ptr_nxt;
                r_ptr        <= r_ptr_nxt;
                cnt          <= cnt_nxt;                
                full         <= full_nxt;
                empty        <= empty_nxt; 
                // valid        <= !empty_nxt;     
                if(FWFT_MODE != "TRUE") begin 
                    data_buf     <= data_buf_nxt;
                end
            end
        end    
    end   

    assign o_rd_data = (FWFT_MODE == "TRUE") ? fifo_data[r_ptr] : data_buf;
    // assign o_valid   = valid;
    assign o_empty   = empty;
    assign o_full    = full;

// synthesis translate_off
    always @(posedge clk) begin    
        if(empty && i_rd) begin 
            $display("[%0t] [%m] FIFO Receive RD Signal when FIFO is Empty!",$time);
            $stop;
        end
        if(full && i_wr) begin 
            $display("[%0t] [%m] FIFO Receive WR Signal when FIFO is FULL!",$time);
            $stop;
        end
    end
// synthesis translate_on    
endmodule
