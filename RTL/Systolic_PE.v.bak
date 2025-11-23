// Processing Element (PE)
// Signed multiply-accumulate with accumulator clear.
module pe #(
  parameter IN_WIDTH = 8,     // input width (int8)
  parameter ACC_WIDTH = 32    // accumulator width (int32)
) (
  input  logic clk,
  input  logic rst_n,

  input  logic in_valid,
  input  logic signed [IN_WIDTH-1:0] a,
  input  logic signed [IN_WIDTH-1:0] b,

  input  logic clear,   // synchronous clear of accumulator

  output logic out_valid,
  output logic signed [ACC_WIDTH-1:0] acc_out
);

  logic signed [ACC_WIDTH-1:0] acc;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      acc <= '0;
      out_valid <= 1'b0;
    end else begin
      if (clear) begin
        acc <= '0;
        out_valid <= 1'b0;
      end else if (in_valid) begin
        acc <= acc + $signed(a) * $signed(b);
        out_valid <= 1'b1;
      end else begin
        out_valid <= 1'b0;
      end
    end
  end

  assign acc_out = acc;

endmodule
