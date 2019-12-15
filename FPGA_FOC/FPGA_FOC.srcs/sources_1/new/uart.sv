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

    parameter BAUD_SCALER = 868;
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
            if (ctr >= BAUD_SCALER) begin
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

module uart_rx(clk, rx_in, data, ready);
    input clk, rx_in;
    output data, ready;
    wire clk, rx_in;
    reg [7:0] data = 0;
    reg ready = 1;
    reg waiting = 1;
    reg [9:0] data_buf = 0;

    reg [10:0] ctr = 0;
    reg [3:0] index = 0;
    parameter BAUD_SCALER = 868;
    reg [10:0] one_ctr = 0;
    always_ff @(posedge clk) begin
        if (waiting) begin
            if (rx_in == 0) begin
                waiting <= 0;
                index <= 0;
                ctr <= 0;
                one_ctr <= 0;
            end
        end
        else if (ready) begin
            if (ctr >= BAUD_SCALER) begin
                one_ctr <= 0;
                if (one_ctr < (BAUD_SCALER >> 1)) begin
                    ctr <= 1;
                    index <= index + 1;
                    ready <= 0;
                end else begin
                    ctr <= 0;
                    waiting <= 1;
                    ready <= 1;
                    index <= 0;
                end
            end else begin
                ctr <= ctr + 1;
                one_ctr <= one_ctr + rx_in;
            end
        end else begin
            if (ctr >= BAUD_SCALER) begin
                ctr <= 1;
                index <= index + 1;
                data_buf[index] <= (one_ctr > (BAUD_SCALER >> 1));
                one_ctr <= 0;
            end
            else begin
                ctr <= ctr + 1;
                one_ctr <= one_ctr + rx_in;
            end
            if (ctr == (BAUD_SCALER >> 1)) begin
                if (index >= 9) begin
                    ready <= 1;
                    waiting <= 1;
                    data <= data_buf[8:1];
                end
            end
        end
    end
endmodule

module uart_rx_decoder(clk, rx_in, sel, payload, ready, valid);
    parameter PAYLOAD_LEN = 4;
    input clk, rx_in;
    output sel, payload, ready, valid;

    wire clk, rx_in;
    reg ready = 1;
    reg valid = 0;
    wire [4*PAYLOAD_LEN-1:0] payload;
    reg [3:0] payload_buf [0:PAYLOAD_LEN-1];

    genvar gi;
    for (gi = 0; gi < PAYLOAD_LEN; gi = gi+1) begin : genpayload
        assign payload[4*gi+3:4*gi] = payload_buf[PAYLOAD_LEN-gi-1];
        initial payload_buf[gi] = 0;
    end


    wire uart_ready;
    wire [7:0] uart_data;

    uart_rx rx( .clk(clk), .rx_in(rx_in), .data(uart_data), .ready(uart_ready) );
    reg [7:0] index = 0;

    reg uart_ready_old = 0;
    reg [7:0] sel = 0;

    task increment_index;
    begin
        if (index < PAYLOAD_LEN-1) begin
            index <= index + 1;
        end
        else begin
            ready <= 1;
            index <= 0;
            valid <= 1;
        end
    end
    endtask

    always_ff @(posedge clk) begin
        uart_ready_old <= uart_ready;
        if (ready) begin
            index <= 0;
            valid <= 0;
            if (uart_ready && !uart_ready_old) begin
                case (uart_data)
                    8'h51 : begin sel <= uart_data; ready <= 0; end
                    8'h49 : begin sel <= uart_data; ready <= 0; end
                    8'h58 : begin sel <= uart_data; ready <= 0; end
                    default : ready <= 1; 
                endcase
            end
        end
        else begin
            if (uart_ready && !uart_ready_old) begin
                case (uart_data)
                    8'h30 : begin payload_buf[index] <= 4'h0; increment_index; end
                    8'h31 : begin payload_buf[index] <= 4'h1; increment_index; end
                    8'h32 : begin payload_buf[index] <= 4'h2; increment_index; end
                    8'h33 : begin payload_buf[index] <= 4'h3; increment_index; end
                    8'h34 : begin payload_buf[index] <= 4'h4; increment_index; end
                    8'h35 : begin payload_buf[index] <= 4'h5; increment_index; end
                    8'h36 : begin payload_buf[index] <= 4'h6; increment_index; end
                    8'h37 : begin payload_buf[index] <= 4'h7; increment_index; end
                    8'h38 : begin payload_buf[index] <= 4'h8; increment_index; end
                    8'h39 : begin payload_buf[index] <= 4'h9; increment_index; end
                    8'h41 : begin payload_buf[index] <= 4'ha; increment_index; end
                    8'h42 : begin payload_buf[index] <= 4'hb; increment_index; end
                    8'h43 : begin payload_buf[index] <= 4'hc; increment_index; end
                    8'h44 : begin payload_buf[index] <= 4'hd; increment_index; end
                    8'h45 : begin payload_buf[index] <= 4'he; increment_index; end
                    8'h46 : begin payload_buf[index] <= 4'hf; increment_index; end
                    8'h61 : begin payload_buf[index] <= 4'ha; increment_index; end
                    8'h62 : begin payload_buf[index] <= 4'hb; increment_index; end
                    8'h63 : begin payload_buf[index] <= 4'hc; increment_index; end
                    8'h64 : begin payload_buf[index] <= 4'hd; increment_index; end
                    8'h65 : begin payload_buf[index] <= 4'he; increment_index; end
                    8'h66 : begin payload_buf[index] <= 4'hf; increment_index; end
                    default : begin sel <= 0; valid <= 0; index <= 0; ready <= 1; end
                endcase
            end
        end
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
