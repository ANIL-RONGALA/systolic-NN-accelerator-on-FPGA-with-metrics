// tb_systolic_top.sv
// Fully Questa-Starter-compatible testbench

`timescale 1ns/1ps

module tb_systolic_top;

  localparam DATA_W = 8;
  localparam ACC_W  = 32;
  localparam ROWS   = 4;
  localparam COLS   = 4;
  localparam K      = 4;

  reg clk;
  reg rst_n;
  reg start;
  wire busy;
  wire done;

  reg  signed [ROWS*K*DATA_W-1:0] a_flat;
  reg  signed [K*COLS*DATA_W-1:0] b_flat;
  wire signed [ROWS*COLS*ACC_W-1:0] c_flat;

  // Declare all integers at module top (Starter edition requirement)
  integer r, c, idx;
  integer hw;
  integer err;
  integer fd;
  integer val;
  integer C_expected [0:ROWS-1][0:COLS-1];

  // DUT
  systolic_top #(
    .DATA_W(DATA_W),
    .ACC_W (ACC_W),
    .ROWS  (ROWS),
    .COLS  (COLS),
    .K     (K)
  ) dut (
    .clk   (clk),
    .rst_n (rst_n),
    .start (start),
    .busy  (busy),
    .done  (done),
    .a_flat(a_flat),
    .b_flat(b_flat),
    .c_flat(c_flat)
  );

  // clock
  always #5 clk = ~clk;

  // -------- FILE READ TASKS ----------
  task read_matrix_A(input [255:0] file_path);
    begin
      fd = $fopen(file_path, "r");
      if (fd == 0) begin
        $display("ERROR: Cannot open %s", file_path);
        $finish;
      end

      for (r = 0; r < ROWS; r = r + 1)
        for (c = 0; c < K; c = c + 1) begin
          $fscanf(fd, "%d", val);
          a_flat[((r*K+c)+1)*DATA_W-1 -: DATA_W] = val;
        end

      $fclose(fd);
    end
  endtask

  task read_matrix_B(input [255:0] file_path);
    begin
      fd = $fopen(file_path, "r");
      if (fd == 0) begin
        $display("ERROR: Cannot open %s", file_path);
        $finish;
      end

      for (r = 0; r < K; r = r + 1)
        for (c = 0; c < COLS; c = c + 1) begin
          $fscanf(fd, "%d", val);
          b_flat[((r*COLS+c)+1)*DATA_W-1 -: DATA_W] = val;
        end

      $fclose(fd);
    end
  endtask

  task read_matrix_C(input [255:0] file_path);
    begin
      fd = $fopen(file_path, "r");
      if (fd == 0) begin
        $display("ERROR: Cannot open %s", file_path);
        $finish;
      end

      for (r = 0; r < ROWS; r = r + 1)
        for (c = 0; c < COLS; c = c + 1) begin
          $fscanf(fd, "%d", val);
          C_expected[r][c] = val;
        end

      $fclose(fd);
    end
  endtask

  // -------- MAIN TEST SEQUENCE ----------
  initial begin
    clk   = 0;
    rst_n = 0;
    start = 0;
    err   = 0;
    a_flat = 0;
    b_flat = 0;

    #20 rst_n = 1;

    read_matrix_A("golden/vectors/A.txt");
    read_matrix_B("golden/vectors/B.txt");
    read_matrix_C("golden/vectors/C.txt");

    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;

    wait(done);
    @(posedge clk);

    // compare results
    err = 0;
    for (r = 0; r < ROWS; r = r + 1)
      for (c = 0; c < COLS; c = c + 1) begin
        idx = r*COLS + c;
        hw  = c_flat[(idx+1)*ACC_W-1 -: ACC_W];

        if (hw !== C_expected[r][c]) begin
          $display("Mismatch (%0d,%0d): HW=%0d  EXP=%0d",
                    r, c, hw, C_expected[r][c]);
          err = err + 1;
        end
      end

    if (err == 0)
      $display("PASS: systolic_top matches golden model!");
    else
      $display("FAIL: %0d mismatches detected.", err);

    $finish;
  end

endmodule
