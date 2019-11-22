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

module cordic_angle(angle_in, angle_out);
    parameter INPUT_WIDTH = 16;
    parameter OUTPUT_WIDTH = 16;

    input angle_in;
    output angle_out;

    wire signed [INPUT_WIDTH-1:0] angle_in;
    wire signed [OUTPUT_WIDTH-1:0] angle_out;

    assign angle_out = (angle_in >>> (INPUT_WIDTH - OUTPUT_WIDTH + 2));
endmodule

module fixed_point (a, b, c);
    parameter SIG_WIDTH = 17;
    input a, b;
    output c;

    wire signed [SIG_WIDTH-1:0] a;
    wire signed [SIG_WIDTH-1:0] b;
    wire signed [SIG_WIDTH-1:0] c;

    wire signed [2*SIG_WIDTH-2:0] c_extended;

    assign c_extended = a * b;

    assign c = c_extended[2*SIG_WIDTH-2:SIG_WIDTH-1];

endmodule

module clark (clk_in, rst, U, V, W, alpha, beta);
    parameter SIG_WIDTH = 16;
    input U, V, W, clk_in, rst;
    output alpha, beta;

    wire signed [SIG_WIDTH-1:0] U;
    wire signed [SIG_WIDTH-1:0] V;
    wire signed [SIG_WIDTH-1:0] W;

    reg signed [SIG_WIDTH-1:0] V_buf = 0;
    reg signed [SIG_WIDTH-1:0] W_buf = 0;

    reg signed [SIG_WIDTH-1:0] alpha_buf = 0;
    reg signed [SIG_WIDTH-1:0] alpha = 0;
    reg signed [SIG_WIDTH-1:0] beta = 0;

    reg signed [SIG_WIDTH:0] two_third = 17'haaaa;
    reg signed [SIG_WIDTH:0] root_three = 17'h93cd;

    reg signed [SIG_WIDTH:0] m_in_1 = 0;
    reg signed [SIG_WIDTH:0] m_in_2 = 0;
    wire signed [SIG_WIDTH:0] m_out;

    fixed_point multiplier(m_in_1, m_in_2, m_out);

    reg index = 0;
    always_ff @(posedge clk_in) begin
        if (!index) begin
            m_in_1 <= U - (V >>> 1) - (W >>> 1);
            m_in_2 <= two_third;
            alpha <= alpha_buf;
            beta <= m_out[SIG_WIDTH-1:0];
            V_buf <= V;
            W_buf <= W;
        end
        else begin
            m_in_1 <= V_buf - W_buf;
            m_in_2 <= root_three;
            alpha_buf <= m_out[SIG_WIDTH-1:0];
        end
        index <= !index;
    end

endmodule


module park(clk_in, rst, alpha, beta, theta, D, Q);
    parameter SIG_WIDTH = 16;
    input alpha, beta, theta, clk_in, rst;
    output D, Q;

    wire signed [SIG_WIDTH-1:0] alpha;
    wire signed [SIG_WIDTH-1:0] beta;
    wire signed [SIG_WIDTH-1:0] theta;
    wire signed [SIG_WIDTH-1:0] cordic_theta;
    wire signed [SIG_WIDTH-1:0] D;
    wire signed [SIG_WIDTH-1:0] Q;

    cordic_angle theta_mod(
        .angle_in(theta),
        .angle_out(cordic_theta));

    cordic_0 cordic(
        .aclk(clk_in),
        .s_axis_cartesian_tdata({beta, alpha}),
        .s_axis_phase_tdata(-cordic_theta),
        .m_axis_dout_tdata({Q, D}));
endmodule


module inv_clark (clk_in, rst, U, V, W, alpha, beta);
    parameter SIG_WIDTH = 16;
    input alpha, beta, clk_in, rst;
    output U, V, W;

    wire signed [SIG_WIDTH-1:0] alpha;
    wire signed [SIG_WIDTH-1:0] beta;

    reg signed [SIG_WIDTH-1:0] alpha_buf = 0;
    wire signed [SIG_WIDTH-1:0] alpha_signed;

    wire signed [SIG_WIDTH-1:0] U;
    wire signed [SIG_WIDTH-1:0] V;
    wire signed [SIG_WIDTH-1:0] W;


    reg signed [SIG_WIDTH:0] root_three = 17'hddb3;

    reg signed [SIG_WIDTH:0] m_in_1 = 0;
    reg signed [SIG_WIDTH:0] m_in_2 = 0;
    wire signed [SIG_WIDTH:0] m_out;

    fixed_point multiplier(m_in_1, m_in_2, m_out);
    assign U = alpha_buf;
    assign alpha_signed = (alpha_buf >>> 1);
    assign V = m_out[SIG_WIDTH-1:0] - alpha_signed;
    assign W = -m_out[SIG_WIDTH-1:0] - alpha_signed;

    always_ff @(posedge clk_in) begin
        alpha_buf <= alpha;
        m_in_1 <= beta;
        m_in_2 <= root_three;
    end
endmodule


module inv_park(clk_in, rst, alpha, beta, theta, D, Q);
    parameter SIG_WIDTH = 16;
    input D, Q, theta, clk_in, rst;
    output alpha, beta;

    wire signed [SIG_WIDTH-1:0] D;
    wire signed [SIG_WIDTH-1:0] Q;
    wire signed [SIG_WIDTH-1:0] theta;
    wire signed [SIG_WIDTH-1:0] cordic_theta;
    wire signed [SIG_WIDTH-1:0] alpha;
    wire signed [SIG_WIDTH-1:0] beta;

    cordic_angle theta_mod(
        .angle_in(theta),
        .angle_out(cordic_theta));

    cordic_0 cordic(
        .aclk(clk_in),
        .s_axis_cartesian_tdata({Q, D}),
        .s_axis_phase_tdata(cordic_theta),
        .m_axis_dout_tdata({beta, alpha}));
endmodule

