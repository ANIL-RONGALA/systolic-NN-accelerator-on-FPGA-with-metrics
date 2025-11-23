// tb_systolic_top.sv
// Full regression testbench.
// Reads A.txt, B.txt, C.txt from golden model.
// Runs systolic_top and compares results.

`timescale 1ns/1ps

module tb_systolic_top;

  localparam DATA_W = 8;
  localparam ACC_W  = 32;
  localparam ROWS   = 4;
  localparam COLS   = 4;
  localparam K      = 4;

  logic clk, rst_n;
  logic start, busy, done;

  logic signed [ROWS*K*DATA_W-1:0] a_flat;
  logic signed [K*COLS*DATA_W-1:0] b_flat;

  logic signed [ROWS*COLS*ACC_W-1:0] c_flat;

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

  // ------------------------------------------------------------
  // file reading helpers
  // ------------------------------------------------------------
  function automatic int read_matrix_A(input string path,
                                       output logic signed [ROWS*K*DATA_W-1:0] flat);
    int fd, r, c, val;
    fd = $fopen(path, "r");
    if (fd == 0) begin
      $display("ERROR: cannot open A file");
      return 0;
    end

    for (r = 0; r < ROWS; r++) begin
      for (c = 0; c < K; c++) begin
        void'($fscanf(fd, "%d", val));
        flat[((r*K+c)+1)*DATA_W-1 -: DATA_W] = val;
      end
    end

    $fclose(fd);
    return 1;
  endfunction

  function automatic int read_matrix_B(input string path,
                                       output logic signed [K*COLS*DATA_W-1:0] flat);
    int fd, r, c, val;
    fd = $fopen(path, "r");

    if (fd == 0) begin
      $display("ERROR: cannot open B file");
      return 0;
    end

    for (r = 0; r < K; r++) begin
      for (c = 0; c < COLS; c++) begin
        void'($fscanf(fd, "%d", val));
        flat[((r*COLS+c)+1)*DATA_W-1 -: DATA_W] = val;
      end
    end

    $fclose(fd);
    return 1;
  endfunction

  function automatic int read_matrix_C(input string path,
                                       output int C_expected[ROWS][COLS]);
    int fd, r, c, val;
    fd = $fopen(path, "r");

    if (fd == 0) begin
      $display("ERROR: cannot open C file");
      return 0;
    end

    for (r = 0; r < ROWS; r++) begin
      for (c = 0; c < COLS; c++) begin
        void'($fscanf(fd, "%d", val));
        C_expected[r][c] = val;
      end
    end

    $fclose(fd);
    return 1;
  endfunction


  // Test sequence
 
  int C_expected[ROWS][COLS];

  initial begin
    clk = 0;
    rst_n = 0;
    start = 0;
    a_flat = '0;
    b_flat = '0;

    #20;
    rst_n = 1;

    // load inputs
    $display("Reading A, B, C golden files...");
    read_matrix_A("golden/vectors/A.txt", a_flat);
    read_matrix_B("golden/vectors/B.txt", b_flat);
    read_matrix_C("golden/vectors/C.txt", C_expected);

    // run systolic_top
    @(posedge clk);
    start = 1;

    @(posedge clk);
    start = 0;

    // wait for done
    wait(done);
    @(posedge clk);

    // compare results
    int err = 0;
    int r, c, idx;
    for (r = 0; r < ROWS; r++) begin
      for (c = 0; c < COLS; c++) begin
        idx = r*COLS + c;
        int hw = c_flat[(idx+1)*ACC_W-1 -: ACC_W];

        if (hw !== C_expected[r][c]) begin
          $display("Mismatch @ (%0d,%0d): HW=%0d, EXPECTED=%0d",
                   r, c, hw, C_expected[r][c]);
          err++;
        end
      end
    end

    if (err == 0)
      $display("PASS: systolic_top matches golden model.");
    else
      $display("FAIL: %0d mismatches.", err);

    $finish;
  end

endmodule

