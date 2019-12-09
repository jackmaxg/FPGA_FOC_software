`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2019 01:46:57 AM
// Design Name: 
// Module Name: adc
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


module adc(clk, sdo, reset, cs, sclk, adc_out, ready);
    input clk, sdo, reset;
    output cs, sclk, adc_out, ready;

    wire clk;
    wire sdo;
    reg cs = 1;
    reg [11:0] adc_out_buf = 0;
    reg [11:0] adc_out = 0;
    reg ready = 0;

    reg [2:0] clk_div = 0;
    wire sclk = clk_div[2];
    reg [4:0] cycle_index = 0;
    always_ff @(posedge clk) begin
        if (clk_div == 0) begin
            if (reset | (cycle_index == 0)) begin
                cs <= 1;
            end
            else if (cycle_index == 1) begin
                cs <= 0;
            end
        end

        if (clk_div == 4) begin
            cycle_index <= cycle_index >= 16 ? 0 : cycle_index + 1;
            if (cycle_index == 14) begin
                adc_out <= {adc_out_buf[10:0], sdo};
            end
            ready <= (cycle_index == 14);
            adc_out_buf <= {adc_out_buf[10:0], sdo};
        end else begin
            ready <= 0;
        end
        clk_div <= clk_div + 1;
    end
endmodule
