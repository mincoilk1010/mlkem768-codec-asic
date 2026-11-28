`timescale 1ns/1ps

module mlkem_compress_enc (
    input  wire        clk,
    input  wire        arstn,

    input  wire        i_coef_valid,
    output logic       o_coef_ready,
    input  wire [11:0] i_coef_data,   // 0 <= x <= 3328
    input  wire        i_coef_last,   // hệ số thứ 256 của đa thức
    input  wire [1:0]  i_d_sel,       // 00: d=1, 01: d=4, 10: d=10 (11 == ERROR)

    output logic        o_word_valid,
    input  wire         i_word_ready,
    output logic [31:0] o_word_data,
    output logic        o_word_last,

    output logic        o_err_range,
    output logic        o_err_proto
);

    logic       first;       
    logic [1:0] d_lat;       
    logic [7:0] coef_cnt;    

    wire [1:0] d_eff  = first ? i_d_sel : d_lat;
    wire       accept = i_coef_valid && o_coef_ready;
    
    //compress
    wire [9:0] c_data;

    compress u_compress (
        .i_d_sel (d_eff),
        .i_data  (i_coef_data),
        .o_data  (c_data)
    );

    //agorithm 5 + 3
    mlkem_word_packer u_packer (
        .clk     (clk),
        .arstn   (arstn),
        .i_valid (i_coef_valid),
        .o_ready (o_coef_ready),
        .i_data  (c_data),
        .i_last  (i_coef_last),
        .i_d_sel (d_eff),
        .o_valid (o_word_valid),
        .i_ready (i_word_ready),
        .o_data  (o_word_data),
        .o_last  (o_word_last)
    );

    // ------------------------------------------------------------------
    // Chốt d, đếm hệ số, cờ lỗi
    // ------------------------------------------------------------------
    always_ff @(posedge clk or negedge arstn) begin
        if (~arstn) begin
            first       <= 1'b1;
            d_lat       <= 2'd0;
            coef_cnt    <= 8'd0;
            o_err_range <= 1'b0;
            o_err_proto <= 1'b0;
        end else if (accept) begin
            if (first) begin
                d_lat <= i_d_sel;                       
                if (i_d_sel == 2'd3) o_err_proto <= 1'b1; 
            end
            first <= i_coef_last;                       

            if (i_coef_data >= 12'd3329)
                o_err_range <= 1'b1;                    
                
            if (i_coef_last != (coef_cnt == 8'd255))
                o_err_proto <= 1'b1;

            coef_cnt <= i_coef_last ? 8'd0 : coef_cnt + 8'd1;
        end
    end

endmodule