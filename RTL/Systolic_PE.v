// systolic_pe.v
// Basic systolic PE
// A moves to the right, B moves down, partial sum goes diagonally.

module systolic_pe #(
    parameter DATA_W = 8,
    parameter ACC_W  = 32
)(
    input  wire                     clk,
    input  wire                     rst_n,

    // Inputs from neighbors / boundary
    input  wire                     valid_in,
    input  wire signed [DATA_W-1:0] a_in,
    input  wire signed [DATA_W-1:0] b_in,
    input  wire signed [ACC_W-1:0]  ps_in,

    // Outputs to neighbors / boundary
    output reg                      valid_out,
    output reg  signed [DATA_W-1:0] a_out,
    output reg  signed [DATA_W-1:0] b_out,
    output reg  signed [ACC_W-1:0]  ps_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 1'b0;
            a_out     <= '0;
            b_out     <= '0;
            ps_out    <= '0;
        end else begin
            // move data through the array
            a_out     <= a_in;
            b_out     <= b_in;
            valid_out <= valid_in;

            if (valid_in) begin
                ps_out <= ps_in + a_in * b_in;
            end else begin
                ps_out <= ps_in;
            end
        end
    end

endmodule

