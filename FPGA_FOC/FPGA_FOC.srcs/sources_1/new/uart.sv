`timescale 1ns / 1ps

module uart(clk, trig, data, tx_out, ready);
    input clk, trig, data;
    output tx_out, ready;

    wire clk;
    wire trig;
    reg ready = 1;

    wire [7:0] data;
    reg [7:0] data_buf = 0;
    wire [9:0] pad_data = {1'b1, data_buf, 1'b0};

    reg tx_out = 1;
    reg [10:0] ctr = 0;
    reg [3:0] index = 4'hf;

    always_ff @(posedge clk) begin
        if (ready) begin
            if (trig) begin
                ctr <= 0;
                ready <= 0;
                data_buf <= data;
                index <= 4'h0;
                tx_out <= pad_data[0];
            end
        end else begin
            if (ctr >= 100) begin
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

module data_to_hex_reg(data, hex_out);
    input data;
    output hex_out;

    parameter DIGITS = 4;
    wire [4*DIGITS-1:0] data;
    wire [8*DIGITS-1:0] hex_out;
    wire [3:0] frames [0:DIGITS-1];

    genvar gi;
    for (gi = 0; gi < DIGITS; gi = gi+1) begin : genhex
        assign frames[gi] = data[4*gi+3:4*gi];
        assign hex_out[8*gi+7:8*gi] = frames[gi] < 10 ? 8'h30 + frames[gi] : 8'h37 + frames[gi];
    end
endmodule

module uart_tx_buf(clk, data, trig, tx_out, ready);
    input clk, trig, data;
    output tx_out, ready;
    parameter BYTES = 4;

    wire [8*BYTES-1:0] data;
    reg [8*BYTES-1:0] data_buf;
    wire [7:0] byte_arr [0:BYTES-1];
    wire trig;
    reg ready = 1;

    genvar gi;
    for (gi = 0; gi < BYTES; gi = gi+1) begin : genbytes
        assign byte_arr[gi] = data_buf[8*gi+7:8*gi];
    end

    reg [7:0] tx_data = 0;
    reg uart_trig = 0;
    wire tx_out;
    wire uart_ready;
    reg [7:0] index = BYTES;

    uart tx(
        .clk(clk),
        .data(tx_data),
        .trig(uart_trig),
        .tx_out(tx_out),
        .ready(uart_ready));

    reg old_uart_ready = 0;
    always_ff @(posedge clk) begin
        if (ready) begin
            if (trig) begin
                data_buf <= data;
                ready <= 0;
                index <= 1;
                tx_data <= data[8*BYTES-1:8*BYTES-8];
                uart_trig <= 1;
            end
            else begin
                uart_trig <= 0;
            end
        end
        else begin
            if (uart_ready && !old_uart_ready) begin
                if (index < BYTES) begin
                    tx_data <= byte_arr[BYTES - 1 - index];
                    index <= index + 1;
                    uart_trig <= 1;
                end
                else begin
                    ready <= 1;
                end
            end
            else begin
                uart_trig <= 0;
            end
        end
        old_uart_ready <= uart_ready;
    end

endmodule

module data_to_hex(clk, reset, data, trig, hex_out, ready, done);
    input clk, trig, data, reset;
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

    always_ff @(posedge clk) begin
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

module uart_tx_hex(clk, data, trig, tx_out);
    input clk, trig, data;
    output tx_out;

    parameter DIGITS = 4;

    wire clk;
    wire trig;
    wire [4*DIGITS-1:0] data;

    reg hex_reset = 0;
    reg hex_trig = 0;
    reg [4*DIGITS-1:0] data_buf = 0;
    wire hex_done;
    wire hex_ready;
    wire [7:0] hex_out;

    data_to_hex #(.DIGITS(DIGITS)) hex_decoder(
        .clk(clk),
        .data(data_buf),
        .reset(hex_reset),
        .trig(hex_trig),
        .hex_out(hex_out),
        .done(hex_done),
        .ready(hex_ready));

    wire uart_ready;
    wire tx_out;

    uart tx(
        .clk(clk),
        .data(hex_out),
        .trig(hex_ready),
        .tx_out(tx_out),
        .ready(uart_ready));

    always_ff @(posedge clk) begin
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
