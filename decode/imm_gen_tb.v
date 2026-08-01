`timescale 1ns/1ps

module imm_gen_tb;

    reg  [31:0] instr;
    wire [31:0] out;

    integer errors = 0;
    integer tests  = 0;

    imm_gen dut (.instr(instr), .out(out));

    task check(input [31:0] expected, input [127:0] name);
    begin
        #1;
        tests = tests + 1;
        if (out !== expected) begin
            errors = errors + 1;
            $display("FAIL [%0s]: got %h, expected %h", name, out, expected);
        end
    end
    endtask

    initial begin
        // Test 1
        instr = {12'd10, 13'b0, 7'b0010011};
        check(32'd10, "I-type positive");

        // Test 2
        instr = {12'hFFF, 13'b0, 7'b0010011};
        check(32'hFFFFFFFF, "I-type negative");

        // Test 3
        instr = {7'd5, 13'b0, 5'd9, 7'b0100011};
        check(32'd169, "S-type positive");

        // Test 4
        instr = {7'b1000001, 13'b0, 5'd3, 7'b0100011};
        check(32'hFFFFF823, "S-type negative");

        // Test 5
        instr = {12'hFFC, 13'b0, 7'b0000011};
        check(32'hFFFFFFFC, "I-type load with negative offset");

        // Test 6
        instr = {12'd8, 13'b0, 7'b0000011};
        check(32'd8, "I-type load with positive offset");

        // Test 7
        instr = {12'hABC, 13'b0, 7'b0110011};
        check(32'b0, "default");

        // Test 8
        instr = {1'b0, 6'b000001, 13'b0, 4'b1101, 1'b0, 7'b1100011};
        check(32'b111010, "B-type positive offset");

        // Test 9
        instr = {1'b1, 6'b111111, 13'b0, 4'b1000, 1'b1, 7'b1100011};
        check(32'hFFFFFFF0, "B-type negative offset");

        // Test 10
        instr = {1'b0, 6'b000000, 13'b0, 4'b0000, 1'b1, 7'b1100011};
        check(32'h00000800, "B-type imm[11] isolated");

        // Test 11
        instr = {1'b0, 10'b100, 1'b0, 8'b0, 5'b0010, 7'b1101111};
        check(32'h8, "J-type positive offset");

        // Test 12
        instr = {1'b1, 10'b1111111100, 1'b1, 8'hFF, 5'b0100, 7'b1101111};
        check(32'hFFFFFFF8, "J-type negative offset");


        if (errors == 0) $display("ALL %0d TESTS PASSED", tests);
        else             $display("%0d/%0d TESTS FAILED", errors, tests);
        $finish;
    end

endmodule