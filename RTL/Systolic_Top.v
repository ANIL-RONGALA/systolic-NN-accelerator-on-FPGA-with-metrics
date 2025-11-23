// systolic_top.v
// Top-level: classic 2D systolic array + small controller.
// A : ROWS x K   (flattened, int8)
// B : K x COLS   (flattened, int8)
// C : ROWS x COLS (flattened, int32)

module systolic_top #(
    parameter DATA_W = 8,
    parameter ACC_W  = 32,
    parameter ROWS   = 4,
    parameter COLS   = 4,
    parameter K      = 4
)(
    input  wire clk,
    input  wire rst_n,

    input  wire start,
    output wire busy,
    output wire done,

    input  wire signed [ROWS*K*DATA_W-1:0] a_flat,
    input  wire signed [K*COLS*DATA_W-1:0] b_flat,

    output reg  signed [ROWS*COLS*ACC_W-1:0] c_flat
);

    // loop / index variables
    integer r;
    integer c;
    integer idx_load_A;
    integer idx_load_B;
    integer idx_flat;

    // internal storage for A and B
    reg signed [DATA_W-1:0] A_reg [0:ROWS-1][0:K-1];
    reg signed [DATA_W-1:0] B_reg [0:K-1][0:COLS-1];

    // controller
    wire ctrl_busy;
    wire ctrl_done;
    wire        valid_src;
    wire [$clog2(K):0] k_idx;

    systolic_controller #(
        .ROWS(ROWS),
        .COLS(COLS),
        .K   (K)
    ) u_ctrl (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start),
        .busy     (ctrl_busy),
        .done     (ctrl_done),
        .valid_src(valid_src),
        .k_idx    (k_idx)
    );

    assign busy = ctrl_busy;
    assign done = ctrl_done;

    // buses that feed the array edges
    reg  signed [ROWS*DATA_W-1:0] a_in_bus;
    reg  signed [COLS*DATA_W-1:0] b_in_bus;

    // outputs from array
    wire signed [ROWS*COLS*ACC_W-1:0] c_bus;
    wire [ROWS*COLS-1:0]              c_valid;

    systolic_array #(
        .DATA_W(DATA_W),
        .ACC_W (ACC_W),
        .ROWS  (ROWS),
        .COLS  (COLS)
    ) u_array (
        .clk     (clk),
        .rst_n   (rst_n),
        .valid_in(valid_src),
        .a_in_bus(a_in_bus),
        .b_in_bus(b_in_bus),
        .c_bus   (c_bus),
        .c_valid (c_valid)
    );

    // marks which C(i,j) has already been captured into c_flat
    reg [ROWS*COLS-1:0] captured;

    // --------------------------------------------------------------------
    // unpack A_flat / B_flat on start and capture C results
    // --------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // clear A/B storage
            for (r = 0; r < ROWS; r = r + 1)
                for (c = 0; c < K; c = c + 1)
                    A_reg[r][c] <= '0;

            for (r = 0; r < K; r = r + 1)
                for (c = 0; c < COLS; c = c + 1)
                    B_reg[r][c] <= '0;

            captured <= '0;
            c_flat   <= '0;
        end
        else begin
            // load new A/B matrices when we get a start while controller idle
            if (start && !ctrl_busy) begin
                // load A : ROWS x K
                for (r = 0; r < ROWS; r = r + 1) begin
                    for (c = 0; c < K; c = c + 1) begin
                        idx_load_A = r*K + c;
                        A_reg[r][c] <= a_flat[(idx_load_A+1)*DATA_W-1 -: DATA_W];
                    end
                end

                // load B : K x COLS
                for (r = 0; r < K; r = r + 1) begin
                    for (c = 0; c < COLS; c = c + 1) begin
                        idx_load_B = r*COLS + c;
                        B_reg[r][c] <= b_flat[(idx_load_B+1)*DATA_W-1 -: DATA_W];
                    end
                end

                // clear previous outputs
                captured <= '0;
                c_flat   <= '0;
            end
            else begin
                // capture C outputs from array
                for (idx_flat = 0; idx_flat < ROWS*COLS; idx_flat = idx_flat + 1) begin
                    if (c_valid[idx_flat] && !captured[idx_flat]) begin
                        captured[idx_flat] <= 1'b1;
                        c_flat[(idx_flat+1)*ACC_W-1 -: ACC_W] <=
                            c_bus[(idx_flat+1)*ACC_W-1 -: ACC_W];
                    end
                end
            end
        end
    end

    
    // drive left / top edges of the systolic array

    always @* begin
        a_in_bus = '0;
        b_in_bus = '0;

        if (ctrl_busy && (k_idx < K)) begin
            // k_idx is column index in A and row index in B
            for (r = 0; r < ROWS; r = r + 1)
                a_in_bus[(r+1)*DATA_W-1 -: DATA_W] = A_reg[r][k_idx];

            for (c = 0; c < COLS; c = c + 1)
                b_in_bus[(c+1)*DATA_W-1 -: DATA_W] = B_reg[k_idx][c];
        end
    end

endmodule

