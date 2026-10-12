`timescale 1ns/1ps
// Week 1 diagnostic for the existing systolic_array RTL.
// Designed to demonstrate whether off-diagonal PEs ever assert valid.
// This is a deliberately EXPECTED-TO-FAIL correctness regression.
module tb_week01_valid_diag;
  localparam DATA_W = 8;
  localparam ACC_W  = 32;
  localparam ROWS   = 2;
  localparam COLS   = 2;

  reg clk = 1'b0;
  always #5 clk = ~clk;

  reg rst_n = 1'b0;
  reg valid_in = 1'b0;
  reg signed [ROWS*DATA_W-1:0] a_bus = '0;
  reg signed [COLS*DATA_W-1:0] b_bus = '0;
  wire signed [ROWS*COLS*ACC_W-1:0] c_bus;
  wire [ROWS*COLS-1:0] c_valid;
  reg [ROWS*COLS-1:0] seen_valid = '0;

  systolic_array #(
    .DATA_W(DATA_W), .ACC_W(ACC_W), .ROWS(ROWS), .COLS(COLS)
  ) dut (
    .clk(clk), .rst_n(rst_n), .valid_in(valid_in),
    .a_in_bus(a_bus), .b_in_bus(b_bus),
    .c_bus(c_bus), .c_valid(c_valid)
  );

  // Sample at falling edges, after PE registered outputs have settled.
  always @(negedge clk)
    if (rst_n)
      seen_valid = seen_valid | c_valid;

  initial begin
    // Test matrices: A = identity, B = [[1,2],[3,4]]
    // Correct GEMM C = [[1,2],[3,4]], all four results must exist.
    repeat (2) @(negedge clk);
    rst_n = 1'b1;

    // Feed k=0 on the next positive edge:
    // A[:,0] = [1,0], B[0,:] = [1,2]
    @(negedge clk);
    valid_in = 1'b1;
    a_bus = {8'd0, 8'd1};
    b_bus = {8'd2, 8'd1};

    // Feed k=1:
    // A[:,1] = [0,1], B[1,:] = [3,4]
    @(negedge clk);
    a_bus = {8'd1, 8'd0};
    b_bus = {8'd4, 8'd3};

    // Flush and observe propagated valid signals.
    @(negedge clk);
    valid_in = 1'b0;
    a_bus = '0;
    b_bus = '0;
    repeat (6) @(negedge clk);

    $display("Observed c_valid bits at least once: %b", seen_valid);
    $display("Bit mapping: [3]=PE(1,1), [2]=PE(1,0), [1]=PE(0,1), [0]=PE(0,0)");
    if (!seen_valid[1] || !seen_valid[2]) begin
      $display("EXPECTED FAILURE: Off-diagonal results were never valid.");
      $fatal(1, "Existing array does not satisfy the 2x2 GEMM valid-output requirement");
    end else begin
      $display("Off-diagonal valids seen; inspect output values separately.");
    end
    $finish;
  end
endmodule
