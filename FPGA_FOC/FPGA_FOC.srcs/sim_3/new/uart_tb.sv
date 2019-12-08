`timescale 1ns / 1ps
module uart_tb();
    reg sysclk = 0;
    wire tx_out;
    reg trig = 0;

    /*
    wire ready;
    uart my_uart(
        .sysclk(sysclk),
        .trig(trig),
        .data(8'h41),
        .tx_out(tx_out),
        .ready(ready));
    */
    
    uart_tx_hex my_uart_hex(
        .sysclk(sysclk),
        .data(16'habcd),
        .trig(trig),
        .tx_out(tx_out));
        
    always begin
        #5;
        sysclk = !sysclk;
    end
    
    initial begin
        #100;
        trig = 1;
        #10;
        trig = 0;
        #1000000;
        trig = 1;
        #10;
        trig = 0;
    end

endmodule