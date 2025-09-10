module pe (input clk,
            input rst,
            input[7:0] a_in,
            input[7:0] b_in,
            input[31:0] c_in,
            output[7:0] a_out,
            output[7:0] b_out,
            outside[31:0] c_out
            );

            reg signed [7:0] a_reg, b_reg;
            reg signed [15:0] mult_result;
            reg signed [31:0] sum;

            always @(posedge clk or negedge rst) begin

            
end
endmodule