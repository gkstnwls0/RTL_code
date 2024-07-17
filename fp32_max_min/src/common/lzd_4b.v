`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KETI
// Engineer: MinKyu Lee
// 
// Create Date: 12/12/2023 02:47:04 PM
// Design Name: 
// Module Name: lzd_4b
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


module lzd_4b(input [3:0] i_a,
              output wire [1:0] o_po,
              output wire o_po_valid);

    reg [2:0] po_and_valid;
    always @(*) begin 
        casez(i_a)
            4'b0000: po_and_valid = 3'b0_00;
            4'b0001: po_and_valid = 3'b1_00;
            4'b001?: po_and_valid = 3'b1_01;
            4'b01??: po_and_valid = 3'b1_10;
            4'b1???: po_and_valid = 3'b1_11;
            default: po_and_valid = 3'b0_00;
        endcase
    end

    assign o_po       = po_and_valid[1:0];
    assign o_po_valid = po_and_valid[2];
endmodule
