// Dual-port synchronous RAM (maps to FPGA BRAMs)
module mem_dp #(
  parameter WIDTH = 8,
  parameter DEPTH = 1024,
  parameter ADDR_WIDTH = $clog2(DEPTH)
)(
  input  logic clk,

  // Port A (read/write)
  input  logic                  we_a,
  input  logic [ADDR_WIDTH-1:0] addr_a,
  input  logic [WIDTH-1:0]      din_a,
  output logic [WIDTH-1:0]      dout_a,

  // Port B (read-only)
  input  logic [ADDR_WIDTH-1:0] addr_b,
  output logic [WIDTH-1:0]      dout_b
);

  logic [WIDTH-1:0] mem [0:DEPTH-1];

  always_ff @(posedge clk) begin
    if (we_a)
      mem[addr_a] <= din_a;
    dout_a <= mem[addr_a];
    dout_b <= mem[addr_b];
  end

endmodule