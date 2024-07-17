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

`define OP_GTE  0  // >=
`define OP_GT   1  // >
`define OP_EQ   2  // =
`define OP_LT   3  // <
`define OP_LTE  4  // <=

`define MAX  1
`define MIN  0

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
    logic           result_cmp_valid;
    logic           result_cmp;
    logic           nan_err;

    shortreal a, b;


     INTtoFP32 INTtoFP32_u0(
        .INT    (in_int_a), 
        .FP32   (fp32_a)
    );

    INTtoFP32 INTtoFP32_u1(
        .INT    (in_int_b), 
        .FP32   (fp32_b)
    );

    FP32_cmp #(.output_buffering_on("ON"))
    FP32_cmp_u0(
        .clk            (clk), 
        .rstn           (reset_n), 
        .i_valid        (1'b1), 
        .i_op           (is_op), 
        .i_a            (fp32_a), 
        .i_b            (fp32_b), 
        .o_res_valid    (result_cmp_valid), 
        .o_res          (result_cmp),
        .o_nan_err      (nan_err)
    );

    FP32_cmp_value #(.output_buffering_on("ON"))
    FP32_cmp_value_u0(
        .clk            (clk), 
        .rstn           (reset_n), 
        .i_valid        (1'b1), 
        .i_is_max       (is_max), 
        .i_a            (fp32_a), 
        .i_b            (fp32_b), 
        .o_res_valid    (result_fp32_valid), 
        .o_res          (result_fp32)
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
        in_int_a = $random;
        in_int_b = $random;
        is_max = `MAX;
        is_op = `OP_GTE;

        #2000;
        in_int_a = -27;
        in_int_b = -27;

        #2000;
        in_int_a = $random;
        in_int_b = $random;
        is_max = `MAX;
        is_op = `OP_GT;

        #2000;
        in_int_a = -27;
        in_int_b = -27;

        #2000;
        in_int_a = $random;
        in_int_b = $random;
        is_max = `MAX;
        is_op = `OP_EQ;

        #2000;
        in_int_a = 0;
        in_int_b = 0;

        #2000;
        in_int_a = $random;
        in_int_b = $random;
        is_max = `MIN;
        is_op = `OP_LT;

        #2000;
        in_int_a = -27;
        in_int_b = -27;

        #2000;
        in_int_a = $random;
        in_int_b = $random;
        is_max = `MIN;
        is_op = `OP_LTE;

        #2000;
        in_int_a = -27;
        in_int_b = -27;



        //negative test
        // a = -($random);
        // b = -($random);
        // fp32_a = $shortrealtobits(a);
        // fp32_b = $shortrealtobits(b);
        // is_max = `MAX;
        // is_op = `OP_GTE;

        // #2000;
        // a = -17.0;
        // b = -17.0;
        // fp32_a = $shortrealtobits(a);
        // fp32_b = $shortrealtobits(b);

        // #2000;
        // a = -($random);
        // b = -($random);
        // fp32_a = $shortrealtobits(a);
        // fp32_b = $shortrealtobits(b);
        // is_max = `MAX;
        // is_op = `OP_GT;

        // #2000;
        // a = -17.0;
        // b = -17.0;
        // fp32_a = $shortrealtobits(a);
        // fp32_b = $shortrealtobits(b);

        // #2000;
        // a = -($random);
        // b = -($random);
        // fp32_a = $shortrealtobits(a);
        // fp32_b = $shortrealtobits(b);
        // is_max = `MAX;
        // is_op = `OP_EQ;

        // #2000;
        // a = -17.0;
        // b = -17.0;
        // fp32_a = $shortrealtobits(a);
        // fp32_b = $shortrealtobits(b);


        // #2000;
        // a = -($random);
        // b = -($random);
        // fp32_a = $shortrealtobits(a);
        // fp32_b = $shortrealtobits(b);
        // is_max = `MIN;
        // is_op = `OP_LT;

        // #2000;
        // a = -17.0;
        // b = -17.0;
        // fp32_a = $shortrealtobits(a);
        // fp32_b = $shortrealtobits(b);

        // #2000;
        // a = -($random);
        // b = -($random);
        // fp32_a = $shortrealtobits(a);
        // fp32_b = $shortrealtobits(b);
        // is_max = `MIN;
        // is_op = `OP_LTE;

        // #2000;
        // a = -17.0;
        // b = -17.0;
        // fp32_a = $shortrealtobits(a);
        // fp32_b = $shortrealtobits(b);
       

        #2000;
         $stop;
    end


endmodule
