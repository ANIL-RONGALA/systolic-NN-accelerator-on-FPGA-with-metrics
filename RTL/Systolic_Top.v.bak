// Top-level: controller + memories + PE array
module matmul_top #(
  parameter M = 64,
  parameter K = 64,
  parameter N = 64,
  parameter IN_WIDTH = 8,
  parameter ACC_WIDTH = 32
)(
  input  logic clk,
  input  logic rst_n,

  // status
  output logic done
);

  // Memories for A and B
  logic [IN_WIDTH-1:0] dout_a, dout_b;
  logic [31:0] addr_a, addr_b;

  mem_dp #(.WIDTH(IN_WIDTH), .DEPTH(M*K)) mem_A (
    .clk(clk),
    .we_a(1'b0), .addr_a(addr_a[$clog2(M*K)-1:0]), .din_a('0), .dout_a(),
    .addr_b(addr_a[$clog2(M*K)-1:0]), .dout_b(dout_a)
  );

  mem_dp #(.WIDTH(IN_WIDTH), .DEPTH(K*N)) mem_B (
    .clk(clk),
    .we_a(1'b0), .addr_a(addr_b[$clog2(K*N)-1:0]), .din_a('0), .dout_a(),
    .addr_b(addr_b[$clog2(K*N)-1:0]), .dout_b(dout_b)
  );

  // Controller
  logic pe_in_valid, clear_acc;
  logic signed [IN_WIDTH-1:0] pe_a, pe_b;

  controller #(.M(M), .K(K), .N(N)) u_ctrl (
    .clk(clk), .rst_n(rst_n),
    .addr_a(addr_a), .addr_b(addr_b),
    .req(), // not used in this simple TB
    .data_a(dout_a), .data_b(dout_b),
    .pe_in_valid(pe_in_valid), .pe_a(pe_a), .pe_b(pe_b),
    .clear_acc(clear_acc), .done(done)
  );

  // PE array
  logic signed [ACC_WIDTH-1:0] c_out [1];

  pe_array #(.IN_WIDTH(IN_WIDTH), .ACC_WIDTH(ACC_WIDTH), .PE_ROWS(1), .PE_COLS(1)) u_array (
    .clk(clk), .rst_n(rst_n),
    .in_valid(pe_in_valid),
    .a_in(pe_a),
    .b_in(pe_b),
    .clear(clear_acc),
    .out_valid(),
    .c_out(c_out)
  );

endmodule
