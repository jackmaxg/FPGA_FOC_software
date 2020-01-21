`timescale 1ns / 1ps

//Jackson Gray 2019/12/8

module tb_svpwm;
    localparam BITS = 12;
    
    // Inputs
    logic clock;
    logic reset;
    logic signed [BITS-1:0] vu;
    logic signed [BITS-1:0] vv;
    logic signed [BITS-1:0] vw;
    
    // Outputs
    wire pwm_u;
    wire pwm_v;
    wire pwm_w;
    
    svpwm #(
            .CLK_IN_HZ(100_000),
            .BITS(12),
            .SW_HZ(4)
        ) my_svpwm (
            .clk_in( clock ),
            .rst_in( reset ),
            .u_vset_in(vu),
            .v_vset_in(vv),
            .w_vset_in(vw),
            .ph_u_out(pwm_u),
            .ph_v_out(pwm_v),
            .ph_w_out(pwm_w)
        );
    
    always #5 clock = !clock;
    
    initial begin
        // Initialize Inputs
        clock = 1'b0;
        reset = 1'b1;
        
        vu = 'h444;
        vv = 'h0;
        vw = -'h444;
        // Wait 50 ns for global reset to finish
        #46;
        reset = 1'b0;
        #4;
        #50;
        #1_000_000;
        $finish;
    end
endmodule