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
    parameter TABLE_WIDTH = 10;
    parameter INDEX_WIDTH = 32;

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

    const reg signed [SIG_WIDTH-1:0] third = 32'h55555555;
    wire signed [SIG_WIDTH-1:0] theta_u = theta;
    wire signed [SIG_WIDTH-1:0] theta_v = theta + third;
    wire signed [SIG_WIDTH-1:0] theta_w = theta - third;
    

    interp #(
        .FILENAME("inductance.txt"),
        .TABLE_DEPTH(SIG_WIDTH),
        .TABLE_INDEX_WIDTH(TABLE_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH)
    ) l_u (
        .clk_in(clk_in),
        .index(theta_u),
        .out_value(inductance_u));

    interp #(
        .FILENAME("flux.txt"),
        .TABLE_DEPTH(SIG_WIDTH),
        .TABLE_INDEX_WIDTH(TABLE_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH)
    ) phi_u (
        .clk_in(clk_in),
        .index(theta_u),
        .out_value(flux_u));

    interp #(
        .FILENAME("inductance.txt"),
        .TABLE_DEPTH(SIG_WIDTH),
        .TABLE_INDEX_WIDTH(TABLE_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH)
    ) l_v (
        .clk_in(clk_in),
        .index(theta_v),
        .out_value(inductance_v));

    interp #(
        .FILENAME("flux.txt"),
        .TABLE_DEPTH(SIG_WIDTH),
        .TABLE_INDEX_WIDTH(TABLE_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH)
    ) phi_v (
        .clk_in(clk_in),
        .index(theta_v),
        .out_value(flux_v));

    interp #(
        .FILENAME("inductance.txt"),
        .TABLE_DEPTH(SIG_WIDTH),
        .TABLE_INDEX_WIDTH(TABLE_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH)
    ) l_w (
        .clk_in(clk_in),
        .index(theta_w),
        .out_value(inductance_w));

    interp #(
        .FILENAME("flux.txt"),
        .TABLE_DEPTH(SIG_WIDTH),
        .TABLE_INDEX_WIDTH(TABLE_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH)
    ) phi_w (
        .clk_in(clk_in),
        .index(theta_w),
        .out_value(flux_w));

endmodule

module phase_model(clk_in, current, omega, theta, voltage, current_delta);
    input clk_in, current, omega, theta, voltage;
    output current_delta;
    parameter RESISTANCE = 12345;
    parameter SIG_WIDTH = 32;
    parameter TABLE_WIDTH = 10;
    parameter INDEX_WIDTH = 32;
    parameter INDUCTANCE_FILE = "inductance.txt";
    parameter INDUCTANCE_DERIV_FILE = "inductance_deriv.txt";
    parameter FLUX_DERIV_FILE = "flux_deriv.txt";
    parameter CURRENT_INT = 8;
    parameter OMEGA_INT = 16;
    
    wire signed [SIG_WIDTH-1:0] inductance;
    wire signed [SIG_WIDTH-1:0] inductance_deriv;
    wire signed [SIG_WIDTH-1:0] flux_deriv;
    wire signed [SIG_WIDTH-1:0] back_emf;
    wire signed [SIG_WIDTH-1:0] reluctance_flux_deriv;
    reg signed [SIG_WIDTH-1:0] total_flux_deriv = 0;

    always_ff @(posedge clk_in) begin
        total_flux_deriv <= flux_deriv + reluctance_flux_deriv;
    end

    fixed_point #(
        .INT_A(SIG_WIDTH-1), .FRAC_A(0),
        .INT_B(CURRENT_INT), .FRAC_B(SIG_WIDTH - CURRENT_INT - 1),
        .INT_C(SIG_WIDTH-1), .FRAC_C(0)
    ) inductance_current (.a(inductance_deriv), .b(current), .c(reluctance_flux_deriv));

    fixed_point #(
        .INT_A(SIG_WIDTH-1), .FRAC_A(0),
        .INT_B(CURRENT_INT), .FRAC_B(SIG_WIDTH - CURRENT_INT - 1),
        .INT_C(SIG_WIDTH-1), .FRAC_C(0)
    ) back_emf_scale (.a(total_flux), .b(omega), .c(back_emf));

    interp #(
        .FILENAME(INDUCTANCE_FILE),
        .TABLE_DEPTH(SIG_WIDTH),
        .TABLE_INDEX_WIDTH(TABLE_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH)
    ) l (
        .clk_in(clk_in),
        .index(theta),
        .out_value(inductance)
    );

    interp #(
        .FILENAME(INDUCTANCE_DERIV_FILE),
        .TABLE_DEPTH(SIG_WIDTH),
        .TABLE_INDEX_WIDTH(TABLE_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH)
    ) l_deriv (
        .clk_in(clk_in),
        .index(theta),
        .out_value(inductance_deriv)
    );

    interp #(
        .FILENAME(FLUX_DERIV_FILE),
        .TABLE_DEPTH(SIG_WIDTH),
        .TABLE_INDEX_WIDTH(TABLE_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH)
    ) phi (
        .clk_in(clk_in),
        .index(theta),
        .out_value(flux_deriv)
    );
    
