
module systolic_pe #(
    parameter DATA_W = 8,
    parameter ACC_W  = 32,
    parameter K      = 2
)(
    input wire clk,
    input wire rst_n,

    input wire signed [DATA_W-1:0] a_in,
    input wire signed [DATA_W-1:0] b_in,
    input wire a_valid_in,
    input wire b_valid_in,

    output reg signed [DATA_W-1:0] a_out,
    output reg signed [DATA_W-1:0] b_out,
    output reg a_valid_out,
    output reg b_valid_out,

    output reg signed [ACC_W-1:0] ps_out,
    output reg valid_out
);

    integer count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out       <= 0;
            b_out       <= 0;
            a_valid_out <= 0;
            b_valid_out <= 0;
            ps_out      <= 0;
            valid_out   <= 0;
            count       <= 0;
        end else begin
            a_out       <= a_in;
            b_out       <= b_in;
            a_valid_out <= a_valid_in;
            b_valid_out <= b_valid_in;

            valid_out <= 0;

            if (a_valid_in && b_valid_in && count < K) begin
                ps_out <= ps_out + a_in * b_in;
                count <= count + 1;

                if (count == K-1)
                    valid_out <= 1;
            end
        end
    end

endmodule
