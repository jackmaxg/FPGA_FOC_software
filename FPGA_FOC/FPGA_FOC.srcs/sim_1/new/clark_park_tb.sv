`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2019 03:06:51 PM
// Design Name: 
// Module Name: clark_park_tb
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

module clark_park_tb(

    );
    
    logic signed [15:0] d_in = 16'h4000;
    logic signed [15:0] q_in = 0;

    logic signed [15:0] d_out;
    logic signed [15:0] q_out;

    logic signed [15:0] u_in;
    logic signed [15:0] v_in;
    logic signed [15:0] w_in;

    logic signed [15:0] alpha_in;
    logic signed [15:0] beta_in;

    logic signed [15:0] alpha_out;
    logic signed [15:0] beta_out;

    logic signed [15:0] theta = 16'h0000;

    logic clk_in = 0;
    always begin
        clk_in <= !clk_in;
        #5;
    end
    
    clark my_clark(
        .clk_in(clk_in),
        .rst(0),
        .U(u_in),
        .V(v_in),
        .W(w_in),
        .alpha(alpha_out),
        .beta(beta_out));

    inv_clark my_inv_clark(
        .clk_in(clk_in),
        .rst(0),
        .U(u_in),
        .V(v_in),
        .W(w_in),
        .alpha(alpha_in),
        .beta(beta_in));

    inv_park my_inv_park(
        .clk_in(clk_in),
        .rst(0),
        .D(d_in),
        .Q(q_in),
        .theta(theta),
        .alpha(alpha_in),
        .beta(beta_in));

    park my_park(
        .clk_in(clk_in),
        .rst(0),
        .D(d_out),
        .Q(q_out),
        .theta(theta),
        .alpha(alpha_out),
        .beta(beta_out));
        
    
    initial begin
        #2000;
        for (int i = 0; i < 16; i = i+1) begin
            theta = theta + 16'h1000;
            #2000;
        end
        theta = 16'h0000;
        d_in = 16'h0000;
        q_in = 16'h4000;
        #2000;
        for (int i = 0; i < 16; i = i+1) begin
            theta = theta + 16'h1000;
            #2000;
        end
    end
        
    
endmodule
