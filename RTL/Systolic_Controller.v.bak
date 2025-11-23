// Minimal controller FSM
// Walks over MxN result space, accumulates across K dimension.
module controller #(
  parameter M = 64,
  parameter K = 64,
  parameter N = 64
)(
  input  logic clk,
  input  logic rst_n,

  // To memories (TB preloads them)
  output logic [31:0] addr_a,
  output logic [31:0] addr_b,
  output logic        req,        // request data

  input  logic signed [7:0] data_a,
  input  logic signed [7:0] data_b,

  // To PEs
  output logic        pe_in_valid,
  output logic signed [7:0] pe_a,
  output logic signed [7:0] pe_b,
  output logic        clear_acc,

  // Status
  output logic        done
);

  typedef enum logic [1:0] {IDLE, STREAM, NEXT, FINISH} state_t;
  state_t state;

  integer i_m, i_n, i_k;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      i_m <= 0; i_n <= 0; i_k <= 0;
      pe_in_valid <= 0;
      clear_acc <= 1;
      done <= 0;
      req <= 0;
    end else begin
      case (state)
        IDLE: begin
          i_m <= 0; i_n <= 0; i_k <= 0;
          clear_acc <= 1;
          state <= STREAM;
        end

        STREAM: begin
          req <= 1;
          pe_a <= data_a;
          pe_b <= data_b;
          pe_in_valid <= 1;
          clear_acc <= (i_k == 0);
          i_k <= i_k + 1;
          if (i_k == K-1) begin
            i_k <= 0;
            state <= NEXT;
          end
        end

        NEXT: begin
          pe_in_valid <= 0;
          req <= 0;
          clear_acc <= 1;
          i_n <= i_n + 1;
          if (i_n == N) begin
            i_n <= 0;
            i_m <= i_m + 1;
            if (i_m == M) begin
              state <= FINISH;
            end else begin
              state <= STREAM;
            end
          end else begin
            state <= STREAM;
          end
        end

        FINISH: begin
          done <= 1;
          pe_in_valid <= 0;
          req <= 0;
        end
      endcase
    end
  end

  assign addr_a = i_m*K + i_k;
  assign addr_b = i_k*N + i_n;

endmodule
