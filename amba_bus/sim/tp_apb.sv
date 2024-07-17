`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2024 02:21:44 PM
// Design Name: 
// Module Name: tp_apb
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


module tp_apb();
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    import axi_vip_pkg::*;
    import axi_vip_0_pkg::*;

    axi_vip_0_mst_t vip_mst_agent;
    xil_axi_resp_t  axi_resp;

    logic                  clk;
    logic                  reset_n;
    logic                  apb_psel;
    logic                  apb_penable;
    logic                  apb_pwrite;
    logic [ADDR_WIDTH-1:0] apb_paddr;
    logic [DATA_WIDTH-1:0] apb_pwdata;
    logic                  apb_pready;
    logic [DATA_WIDTH-1:0] apb_prdata;
    logic                  apb_pslver;

  
    logic [31 : 0]  m_axi_awaddr;
    logic           m_axi_awvalid;
    logic           m_axi_awready;
    logic [31 : 0]  m_axi_wdata;
    logic           m_axi_wvalid;
    logic           m_axi_wready;
    logic [1 : 0]   m_axi_bresp;
    logic           m_axi_bvalid;
    logic           m_axi_bready;
    logic [31 : 0]  m_axi_araddr;
    logic           m_axi_arvalid;
    logic           m_axi_arready;
    logic [31 : 0]  m_axi_rdata;
    logic [1 : 0]   m_axi_rresp;
    logic           m_axi_rvalid;
    logic           m_axi_rready;

    // Test Bench
    int                     slv_base_addr;
    bit [DATA_WIDTH-1:0]    resp_data;


    axi_vip_0 u_axi_lite_vip (
        .aclk          (clk),             // input wire aclk
        .aresetn       (reset_n),         // input wire aresetn
        .m_axi_awaddr  (m_axi_awaddr),    // output wire [31 : 0] m_axi_awaddr
        .m_axi_awvalid (m_axi_awvalid),   // output wire m_axi_awvalid
        .m_axi_awready (m_axi_awready),   // input wire m_axi_awready
        .m_axi_wdata   (m_axi_wdata),     // output wire [31 : 0] m_axi_wdata
        .m_axi_wvalid  (m_axi_wvalid),    // output wire m_axi_wvalid
        .m_axi_wready  (m_axi_wready),    // input wire m_axi_wready
        .m_axi_bresp   (m_axi_bresp),     // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid  (m_axi_bvalid),    // input wire m_axi_bvalid
        .m_axi_bready  (m_axi_bready),    // output wire m_axi_bready
        .m_axi_araddr  (m_axi_araddr),    // output wire [31 : 0] m_axi_araddr
        .m_axi_arvalid (m_axi_arvalid),   // output wire m_axi_arvalid
        .m_axi_arready (m_axi_arready),   // input wire m_axi_arready
        .m_axi_rdata   (m_axi_rdata),     // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp   (m_axi_rresp),     // input wire [1 : 0] m_axi_rresp
        .m_axi_rvalid  (m_axi_rvalid),    // input wire m_axi_rvalid
        .m_axi_rready  (m_axi_rready)     // output wire m_axi_rready
      );
    // AXI Interconnect (AXI - AXI_Lite - APB)
    design_1_wrapper u_axi_inct (
        .ACLK_0             (clk),
        .ARESETN_0          (reset_n),
        // APB Interface
        .APB_M_0_paddr      (apb_paddr),
        .APB_M_0_penable    (apb_penable),
        .APB_M_0_prdata     (apb_prdata),
        .APB_M_0_pready     (apb_pready),
        .APB_M_0_psel       (apb_psel),
        .APB_M_0_pslverr    (apb_pslver),
        .APB_M_0_pwdata     (apb_pwdata),
        .APB_M_0_pwrite     (apb_pwrite),
        // AXI Interface
        .S00_AXI_0_araddr   (m_axi_araddr),
        .S00_AXI_0_arready  (m_axi_arready),
        .S00_AXI_0_arvalid  (m_axi_arvalid),
        .S00_AXI_0_awaddr   (m_axi_awaddr),
        .S00_AXI_0_awready  (m_axi_awready),
        .S00_AXI_0_awvalid  (m_axi_awvalid),
        .S00_AXI_0_bready   (m_axi_bready),
        .S00_AXI_0_bresp    (m_axi_bresp),
        .S00_AXI_0_bvalid   (m_axi_bvalid),
        .S00_AXI_0_rdata    (m_axi_rdata),
        .S00_AXI_0_rready   (m_axi_rready),
        .S00_AXI_0_rresp    (m_axi_rresp),
        .S00_AXI_0_rvalid   (m_axi_rvalid),
        .S00_AXI_0_wdata    (m_axi_wdata),
        .S00_AXI_0_wready   (m_axi_wready),
        .S00_AXI_0_wvalid   (m_axi_wvalid)
        );

    apb_wrapper # (
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
      // Common 
        .i_clk                  (clk),
        .i_reset_n              (reset_n),
      // Bus Interface
        .i_psel                 (apb_psel),
        .i_penable              (apb_penable),
        .i_pwrite               (apb_pwrite),
        .i_paddr                (apb_paddr),
        .i_pwdata               (apb_pwdata),
        .o_pready               (apb_pready),
        .o_prdata               (apb_prdata),
        .o_pslverr              (apb_pslver) 
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

    // AXI Lite Base Address : 0x44A0_0000
    initial begin 
        slv_base_addr = 32'h44A0_0000;
        #5000;
        vip_mst_agent = new("master vip agent", u_axi_lite_vip.inst.IF);

        vip_mst_agent.start_master();

        vip_mst_agent.AXI4LITE_WRITE_BURST(slv_base_addr,0,32'h0123,axi_resp);

        vip_mst_agent.AXI4LITE_READ_BURST(slv_base_addr,0,resp_data,axi_resp);
        
        vip_mst_agent.AXI4LITE_WRITE_BURST(32'h44A0_000C,0,32'h1234,axi_resp);
        
        vip_mst_agent.AXI4LITE_READ_BURST(32'h44A0_000C,0,resp_data,axi_resp);

        $display("[AXI4LITE] RESP DATA [%x]",resp_data);
        
        $stop;

    end

endmodule
