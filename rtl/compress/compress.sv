`timescale 1ns/1ps

module compress (
    // input clk,
    // input arstn,
    input [1:0] i_d_sel, //00: d = 1, 01: d = 4, 10: d = 10
    input [11:0] i_data,

    output logic [9:0] o_data //reminder (modulo 2^d)

    // //handshake
    // input i_ready,
    // output o_valid,
    // output o_last,
    // output o_ready
);

localparam logic [21:0] M = 2580335;

wire [21:0] n;
wire [43:0] dividend;
wire [9:0] quotient;
// logic [9:0] data_out_reg;
logic [3:0] sh;

assign n = (22'(i_data) << sh)  + 22'd1664;
assign dividend = n * M;
assign quotient = dividend[42:33];

always_comb begin
    case(i_d_sel)
        2'b00: begin
            sh = 4'd1;
        end
        2'b01: begin
            sh = 4'd4;
        end
        2'b10: begin
            sh = 4'd10;
        end
        default: begin
            sh = 4'd0;
        end
    endcase
end

always_comb begin 
    case(i_d_sel) 
        2'b00: begin
            o_data = {9'd0,quotient[0]}; //d = 1
        end
        2'b01: begin
            o_data = {6'd0,quotient[3:0]}; //d = 4
        end
        2'b10: begin
            o_data = quotient; //d = 10
        end
        default: begin
            o_data = 10'd0;
        end
    endcase
end

endmodule