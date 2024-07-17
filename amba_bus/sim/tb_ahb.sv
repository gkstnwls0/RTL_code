`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2024 11:07:55 AM
// Design Name: 
// Module Name: tb_ahb
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


module tb_ahb();
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    logic                           clk;
    logic                           reset_n;    
    logic [ADDR_WIDTH-1:0]          AHB_INTERFACE_0_haddr;
    logic [2:0]                     AHB_INTERFACE_0_hburst;
    logic [3:0]                     AHB_INTERFACE_0_hprot;
    logic [DATA_WIDTH-1:0]          AHB_INTERFACE_0_hrdata;
    // logic                           AHB_INTERFACE_0_hready_in;
    logic                           AHB_INTERFACE_0_hready_out;
    logic                           AHB_INTERFACE_0_hresp;
    logic [2:0]                     AHB_INTERFACE_0_hsize;
    logic [1:0]                     AHB_INTERFACE_0_htrans;
    logic [DATA_WIDTH-1:0]          AHB_INTERFACE_0_hwdata;
    logic                           AHB_INTERFACE_0_hwrite;
    logic                           AHB_INTERFACE_0_sel;

    logic                           req_valid;
    logic                           req_read; 
    logic [ADDR_WIDTH-1:0]          req_addr;
    logic [4:0]                     req_sz;              
    logic                           req_wdata_valid;     
    logic [DATA_WIDTH-1:0]          req_wdata;
    logic                           req_rddata_valid;
    logic [DATA_WIDTH-1:0]          req_rdata;
    logic                           ahb_busy;

    ahb_master #(
        .AHB_LITE_ON("ON"),
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .MASK_WIDTH(32/8),
        .MASTER_NUM(0)
        ) u_ahb_master (
          // Common 
        .i_clk                          (clk),
        .i_reset_n                      (reset_n),
        // Read/Write Request from IP
        .i_req_valid                    (req_valid),
        .i_req_read                     (req_read), 
        .i_req_addr                     (req_addr),
        .i_req_sz                       (req_sz),              
        .i_req_wdata_valid              (req_wdata_valid),     
        .i_req_wdata                    (req_wdata),
        .o_req_rddata_valid             (req_rddata_valid),
        .o_req_rdata                    (req_rdata),
        .o_ahb_busy                     (ahb_busy),
        // Bus Interface - Arbiter
        .o_arb_hbusreq                  (),          
        .o_arb_hlock                    (),            
        .i_arb_hgrant                   (),           
        .i_arb_hmaster                  (),          
        .i_arb_hmasterlock              (),      
        // Bus Interface - Slave
        .o_hsel                         (AHB_INTERFACE_0_sel),                 
        .o_haddr                        (AHB_INTERFACE_0_haddr),                
        .o_hburst                       (AHB_INTERFACE_0_hburst),               
        .o_hmasterlock                  (),          
        .o_hprot                        (AHB_INTERFACE_0_hprot),                
        .o_hsize                        (AHB_INTERFACE_0_hsize),                
        .o_htrans                       (AHB_INTERFACE_0_htrans),               
        .o_hwdata                       (AHB_INTERFACE_0_hwdata),               
        .o_hstrb                        (),                
        .o_hwrite                       (AHB_INTERFACE_0_hwrite),               
        .i_hrdata                       (AHB_INTERFACE_0_hrdata),               
        .i_hready                       (AHB_INTERFACE_0_hready_out),               
        .i_hresp                        (AHB_INTERFACE_0_hresp)                 
        ); 

    ahb_test_wrapper u_ahb_test(
        .s_ahb_hclk_0               (clk),
        .s_ahb_hresetn_0            (reset_n),
        .AHB_INTERFACE_0_haddr      (AHB_INTERFACE_0_haddr),
        .AHB_INTERFACE_0_hburst     (AHB_INTERFACE_0_hburst),
        .AHB_INTERFACE_0_hprot      (AHB_INTERFACE_0_hprot),
        .AHB_INTERFACE_0_hrdata     (AHB_INTERFACE_0_hrdata),
        .AHB_INTERFACE_0_hready_in  (AHB_INTERFACE_0_hready_out),
        .AHB_INTERFACE_0_hready_out (AHB_INTERFACE_0_hready_out),
        .AHB_INTERFACE_0_hresp      (AHB_INTERFACE_0_hresp),
        .AHB_INTERFACE_0_hsize      (AHB_INTERFACE_0_hsize),
        .AHB_INTERFACE_0_htrans     (AHB_INTERFACE_0_htrans),
        .AHB_INTERFACE_0_hwdata     (AHB_INTERFACE_0_hwdata),
        .AHB_INTERFACE_0_hwrite     (AHB_INTERFACE_0_hwrite),
        .AHB_INTERFACE_0_sel        (AHB_INTERFACE_0_sel)
    );

    //**************************************************************************//
    // Reset Generation
    //**************************************************************************//    
    initial begin
        reset_n = 1'b0;
        #1000;
        reset_n = 1'b1;

     end
   
     //**************************************************************************//
     // Clock Generation
     //**************************************************************************//
   
     initial
        clk = 1'b0;
     always
        clk = #20 ~clk;    

    // AXI Base Address : C000_0000
    initial begin 
        req_valid        = 0;
        req_read         = 0; 
        req_addr         = 0;
        req_sz           = 0;              
        req_wdata_valid  = 0;     
        req_wdata        = 0;
        // req_rddata_valid = 0;
        // req_rdata        = 0;
        // ahb_busy         = 0;   
        
        #5000;
        @(posedge clk);
        req_valid        = 1;
        req_read         = 0; 
        req_addr         = 'hC000_0000;
        req_sz           = 3;  
        req_wdata_valid  = 1'b1;
        req_wdata        = 'h1234;   
        @(posedge clk);
        req_valid        = 1'b0;
        req_wdata_valid  = 1'b1;
        req_wdata        = 'h4567;   
        @(posedge clk);
        req_wdata_valid  = 1'b1;
        req_wdata        = 'h89AB;   
        @(posedge clk);
        req_wdata_valid  = 1'b1;
        req_wdata        = 'hCDEF;   
        @(posedge clk);     
        req_wdata_valid  = 1'b0;

        #1000;

        @(posedge clk);     
        req_valid        = 1;
        req_read         = 1; 
        req_addr         = 'hC000_0000;
        req_sz           = 3;  

        @(posedge clk);     
        req_valid        = 0;        
        #1000;
        $stop;
                  
    end    
endmodule
