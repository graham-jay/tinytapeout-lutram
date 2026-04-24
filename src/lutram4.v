// This design is a 4-input Logic Element with 16x1 RAM capabilities

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

module ccff (clk, rst, D, config_done, Q);
    input clk;
    input rst;
    input D;
    input config_done;
    output Q;

    wire w0;

    mux mux0 (D, Q, config_done, w0);
    dff dff0 (clk, rst, w0, Q);
endmodule

module ccff_ram (clk, rst, D, config_done, we, data, Q);
    input clk;
    input rst;
    input D;
    input config_done;
    input we;
    input data;
    output Q;

    wire w0, w1;

    mux mux0 (Q, data, we, w0);
    mux mux1 (D, w0, config_done, w1);
    dff dff0 (clk, rst, w1, Q);
endmodule

module configuration_chain (clk, rst, config_done, we, data, ccff_head, ccff_tail, ccff_out);
    input clk;
    input rst;
    input config_done;
    input [15:0] we;
    input data;
    input ccff_head;
    output ccff_tail;
    output [17:0] ccff_out;

    wire w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16;
    
    // This holds config for LUT vs RAM mode (0 = LUT, 1 = RAM)
    ccff ccff_0 (clk, rst, ccff_head, config_done, w0);
    // This holds config for Sequ vs Comb output mode (0 = COMB, 1 = SEQU)
    ccff ccff_1 (clk, rst, w0, config_done, w1);
    // The next 16 ccff_ram are to support 16x1 RAM
    ccff_ram ccff_2  (clk, rst, w1,  config_done, we[0],  data, w2);
    ccff_ram ccff_3  (clk, rst, w2,  config_done, we[1],  data, w3);
    ccff_ram ccff_4  (clk, rst, w3,  config_done, we[2],  data, w4);
    ccff_ram ccff_5  (clk, rst, w4,  config_done, we[3],  data, w5);
    ccff_ram ccff_6  (clk, rst, w5,  config_done, we[4],  data, w6);
    ccff_ram ccff_7  (clk, rst, w6,  config_done, we[5],  data, w7);
    ccff_ram ccff_8  (clk, rst, w7,  config_done, we[6],  data, w8);
    ccff_ram ccff_9  (clk, rst, w8,  config_done, we[7],  data, w9);
    ccff_ram ccff_10 (clk, rst, w9,  config_done, we[8],  data, w10);
    ccff_ram ccff_11 (clk, rst, w10, config_done, we[9],  data, w11);
    ccff_ram ccff_12 (clk, rst, w11, config_done, we[10], data, w12);
    ccff_ram ccff_13 (clk, rst, w12, config_done, we[11], data, w13);
    ccff_ram ccff_14 (clk, rst, w13, config_done, we[12], data, w14);
    ccff_ram ccff_15 (clk, rst, w14, config_done, we[13], data, w15);
    ccff_ram ccff_16 (clk, rst, w15, config_done, we[14], data, w16);
    ccff_ram ccff_17 (clk, rst, w16, config_done, we[15], data, ccff_tail);

    assign ccff_out = {ccff_tail, w16, w15, w14, w13, w12, w11, w10, w9, w8, w7, w6, w5, w4, w3, w2, w1, w0};
endmodule

module decoder (in, en, out);
    input  wire [3:0]  in;
    input  wire        en;
    output wire [15:0] out;

    assign out = en ? (16'b1 << in) : 16'b0;
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

module lutram (clk, rst, config_done, we, data, ccff_head, in, ccff_tail, out);
    input clk;
    input rst; 
    input config_done;
    input we;
    input data;
    input ccff_head;
    input [3:0] in;
    output ccff_tail;
    output out;

    wire [15:0] decoder_out;
    wire [17:0] cc_out;
    wire decoder_en;
    wire lut_out;
    wire reg_out;

    configuration_chain cc (clk, rst, config_done, decoder_out, data, ccff_head, ccff_tail, cc_out);
    decoder dec (in, decoder_en, decoder_out);
    lut lut4 (in, cc_out[17:2], lut_out);
    dff ff (clk, rst, lut_out, reg_out);
    mux mux1 (lut_out, reg_out, cc_out[1], out);
    mux mux2 (1'b0, we, cc_out[0], decoder_en);
endmodule
