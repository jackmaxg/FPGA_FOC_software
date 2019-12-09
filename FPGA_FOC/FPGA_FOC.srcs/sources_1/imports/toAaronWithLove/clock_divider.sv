`timescale 1ns / 1ps
//Jackson Gray 2019/12/8

//ALWAYS HAVE A LARGER DENOMINATOR THAN NUMERATOR
module clock_divider #(
        parameter SCALE_NUMERATOR = 1, 
        parameter SCALE_DENOMINATOR = 100
        ) (   
        input clk_in,
        input rst_in,
        output logic clk_out
    );
    
    localparam CNT_WIDTH = $clog2(SCALE_DENOMINATOR);
    localparam CNT_INC = SCALE_NUMERATOR;
    localparam CNT_MAX = SCALE_DENOMINATOR;
    localparam CNT_LIM = CNT_MAX - CNT_INC;
    
    logic [CNT_WIDTH-1:0] counter;
    
    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            counter <= 'b0;
            clk_out <= 1'b0;
        end else begin
            if (counter >= CNT_LIM) begin
                counter <= counter - CNT_LIM; //roll over back to the start
                clk_out <= 1'b1;
            end else begin
                counter <= counter + CNT_INC;
                clk_out <= 1'b0;
            end
        end
    end
    
endmodule