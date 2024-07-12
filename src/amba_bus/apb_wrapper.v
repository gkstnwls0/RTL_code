`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KETI 
// Engineer: minkyu lee
// 
// Create Date: 06/07/2024 10:29:53 AM
// Design Name: 
// Module Name: apb_wrapper
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
// 
//////////////////////////////////////////////////////////////////////////////////

`define APB_IDLE   2'b00
`define APB_ACK    2'b01
`define APB_WAIT   2'b10
`define APB_ERR    2'b11
`define ADDR_BASE  4'b0000
`define ADDR_END   4'b1100
`define WAIT_CYCLES 3

module apb_wrapper #
    ( parameter ADDR_WIDTH = 32,
      parameter DATA_WIDTH = 32
    ) (
      // Common 
      input                           i_clk,
      input                           i_reset_n,
      // Bus Interface
      input                           i_psel,
      input                           i_penable,
      input                           i_pwrite,
      input [ADDR_WIDTH-1:0]          i_paddr,
      input [DATA_WIDTH-1:0]          i_pwdata,
      output wire                     o_pready,
      output wire [DATA_WIDTH-1:0]    o_prdata,
      output wire                     o_pslverr
    );

    // APB Wrapper Internal Signals
    reg                     apb_ready;      
    reg [1:0]               apb_status;        // 0: IDLE, 1: ACK, 2: WAIT
    reg [ADDR_WIDTH-1:0]    apb_waddr;
    reg                     apb_slverr;
    reg [DATA_WIDTH-1:0]    apb_rdata;

    reg                     apb_ready_nxt;
    reg [1:0]               apb_status_nxt;
    reg [ADDR_WIDTH-1:0]    apb_waddr_nxt;
    reg                     apb_slverr_nxt;
    reg [DATA_WIDTH-1:0]    apb_rdata_nxt;
    
    // Test Internal logic 
    reg [2:0] wait_counter;
    reg                     peri_ready;
    reg                     peri_error;
    reg [DATA_WIDTH-1:0]    peri_reg[0:11];
    integer i;

    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            apb_status  <= `APB_IDLE;
            apb_ready   <= 1'b0;
            apb_waddr   <= 0;
            apb_slverr  <= 1'b0;
            apb_rdata   <= 0;
            wait_counter <= 0;
        end
        else begin 
            apb_status  <= apb_status_nxt;
            apb_ready   <= apb_ready_nxt;
            apb_waddr   <= apb_waddr_nxt;
            apb_slverr  <= apb_slverr_nxt;            
            apb_rdata   <= apb_rdata_nxt;
            if (!(apb_status_nxt == `APB_IDLE) && i_psel && wait_counter < `WAIT_CYCLES+1) begin
                wait_counter <= wait_counter + 1;
            end else begin
                wait_counter <= 0;
            end
        end
    end   


    always @(*) begin 
        apb_status_nxt = apb_status;
        apb_ready_nxt  = apb_ready;
        apb_waddr_nxt  = apb_waddr;
        apb_slverr_nxt = 1'b0;
        apb_rdata_nxt  = apb_rdata;

        if(apb_status == `APB_IDLE) begin 
            if(i_psel && !i_penable) begin 
                apb_waddr_nxt  = i_paddr;
                if(peri_ready) begin 
                    if (i_paddr[3:0] < `ADDR_BASE || i_paddr[3:0] > `ADDR_END-1) begin 
                        apb_status_nxt = `APB_ERR;
                        apb_slverr_nxt = 1'b1;
                    end
                    else           apb_status_nxt = `APB_ACK;
                    apb_ready_nxt  = 1'b1;
                    if(!i_pwrite) apb_rdata_nxt <= peri_reg[i_paddr[3:0]];     
                end else begin 
                    apb_status_nxt = `APB_WAIT;
                    apb_ready_nxt  = 1'b0;
                end
            end else begin 
                apb_status_nxt = `APB_IDLE;
                apb_ready_nxt  = 1'b0;
            end
        end else if(apb_status == `APB_ACK) begin 
            apb_status_nxt = `APB_IDLE;
            apb_ready_nxt  = 1'b0;                
        end else if(apb_status == `APB_WAIT) begin 
            if(i_psel && i_penable) begin 
                if(peri_ready) begin 
                    if (i_paddr[3:0] < `ADDR_BASE || i_paddr[3:0] > `ADDR_END-1) begin 
                        apb_status_nxt = `APB_ERR;
                        apb_slverr_nxt = 1'b1;
                    end 
                    else           apb_status_nxt = `APB_ACK;
                    if(!i_pwrite) apb_rdata_nxt <= peri_reg[i_paddr[3:0]];     
                    apb_ready_nxt  = 1'b1;                         
                end else begin 
                    apb_status_nxt = `APB_WAIT;
                    apb_ready_nxt  = 1'b0;                     
                end
            end else begin 
                apb_status_nxt = `APB_ERR;
                apb_ready_nxt  = 1'b1;
                apb_slverr_nxt = 1'b1;
            end
        end
        else begin
            apb_status_nxt = `APB_IDLE;
            apb_ready_nxt = 1'b0;
            apb_slverr_nxt = 1'b0;
        end
    end


    // Test - Internal Logic
    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            peri_ready <= 1'b0;
            peri_error <= 1'b0;
            
            for(i=0; i<16; i=i+1)begin
                peri_reg[i]   <= 1'b0;
            end
        end
        else begin 
            // peri_ready <= 1'b1;
            // if(i_psel && !i_penable && i_pwrite)
            //     peri_reg[i_paddr[3:0]]   <= i_pwdata;    
            if (wait_counter == `WAIT_CYCLES) peri_ready <= 1'b1;
            else peri_ready <= 1'b0;

            if(i_psel && peri_ready) begin
                if(i_pwrite) peri_reg[i_paddr[3:0]]   <= i_pwdata;        
            end  
        end
    end    
    
    assign o_pready   = apb_ready;
    assign o_prdata   = apb_rdata;
    assign o_pslverr  = apb_slverr;
    
        
endmodule
