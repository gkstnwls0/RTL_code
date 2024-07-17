`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2024 02:53:47 PM
// Design Name: 
// Module Name: FP32_cmp
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

module FP32_cmp #(parameter output_buffering_on = "ON") (
    input                             clk,
    input                             rstn, 
    // Input Signals
    input                             i_valid,
    input [2:0]                       i_op,     
    input [`FP32_K_WIDTH-1:0]         i_a,
    input [`FP32_K_WIDTH-1:0]         i_b,
    // Output Signals
    output wire                       o_res_valid,
    output wire                       o_res,
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

     reg                              res_p, res_p_nxt;
    reg                               res_p_valid, res_p_valid_nxt;
    reg                               nan_err_p, nan_err_p_nxt;
    reg                               res_c;
    reg                               res_c_valid;
    reg                               nan_err_c;
    
     // unpacking for A and B
    assign a_sign = (i_valid == 1) ? i_a[`FP32_E_WIDTH+`FP32_M_WIDTH+:1] : 0;
    assign a_exp  = (i_valid == 1) ? i_a[`FP32_M_WIDTH+:`FP32_E_WIDTH]   : {`FP32_E_WIDTH{1'b0}};
    assign a_mant = (i_valid == 1) ? i_a[0+:`FP32_M_WIDTH]               : {`FP32_M_WIDTH{1'b0}};

    assign b_sign = (i_valid == 1) ? i_b[`FP32_E_WIDTH+`FP32_M_WIDTH+:1] : 0;
    assign b_exp  = (i_valid == 1) ? i_b[`FP32_M_WIDTH+:`FP32_E_WIDTH]   : {`FP32_E_WIDTH{1'b0}};
    assign b_mant = (i_valid == 1) ? i_b[0+:`FP32_M_WIDTH]               : {`FP32_M_WIDTH{1'b0}};

    // Compare Sign/Exponents/Mantissa
    assign signDiff       = (a_sign == b_sign) ? 0 : 1;
    assign expDiff        = {1'b0,a_exp}  + {1'b1,~b_exp}  + 1; 
    assign mantDiff       = {1'b0,a_mant} + {1'b1,~b_mant} + 1; 
    assign expDiffisZero  = ~(|expDiff);
    assign mantDiffisZero = ~(|mantDiff);

    // MAX or MIN or EQUAL
    assign isAbsBigA   = expDiffisZero   ? ~mantDiff[`FP32_M_WIDTH]  : ~expDiff[`FP32_E_WIDTH];    
    assign isBigA      = !signDiff       ? (a_sign ? ~isAbsBigA : isAbsBigA) :
                                           (a_sign ? 1'b0       : 1'b1     );
    assign isEQ        = (!signDiff && expDiffisZero && mantDiffisZero) ? 1 : 0;

    //Compare and Output True or False
    always @(*) begin 
        res_p_valid_nxt  = 0;
        res_p_nxt  = 0;
        nan_err_p_nxt = 0;
        if(i_valid) begin      
            res_p_valid_nxt = 1'b1;
            if((&a_exp && |a_mant) || (&b_exp && |b_mant)) begin
                nan_err_p_nxt   = 1'b1;                 
            end else begin 
                if(i_op == `OP_GTE) begin 
                    if(isBigA || isEQ)   res_p_nxt = 1'b1;
                    else                 res_p_nxt = 1'b0;
                end else if(i_op == `OP_GT)begin 
                    if(isBigA && !isEQ)  res_p_nxt = 1'b1;
                    else                 res_p_nxt = 1'b0;
                end else if(i_op == `OP_EQ) begin
                    if(isEQ)             res_p_nxt = 1'b1;
                    else                 res_p_nxt = 1'b0;
                end else if(i_op == `OP_LT) begin
                    if(!isBigA && !isEQ) res_p_nxt = 1'b1;
                    else                 res_p_nxt = 1'b0;
                end else begin
                     if(!isBigA || isEQ) res_p_nxt = 1'b1;
                    else                 res_p_nxt = 1'b0;
                end
            end           
        end 
    end    

    // Intermediate values buffering for pipelining   
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin     
            res_p_valid  <= 0;                 
            res_p        <= 0;     
            nan_err_p    <= 0;        
        end
        else begin 
            res_p_valid   <= res_p_valid_nxt;   
            if(res_p_valid_nxt) begin 
                res_p     <= res_p_nxt;             
                nan_err_p <= nan_err_p_nxt;
            end
        end
    end  
 generate 
        if(output_buffering_on == "ON") begin : OUTPUT_BUFFERING_ON 
            always @(posedge clk or negedge rstn) begin
                if(!rstn) begin
                    res_c        <= 0;
                    res_c_valid  <= 0;
                    nan_err_c    <= 0;
                end
                else begin                     
                    res_c_valid   <= res_p_valid;
                    if(res_p_valid) begin 
                        res_c     <= res_p;
                        nan_err_c <= nan_err_p;
                    end
                end    
            end // : OUTPUT_BUFFERING_ON   
        end else begin : OUTPUT_BUFFERING_OFF
            always @(*) begin
                res_c        = res_p;
                res_c_valid  = res_p_valid;
                nan_err_c    = nan_err_p; 
            end    
        end// : OUTPUT_BUFFERING_OFF 
    endgenerate


    assign o_res_valid = res_c_valid;
    assign o_res       = res_c;
    assign o_nan_err   = nan_err_c;


endmodule