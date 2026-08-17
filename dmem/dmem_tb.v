`timescale 1ns/1ps

module dmem_tb;
    reg clk;
    reg [31:0] addr;
    reg [31:0] store_data;
    reg [3:0] write_enable;
    wire [31:0] read_data;

    dmem dut (
        .clk(clk), .addr(addr), .store_data(store_data),
        .write_enable(write_enable), .read_data(read_data)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Test 1: write then read
        write_enable = 4'b1111;
        addr = 32'h10;
        store_data = 32'hDDDDEEEE;
        @(posedge clk); #1;
        write_enable = 4'b0000;
        if (read_data === 32'hDDDDEEEE) $display("PASS: write-read");
        else $display("FAIL: write-read, got %0h", read_data);

        // Test 2: uninitialized read
        addr = 32'h01;
        #1;
        if (read_data === 32'hxxxxxxxx) $display("PASS: uninitialized read");
        else $display("FAIL: uninitialized read, got %0h", read_data);
        
        // Test 3: write disabled
        write_enable = 4'b0000;
        addr = 32'h10;
        store_data = 32'hABCD1234;
        @(posedge clk); #1;
        if (read_data === 32'hDDDDEEEE) $display("PASS: write disabled");
        else $display("FAIL: write disabled, got %0h", read_data);

        // Test 4: No clobber
        write_enable = 4'b1111;
        addr = 32'h110;
        #1;
        store_data = 32'hAAAABBBB;
        @(posedge clk); #1;
        write_enable = 4'b0000;

        // Test 5
        addr = 32'h10;
        #1;
        if (read_data !== 32'hDDDDEEEE) $display("FAIL: clobber, got %0h", read_data);
        else $display ("PASS: first address preserved");

        // Test 6
        addr = 32'h110;
        #1;
        if (read_data === 32'hAAAABBBB) $display("PASS: no clobber");
        else $display("FAIL: clobber, got %0h", read_data);

        // Test 7: write, read, SH-style write, read again
        addr = 32'h20;
        write_enable = 4'b1111;
        store_data = 32'hABCD1234;
        @(posedge clk); #1;
        if (read_data === 32'hABCD1234) begin
            write_enable = 4'b0011;
            store_data = 32'hEEEEFFFF;
            @(posedge clk); #1;
            if (read_data === 32'hABCDFFFF) $display("PASS: SH-style write");
            else $display("FAIL: SH-style write, got %0h", read_data);
        end

        // Test 8: read, SB-style write, read again
        addr = 32'h20;
        if (read_data === 32'hABCDFFFF) begin
            write_enable = 4'b0100;
            store_data = 32'h00780000;
            @(posedge clk); #1;
            if (read_data === 32'hAB78FFFF) $display("PASS: SB-style write");
            else $display("FAIL: SB-style write, got %0h", read_data);
        end

        $finish;
    end
endmodule
