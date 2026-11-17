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
  
  logic [21:0] temp;
  
  always_comb begin
    byte_out = (byte_in * 3329) / (1<<d);
  end
  
endmodule
