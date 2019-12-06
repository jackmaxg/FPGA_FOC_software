`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2019 08:29:33 PM
// Design Name: 
// Module Name: fixed_point
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
// 
//////////////////////////////////////////////////////////////////////////////////

// default is zero integer bits, 16 fractional bits, 1 sign bit
module fixed_point (a, b, c);
    parameter INT  = 0;
    parameter FRAC = 16;

    parameter INT_A = INT;
    parameter INT_B = INT;
    parameter INT_C = INT;

    parameter FRAC_A = FRAC;
    parameter FRAC_B = FRAC;
    parameter FRAC_C = FRAC;

    parameter C_EXT_LEN = INT_A + INT_B + FRAC_A + FRAC_B;
    parameter C_EXT_FRAC = FRAC_A + FRAC_B - FRAC_C;

    // assert (FRAC_C <= FRAC_A + FRAC_B) $display ("fixed point fractionals ok") else $display("fuck");
    // assert (INT_C >= INT_A + INT_B);

    input a, b;
    output c;

    wire signed [INT_A+FRAC_A:0] a;
    wire signed [INT_B+FRAC_B:0] b;
    wire signed [INT_C+FRAC_C:0] c;

    wire signed [C_EXT_LEN:0] c_extended;

    assign c_extended = a * b;
    assign c = {c_extended[C_EXT_LEN], c_extended[INT_C+FRAC_C+C_EXT_FRAC-1:C_EXT_FRAC]};

endmodule

// module fixed_point (a, b, c);
//     parameter SIG_WIDTH = 17;
//     input a, b;
//     output c;
// 
//     wire signed [SIG_WIDTH-1:0] a;
//     wire signed [SIG_WIDTH-1:0] b;
//     wire signed [SIG_WIDTH-1:0] c;
// 
//     wire signed [2*SIG_WIDTH-2:0] c_extended;
// 
//     assign c_extended = a * b;
// 
//     assign c = c_extended[2*SIG_WIDTH-2:SIG_WIDTH-1];
// 
// endmodule
