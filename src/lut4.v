// This design is a 4-input Logic Element

module mux (in0, in1, sel, out);
    input  in0;
    input  in1; 
    input  sel;
    output out;

    assign out = sel ? in1 : in0;
endmodule

module dff (clk, rst, D, Q);
    input clk;
    input rst;
    input D;
    output reg Q;
    
    always @(posedge clk or negedge rst) begin 
        if (rst == 1'b0)
            Q <= 1'b0;
        else 
            Q <= D;
        end
endmodule

module ccff (clk, rst, D, Q, config_done);
    input clk;
    input rst;
    input D;
    output Q;
    input config_done;

    wire w0;

    mux mux0 (D, Q, config_done, w0);
    dff dff0 (clk, rst, w0, Q);
endmodule

module configuration_chain (clk, rst, config_done, ccff_head, ccff_tail, ccff_out);
    input clk;
    input rst;
    input config_done;
    input ccff_head;
    output ccff_tail;
    output [16:0] ccff_out;

    wire w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15;
    
    // This holds config for Sequ vs Comb output mode (0 = COMB, 1 = SEQU)
    ccff ccff_0  (clk, rst, ccff_head, w0,  config_done);
    ccff ccff_1  (clk, rst, w0,        w1,  config_done);
    ccff ccff_2  (clk, rst, w1,        w2,  config_done);
    ccff ccff_3  (clk, rst, w2,        w3,  config_done);
    ccff ccff_4  (clk, rst, w3,        w4,  config_done);
    ccff ccff_5  (clk, rst, w4,        w5,  config_done);
    ccff ccff_6  (clk, rst, w5,        w6,  config_done);
    ccff ccff_7  (clk, rst, w6,        w7,  config_done);
    ccff ccff_8  (clk, rst, w7,        w8,  config_done);
    ccff ccff_9  (clk, rst, w8,        w9,  config_done);
    ccff ccff_10 (clk, rst, w9,        w10, config_done);
    ccff ccff_11 (clk, rst, w10,       w11, config_done);
    ccff ccff_12 (clk, rst, w11,       w12, config_done);
    ccff ccff_13 (clk, rst, w12,       w13, config_done);
    ccff ccff_14 (clk, rst, w13,       w14, config_done);
    ccff ccff_15 (clk, rst, w14,       w15, config_done);
    ccff ccff_16 (clk, rst, w15, ccff_tail, config_done);

    assign ccff_out = {ccff_tail, w15, w14, w13, w12, w11, w10, w9, w8, w7, w6, w5, w4, w3, w2, w1, w0};
endmodule

module lut (in, config_bits, out);
    input [3:0] in;
    input [15:0] config_bits;
    output out;

    wire mux_3_0_out, mux_3_1_out, mux_3_2_out, mux_3_3_out, mux_3_4_out, mux_3_5_out, mux_3_6_out, mux_3_7_out;
    wire mux_2_0_out, mux_2_1_out, mux_2_2_out, mux_2_3_out;
    wire mux_1_0_out, mux_1_1_out;

    mux mux_3_0 (config_bits[0],  config_bits[1],  in[3], mux_3_0_out);
    mux mux_3_1 (config_bits[2],  config_bits[3],  in[3], mux_3_1_out);
    mux mux_3_2 (config_bits[4],  config_bits[5],  in[3], mux_3_2_out);
    mux mux_3_3 (config_bits[6],  config_bits[7],  in[3], mux_3_3_out);
    mux mux_3_4 (config_bits[8],  config_bits[9],  in[3], mux_3_4_out);
    mux mux_3_5 (config_bits[10], config_bits[11], in[3], mux_3_5_out);
    mux mux_3_6 (config_bits[12], config_bits[13], in[3], mux_3_6_out);
    mux mux_3_7 (config_bits[14], config_bits[15], in[3], mux_3_7_out);
    mux mux_2_0 (mux_3_0_out, mux_3_1_out, in[2], mux_2_0_out);
    mux mux_2_1 (mux_3_2_out, mux_3_3_out, in[2], mux_2_1_out);
    mux mux_2_2 (mux_3_4_out, mux_3_5_out, in[2], mux_2_2_out);
    mux mux_2_3 (mux_3_6_out, mux_3_7_out, in[2], mux_2_3_out);
    mux mux_1_0 (mux_2_0_out, mux_2_1_out, in[1], mux_1_0_out);
    mux mux_1_1 (mux_2_2_out, mux_2_3_out, in[1], mux_1_1_out);
    mux mux_0_0 (mux_1_0_out, mux_1_1_out, in[0], out);
endmodule

module lut4 (clk, rst, config_done, ccff_head, in, ccff_tail, out);
    input clk;
    input rst; 
    input config_done;
    input ccff_head;
    input [3:0] in;
    output ccff_tail;
    output out;

    wire [16:0] cc_out;
    wire lut_out;
    wire reg_out;

    configuration_chain cc (
        .clk(clk), 
        .rst(rst), 
        .config_done(config_done),
        .ccff_head(ccff_head),
        .ccff_tail(ccff_tail),
        .ccff_out(cc_out)
    );

    lut lut4 (
        .in(in),
        .config_bits(cc_out[16:1]),
        .out(lut_out)
    );

    dff ff (clk, rst, lut_out, reg_out);
    mux mux1 (lut_out, reg_out, cc_out[0], out);
endmodule
