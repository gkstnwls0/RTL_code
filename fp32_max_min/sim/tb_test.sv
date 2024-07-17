`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2024 11:59:57 AM
// Design Name: 
// Module Name: tb_test
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


module tb_test();
    logic           clk;
    logic           reset_n;
    logic           is_max;
    logic [2:0]     is_op;
    logic [31 : 0]  in_int_a;
    logic [31 : 0]  in_int_b;
    logic [31 : 0]  fp32_a;
    logic [31 : 0]  fp32_b;
    logic           result_fp32_valid;
    logic [31 : 0]  result_fp32;
    logic           result_valid;
    logic           result;
    logic           nan_err;


    INTtoFP32 INT2FP32_1(in_int_a, fp32_a);
    INTtoFP32 INT2FP32_2(in_int_b, fp32_b);

    FP32_cmp_value FP32_cmp_value_u0(clk, reset_n, 1'b1, is_max, fp32_a, fp32_b, result_fp32_valid, result_fp32);

    FP32_cmp UFP32_cmp_u0(clk, reset_n, 1'b1, is_op, fp32_a, fp32_b, result_valid, result, nan_err);

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
        in_int_a = 16;
        in_int_b = -17;
        is_max = 1;
        is_op = 0;

        #2000;
        is_max = 0;
        is_op = 1;


        #2000;
        is_op = 2;

        #2000;
        is_op = 3;

        #2000;
        is_op = 4;

        #2000;
         $stop;
    end


endmodule
