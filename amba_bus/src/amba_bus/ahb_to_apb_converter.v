`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2024 04:36:33 PM
// Design Name: 
// Module Name: ahb_to_apb_converter
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

`define S_IDLE       3'b000
`define S_WDATA_EN   3'b001
`define S_ENABLE     3'b010
`define S_WAIT       3'b011
`define S_ERROR      3'b100

`define HTRANS_IDLE   2'b00
`define HTRANS_BUSY   2'b01
`define HTRANS_NONSEQ 2'b10
`define HTRANS_SEQ    2'b11

module ahb_to_apb_converter #(
    parameter ADDR_WIDTH  = 32,
    parameter DATA_WIDTH  = 32
    )
    (
    // Common
    input                           i_clk,
    input                           i_reset_n,

    //Bus Interface - AHB-Lite Slave port
    input [ADDR_WIDTH-1:0]          i_haddr,               
    input [2:0]                     i_hburst,             
    input                           i_hmasterlock,     
    input [3:0]                     i_hprot,               
    input [2:0]                     i_hsize,            //0: FIXED, 1: INCR, 2: WRAP4, 3: INCR4 ... 7: INCR16   
    input [1:0]                     i_htrans,           //0: IDLE, 1: BUSY, 2: NONSEQ, 3: SEQ      
    input [DATA_WIDTH-1:0]          i_hwdata,              
    input                           i_hwrite,           //H: Write / L: Read 
    input                           i_hreadyin, 
    output wire [DATA_WIDTH-1:0]    o_hrdata,              
    output wire                     o_hreadyout,        
    output wire                     o_hresp,            //L: OK / H : ERROR 

    //Bus Interface - APB3 Master port
    output wire                     o_psel,                
    output wire                     o_penable,          
    output wire                     o_pwrite,           //H: Write / L: Read 
    output wire [ADDR_WIDTH-1:0]    o_paddr,
    output wire [DATA_WIDTH-1:0]    o_pwdata,
    input                           i_pready,
    input [DATA_WIDTH-1:0]          i_prdata,
    input                           i_pslverr           //L: OK / H : ERROR 
    );

    //FSM
    reg [2:0]                       status, status_nxt;

    //output reg
    reg                             r_hready,     r_hready_nxt;
    reg [DATA_WIDTH-1:0]            r_hrdata,     r_hrdata_nxt;
    reg                             r_hresp,      r_hresp_nxt;
    reg                             r_psel,       r_psel_nxt;
    reg                             r_penable,    r_penable_nxt;
    reg                             r_pwrite,     r_pwrite_nxt;
    reg [ADDR_WIDTH-1:0]            r_paddr,      r_paddr_nxt;
    reg [DATA_WIDTH-1:0]            r_pwdata,     r_pwdata_nxt;

    reg [ADDR_WIDTH-1:0]            tmp_haddr,    tmp_haddr_nxt;
    reg                             tmp_hwrite,   tmp_hwrite_nxt; 

    
    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            status      <= `S_IDLE;
            r_hready    <= 1'b0;
            r_hrdata    <= 0;
            r_hresp     <= 1'b0;
            r_psel      <= 1'b0;
            r_penable   <= 1'b0;
            r_pwrite    <= 1'b0;
            r_paddr     <= 0;
            r_pwdata    <= 0;
            tmp_haddr   <= 0;
            tmp_hwrite  <= 1'b0;
        end
        else begin 
            status      <= status_nxt;
            r_hready    <= r_hready_nxt;
            r_hrdata    <= r_hrdata_nxt;
            r_hresp     <= r_hresp_nxt;
            r_psel      <= r_psel_nxt;
            r_penable   <= r_penable_nxt;
            r_pwrite    <= r_pwrite_nxt;
            r_paddr     <= r_paddr_nxt;
            r_pwdata    <= r_pwdata_nxt;
            tmp_haddr   <= tmp_haddr_nxt;
            tmp_hwrite  <= tmp_hwrite_nxt;
        end
    end 

    always @(*) begin
        status_nxt = status;

        case(status)
            `S_IDLE:begin
                if(i_hreadyin && (i_htrans == `HTRANS_NONSEQ || i_htrans == `HTRANS_SEQ)) begin
                    if(i_hwrite) status_nxt = `S_WDATA_EN;
                    else         status_nxt = `S_ENABLE;
                end
                else
                    status_nxt = `S_IDLE;
            end
             `S_WDATA_EN:begin
                status_nxt = `S_ENABLE;
            end
            `S_ENABLE:begin
                status_nxt = `S_WAIT;
            end
            `S_WAIT:begin
                if(i_pready) begin
                    if(i_pslverr) status_nxt = `S_ERROR;
                    else          status_nxt = `S_IDLE;
                end
                else begin
                    status_nxt = `S_WAIT;
                end
            end
            default:begin
                status_nxt = `S_IDLE;
            end
        endcase
    end

    always @(*) begin
        r_hready_nxt   = r_hready;
        r_hrdata_nxt   = r_hrdata;
        r_hresp_nxt    = r_hresp;
        r_psel_nxt     = r_psel;
        r_penable_nxt  = r_penable;
        r_pwrite_nxt   = r_pwrite;
        r_paddr_nxt    = r_paddr;
        r_pwdata_nxt   = r_pwdata;
        tmp_haddr_nxt  = tmp_haddr;
        tmp_hwrite_nxt = tmp_hwrite_nxt;
        case(status)
            `S_IDLE:begin
                r_hready_nxt  = 1'b1;
                r_hrdata_nxt  = 0;
                r_hresp_nxt   = 1'b0;
                r_psel_nxt    = 1'b0;
                r_penable_nxt = 1'b0;
                r_pwrite_nxt  = 1'b0;
                r_pwdata_nxt  = 0;
                if(i_hreadyin && (i_htrans == `HTRANS_NONSEQ || i_htrans == `HTRANS_SEQ)) begin
                    r_hready_nxt  = i_pready;
                    if(i_hwrite) begin
                        tmp_haddr_nxt     = i_haddr;
                        tmp_hwrite_nxt    = i_hwrite;
                    end
                    else begin
                        r_psel_nxt    = 1'b1;
                        r_paddr_nxt   = i_haddr;
                        r_pwrite_nxt  = i_hwrite;
                    end
                end
            end
            `S_WDATA_EN:begin
                    r_psel_nxt    = 1'b1;
                    r_paddr_nxt   = tmp_haddr;
                    r_pwrite_nxt  = tmp_hwrite;
                    r_hready_nxt  = i_pready;
                    r_pwdata_nxt  = i_hwdata;
            end
            `S_ENABLE:begin
                r_penable_nxt = 1'b1;
                r_hready_nxt  = i_pready;
            end
            `S_WAIT:begin
                if(i_pready) begin
                    r_penable_nxt = 1'b0;
                    r_psel_nxt    = 1'b0;
                    r_hresp_nxt   = i_pslverr;
                    if(r_pwrite) begin 
                        r_pwrite_nxt  = 1'b0;
                        r_pwdata_nxt  = 0;
                    end
                    else         r_hrdata_nxt  = i_prdata;

                    if(i_pslverr) r_hready_nxt  = 1'b0;
                    else          r_hready_nxt  = i_pready;
                end 
            end
            default:begin
                r_hresp_nxt  = 1'b1;
                r_hready_nxt = 1'b1;
            end
        endcase
    end
    
    assign o_hreadyout = r_hready;
    assign o_hrdata    = r_hrdata;
    assign o_hresp     = r_hresp;
    assign o_psel      = r_psel;
    assign o_penable   = r_penable;
    assign o_pwrite    = r_pwrite;
    assign o_paddr     = r_paddr;
    assign o_pwdata    = r_pwdata;

endmodule
