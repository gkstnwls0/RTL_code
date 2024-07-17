`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/02 20:48:06
// Design Name: 
// Module Name: tb_ahb_master
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

`define AXI_SLAVE_BASE_ADDRESS 32'hc44A0_0000

module tb_ahb2apb();
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    import axi_vip_pkg::*;
    import axi_vip_0_pkg::*;


    axi_vip_0_mst_t vip_mst_agent;
    xil_axi_resp_t  axi_resp;
    xil_axi_resp_t  [1:0]axi_bresp;
    xil_axi_resp_t  [1:0]axi_rresp;
    xil_axi_ulong axi4_addr;
    bit [DATA_WIDTH-1:0] axi4_data[4];
    bit [DATA_WIDTH-1:0] resp_data;
    xil_axi_len_t axi4_len;
    xil_axi_size_t axi4_size;
    xil_axi_burst_t axi4_burst;
    xil_axi_lock_t axi4_lock;
    xil_axi_cache_t axi4_cache;
    xil_axi_prot_t axi4_prot;
    xil_axi_region_t axi4_region;
    xil_axi_qos_t axi4_qos;
    xil_axi_user_beat axi4_awuser;
    xil_axi_data_beat  axi4_wuser;
    xil_axi_user_beat axi4_aruser;
    xil_axi_data_beat axi4_ruser;
    

    logic                  clk;
    logic                reset_n;
    logic [31 : 0]  m_axi_awaddr;
    logic [2:0]     m_axi_awprot;
    logic [1:0]     m_axi_awburst;
    logic [3:0]     m_axi_awcache;
    logic [7:0]     m_axi_awlen;
    logic           m_axi_awlock;
    logic [2:0]     m_axi_awsize;
    logic           m_axi_awvalid;
    logic           m_axi_awready;

    logic [31 : 0]  m_axi_wdata;
    logic [3:0]     m_axi_wstrb;
    logic           m_axi_wvalid;
    logic           m_axi_wready;
    logic           m_axi_wlast;

    logic [1 : 0]   m_axi_bresp;
    logic           m_axi_bvalid;
    logic           m_axi_bready;

    logic [31 : 0]  m_axi_araddr;
    logic [1:0]     m_axi_arburst;
    logic [2:0]     m_axi_arprot;
    logic [3:0]     m_axi_arcache;
    logic [7:0]     m_axi_arlen;
    logic           m_axi_arlock;
    logic [2:0]     m_axi_arprot;
    logic [2:0]     m_axi_arsize;
    logic           m_axi_arvalid;
    logic           m_axi_arready;

    logic [31 : 0]  m_axi_rdata;
    logic [1 : 0]   m_axi_rresp;
    logic           m_axi_rvalid;
    logic           m_axi_rready;
    logic           m_axi_rlast;

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

    logic                  apb_psel;
    logic                  apb_penable;
    logic                  apb_pwrite;
    logic [ADDR_WIDTH-1:0] apb_paddr;
    logic [DATA_WIDTH-1:0] apb_pwdata;
    logic                  apb_pready;
    logic [DATA_WIDTH-1:0] apb_prdata;
    logic                  apb_pslver;

    // Test Bench
    int slv_base_addr;

    
    //axi lite
    // axi_vip_1 u_axi_lite_vip (
    //     .aclk          (clk),             // input wire aclk
    //     .aresetn       (reset_n),         // input wire aresetn
    //     .m_axi_awaddr  (m_axi_awaddr),    // output wire [31 : 0] m_axi_awaddr
    //     .m_axi_awvalid (m_axi_awvalid),   // output wire m_axi_awvalid
    //     .m_axi_awready (m_axi_awready),   // input wire m_axi_awready
    //     .m_axi_wdata   (m_axi_wdata),     // output wire [31 : 0] m_axi_wdata
    //     .m_axi_wvalid  (m_axi_wvalid),    // output wire m_axi_wvalid
    //     .m_axi_wready  (m_axi_wready),    // input wire m_axi_wready
    //     .m_axi_bresp   (m_axi_bresp),     // input wire [1 : 0] m_axi_bresp
    //     .m_axi_bvalid  (m_axi_bvalid),    // input wire m_axi_bvalid
    //     .m_axi_bready  (m_axi_bready),    // output wire m_axi_bready
    //     .m_axi_araddr  (m_axi_araddr),    // output wire [31 : 0] m_axi_araddr
    //     .m_axi_arvalid (m_axi_arvalid),   // output wire m_axi_arvalid
    //     .m_axi_arready (m_axi_arready),   // input wire m_axi_arready
    //     .m_axi_rdata   (m_axi_rdata),     // input wire [31 : 0] m_axi_rdata
    //     .m_axi_rresp   (m_axi_rresp),     // input wire [1 : 0] m_axi_rresp
    //     .m_axi_rvalid  (m_axi_rvalid),    // input wire m_axi_rvalid
    //     .m_axi_rready  (m_axi_rready)     // output wire m_axi_rready
    // );

    //   design_2_wrapper u_axi_inct1 (
    //     .ACLK_0(clk),
    //     .ARESETN_0(reset_n),
    //     .M_AHB_0_haddr(AHB_INTERFACE_0_haddr),
    //     .M_AHB_0_hburst(AHB_INTERFACE_0_hburst),
    //     .M_AHB_0_hmastlock(),
    //     .M_AHB_0_hprot(AHB_INTERFACE_0_hprot),
    //     .M_AHB_0_hrdata(AHB_INTERFACE_0_hrdata),
    //     .M_AHB_0_hready(AHB_INTERFACE_0_hready_out),
    //     .M_AHB_0_hresp(AHB_INTERFACE_0_hresp),
    //     .M_AHB_0_hsize(AHB_INTERFACE_0_hsize),
    //     .M_AHB_0_htrans(AHB_INTERFACE_0_htrans),
    //     .M_AHB_0_hwdata(AHB_INTERFACE_0_hwdata),
    //     .M_AHB_0_hwrite(AHB_INTERFACE_0_hwrite),

    //     .S00_AXI_0_araddr(m_axi_araddr),
    //     .S00_AXI_0_arready(m_axi_arready),
    //     .S00_AXI_0_arvalid(m_axi_arvalid),
    //     .S00_AXI_0_arprot(3'b000),
        
    //     .S00_AXI_0_awaddr(m_axi_awaddr),
    //     .S00_AXI_0_awready(m_axi_awready),
    //     .S00_AXI_0_awvalid(m_axi_awvalid),
    //     .S00_AXI_0_awprot(3'b000),
        
    //     .S00_AXI_0_bready(m_axi_bready),
    //     .S00_AXI_0_bresp(m_axi_bresp),
    //     .S00_AXI_0_bvalid(m_axi_bvalid),

    //     .S00_AXI_0_rdata(m_axi_rdata),
    //     .S00_AXI_0_rready(m_axi_rready),
    //     .S00_AXI_0_rresp(m_axi_rresp),
    //     .S00_AXI_0_rvalid(m_axi_rvalid),

    //     .S00_AXI_0_wdata(m_axi_wdata),
    //     .S00_AXI_0_wstrb(4'b1111),
    //     .S00_AXI_0_wready(m_axi_wready),
    //     .S00_AXI_0_wvalid(m_axi_wvalid)
    // );

    //axi4
    axi_vip_0 u_axi_vip (
        .aclk          (clk),             // input wire aclk
        .aresetn       (reset_n),         // input wire aresetn
        .m_axi_awaddr  (m_axi_awaddr),    // output wire [31 : 0] m_axi_awaddr
        .m_axi_awlen   (m_axi_awlen),
        .m_axi_awsize  (m_axi_awsize),
        .m_axi_awburst (m_axi_awburst),
        .m_axi_awprot  (m_axi_awprot),
        .m_axi_awvalid (m_axi_awvalid),   // output wire m_axi_awvalid
        .m_axi_awready (m_axi_awready),   // input wire m_axi_awready
        .m_axi_wdata   (m_axi_wdata),     // output wire [31 : 0] m_axi_wdata
        .m_axi_wvalid  (m_axi_wvalid),    // output wire m_axi_wvalid
        .m_axi_wready  (m_axi_wready),    // input wire m_axi_wready
        .m_axi_wlast   (m_axi_wlast),
        .m_axi_bresp   (m_axi_bresp),     // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid  (m_axi_bvalid),    // input wire m_axi_bvalid
        .m_axi_bready  (m_axi_bready),    // output wire m_axi_bready
        .m_axi_araddr  (m_axi_araddr),    // output wire [31 : 0] m_axi_araddr
        .m_axi_arlen   (m_axi_arlen),
        .m_axi_arsize  (m_axi_arsize),
        .m_axi_arburst (m_axi_arburst),
        .m_axi_arprot  (m_axi_arprot),
        .m_axi_arvalid (m_axi_arvalid),   // output wire m_axi_arvalid
        .m_axi_arready (m_axi_arready),   // input wire m_axi_arready
        .m_axi_rdata   (m_axi_rdata),     // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp   (m_axi_rresp),     // input wire [1 : 0] m_axi_rresp
        .m_axi_rlast   (m_axi_rlast),
        .m_axi_rvalid  (m_axi_rvalid),    // input wire m_axi_rvalid
        .m_axi_rready  (m_axi_rready)     // output wire m_axi_rready
      );

      design_2_wrapper u_axi_inct1 (
        .ACLK_0(clk),
        .ARESETN_0(reset_n),
        .M_AHB_0_haddr(AHB_INTERFACE_0_haddr),
        .M_AHB_0_hburst(AHB_INTERFACE_0_hburst),
        .M_AHB_0_hmastlock(),
        .M_AHB_0_hprot(AHB_INTERFACE_0_hprot),
        .M_AHB_0_hrdata(AHB_INTERFACE_0_hrdata),
        .M_AHB_0_hready(AHB_INTERFACE_0_hready_out),
        .M_AHB_0_hresp(AHB_INTERFACE_0_hresp),
        .M_AHB_0_hsize(AHB_INTERFACE_0_hsize),
        .M_AHB_0_htrans(AHB_INTERFACE_0_htrans),
        .M_AHB_0_hwdata(AHB_INTERFACE_0_hwdata),
        .M_AHB_0_hwrite(AHB_INTERFACE_0_hwrite),

        .S00_AXI_0_araddr(m_axi_araddr),
        .S00_AXI_0_arready(m_axi_arready),
        .S00_AXI_0_arvalid(m_axi_arvalid),
        .S00_AXI_0_arprot(m_axi_arprot),
        .S00_AXI_0_arburst(m_axi_arburst),
        .S00_AXI_0_arcache(),
        .S00_AXI_0_arlen(m_axi_arlen),
        .S00_AXI_0_arlock(),
        .S00_AXI_0_arsize(m_axi_arsize),
        
        .S00_AXI_0_awaddr(m_axi_awaddr),
        .S00_AXI_0_awready(m_axi_awready),
        .S00_AXI_0_awvalid(m_axi_awvalid),
        .S00_AXI_0_awprot(m_axi_awprot),
        .S00_AXI_0_awburst(m_axi_awburst),
        .S00_AXI_0_awcache(),
        .S00_AXI_0_awlen(m_axi_awlen),
        .S00_AXI_0_awlock(),
        .S00_AXI_0_awsize(m_axi_awsize),
        
        .S00_AXI_0_bready(m_axi_bready),
        .S00_AXI_0_bresp(m_axi_bresp),
        .S00_AXI_0_bvalid(m_axi_bvalid),

        .S00_AXI_0_rdata(m_axi_rdata),
        .S00_AXI_0_rready(m_axi_rready),
        .S00_AXI_0_rresp(m_axi_rresp),
        .S00_AXI_0_rvalid(m_axi_rvalid),
        .S00_AXI_0_rlast(m_axi_rlast),

        .S00_AXI_0_wdata(m_axi_wdata),
        .S00_AXI_0_wstrb(m_axi_wstrb),
        .S00_AXI_0_wready(m_axi_wready),
        .S00_AXI_0_wvalid(m_axi_wvalid),
        .S00_AXI_0_wlast(m_axi_wlast)
    );
      
    ahb_to_apb_converter # (
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) ahb2apb_bridge (
        .i_clk          (clk),
        .i_reset_n      (reset_n),
        .i_haddr        (AHB_INTERFACE_0_haddr),
        .i_hburst       (AHB_INTERFACE_0_hburst),
        .i_hmasterlock  (),
        .i_hprot        (AHB_INTERFACE_0_hprot),
        .i_hsize        (AHB_INTERFACE_0_hsize),
        .i_htrans       (AHB_INTERFACE_0_htrans),
        .i_hwdata       (AHB_INTERFACE_0_hwdata),
        .i_hwrite       (AHB_INTERFACE_0_hwrite),
        .i_hreadyin     (AHB_INTERFACE_0_hready_out),
        .o_hrdata       (AHB_INTERFACE_0_hrdata),
        .o_hreadyout    (AHB_INTERFACE_0_hready_out),
        .o_hresp        (AHB_INTERFACE_0_hresp),
        .o_psel         (apb_psel),
        .o_penable      (apb_penable),
        .o_pwrite       (apb_pwrite),
        .o_paddr        (apb_paddr),
        .o_pwdata       (apb_pwdata),
        .i_pready       (apb_pready),
        .i_prdata       (apb_prdata),
        .i_pslverr      (apb_pslver)
    );


    apb_wrapper # (
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) apb_slave (
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

   
    initial begin 
        
        // AXI Lite 
        //Base Address : 0x44A0_0000
        // slv_base_addr = 32'h44A0_0004;
 
        // vip_mst_agent = new("master vip agent", u_axi_lite_vip.inst.IF);

        // vip_mst_agent.start_master();

        // vip_mst_agent.AXI4LITE_WRITE_BURST(32'h44A0_0000,0,32'h0123,axi_resp);
        
        // vip_mst_agent.AXI4LITE_WRITE_BURST(32'h44A0_0004,0,32'h1234,axi_resp);
        
        // vip_mst_agent.AXI4LITE_READ_BURST(32'h44A0_0000,0,resp_data,axi_resp);

        // vip_mst_agent.AXI4LITE_READ_BURST(32'h44A0_0004,0,resp_data,axi_resp);

        // $stop;

        //axi4
        axi4_size   = XIL_AXI_SIZE_4BYTE;
        axi4_burst  = XIL_AXI_BURST_TYPE_WRAP;
        axi4_len    = 3;
        axi4_lock   = XIL_AXI_ALOCK_NOLOCK;
        axi4_cache  = 0;
        axi4_prot   = 3'b000;
        axi4_region = 0;
        axi4_qos    = 0;
        axi4_awuser = 0;
        axi4_aruser = 0;
        axi4_wuser  = 0;
        axi4_ruser  = 0;
        
        slv_base_addr = 32'h44A0_0004;

        vip_mst_agent = new("master vip agent", u_axi_vip.inst.IF);

        vip_mst_agent.start_master();
        
        foreach (axi4_data[i]) begin
            axi4_data[i] = $random;
        end

        vip_mst_agent.AXI4_WRITE_BURST(
            0,              //ID
            slv_base_addr,  //ADDR
            axi4_len,       //Burst Length
            axi4_size,      //Data Size
            axi4_burst,     //Burst type
            axi4_lock,      //Lock
            axi4_cache,     //Cache
            axi4_prot,      //Prot
            axi4_region,    //Region
            axi4_qos,       //Qos
            axi4_awuser,    //AWUSER
            {axi4_data[3], axi4_data[2], axi4_data[1], axi4_data[0]},   //WDATA({axi4_data[3], axi4_data[2], axi4_data[1], axi4_data[0]},)
            axi4_wuser,     //WUSER                  
            axi_bresp        //RESP
        );

        vip_mst_agent.AXI4_READ_BURST(
            0,              //ID
            slv_base_addr,  //ADDR
            axi4_len,       //Burst Length
            axi4_size,      //Data Size
            axi4_burst,     //Burst type
            axi4_lock,      //Lock
            axi4_cache,     //Cache
            axi4_prot,      //Prot
            axi4_region,    //Region
            axi4_qos,       //Qos
            axi4_awuser,    //AWUSER
            resp_data,      //WDATA
            axi_rresp,      //RESP                  
            axi4_ruser     //RUSER
        );

        $stop;
        
        // $display("[AXI4LITE] RESP DATA [%x]",resp_data);

    end

endmodule
