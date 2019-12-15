`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2019 12:37:11 AM
// Design Name: 
// Module Name: cmod_a7_test
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


module cmod_a7_test(led, btn, sysclk, uart_rxd_out, uart_txd_in, ja,
    pio39, pio40, pio41,
    pio36, pio37, pio38,
    pio32, pio33, pio34, pio35);
    
    wire clk_100mhz;
    wire sysclk;

    input sysclk, pio40, pio37, btn, ja, uart_txd_in;
    output led, uart_rxd_out, pio39, pio41, pio36, pio38;
    output pio32, pio33, pio34, pio35;
    clk_wiz_0 sys_clk_gen(.clk_in1(sysclk), .clk_out1(clk_100mhz), .reset(0));

    wire ja[7:0];
    wire uart_rxd_out;
    wire uart_txd_in;
    reg [25:0] ctr = 0;
    reg [7:0] data = 8'h41;
    reg send_enable = 1;
    wire trig = send_enable && (ctr[20:0] == 0);
    wire pio39, pio40, pio41;
    wire [1:0] btn;
    wire [1:0] led;
    assign led[1] = 0;

    wire [11:0] gv_adc_out;
    wire gv_adc_ready;
    wire gv_sclk = pio39;
    wire gv_sdo = pio40;
    wire gv_cs = pio41;

    wire [11:0] gw_adc_out;
    wire gw_adc_ready;
    wire gw_sclk = pio36;
    wire gw_sdo = pio37;
    wire gw_cs = pio38;

    wire signed [11:0] gv_current = gv_adc_out - 12'h800;
    wire signed [11:0] gw_current = gw_adc_out - 12'h800;
    wire signed [11:0] gu_current = -gv_current - gw_current;

    wire signed [15:0] gu_current_pad = {gu_current[11], gu_current, 3'b0};
    wire signed [15:0] gv_current_pad = {gv_current[11], gv_current, 3'b0};
    wire signed [15:0] gw_current_pad = {gw_current[11], gw_current, 3'b0};

    wire guu;
    wire gvu;
    wire gwu;

    reg gsdn = 0;

    wire pio32 = guu;
    wire pio33 = gsdn;
    wire pio34 = gwu;
    wire pio35 = gvu;


    wire signed [15:0] alpha_voltage;
    wire signed [15:0] beta_voltage;
    wire signed [15:0] alpha_current;
    wire signed [15:0] beta_current;
    wire signed [15:0] D_voltage;
    wire signed [15:0] Q_voltage;
    wire signed [15:0] D_current;
    wire signed [15:0] Q_current;
    reg signed [15:0] D_current_setpoint = 16'h0000;
    reg signed [15:0] Q_current_setpoint = 16'h0200;
    wire signed [15:0] D_err = D_current - D_current_setpoint;
    wire signed [15:0] Q_err = Q_current - Q_current_setpoint;
    pid D_pid (
        .clk(clk_100mhz), .kp(16'h0000), .ki(16'h0001),
        .err(D_err), .out(D_voltage));

    pid Q_pid (
        .clk(clk_100mhz), .kp(16'h0000), .ki(16'h0001),
        .err(Q_err), .out(Q_voltage));
    wire [15:0] theta = {theta_elec, 4'b0};
    // reg [15:0] theta = 0;

    clark my_clark (
        .clk_in(clk_100mhz),
        .rst(0),
        .U(gu_current_pad),
        .V(gv_current_pad),
        .W(gw_current_pad),
        .alpha(alpha_current),
        .beta(beta_current));

    park my_park(
        .clk_in(clk_100mhz),
        .rst(0),
        .alpha(alpha_current),
        .beta(beta_current),
        .theta(theta),
        .D(D_current),
        .Q(Q_current));

    inv_park my_inv_park(
        .clk_in(clk_100mhz),
        .rst(0),
        .alpha(alpha_voltage),
        .beta(beta_voltage),
        .theta(theta),
        .D(D_voltage),
        .Q(Q_voltage));

    wire signed [15:0] u_voltage;
    wire signed [15:0] v_voltage;
    wire signed [15:0] w_voltage;

    inv_clark my_inv_clark (
        .clk_in(clk_100mhz),
        .rst(0),
        .U(u_voltage),
        .V(v_voltage),
        .W(w_voltage),
        .alpha(alpha_voltage),
        .beta(beta_voltage));

    adc gv_adc (
        .clk(clk_100mhz),
        .sdo(gv_sdo),
        .reset(btn[0]),
        .cs(gv_cs),
        .sclk(gv_sclk),
        .adc_out(gv_adc_out),
        .ready(gv_adc_ready) );

    adc gw_adc (
        .clk(clk_100mhz),
        .sdo(gw_sdo),
        .reset(btn[0]),
        .cs(gw_cs),
        .sclk(gw_sclk),
        .adc_out(gw_adc_out),
        .ready(gw_adc_ready) );


    wire [11:0] u_in;
    wire [11:0] v_in;
    wire [11:0] w_in;

    clipper (.in(u_voltage), .out(u_in));
    clipper (.in(v_voltage), .out(v_in));
    clipper (.in(w_voltage), .out(w_in));

    svpwm #(
        .CLK_IN_HZ(100_000_000),
        .BITS(12),
        .SW_HZ(5_000)
    ) my_svpwm (
        .rst_in(0),
        .clk_in(clk_100mhz),
        .u_vset_in(u_in),
        .v_vset_in(v_in),
        .w_vset_in(w_in),
        .ph_u_out(guu),
        .ph_v_out(gvu),
        .ph_w_out(gwu)
    );

    wire [11:0] enc_theta;
    wire signed [11:0] enc_comp = enc_theta - 860;
    reg signed [11:0] theta_elec = 0;
    wire enc_a = ja[0];
    wire enc_b = ja[1];
    wire enc_i = ja[2];
    wire enc_ready;
    assign led[0] = enc_ready;
    abi_encoder my_enc (
        .clk(clk_100mhz),
        .a(enc_a),
        .b(enc_b),
        .i(enc_i),
        .reset(btn[0]),
        .theta(enc_theta),
        .ready(enc_ready));

    wire [7:0] uart_rx_sel;
    wire [15:0] uart_rx_payload;
    wire uart_rx_ready;
    wire uart_rx_valid;
    uart_rx_decoder rx_dec(
        .clk(clk_100mhz), .rx_in(uart_txd_in), .sel(uart_rx_sel), .payload(uart_rx_payload), .ready(uart_rx_ready), .valid(uart_rx_valid));


    wire uart_ready;
    wire [23:0] gv_hex_out;
    data_to_hex_reg #(.DIGITS(3)) gv_hex(
        .data(gv_adc_out),
        .hex_out(gv_hex_out));

    wire [23:0] gw_hex_out;
    data_to_hex_reg #(.DIGITS(3)) gw_hex(
        .data(gw_adc_out),
        .hex_out(gw_hex_out));

    wire [23:0] enc_hex_out;
    data_to_hex_reg #(.DIGITS(3)) enc_hex(
        .data(theta_elec),
        .hex_out(enc_hex_out));

    wire [31:0] Q_cur_hex;
    data_to_hex_reg #(.DIGITS(4)) q_cur_hex(
        .data(Q_current),
        .hex_out(Q_cur_hex));

    wire [31:0] D_cur_hex;
    data_to_hex_reg #(.DIGITS(4)) d_cur_hex(
        .data(D_current),
        .hex_out(D_cur_hex));

    wire [31:0] Q_set_hex;
    data_to_hex_reg #(.DIGITS(4)) q_set_hex(
        .data(Q_current_setpoint),
        .hex_out(Q_set_hex));

    wire [31:0] D_set_hex;
    data_to_hex_reg #(.DIGITS(4)) d_set_hex(
        .data(D_current_setpoint),
        .hex_out(D_set_hex));

    parameter TX_BYTES = 24;
    wire [TX_BYTES*8-1:0] uart_data = {Q_set_hex, 8'h20, Q_cur_hex, 32'h20202020, D_set_hex, 8'h20, D_cur_hex, 16'h0A0D};
    uart_tx_buf #(.BYTES(TX_BYTES)) my_uart_tx(
        .clk(clk_100mhz),
        .data(uart_data),
        .trig(trig),
        .tx_out(uart_rxd_out),
        .ready(uart_ready));
        
    always_ff @(posedge clk_100mhz) begin
        ctr = ctr + 1;
        if (btn[1] || !enc_ready)
            gsdn <= enc_ready;
        theta_elec <= enc_comp * 3;
        send_enable <= uart_rx_ready;
        if (uart_rx_ready && uart_rx_valid) begin
            case (uart_rx_sel)
                8'h51 : Q_current_setpoint <= uart_rx_payload;
                8'h49 : D_current_setpoint <= uart_rx_payload;
            endcase
        end
    end
endmodule

module clipper(in, out);
    input wire signed [15:0] in;
    output wire signed [11:0] out;
    assign out = in > 16'h3FFF ? 12'h3FF : (in < -16'h3FFF ? -12'h3FF : {in[15], in[13:3]});
endmodule
