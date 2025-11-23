// systolic_array.v
// 2D wavefront systolic array.
// A enters from left edge (one value per row).
// B enters from top edge (one value per column).
// Partial sums move diagonally.

module systolic_array #(
    parameter DATA_W = 8,
    parameter ACC_W  = 32,
    parameter ROWS   = 4,
    parameter COLS   = 4
)(
    input  wire                         clk,
    input  wire                         rst_n,

    // Valid source for the wavefront
    input  wire                         valid_in,

    // Left edge A inputs: one per row
    input  wire signed [ROWS*DATA_W-1:0] a_in_bus,

    // Top edge B inputs: one per column
    input  wire signed [COLS*DATA_W-1:0] b_in_bus,

    // Flattened partial sums from each PE (row-major)
    output wire signed [ROWS*COLS*ACC_W-1:0] c_bus,
    // Valid flags from each PE (same order as c_bus)
    output wire [ROWS*COLS-1:0]              c_valid
);

    // internal buses
    wire signed [DATA_W-1:0] a_bus [0:ROWS-1][0:COLS];
    wire signed [DATA_W-1:0] b_bus [0:ROWS][0:COLS-1];
    wire signed [ACC_W-1:0]  ps_bus[0:ROWS][0:COLS];
    wire                     v_bus [0:ROWS][0:COLS];

    genvar i, j;

    // left edge: feed A
    generate
        for (i = 0; i < ROWS; i = i + 1) begin : LEFT_EDGE
            assign a_bus[i][0] = a_in_bus[(i+1)*DATA_W-1 -: DATA_W];
        end
    endgenerate

    // top edge: feed B
    generate
        for (j = 0; j < COLS; j = j + 1) begin : TOP_EDGE
            assign b_bus[0][j] = b_in_bus[(j+1)*DATA_W-1 -: DATA_W];
        end
    endgenerate

    // origin of wavefront
    assign ps_bus[0][0] = '0;
    assign v_bus[0][0]  = valid_in;

    // top row ps/v (except origin) = 0
    generate
        for (j = 1; j <= COLS; j = j + 1) begin : TOP_PS
            assign ps_bus[0][j] = '0;
            assign v_bus[0][j]  = 1'b0;
        end
    endgenerate

    // left column ps/v (except origin) = 0
    generate
        for (i = 1; i <= ROWS; i = i + 1) begin : LEFT_PS
            assign ps_bus[i][0] = '0;
            assign v_bus[i][0]  = 1'b0;
        end
    endgenerate

    // PEs
    generate
        for (i = 0; i < ROWS; i = i + 1) begin : ROW_GEN
            for (j = 0; j < COLS; j = j + 1) begin : COL_GEN

                wire signed [DATA_W-1:0] a_in, b_in;
                wire signed [ACC_W-1:0]  ps_in;
                wire                     v_in;

                wire signed [DATA_W-1:0] a_out, b_out;
                wire signed [ACC_W-1:0]  ps_out;
                wire                     v_out;

                assign a_in  = a_bus[i][j];
                assign b_in  = b_bus[i][j];
                assign ps_in = ps_bus[i][j];
                assign v_in  = v_bus[i][j];

                systolic_pe #(
                    .DATA_W(DATA_W),
                    .ACC_W (ACC_W)
                ) u_pe (
                    .clk       (clk),
                    .rst_n     (rst_n),
                    .valid_in  (v_in),
                    .a_in      (a_in),
                    .b_in      (b_in),
                    .ps_in     (ps_in),
                    .valid_out (v_out),
                    .a_out     (a_out),
                    .b_out     (b_out),
                    .ps_out    (ps_out)
                );

                // feed neighbors
                assign a_bus[i][j+1]   = a_out;
                assign b_bus[i+1][j]   = b_out;
                assign ps_bus[i+1][j+1] = ps_out;
                assign v_bus[i+1][j+1]  = v_out;

                // flatten outputs
                localparam int INDEX = i*COLS + j;
                assign c_bus  [(INDEX+1)*ACC_W-1 -: ACC_W] = ps_out;
                assign c_valid[INDEX]                      = v_out;

            end
        end
    endgenerate

endmodule

