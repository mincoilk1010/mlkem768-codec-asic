`timescale 1ns/1ps
module mlkem_word_packer (
    input wire clk,
    input wire arstn,

    input wire i_valid,
    output logic o_ready,
    input wire [9:0] i_data, //receive x (0 <= x <= 3328)
    input wire i_last,
    input wire [1:0] i_d_sel, //0:d=1, 1:d=4, 2:d=10

    output logic o_valid, 
    input wire i_ready,
    output logic [31:0] o_data,
    output logic o_last
);

    logic [3:0] d_bits;
    logic [9:0] c_mask;
    always_comb begin
        case (i_d_sel)
            2'd0: begin d_bits = 4'd1; c_mask = 10'h001; end //1 bit "1"
            2'd1: begin d_bits = 4'd4; c_mask = 10'h00F; end //4 bit "1"
            default: begin d_bits = 4'd10; c_mask = 10'h3FF; end //10 bit "1"
        endcase
    end

    logic [40:0] acc; //buffer store d
    logic [5:0]  cnt; //buffer bit cnt

    logic out_v; //output valid flag
    logic out_last; //last output flag
    logic [31:0] out_d; //data out

    assign o_ready = !out_v; 
    assign o_valid = out_v;
    assign o_data  = out_d;           
    assign o_last  = out_last;        

    wire accept = i_valid && o_ready; //decompress accept word
    wire [40:0] acc_next;
    assign acc_next = acc | (41'(i_data & c_mask) << cnt);

    wire [5:0]  cnt_next = cnt + 6'(d_bits);
    wire full = (cnt_next >= 6'd32);

    always_ff @(posedge clk or negedge arstn) begin
        if(~arstn) begin
            acc <= '0;
            cnt <= '0;
            out_v    <= 1'b0;        
            out_d    <= '0;          
            out_last <= 1'b0;        
        end
        else begin
            if (out_v && i_ready)    
                out_v <= 1'b0;

            if(accept) begin
                if (full || i_last) begin   
                    out_v    <= 1'b1;
                    out_d    <= acc_next[31:0];
                    out_last <= i_last;
                end

                if(i_last) begin
                    acc <= '0;
                    cnt <= '0;
                end
                else if(full) begin
                    acc <= acc_next >> 32;         
                    cnt <= cnt_next - 6'd32;        
                end
                else begin
                    acc <= acc_next;
                    cnt <= cnt_next;
                end
            end            
        end
    end
endmodule