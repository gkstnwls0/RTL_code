`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KETI VIP
// Engineer: minkyu lee
// 
// Create Date: 06/09/2024 01:53:09 PM
// Design Name: 
// Module Name: ahb_master
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

`define AHB_IDLE   3'b000
`define AHB_NONSEQ 3'b001
`define AHB_BUSY   3'b010
`define AHB_SEQ    3'b011
`define AHB_WAIT   3'b100

`define HTRANS_IDLE   2'b00
`define HTRANS_BUSY   2'b01
`define HTRANS_NONSEQ 2'b10
`define HTRANS_SEQ    2'b11

`define HBURST_SINGLE 3'b000
`define HBURST_INCR   3'b001
`define HBURST_WRAP4  3'b010
`define HBURST_INCR4  3'b011
`define HBURST_WRAP8  3'b100
`define HBURST_INCR8  3'b101
`define HBURST_WRAP16 3'b110
`define HBURST_INCR16 3'b111

`define HSIZE_1B   3'b000
`define HSIZE_2B   3'b001
// Only Use HSIZE_4B
`define HSIZE_4B   3'b010
`define HSIZE_64B  3'b011
`define HSIZE_128B 3'b100
`define HSIZE_256B 3'b101
`define HSIZE_512B 3'b110
`define HSIZE_1KB 3'b111

