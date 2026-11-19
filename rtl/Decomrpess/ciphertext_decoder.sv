`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2026 10:38:21 AM
// Design Name: 
// Module Name: ciphertext_decoder
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


module ciphertext_decoder(
  input logic clk,
  input logic rst,
  input logic word_valid,
  input logic coeff_ready,
  input logic [31:0] data_in,
  input logic last_in,
  input logic [1:0] d_sel,
  
  output logic coeff_valid,
  output logic word_ready,
  output logic [11:0] data_out,
  output logic last_out,
  output logic err_proto
);

  logic [3:0] d_reg;
  logic d_sel_err;
  
  logic last_in_err;
  
  assign err_proto = d_sel_err && last_in_err;
  
  always_comb begin 
    case(d_sel)
      0: d_reg = 1;
      1: d_reg = 4;
      2: d_reg = 10;
      3: d_sel_err = 1;
      default: d_reg = 1;
    endcase
  end
  
  always_ff @(posedge clk) begin
    if(last_in) begin
      if(word_count != word_max) begin
        last_in_err = 1;
      end
    end
  end
  
  logic [9:0] byte_in_decompress;
  logic [11:0] byte_out_decompress;
  decompress u_decompress (.byte_in (byte_in_decompress), .d (d_reg), .byte_out(byte_out_decompress));
  
  assign data_out = byte_out_decompress;
  
  logic [63:0] shift_reg;
  logic [5:0] shift_count;
  logic shift_in;
  logic shift_out;
  logic [11:0]shift_data_out;
  //Shift Register
  always_ff @(posedge clk) begin
    if(!rst) begin
      shift_reg <= 0;
      shift_count <= 0;
    end
    else if(shift_in && shift_out) begin
      shift_reg <= shift_reg | ({52'b0, data_in} << (64-shift_count)) ;
      shift_count <= shift_count + 32;
      shift_reg <= shift_reg << d_reg;
      shift_count <= shift_count - d_reg;
    end
    else if(shift_in) begin
      shift_reg <= shift_reg | ({52'b0, data_in} << (64-shift_count)) ;
      shift_count <= shift_count + 32;
      incr_word_count <= 1;
    end
    else if(shift_out) begin
       shift_reg <= shift_reg << d_reg;
       shift_count <= shift_count - d_reg;
       incr_coef_count <= 1;
    end
  end
  
  assign shift_data_out = (shift_reg >> (64 - d_reg)) & ((1 << d_reg) - 1);
  
  always_comb begin
    if(shift_count <= 32)
      word_ready = 1;
    if(shift_count > d_reg)
      coeff_valid = 1;
  end
  
  assign shift_in = word_ready & word_valid;
  assign shift_out = coeff_ready & coeff_valid;
  
  logic [6:0] word_max;
  always_comb begin
    case(d_reg)
      1: word_max = 8;
      4: word_max = 32;
      10: word_max = 80;
    endcase
  end
  
  logic [6:0] word_count;
  logic incr_word_count;
  logic clr_word_count;
  //Word Count
  always_ff @(posedge clk) begin
    if (!rst) begin
      word_count <= 0;
    end
    else if (clr_word_count) begin
      word_count <= 0;
    end
    else if (incr_word_count) begin
      if(word_count == word_max)
        word_count <= 1;
      else
        word_count <= word_count + 1;
    end
    
  end
  
  logic [6:0] coef_count;
  logic incr_coef_count;
  logic clr_coef_count;
  //Coef Count
  always_ff @(posedge clk) begin
    if (!rst) begin
      coef_count <= 0;
    end
    else if (clr_coef_count) begin
      coef_count <= 0;
    end
    else if (incr_coef_count) begin
      if(coef_count == 256)
        coef_count <= 1;
      else
        coef_count <= coef_count + 1;
    end
  end
  
  assign last_out = (coef_count == 256) ? 1 : 0;
  
endmodule
