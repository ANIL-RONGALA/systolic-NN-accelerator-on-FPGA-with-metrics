// tb_systolic_array.sv
// Tests the 2×2 systolic array with a fixed small example.
// This shows the wavefront timing clearly.

`timescale 1ns/1ps

module tb_systolic_array;

  localparam DATA_W = 8;
  localparam ACC_W  = 32;
  localparam ROWS   = 2;
  localparam COLS   = 2;
  localparam K      = 2;

  logic clk, rst_n;
  logic valid_in;

  logic signed [ROWS*DATA_W-1:0] a_bus;
  logic signed [COLS*DATA_W-1:0] b_bus;

  logic signed [ROWS*COLS*ACC_W-1:0] c_bus;
  logic [ROWS*COLS-1:0]              c_valid;

  systolic_array #(
    .DATA_W(DATA_W),
    .ACC_W (ACC_W),
    .ROWS  (ROWS),
    .COLS  (COLS)
  ) dut (
    .clk     (clk),
    .rst_n   (rst_n),
    .valid_in(valid_in),
    .a_in_bus(a_bus),
    .b_in_bus(b_bus),
    .c_bus   (c_bus),
    .c_valid (c_valid)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0;
    valid_in = 0;
    a_bus = '0;
    b_bus = '0;

    #20;
    rst_n = 1;

    // -------------------------------------------------------
    // Example:
    // A = [1 2]
    //     [3 4]
    // B = [5 6]
    //     [7 8]
    //
    // Feed A[:,k] and B[k,:] each cycle for k=0..1
    // -------------------------------------------------------

    // cycle 0: feed k=0
    @(posedge clk);
    valid_in = 1;

    a_bus[7:0]    = 1;    // A[0][0]
    a_bus[15:8]   = 3;    // A[1][0]

    b_bus[7:0]    = 5;    // B[0][0]
    b_bus[15:8]   = 6;    // B[0][1]

    // cycle 1: feed k=1
    @(posedge clk);

    a_bus[7:0]    = 2;    // A[0][1]
    a_bus[15:8]   = 4;    // A[1][1]

    b_bus[7:0]    = 7;    // B[1][0]
    b_bus[15:8]   = 8;    // B[1][1]

    // drop valid after K cycles
    @(posedge clk);
    valid_in = 0;
    a_bus = '0;
    b_bus = '0;

    // wait a few cycles for flush
    repeat(6) @(posedge clk);

    $display("C(0,0) = %0d", c_bus[ACC_W-1:0]);
    $display("C(0,1) = %0d", c_bus[2*ACC_W-1:ACC_W]);
    $display("C(1,0) = %0d", c_bus[3*ACC_W-1:2*ACC_W]);
    $display("C(1,1) = %0d", c_bus[4*ACC_W-1:3*ACC_W]);

    $finish;
  end

endmodule
