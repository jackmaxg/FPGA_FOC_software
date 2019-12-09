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
    wire [63:0] hex_out;
    data_to_hex_reg #(
        .DIGITS(8))
        my_hex(
        .data(32'h0123abcd),
        .hex_out(hex_out));
        
        
    wire [79:0] uart_data = {hex_out, 8'h0A, 8'h0C};
    uart_tx_buf #(.BYTES(10)) my_uart_tx(
        .clk(clk),
        .data(uart_data),
        .trig(trig),
        .tx_out(tx_out),
        .ready(ready));
        
    always begin
        #5;
        clk = !clk;
    end
    
    initial begin
        #100;
        trig = 1;
        #10;
        trig = 0;
        #200000;
        trig = 1;
        #10;
        trig = 0;
        #200000;
        $finish;
    end

endmodule