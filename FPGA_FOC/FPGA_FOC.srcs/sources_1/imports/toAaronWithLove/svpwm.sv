`timescale 1ns / 1ps
//Jackson Gray 2019/12/8

module svpwm #(
        parameter CLK_IN_HZ = 100_000_000,
        parameter BITS = 12,
        parameter SW_HZ = 20_000
    )  (
        input rst_in,
        input clk_in,
        
        input signed [BITS-1:0] u_vset_in,
        input signed [BITS-1:0] v_vset_in,
        input signed [BITS-1:0] w_vset_in,
        
        output logic ph_u_out,
        output logic ph_v_out,
        output logic ph_w_out
    );
    localparam clk_div_num = SW_HZ * 2**BITS;
    localparam clk_div_denom = CLK_IN_HZ;
    
    logic sw_counter_clock;
    
    logic [BITS-1:0] counter;
    logic upcount = 1'b1;
    logic [BITS-1:0] counter_max;
    
    logic [BITS-1:0] u_thresh;
    logic [BITS-1:0] v_thresh;
    logic [BITS-1:0] w_thresh;
    
    
    clock_divider #(
            .SCALE_NUMERATOR(clk_div_num),
            .SCALE_DENOMINATOR(clk_div_denom)
        ) clk_div (
            .clk_in(clk_in),
            .rst_in(rst_in),
            .clk_out(sw_counter_clock)
    );
    
    
    task set_thresholds;
        u_thresh <= { ~u_vset_in[BITS-1], u_vset_in[BITS-2:0] };
        v_thresh <= { ~v_vset_in[BITS-1], v_vset_in[BITS-2:0] };
        w_thresh <= { ~w_vset_in[BITS-1], w_vset_in[BITS-2:0] };
    endtask
    
    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            ph_u_out <= 'b0;
            ph_v_out <= 'b0;
            ph_w_out <= 'b0;
            
            set_thresholds;
            
            counter <= 'b0;
            upcount <= 1'b1;
            counter_max <= ('b0)-1;
        end else begin
            if(sw_counter_clock) begin
                if (upcount) begin //if counting up
                    if(counter >= counter_max) begin //if going to count past limit
                        set_thresholds; //grab new thresholds
                        counter <= ~('b0);
                        upcount <= 1'b0; //start counting down
                    end else begin
                        u_thresh <= u_thresh;
                        v_thresh <= v_thresh;
                        w_thresh <= w_thresh;
                        counter <= counter + 'b1;
                        upcount <= 1'b1;
                    end 
                end else begin //if counting down
                    if (counter <= 'b0) begin //if going to count past limit
                        set_thresholds; //grab new thresholds
                        counter <= 'b0;
                        upcount <= 1'b1; //start counting ups
                    end else begin
                        u_thresh <= u_thresh;
                        v_thresh <= v_thresh;
                        w_thresh <= w_thresh;
                        counter <= counter - 'b1;
                        upcount <= 1'b0;
                    end
                end
            end
            ph_u_out <= (counter < u_thresh);
            ph_v_out <= (counter < v_thresh);
            ph_w_out <= (counter < w_thresh);
        end
    end
endmodule
