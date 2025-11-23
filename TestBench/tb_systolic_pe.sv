// tb_systolic_pe.sv
// Basic unit test for systolic_pe

`timescale 1ns/1ps

module tb_systolic_pe;

  localparam DATA_W = 8;
  localparam ACC_W  = 32;

  logic clk, rst_n;
  logic valid_in;
  logic signed [DATA_W-1:0] a_in, b_in;
  logic signed [ACC_W-1:0]  ps_in;

  logic valid_out;
  logic signed [DATA_W-1:0] a_out, b_out;
  logic signed [ACC_W-1:0]  ps_out;

  // DUT
  systolic_pe #(
    .DATA_W(DATA_W),
    .ACC_W (ACC_W)
  ) dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .valid_in  (valid_in),
    .a_in      (a_in),
    .b_in      (b_in),
    .ps_in     (ps_in),
    .valid_out (valid_out),
    .a_out     (a_out),
    .b_out     (b_out),
    .ps_out    (ps_out)
  );

  // clock
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0;
    valid_in = 0;
    a_in = 0;
    b_in = 0;
    ps_in = 0;

    #20;
    rst_n = 1;

    // feed one MAC
    @(posedge clk);
    valid_in = 1;
    a_in = 3;
    b_in = 4;
    ps_in = 10;   // expected new ps = 10 + 3*4 = 22

    @(posedge clk);
    valid_in = 0;

    @(posedge clk);
    $display("ps_out = %0d  (expected 22)", ps_out);
    $finish;
  end

endmodule
