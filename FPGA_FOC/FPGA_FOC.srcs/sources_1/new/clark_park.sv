`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2019 03:14:49 PM
// Design Name: 
// Module Name: clark_park
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


module clark (clk_in, rst, U, V, W, alpha, beta, gamma);
    parameter SIG_WIDTH = 12;
    input U, V, W, clk_in, rst;
    output alpha, beta, gamma;

    wire signed [SIG_WIDTH-1:0] U;
    wire signed [SIG_WIDTH-1:0] V;
    wire signed [SIG_WIDTH-1:0] W;

    reg signed [SIG_WIDTH-1:0] alpha;
    reg signed [SIG_WIDTH-1:0] beta;
    reg signed [SIG_WIDTH-1:0] gamma;

endmodule


module park(clk_in, rst, alpha, beta, theta, D, Q);
    parameter SIG_WIDTH = 12;
    parameter THETA_WIDTH = 16;
    input alpha, beta, theta, clk_in, rst;
    output D, Q;

    wire signed [SIG_WIDTH-1:0] alpha;
    wire signed [SIG_WIDTH-1:0] beta;
    wire [THETA_WIDTH-1:0] theta;

    reg signed [SIG_WIDTH-1:0] D;
    reg signed [SIG_WIDTH-1:0] Q;

endmodule


module inv_clark (clk_in, rst, U, V, W, alpha, beta, gamma);
    parameter SIG_WIDTH = 12;
    input alpha, beta, gamma, clk_in, rst;
    output U, V, W;

    wire signed [SIG_WIDTH-1:0] alpha;
    wire signed [SIG_WIDTH-1:0] beta;
    wire signed [SIG_WIDTH-1:0] gamma;

    reg signed [SIG_WIDTH-1:0] U;
    reg signed [SIG_WIDTH-1:0] V;
    reg signed [SIG_WIDTH-1:0] W;

endmodule


module inv_park(clk_in, rst, alpha, beta, theta, D, Q);
    parameter SIG_WIDTH = 12;
    parameter THETA_WIDTH = 16;
    input D, Q, theta, clk_in, rst;
    output alpha, beta;

    wire signed [SIG_WIDTH-1:0] D;
    wire signed [SIG_WIDTH-1:0] Q;
    wire [THETA_WIDTH-1:0] theta;

    reg signed [SIG_WIDTH-1:0] alpha;
    reg signed [SIG_WIDTH-1:0] beta;

endmodule

