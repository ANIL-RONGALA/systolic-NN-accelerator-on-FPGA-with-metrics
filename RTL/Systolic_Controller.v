// systolic_controller.v
// Small controller for classic systolic array timing.
// Feeds K cycles of valid data, then lets the wave flush.

module systolic_controller #(
    parameter ROWS = 4,
    parameter COLS = 4,
    parameter K    = 4
)(
    input  wire clk,
    input  wire rst_n,

    input  wire start,
    output reg  busy,
    output reg  done,

    // drive this into systolic_array.valid_in
    output reg  valid_src,
    // current k index while feeding (0..K-1)
    output reg [$clog2(K):0] k_idx
);

    localparam integer FLUSH_CYCLES = ROWS + COLS - 2;

    typedef enum logic [1:0] {
        S_IDLE  = 2'b00,
        S_FEED  = 2'b01,
        S_FLUSH = 2'b10,
        S_DONE  = 2'b11
    } state_t;

    state_t state, next_state;

    reg [$clog2(FLUSH_CYCLES+1):0] flush_cnt;

    // state register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (start)
                    next_state = S_FEED;
            end

            S_FEED: begin
                if (k_idx == K)  // we fed K cycles
                    next_state = S_FLUSH;
            end

            S_FLUSH: begin
                if (flush_cnt == FLUSH_CYCLES)
                    next_state = S_DONE;
            end

            S_DONE: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // outputs and counters
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy       <= 1'b0;
            done       <= 1'b0;
            valid_src  <= 1'b0;
            k_idx      <= '0;
            flush_cnt  <= '0;
        end else begin
            done      <= 1'b0;
            valid_src <= 1'b0;

            case (state)
                S_IDLE: begin
                    busy      <= 1'b0;
                    k_idx     <= '0;
                    flush_cnt <= '0;
                end

                S_FEED: begin
                    busy      <= 1'b1;
                    valid_src <= 1'b1;  // feeding A/B into array

                    if (k_idx < K)
                        k_idx <= k_idx + 1;
                end

                S_FLUSH: begin
                    busy <= 1'b1;
                    // no more valid_src here, just let wave move
                    if (flush_cnt < FLUSH_CYCLES)
                        flush_cnt <= flush_cnt + 1;
                end

                S_DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    k_idx     <= '0;
                    flush_cnt <= '0;
                end
            endcase
        end
    end

endmodule

