`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KETI
// Engineer: MinKyu Lee
// 
// Create Date: 12/12/2023 02:46:27 PM
// Design Name: 
// Module Name: lzd_8b
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


module lzd_16b(
    input [15:0]      i_a,          
    output wire [3:0] o_po,              
    output wire       o_po_valid);

    wire [2:0] upper_po;
    wire [2:0] lower_po;
    wire       upper_po_valid;
    wire       lower_po_valid;

    lzd_8b upper_lzd(i_a[15:8],upper_po,upper_po_valid);
    lzd_8b lower_lzd(i_a[7:0],lower_po,lower_po_valid);

    assign o_po_valid = upper_po_valid || lower_po_valid;
    assign o_po       = upper_po_valid ? {1'b1,upper_po} : {1'b0,lower_po};

endmodule
