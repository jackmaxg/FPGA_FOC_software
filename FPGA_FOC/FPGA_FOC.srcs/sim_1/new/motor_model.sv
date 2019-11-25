`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2019 04:38:10 PM
// Design Name: 
// Module Name: motor_model
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

module motor_model(
    clk_in, vu, vv, vw, omega,
    iu, iv, iw, theta);

    parameter SIG_WIDTH = 32;
    input clk_in, vu, vv, vw, omega;
    output iu, iv, iw, theta;

    wire signed [SIG_WIDTH-1:0] vu;
    wire signed [SIG_WIDTH-1:0] vv;
    wire signed [SIG_WIDTH-1:0] vw;
    wire signed [SIG_WIDTH-1:0] omega;

    reg signed [SIG_WIDTH-1:0] theta;
    reg signed [SIG_WIDTH-1:0] iu;
    reg signed [SIG_WIDTH-1:0] iv;
    reg signed [SIG_WIDTH-1:0] iw;

    interp L
    #(parameter FILENAME = "inductance.txt")(
        .clk_in(clk_in),
        .index(theta),
        .out_value(inductance));

    interp phi
    #(parameter FILENAME = "flux.txt")(
        .clk_in(clk_in),
        .index(theta),
        .out_value(flux));

endmodule

module interp(clk_in, index, out_value);

    parameter INDEX_WIDTH = 3;
    parameter TABLE_DEPTH = 16;
    parameter FILENAME = "data.txt";

    input clk_in, index;
    output out_value;

    reg signed [TABLE_DEPTH-1:0] lut [0:2**(INDEX_WIDTH) - 1];
    initial $readmemh(FILENAME, lut);

    initial begin
        integer i;
        $display("rdata:");
        for (i = 0; i < 8; i=i+1)
            $display("%d: %h", i, lut[i]);
    end

endmodule

