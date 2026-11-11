
`timescale 1ns/1ps

module tb_week02_capture;

    reg clk = 0;
    reg rst_n = 0;

    reg signed [15:0] a_bus = 0;
    reg signed [15:0] b_bus = 0;

    reg [1:0] a_valid = 0;
    reg [1:0] b_valid = 0;

    wire signed [127:0] c_bus;
    wire [3:0] c_valid;

    integer fd;
    integer cycle = 0;
    integer i;
    integer seen [0:3];

    reg signed [31:0] expected [0:3];

    always #5 clk = ~clk;

    systolic_array #(
        .DATA_W(8),
        .ACC_W(32),
        .ROWS(2),
        .COLS(2),
        .K(2)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .a_in_bus(a_bus),
        .b_in_bus(b_bus),
        .a_valid_bus(a_valid),
        .b_valid_bus(b_valid),
        .c_bus(c_bus),
        .c_valid(c_valid)
    );

    always @(posedge clk) begin
        #1;

        if (rst_n) begin
            for (i=0; i<4; i=i+1) begin
                $fdisplay(fd, "%0d,%0d,%0d,%0d,%0d",
                    cycle,
                    i/2,
                    i%2,
                    c_valid[i],
                    $signed(c_bus[i*32 +: 32])
                );

                if (c_valid[i]) begin
                    seen[i] = seen[i] + 1;

                    if (seen[i] > 1)
                        $fatal(1, "Duplicate result at PE %0d", i);

                    if ($signed(c_bus[i*32 +: 32]) !== expected[i])
                        $fatal(1,
                            "PE %0d: expected %0d, got %0d",
                            i, expected[i],
                            $signed(c_bus[i*32 +: 32])
                        );
                end
            end

            cycle = cycle + 1;
        end
    end

    initial begin
        expected[0] = 19;
        expected[1] = 22;
        expected[2] = 43;
        expected[3] = 50;

        for (i=0; i<4; i=i+1)
            seen[i] = 0;

        fd = $fopen("week02_rtl_outputs.csv", "w");
        if (fd == 0)
            $fatal(1, "Cannot open CSV");

        $fdisplay(fd, "cycle,row,col,valid,value");

        repeat (2) @(negedge clk);
        rst_n = 1;

        // Time 0: A00=1, B00=5
        @(negedge clk);
        a_bus = {8'd0, 8'd1};
        b_bus = {8'd0, 8'd5};
        a_valid = 2'b01;
        b_valid = 2'b01;

        // Time 1: A01=2, A10=3, B10=7, B01=6
        @(negedge clk);
        a_bus = {8'd3, 8'd2};
        b_bus = {8'd6, 8'd7};
        a_valid = 2'b11;
        b_valid = 2'b11;

        // Time 2: A11=4, B11=8
        @(negedge clk);
        a_bus = {8'd4, 8'd0};
        b_bus = {8'd8, 8'd0};
        a_valid = 2'b10;
        b_valid = 2'b10;

        @(negedge clk);
        a_bus = 0;
        b_bus = 0;
        a_valid = 0;
        b_valid = 0;

        repeat (8) @(negedge clk);

        for (i=0; i<4; i=i+1)
            if (seen[i] != 1)
                $fatal(1, "Missing result at PE %0d", i);

        $display("PASS: All four matrix results verified");
        $fclose(fd);
        $finish;
    end

endmodule
