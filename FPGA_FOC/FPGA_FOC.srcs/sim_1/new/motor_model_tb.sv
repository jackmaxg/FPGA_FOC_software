`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2019 04:37:24 PM
// Design Name: 
// Module Name: motor_model_tb
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


module motor_model_tb();
    logic clk = 0;

    always begin
        clk = !clk;
        #5;
    end

    logic [15:0] index = 0;
    logic signed [15:0] out_value;

    interp #(
        .FILENAME("lut.txt"),
        .TABLE_INDEX_WIDTH(10),
        .TABLE_DEPTH(16),
        .INDEX_WIDTH(16))
    my_interp(
        .clk_in(clk),
        .index(index),
        .out_value(out_value));

    initial begin
        for (int i = 0; i < (1 << 16); i = i+1) begin
            index = i;
            #10;
        end
    end
endmodule
