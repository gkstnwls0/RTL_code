`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2024 03:33:00 PM
// Design Name: 
// Module Name: lzd_32b
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


module lzd_32b(
    input [31:0]      i_a,          
    output wire [4:0] o_po,              
    output wire       o_po_valid);

    wire [3:0] upper_po;
    wire [3:0] lower_po;
    wire       upper_po_valid;
    wire       lower_po_valid;

    lzd_16b upper_lzd(i_a[31:16],upper_po,upper_po_valid);
    lzd_16b lower_lzd(i_a[15:0],lower_po,lower_po_valid);

    assign o_po_valid = upper_po_valid || lower_po_valid;
    assign o_po       = upper_po_valid ? {1'b1,upper_po} : {1'b0,lower_po};

endmodule
