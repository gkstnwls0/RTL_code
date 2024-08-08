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

module apb_wrapper #
    ( parameter ADDR_WIDTH = 32,
      parameter DATA_WIDTH = 32
    ) (
      // Common 
      input                           i_clk,
      input                           i_reset_n,
      //Transmit data to IP
      input                           i_req_ready,
      input  [DATA_WIDTH-1:0]         i_req_rdata,
      output                          o_req_valid,
      output                          o_req_write,
      output [ADDR_WIDTH-1:0]         o_req_addr,
      output [DATA_WIDTH-1:0]         o_req_wdata,
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
    reg [1:0]               apb_status       ,apb_status_nxt;      // 0: IDLE, 1: ACK, 2: WAIT
    reg                     apb_ready        ,apb_ready_nxt;      
    reg                     apb_slverr       ,apb_slverr_nxt;
    reg [DATA_WIDTH-1:0]    apb_rdata        ,apb_rdata_nxt;
    reg                     req_valid        ,req_valid_nxt;
    reg                     req_write        ,req_write_nxt;
    reg [ADDR_WIDTH-1:0]    req_addr         ,req_addr_nxt;
    reg [DATA_WIDTH-1:0]    req_wdata        ,req_wdata_nxt;



    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            apb_status      <= `APB_IDLE;
            apb_ready       <= 1'b0;
            apb_slverr      <= 1'b0;
            apb_rdata       <= 0;
            req_valid       <= 1'b0;
            req_write       <= 1'b0;
            req_addr        <= 0;
            req_wdata       <= 0;
        end
        else begin 
            apb_status      <= apb_status_nxt;
            apb_ready       <= apb_ready_nxt;
            apb_slverr      <= apb_slverr_nxt;
            apb_rdata       <= apb_rdata_nxt;
            req_valid       <= req_valid_nxt;
            req_write       <= req_write_nxt;
            req_addr        <= req_addr_nxt;            
            req_wdata       <= req_wdata_nxt;
        end
    end   


    always @(*) begin 
        apb_status_nxt = apb_status;
        apb_ready_nxt  = apb_ready;
        apb_slverr_nxt = 1'b0;
        apb_rdata_nxt  = apb_rdata;
        req_addr_nxt   = req_addr;
        req_write_nxt  = req_write;
        req_valid_nxt  = req_valid;
        req_wdata_nxt  = req_wdata;

        if(apb_status == `APB_IDLE) begin 
             req_write_nxt = i_pwrite;
            if(i_psel && !i_penable) begin 
                req_addr_nxt  = i_paddr;
                if(i_req_ready) begin        
                    apb_status_nxt = `APB_ACK;
                    req_valid_nxt  = 1'b1;      
                    apb_ready_nxt  = 1'b1;
                    if(!i_pwrite) apb_rdata_nxt <= i_req_rdata; 
                    else          req_wdata_nxt <= i_pwdata;    
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
            req_valid_nxt  = 1'b0;                
        end else if(apb_status == `APB_WAIT) begin 
            if(i_psel && i_penable) begin 
                if(i_req_ready) begin 
                    apb_ready_nxt  = 1'b1; 
                    apb_status_nxt = `APB_ACK;
                    req_valid_nxt  = 1'b1;       
                    if(!i_pwrite)  apb_rdata_nxt <= i_req_rdata;  
                    else           req_wdata_nxt <= i_pwdata;                            
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
            apb_ready_nxt  = 1'b0;
            apb_slverr_nxt = 1'b0;
        end
    end
    
    assign o_pready    = apb_ready;
    assign o_prdata    = apb_rdata;
    assign o_pslverr   = apb_slverr;
    assign o_req_valid = req_valid;
    assign o_req_write = req_write;
    assign o_req_addr  = req_addr;
    assign o_req_wdata = req_wdata;
        
endmodule
