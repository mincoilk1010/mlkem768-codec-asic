`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2026 10:12:28 AM
// Design Name: 
// Module Name: decompress
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module decompress(
  input logic [9:0] byte_in,
  input logic [3:0] d,
  
  output logic [11:0] byte_out
);
  
  logic [21:0] tmp;
  
  always_comb begin
    case(d)
      1: begin
        tmp = byte_in * 22'd3329 + 22'd1;
        byte_out = tmp[12:1]; 
      end
      4: begin
        tmp = byte_in * 22'd3329 + 22'd8;
        byte_out = tmp[15:4]; 
      end 
      10: begin
        tmp = byte_in * 22'd3329 + 22'd512;
        byte_out = tmp[21:10]; 
      end 
    endcase
  end
  
endmodule
