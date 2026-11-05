`timescale 1ns/1ps

module tb_week02_capture;

    parameter DATA_W = 8;
    parameter ACC_W  = 32;
    parameter ROWS   = 2;
    parameter COLS   = 2;

    reg clk = 0;
    reg rst_n = 0;
    reg valid_in = 0;

    reg signed [ROWS*DATA_W-1:0] a_bus = 0;
    reg signed [COLS*DATA_W-1:0] b_bus = 0;

    wire signed [ROWS*COLS*ACC_W-1:0] c_bus;
    wire [ROWS*COLS-1:0] c_valid;

    integer cycle = 0;
    integer fd;
    integer i, j, idx;

    always #5 clk = ~clk;

    // Connect the actual systolic-array hardware
    systolic_array #(
        .DATA_W(DATA_W),
        .ACC_W(ACC_W),
        .ROWS(ROWS),
        .COLS(COLS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .a_in_bus(a_bus),
        .b_in_bus(b_bus),
        .c_bus(c_bus),
        .c_valid(c_valid)
    );

    // Capture outputs after rising-edge register updates
    always @(posedge clk) begin
        #1;

        if (rst_n) begin
            for (i = 0; i < ROWS; i = i + 1) begin
                for (j = 0; j < COLS; j = j + 1) begin
                    idx = i * COLS + j;

                    $fdisplay(
                        fd,
                        "%0d,%0d,%0d,%0d,%0d",
                        cycle,
                        i,
                        j,
                        c_valid[idx],
                        $signed(c_bus[idx*ACC_W +: ACC_W])
                    );
                end
            end

            cycle = cycle + 1;
        end
    end

    initial begin
        fd = $fopen("week02_rtl_outputs.csv", "w");

        if (fd == 0)
            $fatal(1, "Cannot create CSV file");

        $fdisplay(fd, "cycle,row,col,valid,value");

        // Hold reset for two cycles
        repeat (2) @(negedge clk);
        rst_n = 1;

        // A = [[1,2],[3,4]]
        // B = [[5,6],[7,8]]

        // First input group (k = 0)
        @(negedge clk);
        valid_in = 1;
        a_bus = {8'd3, 8'd1};
        b_bus = {8'd6, 8'd5};

        // Second input group (k = 1)
        @(negedge clk);
        a_bus = {8'd4, 8'd2};
        b_bus = {8'd8, 8'd7};

        // Stop sending inputs
        @(negedge clk);
        valid_in = 0;
        a_bus = 0;
        b_bus = 0;

        // Allow data to propagate
        repeat (8) @(negedge clk);

        $fclose(fd);

        $display("RTL capture completed");
        $finish;
    end

endmodule
