`timescale 1ns/1ps

module compress (
    input clk,
    input arstn,
    input [1:0] i_d_sel //00: d = 1, 01: d = 4, 10: d = 10

);
localparam Q = 3329;

endmodule