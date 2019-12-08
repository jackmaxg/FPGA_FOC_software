`timescale 1ns / 1ps

module uart(sysclk, trig, data, tx_out, ready);
    input sysclk, trig, data;
    output tx_out, ready;

    wire sysclk;
    wire trig;
    reg ready = 1;

    wire [7:0] data;
    reg [7:0] data_buf = 0;
    wire [9:0] pad_data = {1'b1, data_buf, 1'b0};

    reg tx_out = 1;
    reg [10:0] ctr = 0;
    reg [3:0] index = 4'hf;

    always_ff @(posedge sysclk) begin
        if (ready) begin
            if (trig) begin
                ctr <= 0;
                ready <= 0;
                data_buf <= data;
                index <= 4'h0;
                tx_out <= pad_data[0];
            end
        end else begin
            if (ctr >= 104) begin
                ctr <= 1;
                index <= index + 1;
            end else begin
                ctr <= ctr + 1;
            end

            if (index > 9) begin
                ready <= 1;
                tx_out <= 1;
            end else begin
                tx_out <= pad_data[index];
            end

        end
    end
endmodule

module data_to_hex(sysclk, reset, data, trig, hex_out, ready, done);
    input sysclk, trig, data, reset;
    output hex_out, done, ready;
    parameter DIGITS = 4;

    wire [4*DIGITS-1:0] data;
    wire trig;
    reg old_trig = 0;
    wire reset;

    reg cr = 1;
    reg done = 1;
    wire [7:0] hex_out = done ? 8'h0A : (cr ? 8'h0D : (frame < 10 ? 8'h30 + frame : 8'h37 + frame));
    reg [7:0] index = 0;
    reg [3:0] frame = 0;
    reg ready = 0;

    always_ff @(posedge sysclk) begin
        if (reset) begin
            frame <= data[4*DIGITS-1:4*DIGITS-4];
            index <= 4*DIGITS;
            done <= 0;
            cr <= 0;
            ready <= 0;
        end
        else if (trig && !old_trig) begin
            ready <= 1;
            if (index > 0) begin
                frame <= data >> (index-4);
                index <= index - 4;
            end
            else if (!cr) begin
                cr <= 1;
            end else begin
                done <= 1;
            end
        end else begin
            ready <= 0;
        end
        old_trig <= trig;
    end

endmodule

module uart_tx_hex(sysclk, data, trig, tx_out);
    input sysclk, trig, data;
    output tx_out;

    parameter DIGITS = 4;

    wire sysclk;
    wire trig;
    wire [4*DIGITS-1:0] data;

    reg hex_reset = 0;
    reg hex_trig = 0;
    reg [4*DIGITS-1:0] data_buf = 0;
    wire hex_done;
    wire hex_ready;
    wire [7:0] hex_out;

    data_to_hex #(.DIGITS(DIGITS)) hex_decoder(
        .sysclk(sysclk),
        .data(data_buf),
        .reset(hex_reset),
        .trig(hex_trig),
        .hex_out(hex_out),
        .done(hex_done),
        .ready(hex_ready));

    wire uart_ready;
    wire tx_out;

    uart tx(
        .sysclk(sysclk),
        .data(hex_out),
        .trig(hex_ready),
        .tx_out(tx_out),
        .ready(uart_ready));

    always_ff @(posedge sysclk) begin
        if (hex_done) begin
            if (trig) begin
                data_buf <= data;
                hex_reset <= 1;
            end
            hex_trig <= 0;
        end
        else begin
            hex_reset <= 0;
            hex_trig <= uart_ready;
        end
    end

endmodule
