// Flat array of PEs (simple version — broadcasts a/b to all PEs).
module pe_array #(
  parameter IN_WIDTH = 8,
  parameter ACC_WIDTH = 32,
  parameter PE_ROWS = 1,
  parameter PE_COLS = 1
)(
  input  logic clk,
  input  logic rst_n,

  input  logic in_valid,
  input  logic signed [IN_WIDTH-1:0] a_in,
  input  logic signed [IN_WIDTH-1:0] b_in,
  input  logic clear,

  output logic out_valid,
  output logic signed [ACC_WIDTH-1:0] c_out [PE_ROWS*PE_COLS]
);

  genvar i;
  generate
    for (i = 0; i < PE_ROWS*PE_COLS; i++) begin : pe_gen
      pe #(.IN_WIDTH(IN_WIDTH), .ACC_WIDTH(ACC_WIDTH)) u_pe (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .a(a_in),
        .b(b_in),
        .clear(clear),
        .out_valid(),   // ignored
        .acc_out(c_out[i])
      );
    end
  endgenerate

  assign out_valid = in_valid;

endmodule
