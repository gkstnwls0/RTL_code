`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2024 05:10:16 PM
// Design Name: 
// Module Name: test_top
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


module test_top #
    ( parameter ADDR_WIDTH = 32,
      parameter DATA_WIDTH = 32
    ) (
    input           CLK_IN_D_0_clk_n,
    input           CLK_IN_D_0_clk_p,
    input           c0_sys_0_clk_n,
    input           c0_sys_0_clk_p,
    output          c0_ddr4_0_act_n,
    output [16:0]   c0_ddr4_0_adr,
    output [1:0]    c0_ddr4_0_ba,
    output [1:0]    c0_ddr4_0_bg,
    output [1:0]    c0_ddr4_0_ck_c,
    output [1:0]    c0_ddr4_0_ck_t,
    output [1:0]    c0_ddr4_0_cke,
    output [3:0]    c0_ddr4_0_cs_n,
    inout  [63:0]   c0_ddr4_0_dq,
    inout  [15:0]   c0_ddr4_0_dqs_c,
    inout  [15:0]   c0_ddr4_0_dqs_t,
    output [1:0]    c0_ddr4_0_odt,
    output          c0_ddr4_0_par,
    output          c0_ddr4_0_reset_n,
    output          c0_init_calib_complete_0
  );
 
  //AXI to AHB
  wire [ADDR_WIDTH-1:0]   M_AHB_0_haddr;
  wire [2:0]              M_AHB_0_hburst;
  wire                    M_AHB_0_hmastlock;
  wire [3:0]              M_AHB_0_hprot;
  wire [DATA_WIDTH-1:0]   M_AHB_0_hrdata;
  wire                    M_AHB_0_hready;
  wire                    M_AHB_0_hresp;
  wire [2:0]              M_AHB_0_hsize;
  wire [1:0]              M_AHB_0_htrans;
  wire [DATA_WIDTH-1:0]   M_AHB_0_hwdata;
  wire                    M_AHB_0_hwrite;

  //AHB to AXI
  wire [ADDR_WIDTH-1:0]   AHB_INTERFACE_0_haddr;
  wire [2:0]              AHB_INTERFACE_0_hburst;
  wire [3:0]              AHB_INTERFACE_0_hprot;
  wire [DATA_WIDTH-1:0]   AHB_INTERFACE_0_hrdata;
  wire                    AHB_INTERFACE_0_hready_out;
  wire                    AHB_INTERFACE_0_hresp;
  wire [2:0]              AHB_INTERFACE_0_hsize;
  wire [1:0]              AHB_INTERFACE_0_htrans;
  wire [DATA_WIDTH-1:0]   AHB_INTERFACE_0_hwdata;
  wire                    AHB_INTERFACE_0_hwrite;
  wire                    AHB_INTERFACE_0_sel;

  //APB
  wire                    apb_psel;                
  wire                    apb_penable;          
  wire                    apb_pwrite;
  wire [ADDR_WIDTH-1:0]   apb_paddr;
  wire [DATA_WIDTH-1:0]   apb_pwdata;
  wire                    apb_pready;
  wire [DATA_WIDTH-1:0]   apb_prdata;
  wire                    apb_pslverr; 
  
  wire                    clk;
  wire                    reset_n;
          
    
  design_1_wrapper U0 (
    .CLK_IN_D_0_clk_n             (CLK_IN_D_0_clk_n),
    .CLK_IN_D_0_clk_p             (CLK_IN_D_0_clk_p),
    //AHB to AXI
    .AHB_INTERFACE_0_haddr        (AHB_INTERFACE_0_haddr),
    .AHB_INTERFACE_0_hburst       (AHB_INTERFACE_0_hburst),
    .AHB_INTERFACE_0_hprot        (AHB_INTERFACE_0_hprot),
    .AHB_INTERFACE_0_hrdata       (AHB_INTERFACE_0_hrdata),
    .AHB_INTERFACE_0_hready_in    (AHB_INTERFACE_0_hready_out),
    .AHB_INTERFACE_0_hready_out   (AHB_INTERFACE_0_hready_out),
    .AHB_INTERFACE_0_hresp        (AHB_INTERFACE_0_hresp),
    .AHB_INTERFACE_0_hsize        (AHB_INTERFACE_0_hsize),
    .AHB_INTERFACE_0_htrans       (AHB_INTERFACE_0_htrans),
    .AHB_INTERFACE_0_hwdata       (AHB_INTERFACE_0_hwdata),
    .AHB_INTERFACE_0_hwrite       (AHB_INTERFACE_0_hwrite),
    .AHB_INTERFACE_0_sel          (AHB_INTERFACE_0_sel),
    //AXI to AHB
    .M_AHB_0_haddr                (M_AHB_0_haddr),
    .M_AHB_0_hburst               (M_AHB_0_hburst),
    .M_AHB_0_hmastlock            (M_AHB_0_hmastlock),
    .M_AHB_0_hprot                (M_AHB_0_hprot),
    .M_AHB_0_hrdata               (M_AHB_0_hrdata),
    .M_AHB_0_hready               (M_AHB_0_hready),
    .M_AHB_0_hresp                (M_AHB_0_hresp),
    .M_AHB_0_hsize                (M_AHB_0_hsize),
    .M_AHB_0_htrans               (M_AHB_0_htrans),
    .M_AHB_0_hwdata               (M_AHB_0_hwdata),
    .M_AHB_0_hwrite               (M_AHB_0_hwrite),
    //MIG
    .c0_ddr4_0_act_n              (c0_ddr4_0_act_n),
    .c0_ddr4_0_adr                (c0_ddr4_0_adr),
    .c0_ddr4_0_ba                 (c0_ddr4_0_ba),
    .c0_ddr4_0_bg                 (c0_ddr4_0_bg),
    .c0_ddr4_0_ck_c               (c0_ddr4_0_ck_c),
    .c0_ddr4_0_ck_t               (c0_ddr4_0_ck_t),
    .c0_ddr4_0_cke                (c0_ddr4_0_cke),
    .c0_ddr4_0_cs_n               (c0_ddr4_0_cs_n),
    .c0_ddr4_0_dq                 (c0_ddr4_0_dq),
    .c0_ddr4_0_dqs_c              (c0_ddr4_0_dqs_c),
    .c0_ddr4_0_dqs_t              (c0_ddr4_0_dqs_t),
    .c0_ddr4_0_odt                (c0_ddr4_0_odt),
    .c0_ddr4_0_par                (c0_ddr4_0_par),
    .c0_ddr4_0_reset_n            (c0_ddr4_0_reset_n),
    .c0_init_calib_complete_0     (c0_init_calib_complete_0),
    .c0_sys_0_clk_n               (c0_sys_0_clk_n),
    .c0_sys_0_clk_p               (c0_sys_0_clk_p),
    .c0_ddr4_ui_clk_0             (clk),
    .peripheral_aresetn_0         (reset_n)    
  );
  
  ahb_to_apb_converter #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
  ) AHB2APB_bridge(
    .i_clk                       (clk),
    .i_reset_n                   (reset_n),
    .i_haddr                     (M_AHB_0_haddr),
    .i_hburst                    (M_AHB_0_hburst),
    .i_hmasterlock               (M_AHB_0_hmastlock),
    .i_hprot                     (M_AHB_0_hprot),
    .i_hsize                     (M_AHB_0_hsize),
    .i_htrans                    (M_AHB_0_htrans),
    .i_hwdata                    (M_AHB_0_hwdata),
    .i_hwrite                    (M_AHB_0_hwrite),
    .i_hreadyin                  (M_AHB_0_hready),
    .o_hrdata                    (M_AHB_0_hrdata),
    .o_hreadyout                 (M_AHB_0_hready),
    .o_hresp                     (M_AHB_0_hresp),
    .o_psel                      (apb_psel),
    .o_penable                   (apb_penable),
    .o_pwrite                    (apb_pwrite),
    .o_paddr                     (apb_paddr),
    .o_pwdata                    (apb_pwdata),
    .i_pready                    (apb_pready),
    .i_prdata                    (apb_prdata),
    .i_pslverr                   (apb_pslver)  
  );
  
  test_ip  #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
  ) test_ip(
   .i_clk                       (clk),
   .i_reset_n                   (reset_n),
   .i_psel                      (apb_psel),
   .i_penable                   (apb_penable),
   .i_pwrite                    (apb_pwrite),
   .i_paddr                     (apb_paddr),
   .i_pwdata                    (apb_pwdata),
   .o_pready                    (apb_pready),
   .o_prdata                    (apb_prdata),
   .o_pslverr                   (apb_pslver),
   .i_hrdata                    (AHB_INTERFACE_0_hrdata),
   .i_hready                    (AHB_INTERFACE_0_hready_out),
   .i_hresp                     (AHB_INTERFACE_0_hresp),
   .o_hsel                      (AHB_INTERFACE_0_sel),
   .o_haddr                     (AHB_INTERFACE_0_haddr),
   .o_hburst                    (AHB_INTERFACE_0_hburst),
   .o_hprot                     (AHB_INTERFACE_0_hprot),
   .o_hsize                     (AHB_INTERFACE_0_hsize),
   .o_htrans                    (AHB_INTERFACE_0_htrans),
   .o_hwdata                    (AHB_INTERFACE_0_hwdata),
   .o_hwrite                    (AHB_INTERFACE_0_hwrite)
  );
    
endmodule
