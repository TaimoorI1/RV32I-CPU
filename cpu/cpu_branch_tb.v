module cpu_branch_tb;
    reg clk;
    reg reset;
    wire illegal;
    
    cpu dut (
        .clk(clk),
        .reset(reset),
        .illegal(illegal)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    integer tests = 0;

    integer illegal_count;
    initial illegal_count = 0;

    always @(posedge clk) begin
        if (illegal === 1'b1)
            illegal_count = illegal_count + 1;
    end

    task check(input [31:0] actual, input [31:0] expected, input [127:0] name);
    begin
        #1;
        tests = tests + 1;

        if (actual !== expected) begin
            errors = errors + 1;
            $display("FAIL [%0s]: got %h, expected %h", name, actual, expected);
        end
    end
    endtask

    initial begin
        #100000;
        $display("TIMEOUT: simulation did not finish");
        $fatal(1);
    end

    initial begin
        reset = 1;


        dut.fetch_inst.imem_inst.mem[0] = 32'h00200093;
        dut.fetch_inst.imem_inst.mem[1] = 32'h00300113;
        dut.fetch_inst.imem_inst.mem[2] = 32'h00209463;
        dut.fetch_inst.imem_inst.mem[3] = 32'h06300193;
        dut.fetch_inst.imem_inst.mem[4] = 32'h02A00193;
        dut.fetch_inst.imem_inst.mem[5] = 32'h00000063; // existing beq x0,x0,0 spin

    
        @(posedge clk);
        #1 reset = 0;

        repeat (49) @(posedge clk);

        check(dut.regfile_inst.registers[1], 32'd2,  "BNE setup x1");
        check(dut.regfile_inst.registers[2], 32'd3,  "BNE setup x2");
        check(dut.regfile_inst.registers[3], 32'd42, "BNE skips fall-through");
        check(dut.fetch_inst.pc_inst.pc,     32'd20, "BNE test parked");

        $display("PC = %0d", dut.fetch_inst.pc_inst.pc);

        if (errors == 0) begin
            $display("ALL %0d TESTS PASSED", tests);
        end
        else begin
            $display("%0d/%0d TESTS FAILED", errors, tests);
            $fatal(1);
        end

        $finish;
    end

endmodule