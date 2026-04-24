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

module ccff (clk, rst, config_done, D, Q);
    input clk;
    input rst;
    input D;
    input config_done;
    output Q;

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
    
    ccff ccff_0  (clk, rst, config_done, ccff_head, w0);
    ccff ccff_1  (clk, rst, config_done, w0,  w1);
    ccff ccff_2  (clk, rst, config_done, w1,  w2);
    ccff ccff_3  (clk, rst, config_done, w2,  w3);
    ccff ccff_4  (clk, rst, config_done, w3,  w4);
    ccff ccff_5  (clk, rst, config_done, w4,  w5);
    ccff ccff_6  (clk, rst, config_done, w5,  w6);
    ccff ccff_7  (clk, rst, config_done, w6,  w7);
    ccff ccff_8  (clk, rst, config_done, w7,  w8);
    ccff ccff_9  (clk, rst, config_done, w8,  w9);
    ccff ccff_10 (clk, rst, config_done, w9,  w10);
    ccff ccff_11 (clk, rst, config_done, w10, w11);
    ccff ccff_12 (clk, rst, config_done, w11, w12);
    ccff ccff_13 (clk, rst, config_done, w12, w13);
    ccff ccff_14 (clk, rst, config_done, w13, w14);
    ccff ccff_15 (clk, rst, config_done, w14, w15);
    ccff ccff_17 (clk, rst, config_done, w15, ccff_tail);

    assign ccff_out = {ccff_tail, w15, w14, w13, w12, w11, w10, w9, w8, w7, w6, w5, w4, w3, w2, w1, w0};
endmodule

module lut (in, config, out);
    input [3:0] in;
    input [15:0] config;
    output out;

    wire mux_3_0_out, mux_3_1_out, mux_3_2_out, mux_3_3_out, mux_3_4_out, mux_3_5_out, mux_3_6_out, mux_3_7_out;
    wire mux_2_0_out, mux_2_1_out, mux_2_2_out, mux_2_3_out;
    wire mux_1_0_out, mux_1_1_out;

    mux mux_3_0 (config[0],  config[1],  in[3], mux_3_0_out);
    mux mux_3_1 (config[2],  config[3],  in[3], mux_3_1_out);
    mux mux_3_2 (config[4],  config[5],  in[3], mux_3_2_out);
    mux mux_3_3 (config[6],  config[7],  in[3], mux_3_3_out);
    mux mux_3_4 (config[8],  config[9],  in[3], mux_3_4_out);
    mux mux_3_5 (config[10], config[11], in[3], mux_3_5_out);
    mux mux_3_6 (config[12], config[13], in[3], mux_3_6_out);
    mux mux_3_7 (config[14], config[15], in[3], mux_3_7_out);
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

    configuration_chain cc (clk, rst, config_done, ccff_head, ccff_tail, cc_out);
    lut lut4 (in, cc_out[16:1], lut_out);
    dff ff (clk, rst, lut_out, reg_out);
    mux mux1 (lut_out, reg_out, cc_out[0], out);
endmodule
