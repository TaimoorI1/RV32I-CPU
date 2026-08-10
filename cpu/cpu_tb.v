module cpu_tb;
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

    // instr 1  = 32'h00A00093; addi x1,  x0, 10
    // instr 2  = 32'h01400113; addi x2,  x0, 20
    // instr 3  = 32'h01E00193; addi x3,  x0, 30
    // instr 4  = 32'h0020C233; xor  x4,  x1, x2
    // instr 5  = 32'h0020A2B3; slt  x5,  x1, x2
    // instr 6  = 32'hFF800313; addi x6,  x0, -8
    // instr 7  = 32'h40135393; srai x7,  x6, 1
    // instr 8  = 32'h00112023; sw   x1,  0(x2)
    // instr 9  = 32'h00012403; lw   x8,  0(x2)
    // instr 10 = 32'h00300493; addi x9,  x0, 3
    // instr 11 = 32'h00000513; addi x10, x0, 0
    // instr 12 = 32'h00000593; addi x11, x0, 0

    // loop:
    // instr 13, address 48 = 32'h00A50513; addi x10, x10, 10
    // instr 14, address 52 = 32'hFFF48493; addi x9,  x9, -1
    // instr 15, address 56 = 32'h00B48463; beq  x9,  x11, done  // +8
    // instr 16, address 60 = 32'hFE000AE3; beq  x0,  x0, loop   // -12

    // done:
    // instr 17, address 64  = 32'h06300613; addi x12, x0, 99
    // instr 18, address 68  = 32'h03700713; addi x14, x0, 55   // known starting value
    // instr 19, address 72  = 32'h00C006EF; jal  x13, +12
    // instr 20, address 76  = 32'h06F00713; addi x14, x0, 111  // skipped
    // instr 21, address 80  = 32'h0DE00713; addi x14, x0, 222  // skipped
    // instr 22, address 84  = 32'h04D00793; addi x15, x0, 77   // JAL target

    // JALR:
    // instr 23, address 88  = 32'h06C00813; addi x16, x0, 108  // target base
    // instr 24, address 92  = 32'h04200913; addi x18, x0, 66   // known starting value
    // instr 25, address 96  = 32'h001808E7; jalr x17, 1(x16)
    // instr 26, address 100 = 32'h06F00913; addi x18, x0, 111  // skipped
    // instr 27, address 104 = 32'h0DE00913; addi x18, x0, 222  // skipped
    // instr 28, address 108 = 32'h05800993; addi x19, x0, 88   // JALR target

    // LUI, AUIPC:
    // instr 29, address 112 = 32'h12345A37: lui x20, 0x12345
    // instr 30, address 116 = 32'h00001A97: auipc x21, 0x1    

    // instr 31, address 120 = 32'h0060FB13 andi  x22, x1, 6
    // instr 32, address 124 = 32'h0050EB93 ori x23, x1, 5
    // instr 33, address 128 = 32'h00F0CC13 xori  x24, x1, 15
    // instr 34, address 132 = 32'h00132C93 slti  x25, x6, 1
    // instr 35, address 136 = 32'h00133D13 sltiu x26, x6, 1
    // instr 36, address 140 = 32'h00309D93 slli  x27, x1, 3
    // instr 37, address 144 = 32'h00235E13 srli  x28, x6, 2

    // instr 38, address 148 = 32'h000000FF; illegal instruction
    // instr 39, address 152 = 32'h00000063; beq  x0,  x0, 0     // spin

    initial begin
        #100000;
        $display("TIMEOUT: simulation did not finish");
        $fatal(1);
    end

    initial begin
        reset = 1;

        dut.fetch_inst.imem_inst.mem[0]  = 32'h00A00093;
        dut.fetch_inst.imem_inst.mem[1]  = 32'h01400113;
        dut.fetch_inst.imem_inst.mem[2]  = 32'h01E00193;
        dut.fetch_inst.imem_inst.mem[3]  = 32'h0020C233;
        dut.fetch_inst.imem_inst.mem[4]  = 32'h0020A2B3;
        dut.fetch_inst.imem_inst.mem[5]  = 32'hFF800313;
        dut.fetch_inst.imem_inst.mem[6]  = 32'h40135393;
        dut.fetch_inst.imem_inst.mem[7]  = 32'h00112023;
        dut.fetch_inst.imem_inst.mem[8]  = 32'h00012403;
        dut.fetch_inst.imem_inst.mem[9]  = 32'h00300493;
        dut.fetch_inst.imem_inst.mem[10] = 32'h00000513;
        dut.fetch_inst.imem_inst.mem[11] = 32'h00000593;
        dut.fetch_inst.imem_inst.mem[12] = 32'h00A50513;
        dut.fetch_inst.imem_inst.mem[13] = 32'hFFF48493;
        dut.fetch_inst.imem_inst.mem[14] = 32'h00B48463;
        dut.fetch_inst.imem_inst.mem[15] = 32'hFE000AE3;
        dut.fetch_inst.imem_inst.mem[16] = 32'h06300613;
        dut.fetch_inst.imem_inst.mem[17] = 32'h03700713;
        dut.fetch_inst.imem_inst.mem[18] = 32'h00C006EF;
        dut.fetch_inst.imem_inst.mem[19] = 32'h06F00713;
        dut.fetch_inst.imem_inst.mem[20] = 32'h0DE00713;
        dut.fetch_inst.imem_inst.mem[21] = 32'h04D00793;
        dut.fetch_inst.imem_inst.mem[22] = 32'h06C00813;
        dut.fetch_inst.imem_inst.mem[23] = 32'h04200913;
        dut.fetch_inst.imem_inst.mem[24] = 32'h001808E7;
        dut.fetch_inst.imem_inst.mem[25] = 32'h06F00913;
        dut.fetch_inst.imem_inst.mem[26] = 32'h0DE00913;
        dut.fetch_inst.imem_inst.mem[27] = 32'h05800993;
        dut.fetch_inst.imem_inst.mem[28] = 32'h12345A37;
        dut.fetch_inst.imem_inst.mem[29] = 32'h00001A97;
        dut.fetch_inst.imem_inst.mem[30] = 32'h0060FB13; 
        dut.fetch_inst.imem_inst.mem[31] = 32'h0050EB93; 
        dut.fetch_inst.imem_inst.mem[32] = 32'h00F0CC13; 
        dut.fetch_inst.imem_inst.mem[33] = 32'h00132C93; 
        dut.fetch_inst.imem_inst.mem[34] = 32'h00133D13; 
        dut.fetch_inst.imem_inst.mem[35] = 32'h00309D93; 
        dut.fetch_inst.imem_inst.mem[36] = 32'h00235E13; 
        dut.fetch_inst.imem_inst.mem[37] = 32'h000000FF; 
        dut.fetch_inst.imem_inst.mem[38] = 32'h00000063;

        @(posedge clk);
        #1 reset = 0;

        repeat (45) @(posedge clk);

        check(dut.regfile_inst.registers[0], 32'd0, "x0 must be 0");
        check(dut.regfile_inst.registers[1], 32'd10, "addi x1, x0, 10");
        check(dut.regfile_inst.registers[2], 32'd20, "addi x2, x0, 20");
        check(dut.regfile_inst.registers[3], 32'd30, "addi x3, x0, 30");
        check(dut.regfile_inst.registers[4], 32'd30, "xor x4, x1, x2");
        check(dut.regfile_inst.registers[5], 32'd1, "slt x5, x1, x2");
        check(dut.regfile_inst.registers[6], 32'hFFFFFFF8, "addi x6, x0, -8");
        check(dut.regfile_inst.registers[7], 32'hFFFFFFFC, "srai x7, x6, 1");
        check(dut.dmem_inst.storage[5], 32'd10, "sw x1, 0(x2)");
        check(dut.regfile_inst.registers[8], 32'd10, "lw x8, 0(x2)");
        check(dut.regfile_inst.registers[9], 32'd0, "x9 expected 0");
        check(dut.regfile_inst.registers[10], 32'd30, "x10 expected 30");
        check(dut.regfile_inst.registers[11], 32'd0, "x11 expected 0");
        check(dut.regfile_inst.registers[12], 32'd99, "x12 expected 99");
        check(dut.regfile_inst.registers[13], 32'd76, "JAL writes PC+4 link address to x13");
        check(dut.regfile_inst.registers[14], 32'd55, "JAL leaves x14 unchanged across skipped instructions");
        check(dut.regfile_inst.registers[15], 32'd77, "JAL executes target instruction");
        check(dut.regfile_inst.registers[16], 32'd108, "JALR base register contains target address");
        check(dut.regfile_inst.registers[17], 32'd100, "JALR writes PC+4 link address to x17");
        check(dut.regfile_inst.registers[18], 32'd66, "JALR leaves x18 unchanged across skipped instructions");
        check(dut.regfile_inst.registers[19], 32'd88, "JALR executes target instruction");
        check(dut.regfile_inst.registers[20], 32'h12345000, "LUI loads immediate into x20");
        check(dut.regfile_inst.registers[21], 32'h00001074, "AUIPC loads PC + immediate into x21");
        check(dut.regfile_inst.registers[22], 32'd2, "ANDI x22, x1, 6");
        check(dut.regfile_inst.registers[23], 32'd15, "ORI x23, x1, 5");
        check(dut.regfile_inst.registers[24], 32'd5, "XORI x24, x1, 15");
        check(dut.regfile_inst.registers[25], 32'd1, "SLTI signed -8 < 1");
        check(dut.regfile_inst.registers[26], 32'd0, "SLTIU unsigned 0xFFFFFFF8 < 1");
        check(dut.regfile_inst.registers[27], 32'h00000050, "SLLI x27, x1, 3");
        check(dut.regfile_inst.registers[28], 32'h3FFFFFFE, "SRLI x28, x6, 2");
        check(dut.fetch_inst.pc_inst.pc, 32'd152, "PC parked at relocated spin loop");
        check(illegal_count, 32'd1, "illegal counter expected 1");

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