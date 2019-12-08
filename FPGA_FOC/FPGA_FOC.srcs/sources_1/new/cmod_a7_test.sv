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


module cmod_a7_test(led, sysclk, uart_rxd_out);
    input sysclk;
    output led, uart_rxd_out;
    wire sysclk;
    wire uart_rxd_out;
    reg [25:0] ctr = 0;
    reg [7:0] data = 8'h41;
    wire trig = (ctr[23:0] == 0);
    wire ready;

    /*
    uart my_uart(
        .sysclk(sysclk),
        .trig(trig),
        .data(data),
        .tx_out(uart_rxd_out),
        .ready(ready));
    */

    wire [1:0] led = {ctr[24], ready};

    uart_tx_hex my_uart_hex(
        .sysclk(sysclk),
        .data(16'habcd),
        .trig(trig),
        .tx_out(uart_rxd_out));

    always_ff @(posedge sysclk) begin
        ctr = ctr + 1;
    end
endmodule

