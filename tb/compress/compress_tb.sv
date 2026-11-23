`timescale 1ns/1ps

module compress_tb;

    localparam int Q = 3329;
    localparam string F_D1  = "model/compress_d1_exp.hex";
    localparam string F_D4  = "model/compress_d4_exp.hex";
    localparam string F_D10 = "model/compress_d10_exp.hex";
    logic [1:0]  i_d_sel;
    logic [11:0] i_data;
    logic [9:0]  o_data;

    compress dut (
        .i_d_sel (i_d_sel),
        .i_data  (i_data),
        .o_data  (o_data)
    );

    logic [9:0] exp_d1  [0:Q-1];
    logic [9:0] exp_d4  [0:Q-1];
    logic [9:0] exp_d10 [0:Q-1];

    int errors;
    int checks;

    // công thức chuẩn FIPS 203: round(2^d * x / q) mod 2^d
    // = floor((2^(d+1)*x + q) / (2q)) mod 2^d
    function automatic logic [9:0] ref_compress(input int x, input int d);
        int num, quo;
        logic [9:0] r;
        num = (x << (d + 1)) + Q;
        quo = num / (2 * Q);
        r   = quo & ((1 << d) - 1);
        return r;
    endfunction

    task automatic check(input int x, input logic [1:0] sel, input int d,
                         input logic [9:0] exp_f);
        logic [9:0] exp_r;
        exp_r   = ref_compress(x, d);
        i_d_sel = sel;
        i_data  = x[11:0];
        #1;
        checks++;
        if (^exp_f === 1'bx) begin
            errors++;
            if (errors <= 20)
                $display("LOI: d=%0d x=%0d: file hex chua nap duoc (gia tri X)", d, x);
        end else if (exp_f !== exp_r) begin
            errors++;
            if (errors <= 20)
                $display("LOI GOLDEN: d=%0d x=%0d: file=%0d, ref SV=%0d (script Python hoac file sai)",
                         d, x, exp_f, exp_r);
        end else if (o_data !== exp_f) begin
            errors++;
            if (errors <= 20)
                $display("LOI DUT: d=%0d x=%0d: DUT=%0d, expected=%0d", d, x, o_data, exp_f);
        end
    endtask

    task automatic expect_val(input int x, input logic [1:0] sel,
                              input logic [9:0] val, input string name);
        i_d_sel = sel;
        i_data  = x[11:0];
        #1;
        if (o_data !== val) begin
            errors++;
            $display("LOI vector bien %s: x=%0d, DUT=%0d, expected=%0d", name, x, o_data, val);
        end else begin
            $display("ok   vector bien %s: x=%0d -> %0d", name, x, val);
        end
    endtask

    initial begin
        errors  = 0;
        checks  = 0;
        i_d_sel = '0;
        i_data  = '0;

        $readmemh(F_D1,  exp_d1);
        $readmemh(F_D4,  exp_d4);
        $readmemh(F_D10, exp_d10);

        // 1) vet can toan bo x hop le voi ca ba gia tri d
        for (int x = 0; x < Q; x++) begin
            check(x, 2'd0, 1,  exp_d1[x]);
            check(x, 2'd1, 4,  exp_d4[x]);
            check(x, 2'd2, 10, exp_d10[x]);
        end

        // 2) vector bien trong interface_chung
        expect_val(832,  2'd0, 10'd0, "Compress_1(832)");
        expect_val(833,  2'd0, 10'd1, "Compress_1(833)");
        expect_val(3328, 2'd2, 10'd0, "Compress_10(3328)");

        // 3) d_sel = 3 (cam): dau ra phai bang 0
        for (int x = 0; x < Q; x++) begin
            i_d_sel = 2'd3;
            i_data  = x[11:0];
            #1;
            if (o_data !== 10'd0) begin
                errors++;
                if (errors <= 20)
                    $display("LOI d_sel=3: x=%0d, DUT=%0d (can bang 0)", x, o_data);
            end
        end

        $display("----------------------------------------------");
        if (errors == 0)
            $display("PASS: %0d phep so sanh chinh, 0 loi", checks);
        else
            $display("FAIL: %0d loi trong %0d phep so sanh chinh", errors, checks);
        $display("----------------------------------------------");
        $finish;
    end

endmodule