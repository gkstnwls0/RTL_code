`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2024 05:59:59 PM
// Design Name: 
// Module Name: test_ip
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

`define s_IDLE    2'b00
`define s_READ    2'b01
`define s_PROCESS 2'b10
`define s_WRITE   2'b11
module test_ip #
    ( parameter ADDR_WIDTH = 32,
      parameter DATA_WIDTH = 32
    ) (
      // Common 
      input                           i_clk,
      input                           i_reset_n,
      // APB Bus Interface
      input                           i_psel,
      input                           i_penable,
      input                           i_pwrite,
      input [ADDR_WIDTH-1:0]          i_paddr,
      input [DATA_WIDTH-1:0]          i_pwdata,
      output wire                     o_pready,
      output wire [DATA_WIDTH-1:0]    o_prdata,
      output wire                     o_pslverr,
      // AHB Bus Interface
      input [DATA_WIDTH-1:0]          i_hrdata,               
      input                           i_hready,              
      input                           i_hresp,          
      output wire                     o_hsel,                 
      output wire [ADDR_WIDTH-1:0]    o_haddr,              
      output wire [2:0]               o_hburst,             
      output wire [3:0]               o_hprot,             
      output wire [2:0]               o_hsize,              
      output wire [1:0]               o_htrans,              
      output wire [DATA_WIDTH-1:0]    o_hwdata,            
      output wire                     o_hwrite
    );
    
    //apb   
    wire                           apb_write;
    wire [ADDR_WIDTH-1:0]          apb_addr;
    wire [DATA_WIDTH-1:0]          apb_wdata;
    wire                           apb_valid;
    wire                           apb_ready;
    wire [DATA_WIDTH-1:0]          apb_rdata;

    //fifo
    wire                           start_op;
    wire                           apb_wr_data_en;
    wire  [63:0]                   wr_data;
    wire                           rd_data_en;
    wire  [63:0]                   rd_data;
    wire                           wr_status_en;
    wire [DATA_WIDTH-1:0]          wr_status_data;
    wire                           apb_rd_status_en;
    wire                           write_ready;
    wire                           read_ready;
    wire                           res_data_fifo_empty, res_data_fifo_full;
    wire                           res_status_fifo_empty, res_status_fifo_full;

    //ahb
    reg                           req_valid, req_valid_nxt;
    reg                           req_read, req_read_nxt; 
    reg [ADDR_WIDTH-1:0]          req_addr, req_addr_nxt;            
    reg                           req_wdata_valid, req_wdata_valid_nxt;     
    reg [DATA_WIDTH-1:0]          req_wdata, req_wdata_nxt;
    reg                           ahb_rd_data_en, ahb_rd_data_en_nxt;
    reg                           ahb_busy_r, ahb_resp_r;
    wire                          req_rddata_valid;
    wire [DATA_WIDTH-1:0]         req_rdata;
    wire                          ahb_busy;
    wire                          ahb_resp;

    //operation
    reg [1:0]                     status       ,status_nxt;
    reg [DATA_WIDTH-1:0]          value_A;
    reg [(DATA_WIDTH*4)-1:0]      value_B;
    reg [(DATA_WIDTH*4)-1:0]      value_result;
    reg [2:0]                     burst_count, burst_count_nxt;

    localparam               FIFO_DEPTH = 16;


    apb_wrapper #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
    ) u_apb_slave(
        // Common 
        .i_clk                  (i_clk),
        .i_reset_n              (i_reset_n),
        .i_req_ready            (apb_ready),
        .i_req_rdata            (apb_rdata),
        .o_req_valid            (apb_valid),
        .o_req_write            (apb_write),
        .o_req_addr             (apb_addr),
        .o_req_wdata            (apb_wdata),
        .i_psel                 (i_psel),
        .i_penable              (i_penable),
        .i_pwrite               (i_pwrite),
        .i_paddr                (i_paddr),
        .i_pwdata               (i_pwdata),
        .o_pready               (o_pready),
        .o_prdata               (o_prdata),
        .o_pslverr              (o_pslverr) 
  );

   ahb_master #(
        .AHB_LITE_ON("ON"),
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .MASK_WIDTH(32/8),
        .MASTER_NUM(0)
        ) u_ahb_master (
          // Common 
        .i_clk                          (i_clk),
        .i_reset_n                      (i_reset_n),
        // Read/Write Request from IP
        .i_req_valid                    (req_valid),
        .i_req_read                     (req_read), 
        .i_req_addr                     (req_addr),
        .i_req_sz                       (6'b000011),              
        .i_req_wdata_valid              (req_wdata_valid),     
        .i_req_wdata                    (req_wdata),
        .o_req_rddata_valid             (req_rddata_valid),
        .o_req_rdata                    (req_rdata),
        .o_ahb_busy                     (ahb_busy),
        .o_ahb_resp                     (ahb_resp),
        // Bus Interface - Arbiter
        .o_arb_hbusreq                  (),          
        .o_arb_hlock                    (),            
        .i_arb_hgrant                   (),           
        .i_arb_hmaster                  (),          
        .i_arb_hmasterlock              (),      
        // Bus Interface - Slave
        .o_hsel                         (o_hsel),                 
        .o_haddr                        (o_haddr),                
        .o_hburst                       (o_hburst),               
        .o_hmasterlock                  (),          
        .o_hprot                        (o_hprot),                
        .o_hsize                        (o_hsize),                
        .o_htrans                       (o_htrans),               
        .o_hwdata                       (o_hwdata),               
        .o_hstrb                        (),                
        .o_hwrite                       (o_hwrite),               
        .i_hrdata                       (i_hrdata),               
        .i_hready                       (i_hready),               
        .i_hresp                        (i_hresp)                 
        ); 



  always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin  
            status           <= `s_IDLE;
            req_valid        <= 1'b0;
            req_read         <= 1'b0;
            req_addr         <= 0;
            req_wdata        <= 0;
            req_wdata_valid  <= 1'b0;
            ahb_rd_data_en   <= 1'b1;
            ahb_busy_r       <= 1'b0;
            ahb_resp_r       <= 1'b0;
            burst_count      <= 0;
        end
        else begin  
            status           <= status_nxt;
            req_valid        <= req_valid_nxt;
            req_read         <= req_read_nxt;
            req_addr         <= req_addr_nxt;            
            req_wdata        <= req_wdata_nxt;
            req_wdata_valid  <= req_wdata_valid_nxt;
            ahb_rd_data_en   <= ahb_rd_data_en_nxt;
            ahb_busy_r       <= ahb_busy;
            ahb_resp_r       <= ahb_resp;
            burst_count      <= burst_count_nxt;
        end
    end   

    always @(posedge i_clk or negedge i_reset_n) begin
        if(!i_reset_n) begin
            value_result <= 0;
            value_A      <= 0;
            value_B      <= 0;
        end else begin
            if((status == `s_IDLE) && start_op)
                value_A <= rd_data[31:0];
            else if((status == `s_READ) && req_rddata_valid)
                value_B[32*burst_count+:DATA_WIDTH] <= req_rdata;
            else if(status == `s_PROCESS) begin
                if(value_A[1:0] == 0) begin
                    value_result[32*0+:DATA_WIDTH] <= value_A + value_B[32*0+:DATA_WIDTH];
                    value_result[32*1+:DATA_WIDTH] <= value_A + value_B[32*1+:DATA_WIDTH];
                    value_result[32*2+:DATA_WIDTH] <= value_A + value_B[32*2+:DATA_WIDTH];
                    value_result[32*3+:DATA_WIDTH] <= value_A + value_B[32*3+:DATA_WIDTH];
                end else if(value_A[1:0] == 1) begin
                    value_result[32*0+:DATA_WIDTH] <= value_A - value_B[32*0+:DATA_WIDTH];
                    value_result[32*1+:DATA_WIDTH] <= value_A - value_B[32*1+:DATA_WIDTH];
                    value_result[32*2+:DATA_WIDTH] <= value_A - value_B[32*2+:DATA_WIDTH];
                    value_result[32*3+:DATA_WIDTH] <= value_A - value_B[32*3+:DATA_WIDTH];
                end else if(value_A[1:0] == 2) begin
                    value_result[32*0+:DATA_WIDTH] <= value_A * value_B[32*0+:DATA_WIDTH];
                    value_result[32*1+:DATA_WIDTH] <= value_A * value_B[32*1+:DATA_WIDTH];
                    value_result[32*2+:DATA_WIDTH] <= value_A * value_B[32*2+:DATA_WIDTH];
                    value_result[32*3+:DATA_WIDTH] <= value_A * value_B[32*3+:DATA_WIDTH];
                end else begin
                    value_result[32*0+:DATA_WIDTH] <= value_A > value_B[32*0+:DATA_WIDTH] ? value_A : value_B[32*0+:DATA_WIDTH];
                    value_result[32*1+:DATA_WIDTH] <= value_A > value_B[32*1+:DATA_WIDTH] ? value_A : value_B[32*1+:DATA_WIDTH];
                    value_result[32*2+:DATA_WIDTH] <= value_A > value_B[32*2+:DATA_WIDTH] ? value_A : value_B[32*2+:DATA_WIDTH];
                    value_result[32*3+:DATA_WIDTH] <= value_A > value_B[32*3+:DATA_WIDTH] ? value_A : value_B[32*3+:DATA_WIDTH];
                end
            end
        end
    end

    always @(*) begin 
        status_nxt           = status;
        req_valid_nxt        = req_valid;
        req_read_nxt         = req_read;
        req_addr_nxt         = req_addr;
        req_wdata_nxt        = req_wdata;
        req_wdata_valid_nxt  = req_wdata_valid;
        ahb_rd_data_en_nxt   = ahb_rd_data_en;
        burst_count_nxt      = burst_count;

        case (status)
        `s_IDLE: begin 
            burst_count_nxt  = 0;
            if(start_op) begin 
                status_nxt = `s_READ;
                req_valid_nxt  = 1'b1;
                req_read_nxt   = 1'b1;
                req_addr_nxt   = 32'h00000000 + rd_data[62:32];
                ahb_rd_data_en_nxt = 1'b0;
            end else begin
                status_nxt = `s_IDLE;
            end
        end 
        `s_READ: begin
            req_valid_nxt  = 1'b0; 
            if(req_rddata_valid) begin
                burst_count_nxt = burst_count_nxt + 1;
                if(burst_count_nxt > 3) begin
                    status_nxt = `s_PROCESS;
                    burst_count_nxt = 0;
                end else begin
                    status_nxt = `s_READ;
                end
            end
        end
        `s_PROCESS: begin 
            req_valid_nxt  = 1'b1;
            req_read_nxt   = 1'b0;
            status_nxt = `s_WRITE;
        end
        default: begin
            req_valid_nxt  = 1'b0;
            req_wdata_valid_nxt = 1'b1;
            if(burst_count_nxt > 3) begin
                req_wdata_valid_nxt = 1'b0;
                if(wr_status_en) begin
                    status_nxt = `s_IDLE;
                    ahb_rd_data_en_nxt = 1'b1;
                    burst_count_nxt = 0;
                end else begin
                    status_nxt = `s_WRITE;
                end
            end else begin
                status_nxt = `s_WRITE;
                req_wdata_nxt = value_result[32*burst_count+:DATA_WIDTH];
                burst_count_nxt = burst_count_nxt + 1;
            end
        end
        endcase
    end

   sync_fifo_reg #(
    .FWFT_MODE  ("TRUE"),
    .DEPTH      (FIFO_DEPTH),
    .DATA_WIDTH (DATA_WIDTH + ADDR_WIDTH)
    ) apb_data_fifo (
    //Common Signals
    .clk            (i_clk), 
    .rstn           (i_reset_n),
    //Inputs 
    .i_wr           (apb_wr_data_en),
    .i_wr_data      (wr_data),
    .i_rd           (rd_data_en),
    //Outputs
    .o_rd_data      (rd_data),
    .o_empty        (res_data_fifo_empty),
    .o_full         (res_data_fifo_full)
    );

    assign apb_wr_data_en = apb_valid && apb_write;
    assign wr_data = {apb_addr, apb_wdata};
    assign start_op = !res_data_fifo_empty;
    assign rd_data_en = start_op && ahb_rd_data_en;

    sync_fifo_reg #(
    .FWFT_MODE  ("TRUE"),
    .DEPTH      (FIFO_DEPTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) status_fifo (
    //Common Signals
    .clk            (i_clk), 
    .rstn           (i_reset_n),
    //Inputs 
    .i_wr           (wr_status_en),
    .i_wr_data      (wr_status_data),
    .i_rd           (apb_rd_status_en),
    //Outputs
    .o_rd_data      (apb_rdata),
    .o_empty        (res_status_fifo_empty),
    .o_full         (res_status_fifo_full)
    );

    assign wr_status_en = (ahb_busy_r && !ahb_busy) && !req_read;
    assign apb_rd_status_en = apb_valid && !apb_write;
    assign wr_status_data = {31'b0, !ahb_resp_r};
    assign write_ready = !res_data_fifo_full;
    assign read_ready = !res_status_fifo_empty;
    assign apb_ready = (apb_write && write_ready) || (!apb_write && read_ready);
    
endmodule
