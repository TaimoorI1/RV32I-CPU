
`timescale 1ns/1ps

module practice_pipe_reg_tb;

    logic clk = 0;
    logic reset;
    logic stall;
    logic flush;

    pipe_data_t d;
    pipe_data_t q;
    pipe_data_t expected;

    // Generate a clock with a 10 ns period.
    always #5 clk = ~clk;

    // Connect the hardware to our testbench.
    practice_pipe_reg dut (
        .clk   (clk),
        .reset (reset),
        .stall (stall),
        .flush (flush),
        .d     (d),
        .q     (q)
    );

    initial begin
        // TEST 1: RESET
        reset = 1;
        stall = 0;
        flush = 0;

        d = '0;
        d.valid = 1'b1;

        @(posedge clk);
        #1;

        if (q !== '0)
            $fatal(1, "FAIL: reset");

        $display("PASS: reset");

        // TEST 2: NORMAL LOAD
        reset = 0;

        d.pc    = 32'h00001000;
        d.instr = 32'h00500093;
        d.valid = 1'b1;

        @(posedge clk);
        #1;

        if (q !== d)
            $fatal(1, "FAIL: normal load");

        $display("PASS: normal load");

        // TEST 3: STALL
        expected = q;
        stall = 1;

        d.pc    = 32'h00002000;
        d.instr = 32'h00900113;
        d.valid = 1'b1;

        @(posedge clk);
        #1;

        if (q !== expected)
            $fatal(1, "FAIL: stall");

        $display("PASS: stall");

        // TEST 4: FLUSH
        stall = 0;
        flush = 1;

        @(posedge clk);
        #1;

        if (q !== '0)
            $fatal(1, "FAIL: flush");

        $display("PASS: flush");

        // TEST 5: FLUSH + STALL
        // First load a real instruction.
        flush = 0;
        stall = 0;

        d.pc    = 32'h00003000;
        d.instr = 32'h00100293;
        d.valid = 1'b1;

        @(posedge clk);
        #1;

        if (q !== d)
            $fatal(1, "FAIL: priority test setup");

        // Now assert both simultaneously.
        flush = 1;
        stall = 1;

        @(posedge clk);
        #1;

        if (q !== '0)
            $fatal(1, "FAIL: flush/stall priority");

        $display("PASS: flush beats stall");

        $display("ALL 5 TESTS PASSED");
        $finish;
    end

endmodule
