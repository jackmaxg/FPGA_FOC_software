`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2019 01:49:35 AM
// Design Name: 
// Module Name: pid
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


module pid(clk, kp, ki, err, out);
    input clk, err, kp, ki;
    output out;
    parameter BIT_DEPTH = 16;
    wire clk;
    wire signed [BIT_DEPTH-1:0] err;
    reg signed [2*BIT_DEPTH-1:0] integral  = 0;
    reg signed [BIT_DEPTH-1:0] out  = 0;
    wire signed [BIT_DEPTH-1:0] kp;
    wire signed [BIT_DEPTH-1:0] ki;

    wire signed [2*BIT_DEPTH-2:0] kp_err = err * kp + integral;
    wire signed [BIT_DEPTH-1:0] kp_err_trunc = kp_err[2*BIT_DEPTH-2:BIT_DEPTH-1];
    reg signed [2*BIT_DEPTH-1:0] max_integral = 32'h6000_0000;

    always_ff @(posedge clk) begin
        out <= -(kp_err_trunc + integral[BIT_DEPTH*2-1:BIT_DEPTH]);
        integral <= integral > max_integral ? max_integral : (integral < -max_integral ? -max_integral : integral + ki * err);
    end
    
endmodule
