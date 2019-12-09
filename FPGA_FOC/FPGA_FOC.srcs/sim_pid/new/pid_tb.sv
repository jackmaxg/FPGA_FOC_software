`timescale 1ns / 1ps
module pid_tb();

    reg clk = 0;
    always begin
        #5;
        clk = !clk;
    end

    reg [15:0] err = 0;
    wire [15:0] out;
    reg [15:0] kp = 16'h4000;
    reg [15:0] ki = 16'h0400;

    pid my_pid (
        .clk(clk),
        .kp(kp), .ki(ki),
        .err(err),
        .out(out));

    
    initial begin
        #100;
        err = 1;
        #1000;
        err = -1;
        #1000;
        err = 0;
        #100;
        err = -200;
        #1000;
        err = 200;
        #1000;
        err = 0;
        #100;
        $finish;
    end


endmodule
