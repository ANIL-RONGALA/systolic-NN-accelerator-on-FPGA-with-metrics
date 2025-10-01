`timescale 1ns/1ps

module tb_top;

  // parameters — adjust to match your design
  localparam DATA_WIDTH = 16;
  localparam PE_ROWS = 4;
  localparam PE_COLS = 4;
  localparam MAT_N = 64;
  localparam MAT_K = 64;
  localparam MAT_M = 64;

  // Clock / reset
  logic clk;
  logic rst_n;

  // DUT interface signals (example names — adapt yours)
  logic start;
  logic done;
  logic [DATA_WIDTH-1:0] din_a;
  logic [DATA_WIDTH-1:0] din_b;
  logic din_a_valid, din_b_valid;
  logic [DATA_WIDTH-1:0] dout_c;
  logic dout_c_valid;

  // Instantiate DUT (your top module)
  my_systolic_top #(
    .DATA_WIDTH(DATA_WIDTH),
    .PE_ROWS(PE_ROWS),
    .PE_COLS(PE_COLS)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .done(done),
    .din_a(din_a),
    .din_a_valid(din_a_valid),
    .din_b(din_b),
    .din_b_valid(din_b_valid),
    .dout_c(dout_c),
    .dout_c_valid(dout_c_valid)
    // … plus any control / config ports
  );

  // Clock generator
  always #5 clk = ~clk;

  // Stimulus and checking
  initial begin
    clk = 0;
    rst_n = 0;
    start = 0;
    din_a = 0;
    din_b = 0;
    din_a_valid = 0;
    din_b_valid = 0;

    // hold reset for some cycles
    repeat (10) @(posedge clk);
    rst_n = 1;

    // load stimulus from file
    logic signed [DATA_WIDTH-1:0] A_mem [0:MAT_N*MAT_K-1];
    logic signed [DATA_WIDTH-1:0] B_mem [0:MAT_K*MAT_M-1];
    logic signed [2*DATA_WIDTH-1:0] C_gold [0:MAT_N*MAT_M-1];

    $display("Reading stimulus files...");
    $readmemh("TestBench/stimulus/matrix_a.dat", A_mem);
    $readmemh("TestBench/stimulus/matrix_b.dat", B_mem);
    $readmemh("TestBench/stimulus/golden_c.dat", C_gold);

    // Start the DUT
    start = 1;
    @(posedge clk);
    start = 0;

    // Feed the A and B streams (example protocol — skewed feeding to match systolic schedule)
    integer i;
    for (i = 0; i < MAT_N*MAT_K; i++) begin
      @(posedge clk);
      din_a = A_mem[i];
      din_a_valid = 1;
    end
    din_a_valid = 0;

    for (i = 0; i < MAT_K*MAT_M; i++) begin
      @(posedge clk);
      din_b = B_mem[i];
      din_b_valid = 1;
    end
    din_b_valid = 0;

    // Wait for result valid
    wait (done == 1);
    @(posedge clk);
    // collect outputs
    integer j;
    for (j = 0; j < MAT_N*MAT_M; j++) begin
      @(posedge clk);
      if (dout_c_valid) begin
        if (dout_c !== C_gold[j]) begin
          $error("Mismatch at output %0d: got %0d, expected %0d",
                 j, dout_c, C_gold[j]);
        end
      end
    end

    $display("*** TEST FINISHED ***");
    $finish;
  end

endmodule
