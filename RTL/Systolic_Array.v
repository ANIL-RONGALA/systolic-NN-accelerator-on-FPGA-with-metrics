
module systolic_array #(
    parameter DATA_W = 8,
    parameter ACC_W  = 32,
    parameter ROWS   = 2,
    parameter COLS   = 2,
    parameter K      = 2
)(
    input wire clk,
    input wire rst_n,

    input wire signed [ROWS*DATA_W-1:0] a_in_bus,
    input wire signed [COLS*DATA_W-1:0] b_in_bus,

    input wire [ROWS-1:0] a_valid_bus,
    input wire [COLS-1:0] b_valid_bus,

    output wire signed [ROWS*COLS*ACC_W-1:0] c_bus,
    output wire [ROWS*COLS-1:0] c_valid
);

    wire signed [DATA_W-1:0] a_data [0:ROWS-1][0:COLS];
    wire signed [DATA_W-1:0] b_data [0:ROWS][0:COLS-1];

    wire a_valid [0:ROWS-1][0:COLS];
    wire b_valid [0:ROWS][0:COLS-1];

    genvar i, j;

    generate
        for (i=0; i<ROWS; i=i+1) begin : A_EDGE
            assign a_data[i][0] =
                a_in_bus[i*DATA_W +: DATA_W];
            assign a_valid[i][0] = a_valid_bus[i];
        end

        for (j=0; j<COLS; j=j+1) begin : B_EDGE
            assign b_data[0][j] =
                b_in_bus[j*DATA_W +: DATA_W];
            assign b_valid[0][j] = b_valid_bus[j];
        end

        for (i=0; i<ROWS; i=i+1) begin : ROW_GEN
            for (j=0; j<COLS; j=j+1) begin : COL_GEN

                localparam INDEX = i*COLS+j;

                systolic_pe #(
                    .DATA_W(DATA_W),
                    .ACC_W(ACC_W),
                    .K(K)
                ) pe (
                    .clk(clk),
                    .rst_n(rst_n),

                    .a_in(a_data[i][j]),
                    .b_in(b_data[i][j]),

                    .a_valid_in(a_valid[i][j]),
                    .b_valid_in(b_valid[i][j]),

                    .a_out(a_data[i][j+1]),
                    .b_out(b_data[i+1][j]),

                    .a_valid_out(a_valid[i][j+1]),
                    .b_valid_out(b_valid[i+1][j]),

                    .ps_out(c_bus[INDEX*ACC_W +: ACC_W]),
                    .valid_out(c_valid[INDEX])
                );

            end
        end
    endgenerate

endmodule
