* Systolic Array Controller
 * Manages data flow, memory access, and computation scheduling
 */

module controller #(
    parameter ARRAY_SIZE = 4,
    parameter DATA_WIDTH = 8,
    parameter ACCUM_WIDTH = 32,
    parameter ADDR_WIDTH = 10
)(
    input wire clk,
    input wire rst_n,
    
    // Host interface
    input wire start,
    input wire [7:0] matrix_size_m,
    input wire [7:0] matrix_size_k,  
    input wire [7:0] matrix_size_n,
    output reg done,
    output reg busy,
    
    
    // Array control
    output reg array_enable,
    output reg load_weight,
    output reg clear_accum,
    
    // Array data interfaces
    output reg signed [DATA_WIDTH-1:0] activation_in [0:ARRAY_SIZE-1],
    output reg signed [DATA_WIDTH-1:0] weight_in [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1],
    output reg signed [ACCUM_WIDTH-1:0] partial_sum_in [0:ARRAY_SIZE-1],
    input wire signed [ACCUM_WIDTH-1:0] partial_sum_out [0:ARRAY_SIZE-1]
);

    // FSM States
    typedef enum logic [3:0] {
        IDLE,
        LOAD_WEIGHTS,
        COMPUTE_SETUP,
        COMPUTE,
        DRAIN,
        STORE_RESULTS,
        DONE_STATE
    } state_t;
    
    state_t current_state, next_state;
    
    // Counters and registers
    reg [7:0] tile_m, tile_k, tile_n;
    reg [7:0] m_count, k_count, n_count;
    reg [7:0] cycle_count;
    reg [7:0] compute_cycles;
    
    // Tile coordinates
    reg [7:0] current_tile_m, current_tile_k, current_tile_n;
    
    // Computed parameters
    wire [7:0] total_tiles_m = (matrix_size_m + ARRAY_SIZE - 1) / ARRAY_SIZE;
    wire [7:0] total_tiles_k = (matrix_size_k + ARRAY_SIZE - 1) / ARRAY_SIZE;
    wire [7:0] total_tiles_n = (matrix_size_n + ARRAY_SIZE - 1) / ARRAY_SIZE;
    
   
    // Output logic and counter management
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 0;
            busy <= 0;
            array_enable <= 0;
            load_weight <= 0;
            clear_accum <= 0;
            cycle_count <= 0;
            compute_cycles <= ARRAY_SIZE * 2;
            current_tile_m <= 0;
            current_tile_k <= 0;
            current_tile_n <= 0;
            mem_read_en_a <= 0;
            mem_read_en_b <= 0;
            mem_write_en_c <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    done <= 0;
                    busy <= 0;
                    array_enable <= 0;
                    cycle_count <= 0;
                    current_tile_m <= 0;
                    current_tile_k <= 0;
                    current_tile_n <= 0;
                end
                
                LOAD_WEIGHTS: begin
                    busy <= 1;
                    load_weight <= 1;
                    mem_read_en_b <= 1;
                    cycle_count <= cycle_count + 1;
                    
                    // Load weight matrix tile
                    mem_addr_b <= (current_tile_k * ARRAY_SIZE * matrix_size_n) + 
                                  (current_tile_n * ARRAY_SIZE) + cycle_count;
                    
                    // Simple sequential loading for demonstration
                    if (cycle_count < ARRAY_SIZE * ARRAY_SIZE) begin
                        weight_in[cycle_count / ARRAY_SIZE][cycle_count % ARRAY_SIZE] <= mem_data_b;
                    end
                end
                
                COMPUTE_SETUP: begin
                    load_weight <= 0;
                    mem_read_en_b <= 0;
                    mem_read_en_a <= 1;
                    array_enable <= 1;
                    clear_accum <= (current_tile_k == 0);
                    cycle_count <= 0;
                end
                
                COMPUTE: begin
                    cycle_count <= cycle_count + 1;
                    
                    // Feed activations with proper timing
                    if (cycle_count < ARRAY_SIZE) begin
                        mem_addr_a <= (current_tile_m * ARRAY_SIZE * matrix_size_k) + 
                                      (current_tile_k * ARRAY_SIZE) + cycle_count;
                        activation_in[cycle_count] <= mem_data_a;
                    end
                end
                
                DRAIN: begin
                    mem_read_en_a <= 0;
                    cycle_count <= cycle_count + 1;
                end
                
                STORE_RESULTS: begin
                    mem_write_en_c <= 1;
                    cycle_count <= cycle_count + 1;
                    
                    // Store results
                    if (cycle_count < ARRAY_SIZE) begin
                        mem_addr_c <= (current_tile_m * ARRAY_SIZE * matrix_size_n) + 
                                      (current_tile_n * ARRAY_SIZE) + cycle_count;
                        mem_data_c <= partial_sum_out[cycle_count];
                    end
                    
                    // Update tile counters
                    if (cycle_count == ARRAY_SIZE) begin
                        cycle_count <= 0;
                        
                        if (current_tile_k == total_tiles_k - 1) begin
                            current_tile_k <= 0;
                            if (current_tile_n == total_tiles_n - 1) begin
                                current_tile_n <= 0;
                                current_tile_m <= current_tile_m + 1;
                            end else begin
                                current_tile_n <= current_tile_n + 1;
                            end
                        end else begin
                            current_tile_k <= current_tile_k + 1;
                        end
                    end
                end
                
                DONE_STATE: begin
                    mem_write_en_c <= 0;
                    array_enable <= 0;
                    done <= 1;
                    busy <= 0;
                end
            endcase
        end
    end
    
    // Initialize unused partial sum inputs
    integer i;
    always @(*) begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            partial_sum_in[i] = 0;
        end
    end

endmodule