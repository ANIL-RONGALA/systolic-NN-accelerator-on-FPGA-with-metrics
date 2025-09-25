// rtl/pe_array.v
module pe_array #(
    parameter SIZE = 4
)(
    input                            clk,
    input                            rst_n,

    input      signed [7:0]      a_in[SIZE], // Array of inputs for the leftmost column
    input      signed [7:0]      b_in[SIZE], // Array of inputs for the top row
    
    output     signed [31:0]     c_out[SIZE][SIZE] // Grid of final results
);

   

    // Generate the 4x4 grid of PEs
    genvar i, j;
    generate
        for (i = 0; i < SIZE; i = i + 1) begin
            for (j = 0; j < SIZE; j = j + 1) begin
                
                pe pe_inst (
                    .clk(clk),
                    .rst_n(rst_n),

                    // Connect to wires from left and top
                    .a_in(a_wires[i][j]),
                    .b_in(b_wires[i][j]),
                    .c_in(1'b0), // Accumulation starts from 0

                    // Connect outputs to wires for right and bottom neighbors
                    .a_out(a_wires[i][j+1]),
                    .b_out(b_wires[i+1][j]),
                    .c_out(c_out[i][j])
                );
            end
        end
    endgenerate

endmodule