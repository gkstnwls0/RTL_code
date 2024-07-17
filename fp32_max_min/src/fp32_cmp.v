`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2024 10:42:42 AM
// Design Name: 
// Module Name: fp32_cmp
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

`define FP32_K_WIDTH 32
`define FP32_E_WIDTH 8
`define FP32_M_WIDTH 23
`define QNNN 'hFFFFFFFF

`define OP_GTE  0  // >=
`define OP_GT   1  // >
`define OP_EQ   2  // =
`define OP_LT   3  // <
`define OP_LTE  4  // <=

module fp32_cmp(
     //  common signal
    input                             clk,
    input                             rstn, 
    //  Input Signals
    input                             i_valid,
    input [2:0]                       i_op, 
    input [`FP32_K_WIDTH-1:0]         i_a,
    input [`FP32_K_WIDTH-1:0]         i_b,
    // Output Signals
    output wire                       o_result_valid,
    output wire [`FP32_K_WIDTH-1:0]   o_result_value,
    output wire                       o_result_cmp,
    output wire                       o_nan_err
    );

    wire                              a_sign, b_sign;     // Sign for A and B
    wire [`FP32_E_WIDTH-1:0]          a_exp,  b_exp;      // Exponent for A and B
    wire [`FP32_M_WIDTH-1:0]          a_mant, b_mant;     // Mantissa for A and B       
    wire [`FP32_E_WIDTH:0]            expDiff;            // Difference between exponent for A and B
    wire [`FP32_M_WIDTH:0]            mantDiff;           // Difference between mantissa for A and B
    wire                              signDiff;           // Difference between sign for A and B
    wire                              expDiffisZero;      // is same exponent for A and B?
    wire                              mantDiffisZero;     // is same mantissa for A and B?
    wire                              isAbsBigA;          // is A bigger then B? (Absolute)
    wire                              isBigA;             // is A bigger then B?
    wire                              isEQ;               // is A equal to B?

    reg                               result_valid, result_valid_nxt;
    reg  [`FP32_K_WIDTH-1:0]          result_value, result_vlaue_nxt; // fp32 value
    reg                               result_cmp, result_cmp_nxt;     // true or false
    reg                               nan_err, nan_err_nxt;           // NAN error
    

    // unpacking for FP32 A and B
    assign a_sign = (i_valid == 1) ? i_a[`FP32_E_WIDTH+`FP32_M_WIDTH+:1] : 0;
    assign a_exp  = (i_valid == 1) ? i_a[`FP32_M_WIDTH+:`FP32_E_WIDTH]   : {`FP32_E_WIDTH{1'b0}};
    assign a_mant = (i_valid == 1) ? i_a[0+:`FP32_M_WIDTH]               : {`FP32_M_WIDTH{1'b0}};

    assign b_sign = (i_valid == 1) ? i_b[`FP32_E_WIDTH+`FP32_M_WIDTH+:1] : 0;
    assign b_exp  = (i_valid == 1) ? i_b[`FP32_M_WIDTH+:`FP32_E_WIDTH]   : {`FP32_E_WIDTH{1'b0}};
    assign b_mant = (i_valid == 1) ? i_b[0+:`FP32_M_WIDTH]               : {`FP32_M_WIDTH{1'b0}};

    // Compare Sign/Exponents/Mantissa
    assign signDiff       = (a_sign == b_sign) ? 1'b0 : 1'b1;
    assign expDiff        = {1'b0,a_exp}  + {1'b1,~b_exp}  + 1; 
    assign mantDiff       = {1'b0,a_mant} + {1'b1,~b_mant} + 1; 
    assign expDiffisZero  = ~(|expDiff);
    assign mantDiffisZero = ~(|mantDiff);

    // MAX or MIN or EQUAL
    assign isAbsBigA = expDiffisZero   ? ~mantDiff[`FP32_M_WIDTH]  : ~expDiff[`FP32_E_WIDTH];    
    assign isBigA    = !signDiff       ? (a_sign ? ~isAbsBigA : isAbsBigA) :
                                           (a_sign ? 1'b0       : 1'b1     );
    assign isEQ      = (!signDiff && expDiffisZero && mantDiffisZero) ? 1'b1 : 1'b0;


    //Compare and Output the result value
    always @(*) begin 
        result_valid_nxt  = 0;
        result_value_nxt  = 0;
        if(i_valid) begin      
            result_valid_nxt = 1'b1;
            if((&a_exp && |a_mant) || (&b_exp && |b_mant)) begin
                result_value_nxt   = `QNNN;              
            end else begin 
                if(i_op == `OP_GTE || i_op == `OP_GT || i_op == `OP_EQ) begin 
                    if(isBigA) result_value_nxt = i_a;
                    else       result_value_nxt = i_b;
                end else begin 
                    if(isBigA) result_value_nxt = i_b;
                    else       result_value_nxt = i_a;
                end
            end           
        end 
    end   

    //Compare and Output True or False
    always @(*) begin 
        result_cmp_nxt  = 0;
        nan_err_nxt = 0;
        if(i_valid) begin      
            if((&a_exp && |a_mant) || (&b_exp && |b_mant)) begin
                nan_err_nxt   = 1'b1;                 
            end else begin 
                if(i_op == `OP_GTE) begin 
                    if(isBigA || isEQ)   result_cmp_nxt = 1'b1;
                    else                 result_cmp_nxt = 1'b0;
                end else if(i_op == `OP_GT)begin 
                    if(isBigA && !isEQ)  result_cmp_nxt = 1'b1;
                    else                 result_cmp_nxt = 1'b0;
                end else if(i_op == `OP_EQ) begin
                    if(isEQ)             result_cmp_nxt = 1'b1;
                    else                 result_cmp_nxt = 1'b0;
                end else if(i_op == `OP_LT) begin
                    if(!isBigA && !isEQ) result_cmp_nxt = 1'b1;
                    else                 result_cmp_nxt = 1'b0;
                end else begin
                     if(!isBigA || isEQ) result_cmp_nxt = 1'b1;
                    else                 result_cmp_nxt = 1'b0;
                end
            end           
        end 
    end    


    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin     
            result_valid  <= 1'b0;                 
            result_value  <= 0;     
            result_cmp    <= 1'b0;  
            nan_err       <= 1'b0;        
        end
        else begin 
            result_valid  <= result_valid_nxt;   
            if(result_valid_nxt) begin 
                result_value <= result_value_nxt;
                result_cmp   <= result_cmp_nxt;             
                nan_err      <= nan_err_nxt;
            end
        end
    end  


    assign o_result_valid   = result_valid;
    assign o_result_value   = result_value;
    assign o_result_cmp     = result_cmp;
    assign o_nan_err        = nan_err;
endmodule

