/*
 * Copyright (c) 2026 Jay Graham
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_lutram4 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n 
);
    wire ccff_tail;
    wire out;

    lutram4 dut (
        .clk(clk),
        .rst(rst_n),
        .config_done(ui_in[0]),
        .we(ui_in[1]),
        .wdata(ui_in[2]),
        .ccff_head(ui_in[3]),
        .in(ui_in[7:4]),
        .ccff_tail(ccff_tail),
        .out(out)
    );

    assign uo_out[0]   = ccff_tail;
    assign uo_out[1]   = out;
    assign uo_out[7:2] = 0;
    assign uio_out     = 0;
    assign uio_oe      = 0;

    wire _unused = &{ena, uio_in, 1'b0};

endmodule