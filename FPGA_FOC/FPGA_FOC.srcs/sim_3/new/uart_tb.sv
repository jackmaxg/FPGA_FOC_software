`timescale 1ns / 1ps
module uart_tb();
    reg clk = 0;
    wire tx_out;
    reg trig = 0;
    wire ready;

    /*
    wire ready;
    uart my_uart(
        .sysclk(sysclk),
        .trig(trig),
        .data(8'h41),
        .tx_out(tx_out),
        .ready(ready));
    */
    /*
    uart_tx_hex my_uart_hex(
        .sysclk(sysclk),
        .data(16'habcd),
        .trig(trig),
        .tx_out(tx_out));
        */
    wire [31:0] hex_out;
    data_to_hex_reg #(
        .DIGITS(4))
        my_hex(
        .data(32'h01ef),
        .hex_out(hex_out));
        
        
    parameter BYTES = 4 + 1 + 2;
    wire [BYTES*8-1:0] uart_data = {8'h51, hex_out, 8'h0A, 8'h0C};
    uart_tx_buf #(.BYTES(BYTES)) my_uart_tx(
        .clk(clk),
        .data(uart_data),
        .trig(trig),
        .tx_out(tx_out),
        .ready(ready));
        
    wire [7:0] rx_data;
    wire rx_ready;
    uart_rx rx(
        .clk(clk),
        .rx_in(tx_out),
        .data(rx_data),
        .ready(rx_ready));

    wire [7:0] sel;
    wire [15:0] payload;
    wire uart_rx_thing_ready;
    uart_rx_decoder rx_dec_thing (
        .clk(clk),
        .rx_in(tx_out),
        .sel(sel),
        .payload(payload),
        .ready(uart_rx_thing_ready));
        
    always begin
        #5;
        clk = !clk;
    end
    
    initial begin
        #100;
        trig = 1;
        #10;
        trig = 0;
        #2000000;
        trig = 1;
        #10;
        trig = 0;
        #2000000;
        $finish;
    end


endmodule