module ahb_master #(
    parameter AHB_LITE_ON = "ON",
    parameter ADDR_WIDTH  = 32,
    parameter DATA_WIDTH  = 32,
    parameter MASK_WIDTH  = (32/8),
    parameter MASTER_NUM  = 0
    ) (
      // Common 
    input                           i_clk,
    input                           i_reset_n,
    // Read/Write Request from IP
    input                           i_req_valid,
    input                           i_req_read, 
    input [ADDR_WIDTH-1:0]          i_req_addr,
    input [4:0]                     i_req_sz,              // 0: single, 1: burst-4, 2: burst-8, 3: burst-16
    input                           i_req_wdata_valid,     
    input [DATA_WIDTH-1:0]          i_req_wdata,
    output wire                     o_req_rddata_valid,
    output wire [DATA_WIDTH-1:0]    o_req_rdata,
    output wire                     o_ahb_busy,
    output wire                     o_ahb_resp,
    // Bus Interface - Arbiter
    output wire                     o_arb_hbusreq,          // Indicates that the bus master requires the bus
    output wire                     o_arb_hlock,            // Indicates that the master requires locked access to bus
    input                           i_arb_hgrant,           // Indicates that bus master is currently the highest priority master
    input [3:0]                     i_arb_hmaster,          // Indicates which bus master is currently performing a transfer
    input                           i_arb_hmasterlock,      // Indicates that the current master is performing a locked sequence of transfers
    // Bus Interface - Slave
    output wire                     o_hsel,                 // Slave Select signal (AHB-Lite)
    output wire [ADDR_WIDTH-1:0]    o_haddr,                // the byte address of the transfer
    output wire [2:0]               o_hburst,               // Indicates how many transfer are in burst and how the address increments
    output wire                     o_hmasterlock,          // Indicates the current transfers is part of a locked sequence
    output wire [3:0]               o_hprot,                // Protection Control Sigal
    output wire [2:0]               o_hsize,                // Indicates the size of the transfer
    // output wire                     o_hnonsec,               // Indicates whether the transfer is Non-secure or Secure (AHB5)
    // output wire                     o_hexcl,                 // Indicates whether the transfer is part of an Exclusive Access sequence (AHB5)
    // output wire                     o_hmaster,               // Manager identifier (AHB5)
    output wire [1:0]               o_htrans,               // Indicates the transfer Type: IDLE,  BUSY, NONSEQ, SEQ
    output wire [DATA_WIDTH-1:0]    o_hwdata,               // Transfers data from the manager to subordinates during write operation
    output wire [MASK_WIDTH-1:0]    o_hstrb,                // Write strobes
    output wire                     o_hwrite,               // Indicates the transfer direction. H: Write / L: Read 
    // input                           i_hexokay                // Exclusive Okay. Indicates the success or failure of an Exclusive Transfer (AHB5)
    input [DATA_WIDTH-1:0]          i_hrdata,               // during read operations, the read data bus transfers data
    input                           i_hready,               // Indicates that a transfer has finished on the bus. 
    input                           i_hresp                 // The transfer response provides the Manager with additional information on the status of a transfer 
    ); 

    // APB Master Internal Logic
    reg [2:0]            ahb_status      ,ahb_status_nxt;
    reg                  ahb_sel         ,ahb_sel_nxt;
    reg [ADDR_WIDTH-1:0] ahb_addr        ,ahb_addr_nxt;
    reg [2:0]            ahb_burst       ,ahb_burst_nxt;
    reg                  ahb_masterlock  ,ahb_masterlock_nxt;
    reg [3:0]            ahb_prot        ,ahb_prot_nxt;
    reg [2:0]            ahb_size        ,ahb_size_nxt;
    reg [1:0]            ahb_trans       ,ahb_trans_nxt;
    reg                  ahb_write       ,ahb_write_nxt;
    reg                  ahb_resp        ,ahb_resp_nxt;

    reg                  req_read;
    reg [2:0]            req_burst; 
    reg [3:0]            transfer_sz;
    reg [3:0]            transfer_sz_cnt;
    reg [ADDR_WIDTH-1:0] req_addr;

    // Data FIFO Signals 
    wire                     ahb_rd_data_en;
    wire [DATA_WIDTH-1:0]    ahb_rd_data;
    wire [DATA_WIDTH-1:0]    res_rd_data;   
    wire                     res_rd_fifo_empty;
    wire                     res_rd_fifo_full;
    wire                     ahb_wr_data_en;
    wire [DATA_WIDTH-1:0]    ahb_wr_data;
    wire [DATA_WIDTH-1:0]    req_wr_data;   
    wire                     req_wr_data_en; 
    wire                     req_wr_fifo_empty;
    wire                     req_wr_fifo_full;
    reg [4:0]                rd_data_fifo_cnt;
    reg [4:0]                wr_data_fifo_cnt;
    wire [4:0]               rd_data_fifo_headroom;
    reg                      wr_data_ok;
    reg                      rd_data_ok;
    wire                     next_tranfer_ready;

    localparam               FIFO_DEPTH = 16;
    // AHB Bus Status 
    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            ahb_status  <= `AHB_IDLE;
        end
        else begin 
            ahb_status  <= ahb_status_nxt;
        end
    end  
    
    always @(*) begin 
        ahb_status_nxt = ahb_status;

        if(ahb_status == `AHB_IDLE) begin 
            if(i_req_valid) begin 
                ahb_status_nxt = `AHB_NONSEQ;
            end 
        end else if(ahb_status == `AHB_NONSEQ) begin 
            if(i_hready) begin 
                if (req_burst == `HBURST_SINGLE) begin 
                    ahb_status_nxt = `AHB_IDLE; 
                end else if(next_tranfer_ready) begin 
                    ahb_status_nxt = `AHB_SEQ;
                end else begin
                    ahb_status_nxt = `AHB_BUSY;
                end                                    
            end

        end else if(ahb_status == `AHB_BUSY) begin 
            if((req_read && !res_rd_fifo_full) || (!req_read && !req_wr_fifo_empty)) begin 
                ahb_status_nxt = `AHB_SEQ;                   
            end else begin 
                ahb_status_nxt = `AHB_BUSY;
            end                       
        end else if(ahb_status == `AHB_SEQ) begin 
            if(i_hready) begin 
                if(transfer_sz_cnt >= transfer_sz) begin 
                    if(req_read)    ahb_status_nxt = `AHB_WAIT;
                    else            
                    begin
                        if(req_wr_fifo_empty) begin
                             ahb_status_nxt = `AHB_IDLE;
                        end else begin
                            ahb_status_nxt = `AHB_SEQ;
                        end
                    end       
                end else if(next_tranfer_ready) begin 
                    ahb_status_nxt = `AHB_SEQ;
                end else begin  
                    ahb_status_nxt = `AHB_BUSY;
                end    
            end
        end else begin  // AHB_WAIT (Done)
            if(req_read && !res_rd_fifo_full) begin 
                ahb_status_nxt = `AHB_IDLE;
            end
        end            
    end

    assign next_tranfer_ready = ((!req_read && wr_data_fifo_cnt >= 2) || (req_read && rd_data_fifo_headroom >= 2));

    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            wr_data_ok  <= 1'b0;
            rd_data_ok  <= 1'b0;
        end else begin 
            if(i_hready) begin 
                if(ahb_status == `AHB_NONSEQ || ahb_status == `AHB_SEQ) begin 
                    if(req_read) rd_data_ok <= 1'b1;
                    else         wr_data_ok <= 1'b1;
                end else begin 
                    rd_data_ok <= 1'b0;
                    wr_data_ok <= 1'b0;  
                end
            end
        end 
    end



    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            ahb_sel         <= 0;
            // ahb_addr        <= 0;
            ahb_burst       <= 0;
            ahb_masterlock  <= 0;
            ahb_prot        <= 0;
            ahb_size        <= 0;
            ahb_trans       <= 0;
            ahb_write       <= 0;
            ahb_resp        <= 0;
        end
        else begin 
            ahb_sel         <= ahb_sel_nxt;
            // ahb_addr        <= ahb_addr_nxt;          
            ahb_burst       <= ahb_burst_nxt;
            ahb_masterlock  <= ahb_masterlock_nxt;
            ahb_prot        <= ahb_prot_nxt;
            ahb_size        <= ahb_size_nxt;
            ahb_trans       <= ahb_trans_nxt;
            ahb_write       <= ahb_write_nxt;
            ahb_resp        <= ahb_resp_nxt;
        end
    end      
    
    always @(*) begin 
        ahb_sel_nxt        = ahb_sel;
        // ahb_addr_nxt       = req_addr;            
        ahb_burst_nxt      = ahb_burst;
        ahb_masterlock_nxt = ahb_masterlock;
        ahb_prot_nxt       = ahb_prot;
        ahb_size_nxt       = ahb_size;
        ahb_trans_nxt      = ahb_trans;     
        ahb_write_nxt      = ahb_write; 
        ahb_resp_nxt       = i_hresp;

        if(ahb_status_nxt == `AHB_IDLE) begin 
            ahb_sel_nxt        = 1'b0;
            // ahb_addr_nxt       = 0;
            ahb_burst_nxt      = `HBURST_SINGLE;
            ahb_masterlock_nxt = 1'b0;
            ahb_prot_nxt       = 4'b000;
            ahb_size_nxt       = `HSIZE_4B;
            ahb_trans_nxt      = `HTRANS_IDLE;
            ahb_write_nxt      = !req_read;
        end else if (ahb_status_nxt == `AHB_NONSEQ) begin 
            ahb_sel_nxt        = 1'b1;
            // ahb_addr_nxt       = req_addr;
            ahb_burst_nxt      = req_burst;
            ahb_masterlock_nxt = 1'b1;
            ahb_prot_nxt       = 4'b000;
            ahb_size_nxt       = `HSIZE_4B;
            ahb_trans_nxt      = `HTRANS_NONSEQ;     
            ahb_write_nxt      = !req_read;       
        end else if (ahb_status_nxt == `AHB_BUSY) begin 
            ahb_sel_nxt        = 1'b1;
            // ahb_addr_nxt       = req_addr;
            ahb_burst_nxt      = req_burst;
            ahb_masterlock_nxt = 1'b1;
            ahb_prot_nxt       = 4'b000;
            ahb_size_nxt       = `HSIZE_4B;
            ahb_trans_nxt      = `HTRANS_BUSY;     
            ahb_write_nxt      = !req_read;  
        end else if (ahb_status_nxt == `AHB_SEQ) begin      
            ahb_sel_nxt        = 1'b1;
            // ahb_addr_nxt       = req_addr;
            ahb_burst_nxt      = req_burst;
            ahb_masterlock_nxt = 1'b1;
            ahb_prot_nxt       = 4'b000;
            ahb_size_nxt       = `HSIZE_4B;
            ahb_trans_nxt      = `HTRANS_SEQ;   
            ahb_write_nxt      = !req_read;      
        end else begin   
            ahb_sel_nxt        = 1'b0;
            // ahb_addr_nxt       = req_addr;
            ahb_burst_nxt      = req_burst;
            ahb_masterlock_nxt = 1'b0;
            ahb_prot_nxt       = 4'b000;
            ahb_size_nxt       = `HBURST_SINGLE;
            ahb_trans_nxt      = `HTRANS_IDLE;   
            ahb_write_nxt      = 1'b0;                                 
        end
    end

    assign o_hsel        = ahb_sel;
    assign o_haddr       = req_addr;
    assign o_hburst      = req_burst;
    assign o_hmasterlock = ahb_masterlock;
    assign o_hprot       = ahb_prot;
    assign o_hsize       = ahb_size;
    assign o_htrans      = ahb_trans;
    assign o_hwrite      = !req_read;
    assign o_ahb_resp    = ahb_resp;

    // AHB Burst Type Only Support 5 types: signle, INCR4, INCR8, INCR16, INCR
    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            req_read    <= 1'b0;
            transfer_sz <= 0;
            req_burst   <= `HBURST_SINGLE;
        end else begin 
            if(i_req_valid) begin 
                req_read    <= i_req_read;
                transfer_sz <= i_req_sz;

                if(i_req_sz == 0)       req_burst <= `HBURST_SINGLE;
                else if(i_req_sz == 3)  req_burst <= `HBURST_INCR4;
                else if(i_req_sz == 7)  req_burst <= `HBURST_INCR8;
                else if(i_req_sz == 15) req_burst <= `HBURST_INCR16;
                else                    req_burst <= `HBURST_INCR;
            end
        end
    end      

    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            req_addr        <= 0;
            transfer_sz_cnt <= 0;
        end else begin 
            if(i_req_valid) begin 
                req_addr        <= i_req_addr;                
                transfer_sz_cnt <= 0;
            end else begin 
                if(i_hready && ((ahb_status == `AHB_NONSEQ) || (ahb_status == `AHB_SEQ))) begin
                    req_addr        <= req_addr + 'h4;  // HSIZE Fixed (4B)
                    transfer_sz_cnt <= transfer_sz_cnt + 1;
                end
            end
        end
    end      

    assign o_ahb_busy = (ahb_status == `AHB_IDLE) ? 1'b0 : 1'b1;
    
    sync_fifo_reg #(
    .FWFT_MODE  ("TRUE"),
    .DEPTH      (FIFO_DEPTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) u_rd_data_fifo (
    //Common Signals
    .clk            (i_clk), 
    .rstn           (i_reset_n),
    //Inputs 
    .i_wr           (ahb_rd_data_en),
    .i_wr_data      (ahb_rd_data),
    .i_rd           (o_req_rddata_valid),
    //Outputs
    .o_rd_data      (res_rd_data),
    .o_empty        (res_rd_fifo_empty),
    .o_full         (res_rd_fifo_full)
    );

    assign ahb_rd_data          = i_hrdata;
    assign ahb_rd_data_en       = rd_data_ok && i_hready && req_read; 
    assign o_req_rddata_valid   = !res_rd_fifo_empty;
    assign o_req_rdata          = res_rd_data;

    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            rd_data_fifo_cnt    <= 0;
        end
        else begin 
            if(ahb_rd_data_en && !o_req_rddata_valid)       rd_data_fifo_cnt <= rd_data_fifo_cnt + 1;
            else if (!ahb_rd_data_en && o_req_rddata_valid) rd_data_fifo_cnt <= rd_data_fifo_cnt - 1;
        end
    end          

    sync_fifo_reg #(
    .FWFT_MODE  ("TRUE"),
    .DEPTH      (FIFO_DEPTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) u_wr_data_fifo (
    //Common Signals
    .clk            (i_clk), 
    .rstn           (i_reset_n),
    //Inputs 
    .i_wr           (req_wr_data_en),
    .i_wr_data      (req_wr_data),
    .i_rd           (ahb_wr_data_en),
    //Outputs
    .o_rd_data      (ahb_wr_data),
    .o_empty        (req_wr_fifo_empty),
    .o_full         (req_wr_fifo_full)
    );        
        
    // Write Data from WR_FIFO to AHB Bus
    assign req_wr_data    = i_req_wdata;
    assign req_wr_data_en = i_req_wdata_valid;
    assign ahb_wr_data_en = wr_data_ok && i_hready && !req_read; 
    assign o_hwdata       = ahb_wr_data;
    assign o_hstrb        =  4'b1111; // Hard Fixed

 
     always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            wr_data_fifo_cnt    <= 0;
        end
        else begin 
            if(req_wr_data_en && !ahb_wr_data_en)       wr_data_fifo_cnt <= wr_data_fifo_cnt + 1;
            else if (!req_wr_data_en && ahb_wr_data_en) wr_data_fifo_cnt <= wr_data_fifo_cnt - 1;
        end
    end      

    assign rd_data_fifo_headroom = FIFO_DEPTH - wr_data_fifo_cnt;

endmodule