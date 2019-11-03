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


module clark (U, V, W, alpha, beta, gamma);
    parameter SIG_WIDTH = 12;
    input U, V, W;
    output alpha, beta, gamma;

    wire [SIG_WIDTH-1:0] U;
    wire [SIG_WIDTH-1:0] V;
    wire [SIG_WIDTH-1:0] W;

    reg [SIG_WIDTH-1:0] alpha;
    reg [SIG_WIDTH-1:0] beta;
    reg [SIG_WIDTH-1:0] gamma;

endmodule


module park(alpha, beta, theta, D, Q);
    parameter SIG_WIDTH = 12;
    parameter THETA_WIDTH = 16;
    input alpha, beta, theta;
    output D, Q;

    wire [SIG_WIDTH-1:0] alpha;
    wire [SIG_WIDTH-1:0] beta;
    wire [THETA_WIDTH-1:0] theta;

    reg [SIG_WIDTH-1:0] D;
    reg [SIG_WIDTH-1:0] Q;

endmodule


module inv_clark (U, V, W, alpha, beta, gamma);
    parameter SIG_WIDTH = 12;
    input alpha, beta, gamma;
    output U, V, W;

    wire [SIG_WIDTH-1:0] alpha;
    wire [SIG_WIDTH-1:0] beta;
    wire [SIG_WIDTH-1:0] gamma;

    reg [SIG_WIDTH-1:0] U;
    reg [SIG_WIDTH-1:0] V;
    reg [SIG_WIDTH-1:0] W;

endmodule


module inv_park(alpha, beta, theta, D, Q);
    parameter SIG_WIDTH = 12;
    parameter THETA_WIDTH = 16;
    input D, Q, theta;
    output alpha, beta;

    wire [SIG_WIDTH-1:0] D;
    wire [SIG_WIDTH-1:0] Q;
    wire [THETA_WIDTH-1:0] theta;

    reg [SIG_WIDTH-1:0] alpha;
    reg [SIG_WIDTH-1:0] beta;

endmodule

