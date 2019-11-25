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

    interp my_interp(
        .clk_in(clk),
        .index(0));
endmodule
