`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/15/2024 05:55:36 PM
// Design Name: 
// Module Name: INTtoFP32
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

`define DATA_WIDTH 32
`define FP32_K_WIDTH 32
`define FP32_E_WIDTH 8
`define FP32_M_WIDTH 23

module INTtoFP32(
    input       [`DATA_WIDTH-1:0]   INT,
    output wire [`FP32_K_WIDTH-1:0] FP32 
);

    localparam MSB_IDX_WIDTH = $clog2(`DATA_WIDTH);

    wire                      is_zero;
    wire [`FP32_E_WIDTH-1:0]  tmp_exp;
    wire [`FP32_M_WIDTH-1:0]  tmp_man;
    wire [MSB_IDX_WIDTH-1:0]  msb_idx;
    wire                      msb_idx_valid;

    reg                       fp32_sign;
    reg [`FP32_E_WIDTH-1:0]   fp32_exp;
    reg [`FP32_M_WIDTH-1:0]   fp32_man;

    lzd_32b u_lzd(INT, msb_idx, msb_idx_valid);      

    assign is_zero = (INT == 0) ? 1 : 0;
    assign tmp_exp = 127 + msb_idx;
    assign tmp_man = (msb_idx <= 23) ? (INT << (23 - msb_idx)) & 23'h7fffff : (INT >> (msb_idx - 23)) & 23'h7fffff;

    always @(*) begin 
        fp32_sign = 1'b0;
        fp32_exp  = 0;
        fp32_man  = 0;
        if(!is_zero) begin 
            fp32_exp = tmp_exp;
            fp32_man = tmp_man;
        end
    end 

    assign FP32 = {fp32_sign, fp32_exp, fp32_man};


endmodule
