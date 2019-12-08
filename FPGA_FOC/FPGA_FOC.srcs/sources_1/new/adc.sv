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


module adc(clk, sdo, cs, sclk, adc_out, ready);
    input clk, sdo;
    output cs, sclk, adc_out, ready;

    wire clk;
    wire sdo;
    wire sclk = clk;
    reg cs = 1;
    reg [11:0] adc_out_buf = 0;
    reg [11:0] adc_out = 0;
    reg ready = 0;

    reg [4:0] cycle_index = 0;
    always_ff @(posedge clk) begin
        cs <= (cycle_index == 0);
    end

    always_ff @(negedge clk) begin
        cycle_index <= cycle_index >= 16 ? 0 : cycle_index + 1;
        if (cycle_index == 15) begin
            adc_out <= {adc_out_buf[10:0], sdo};
        end
        ready <= (cycle_index == 15);
        adc_out_buf <= {adc_out_buf[10:0], sdo};
    end

endmodule
