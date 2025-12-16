// This design is a 4-input LUT with 16x1 RAM capabilities
//



module m21(Y, D0, D1, S);

output Y;
input D0, D1, S;
wire T1, T2, Sbar;

and (T1, D1, S), (T2, D0, Sbar);
not (Sbar, S);
or (Y, T1, T2);

endmodule

module DFF(D, clk, rst, Q);
    input D;
    input clk;
    input rst;
    output reg Q;
    
    always @(posedge clk or negedge rst) begin 
        if (rst == 1'b0)
            Q <= 1'b0;
        else 
            Q <= D;
        end
endmodule

module decoder4x16 (
    input  wire [3:0] in,
    input  wire       en,
    output wire [15:0] out
);

assign out = en ? (16'b1 << in) : 16'b0;

endmodule
        

module DFF_custom (clk, rst, D, we, reg_wdata, ccff_done, Q);
    input clk, rst;
    input D;
    input we;
    input reg_wdata;
    input ccff_done;
    output reg Q;

    
    wire n1, n2, n3;

       
    assign n1 = we & reg_wdata;

    m21 m1 (n2, Q, n1, we);
    m21 m2 (n3, n2, D, ccff_done);


    always @(posedge clk or negedge rst) begin 
        if (rst == 1'b0)
            Q <= 1'b0;
        else
            Q <= n3;
    end
    
    
    
endmodule


module configuration_chain (clk, rst, prog_clk, prog_rst, ccff_head, ccff_tail, ccff_done, we, reg_wdata, ccff_data_out);
    input clk, rst;
    input prog_clk, prog_rst;
    input ccff_head, ccff_done, reg_wdata;
    input [15:0] we;
    output ccff_tail;
    output [17:0] ccff_data_out;

    wire n1, n2, n3, n4, n5, n6;
    wire n7, n8, n9, n10, n11;
    wire n12, n13, n14, n15, n16;
    wire n17;

    wire clk_s, rst_s;


    // This mux selects clock for lut/ram operation
    // Durign tech mapping this needs to be mapped to 
    // a specalised clk mux to avoid jitter, etc.. 
    m21 m1 (clk_s, clk, prog_clk, n1);
    // also need to mux the reset
    m21 m2 (rst_s, rst, prog_rst, n1);

    
    // This controls LUT or RAM mode
    DFF ccff_0 (ccff_head, prog_clk, rst, n1);
    // This controls output seq/comb
    DFF ccff_1 (n1, prog_clk, rst, n2);


    
    // The next 16 DFF are DFF_custom to support 16 x 1 ram
    DFF_custom ccff_3 (clk_s, rst_s, n2, we[15], reg_wdata, ccff_done, n3);
    DFF_custom ccff_4 (clk_s, rst_s, n3, we[14], reg_wdata, ccff_done, n4);
    DFF_custom ccff_5 (clk_s, rst_s, n4, we[13], reg_wdata, ccff_done, n5);
    DFF_custom ccff_6 (clk_s, rst_s, n5, we[12], reg_wdata, ccff_done, n6);

    DFF_custom ccff_7 (clk_s, rst_s, n6, we[11], reg_wdata, ccff_done, n7);
    DFF_custom ccff_8 (clk_s, rst_s, n7, we[10], reg_wdata, ccff_done, n8);
    DFF_custom ccff_9 (clk_s, rst_s, n8, we[9], reg_wdata, ccff_done, n9);
    DFF_custom ccff_10 (clk_s, rst_s, n9, we[8], reg_wdata, ccff_done, n10);

    DFF_custom ccff_11 (clk_s, rst_s, n10, we[7], reg_wdata, ccff_done, n11);
    DFF_custom ccff_12 (clk_s, rst_s, n11, we[6], reg_wdata, ccff_done, n12);
    DFF_custom ccff_13 (clk_s, rst_s, n12, we[5], reg_wdata, ccff_done, n13);
    DFF_custom ccff_14 (clk_s, rst_s, n13, we[4], reg_wdata, ccff_done, n14);

    DFF_custom ccff_15 (clk_s, rst_s, n14, we[3], reg_wdata, ccff_done, n15);
    DFF_custom ccff_16 (clk_s, rst_s, n15, we[2], reg_wdata, ccff_done, n16);
    DFF_custom ccff_17 (clk_s, rst_s, n16, we[1], reg_wdata, ccff_done, n17);
    DFF_custom ccff_18 (clk_s, rst_s, n17, we[0], reg_wdata, ccff_done, ccff_tail);


endmodule

module mux_nw (I, ccff_in, mnw_out);
    input [3:0] I;
    input [15:0] ccff_in;
    output mnw_out;

    //########################################
    // Fist implement the 16 to 1 mux network
    wire m_3_0_o, m_3_1_o, m_3_2_o, m_3_3_o, m_3_4_o, m_3_5_o, m_3_6_o, m_3_7_o;
    wire m_2_0_o, m_2_1_o, m_2_2_o, m_2_3_o;
    wire m_1_0_o, m_1_1_o;
        
    //Level 3 muxes
    m21 m_3_0 (m_3_0_o, ccff_in[15], ccff_in[14], I[3]); 
    m21 m_3_1 (m_3_1_o, ccff_in[13], ccff_in[12], I[3]);
    m21 m_3_2 (m_3_2_o, ccff_in[11], ccff_in[10], I[3]);
    m21 m_3_3 (m_3_3_o, ccff_in[9], ccff_in[8], I[3]);
    m21 m_3_4 (m_3_4_o, ccff_in[7], ccff_in[6], I[3]);
    m21 m_3_5 (m_3_5_o, ccff_in[5], ccff_in[4], I[3]);
    m21 m_3_6 (m_3_6_o, ccff_in[3], ccff_in[2], I[3]);
    m21 m_3_7 (m_3_7_o, ccff_in[1], ccff_in[0], I[3]);

    //Level 2 muxes
    m21 m_2_0 (m_2_0_o, m_3_0_o, m_3_1_o, I[2]); 
    m21 m_2_1 (m_2_0_o, m_3_2_o, m_3_3_o, I[2]);
    m21 m_2_2 (m_2_0_o, m_3_4_o, m_3_5_o, I[2]);
    m21 m_2_3 (m_2_0_o, m_3_6_o, m_3_7_o, I[2]);

    //Level 1 muxes
    m21 m_1_0 (m_1_0_o, m_2_0_o, m_2_1_o, I[1]); 
    m21 m_1_1 (m_1_1_o, m_2_2_o, m_2_3_o, I[1]);

    //Level 0 muxes (mux network out (mnw_out))
    m21 m_0_0 (mnw_out, m_1_0_o, m_1_1_o, I[0]);
    //########################################
    
endmodule

    

module lut4_dff_ram (clk, rst, prog_clk, prog_rst, ccff_head, ccff_tail, ccff_done, I, lut4_out, we, wdata_in);
    input clk, rst;
    input prog_clk, prog_rst; 
    input ccff_head;
    input ccff_done;
    input [3:0] I;
    input we;
    input wdata_in;
    output lut4_out;
    output ccff_tail;


    wire [15:0] decode_out;
    wire [17:0] ccff_data_out;
    wire output_dff_w;
    wire mnw_out;

    configuration_chain ccff_chain  (clk, rst, prog_clk, prog_rst, ccff_head, ccff_tail, ccff_done, decode_out, wdata_in, ccff_data_out);
    decoder4x16 decode_addr (I, we, decode_out);
    mux_nw mux_network (I, ccff_data_out[15:0], mnw_out);
    
    
    // mux to control seq/comb output
    m21 output_mux (lut4_out, mnw_out, output_dff_w, ccff_data_out[16]);

    // OUTPUT DFF
    DFF (mnw_out, clk, rst, output_dff_w);
    
endmodule


