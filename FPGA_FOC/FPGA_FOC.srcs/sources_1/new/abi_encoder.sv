`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2019 03:51:31 AM
// Design Name: 
// Module Name: abi_encoder
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


module abi_encoder(clk, a, b, i, reset, theta, omega, ready);
    input wire clk, a, b, i, reset;
    output theta, omega, ready;

    reg [11:0] theta = 0;
    reg signed [15:0] omega = 0;
    reg ready = 0;


    parameter NSYNC = 3;
    synchronize #(.NSYNC(NSYNC)) sync_a (.clk(clk), .in(a), .out(a_good));
    synchronize #(.NSYNC(NSYNC)) sync_b (.clk(clk), .in(b), .out(b_good));
    reg last_a = 0;
    reg last_b = 0;

    task incr_up;
    begin
        if (theta[6:0] == 7'b111_1100)
            theta <= theta + 4;
        else
            theta <= theta + 1;
    end
    endtask

    task incr_down;
    begin
        if (theta[6:0] == 7'b000_0000)
            theta <= theta - 4;
        else
            theta <= theta - 1;
    end
    endtask

    always_ff @(posedge clk) begin
        last_a <= a_good;
        last_b <= b_good;
        if (reset) begin
            theta <= 0;
            ready <= 0;
        end
        else if (ready) begin
            if (last_a != a_good) begin
                if (a_good == b_good)
                    incr_up;
                else
                    incr_down;
            end
            if (last_b != b_good) begin
                if (a_good != b_good)
                    incr_up;
                else
                    incr_down;
            end
        end
        else if (i) begin
            theta <= 0;
            ready <= 1;
        end
    end

endmodule