endmodule

module interp(clk_in, index, out_value);

    parameter TABLE_INDEX_WIDTH = 3;
    parameter INDEX_WIDTH = 16;
    parameter TABLE_DEPTH = 16;
    parameter FILENAME = "data.txt";

    parameter INDEX_LSB_WIDTH = INDEX_WIDTH - TABLE_INDEX_WIDTH;

    input clk_in, index;
    output out_value;

    reg signed [TABLE_DEPTH-1:0] lut [0:2**(TABLE_INDEX_WIDTH) - 1];
    initial $readmemh(FILENAME, lut);

    wire [INDEX_WIDTH-1:0] index;
    wire [TABLE_INDEX_WIDTH-1:0] index_msb;
    wire [TABLE_INDEX_WIDTH-1:0] index_msb_next;
    wire [INDEX_LSB_WIDTH+1:0] index_lsb;
    wire [INDEX_LSB_WIDTH+1:0] index_lsb_next;
    wire signed [TABLE_DEPTH-1:0] lut_value;
    wire signed [TABLE_DEPTH-1:0] lut_value_next;

    wire signed [TABLE_DEPTH+INDEX_LSB_WIDTH-1:0] lut_mult_out;
    wire signed [TABLE_DEPTH+INDEX_LSB_WIDTH-1:0] lut_mult_out_next;
    wire signed [TABLE_DEPTH+INDEX_LSB_WIDTH-1:0] lut_mult_out_sum;
    assign lut_mult_out_sum = lut_mult_out + lut_mult_out_next;

    reg signed [TABLE_DEPTH-1:0] out_value;

    assign index_msb = index[INDEX_WIDTH-1:INDEX_LSB_WIDTH];
    assign index_msb_next = index_msb+1;
    assign index_lsb = {2'b0, index[INDEX_LSB_WIDTH-1:0]};
    assign index_lsb_next = {2'b0, ~index_lsb[INDEX_LSB_WIDTH-1:0]}+1;

    assign lut_value = lut[index_msb];
    assign lut_value_next = lut[index_msb_next];

    fixed_point #(
        .INT_A(TABLE_DEPTH-1), .FRAC_A(0),
        .INT_B(1), .FRAC_B(INDEX_LSB_WIDTH),
        .INT_C(TABLE_DEPTH-1), .FRAC_C(INDEX_LSB_WIDTH))
        lut_mult (.a(lut_value), .b(index_lsb_next), .c(lut_mult_out));

    fixed_point #(
        .INT_A(TABLE_DEPTH-1), .FRAC_A(0),
        .INT_B(1), .FRAC_B(INDEX_LSB_WIDTH),
        .INT_C(TABLE_DEPTH-1), .FRAC_C(INDEX_LSB_WIDTH))
        lut_mult_next (.a(lut_value_next), .b(index_lsb), .c(lut_mult_out_next));

    always_ff @(posedge clk_in) begin
        out_value <= lut_mult_out_sum[TABLE_DEPTH+INDEX_LSB_WIDTH-1:INDEX_LSB_WIDTH];
    end

endmodule

