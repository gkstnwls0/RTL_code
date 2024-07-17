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


module lzd_8b(
    input [7:0]       i_a,          
    output wire [2:0] o_po,              
    output wire       o_po_valid);

    wire [1:0] upper_po;
    wire [1:0] lower_po;
    wire       upper_po_valid;
    wire       lower_po_valid;

    lzd_4b upper_lzd(i_a[7:4],upper_po,upper_po_valid);
    lzd_4b lower_lzd(i_a[3:0],lower_po,lower_po_valid);

    assign o_po_valid = upper_po_valid || lower_po_valid;
    assign o_po       = upper_po_valid ? {1'b1,upper_po} : {1'b0,lower_po};

endmodule
