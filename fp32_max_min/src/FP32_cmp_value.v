`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2024 02:53:47 PM
// Design Name: 
// Module Name: FP32_cmp_value
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

module FP32_cmp_value (
    //  common signal
    input                             clk,
    input                             rstn, 
    //  Input Signals
    input                             i_valid,
    input                             i_is_max,      // 0: min / 1 : max
    input [`FP32_K_WIDTH-1:0]         i_a,
    input [`FP32_K_WIDTH-1:0]         i_b,
    // Output Signals
    output wire                       o_res_valid,
    output wire [`FP32_K_WIDTH-1:0]   o_res 
    );

    wire                              a_sign, b_sign;     // Sign for A and B
    wire [`FP32_E_WIDTH-1:0]          a_exp,  b_exp;      // Exponent for A and B
    wire [`FP32_M_WIDTH-1:0]          a_mant, b_mant;     // Mantissa for A and B       
    wire [`FP32_E_WIDTH:0]            expDiff;            // Difference between exponent for A and B
    wire [`FP32_M_WIDTH:0]            mantDiff;           // Difference between mantissa for A and B
    wire                              expDiffisZero;      // is same exponent for A and B?
    wire                              isAbsBigA;          // is A is bigger then B? (Absolute)
    wire                              isBigA;             // is A is bigger then B?

    //input reg
    reg                               valid_buf;
    reg                               is_max_buf;
    reg [`FP32_K_WIDTH-1:0]           a_buf;
    reg [`FP32_K_WIDTH-1:0]           b_buf;

    //output reg
    reg  [`FP32_K_WIDTH-1:0]          res_p, res_p_nxt;
    reg                               res_p_valid, res_p_valid_nxt;

    // Input Buffering
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin     
            valid_buf  <= 0;                 
            is_max_buf <= 0;     
            a_buf      <= 0;   
            b_buf      <= 0;      
        end
        else begin 
            valid_buf  <= i_valid;                 
            is_max_buf <= i_is_max;     
            a_buf      <= i_a;   
            b_buf      <= i_b;  
        end
    end  


    // unpacking for FP32 A and B
    assign a_sign = (valid_buf == 1) ? a_buf[`FP32_E_WIDTH+`FP32_M_WIDTH+:1] : 0;
    assign a_exp  = (valid_buf == 1) ? a_buf[`FP32_M_WIDTH+:`FP32_E_WIDTH]   : {`FP32_E_WIDTH{1'b0}};
    assign a_mant = (valid_buf == 1) ? a_buf[0+:`FP32_M_WIDTH]               : {`FP32_M_WIDTH{1'b0}};

    assign b_sign = (valid_buf == 1) ? b_buf[`FP32_E_WIDTH+`FP32_M_WIDTH+:1] : 0;
    assign b_exp  = (valid_buf == 1) ? b_buf[`FP32_M_WIDTH+:`FP32_E_WIDTH]   : {`FP32_E_WIDTH{1'b0}};
    assign b_mant = (valid_buf == 1) ? b_buf[0+:`FP32_M_WIDTH]               : {`FP32_M_WIDTH{1'b0}};

    // Compare Exponents/Mantissa
    assign expDiff        = {1'b0,a_exp}  + {1'b1,~b_exp}  + 1; 
    assign mantDiff       = {1'b0,a_mant} + {1'b1,~b_mant} + 1; 
    assign expDiffisZero  = ~(|expDiff);

    //Compare and Output the result value
    assign isAbsBigA   = expDiffisZero   ? ~mantDiff[`FP32_M_WIDTH]  : ~expDiff[`FP32_E_WIDTH];    
    assign isBigA      = (a_sign == b_sign) ? (a_sign ? ~isAbsBigA : isAbsBigA) :
                                                 (a_sign ? 1'b0       : 1'b1     );

    always @(*) begin 
        res_p_valid_nxt  = 0;
        res_p_nxt  = 0;
        if(valid_buf) begin      
            res_p_valid_nxt = 1'b1;
            if((&a_exp && |a_mant) || (&b_exp && |b_mant)) begin
                res_p_nxt   = `QNNN;                 
            end else begin 
                if(is_max_buf) begin 
                    if(isBigA) res_p_nxt = a_buf;
                    else       res_p_nxt = b_buf;
                end else begin 
                    if(isBigA) res_p_nxt = b_buf;
                    else       res_p_nxt = a_buf;
                end
            end           
        end 
    end    

    // Output buffering                                     
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin     
            res_p_valid <= 0;                 
            res_p       <= 0;              
        end
        else begin 
            res_p_valid <= res_p_valid_nxt;   
            if(res_p_valid_nxt)
                res_p   <= res_p_nxt;                       
        end
    end  

    assign o_res_valid  = res_p_valid;
    assign o_res        = res_p;


     

endmodule
