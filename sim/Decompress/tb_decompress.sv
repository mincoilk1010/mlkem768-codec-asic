`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2026 01:19:35 PM
// Design Name: 
// Module Name: tb_decompress
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


module tb_decompress();
  localparam N = 2+16+1024;

  logic clk;
  logic [9:0]  byte_in;
  logic [3:0]  d;
  logic [11:0] byte_out;
  
  logic [9:0] in_test   [0:N-1];
  logic [11:0] exp_test [0:N-1];
  
  int i = 0;
  int i_prev = 0;
  task automatic driver();
    for (int n = 0; n < N; n++) begin
      @(posedge clk);
      byte_in = in_test[i];
      if (i < 2)
        d = 1;
      else if (i < 18)
        d = 4;
      else
        d = 10;
      i ++;
    end
  endtask
  
  int pass_count = 0;
  int fail_count = 0;
  
  task automatic monitor();
    forever begin
      wait (i != i_prev);
      @(negedge clk);
      #1;

      if (byte_out === exp_test[i_prev]) begin
        pass_count++;
      end
      else begin
        fail_count++;
        $display("[FAIL] Vector: %0d, d: %0d, Input: %03h, Expected: %03h, Actual: %03h",
                 i_prev, d, byte_in, exp_test[i_prev], byte_out);
      end

      i_prev = i;
    end
  endtask
  
  initial begin
    $readmemh ( "decompress_d1_in.hex" , in_test , 0 , 1 );
    $readmemh ( "decompress_d4_in.hex" , in_test , 2 , 17 );
    $readmemh ( "decompress_d10_in.hex" , in_test , 18 , 1041);
    $readmemh ( "decompress_d1_exp.hex" , exp_test , 0 , 1 );
    $readmemh ( "decompress_d4_exp.hex" , exp_test , 2 , 17 );
    $readmemh ( "decompress_d10_exp.hex" , exp_test , 18 , 1041);
  end
  
  always begin
    #5 clk = ~clk;
  end

  decompress u_dut (
    .byte_in (byte_in),
    .d       (d),
    .byte_out(byte_out)
  );
  
  initial begin
    clk = 0;
    fork
      driver();
      monitor();
      begin
        #((N * 20) + 100);
      end
    join_any
      $display("PASS = %d, FAIL = %d: ", pass_count, fail_count);
  end
  
endmodule
