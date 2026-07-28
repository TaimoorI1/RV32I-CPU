module control_tb;

reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;

wire reg_write;
wire alu_src;
wire [3:0] alu_control;
wire mem_write;
wire mem_to_reg;
wire branch;
wire illegal;


integer errors;
integer tests;

control dut (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .alu_control(alu_control),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .illegal(illegal)
);

task check;
    input [3:0] exp_alu_control;
    input exp_alu_src;
    input exp_reg_write;
    input exp_mem_write;
    input exp_mem_to_reg;
    input exp_branch;
    input exp_illegal;
    begin
        tests = tests + 1;

        if (!(alu_control === exp_alu_control &&
              alu_src === exp_alu_src &&
              reg_write === exp_reg_write &&
              mem_write === exp_mem_write &&
              mem_to_reg === exp_mem_to_reg &&
              branch === exp_branch &&
              illegal === exp_illegal
            )) begin

            errors = errors + 1;

            $display(
                "FAIL: opcode=%b funct3=%b funct7=%b | got ctrl=%b src=%b wr=%b mw=%b m2r=%b br=%b illegal=%b | expected ctrl=%b src=%b wr=%b mw=%b m2r=%b br=%b illegal=%b",
                opcode,
                funct3,
                funct7,
                alu_control,
                alu_src,
                reg_write,
                mem_write,
                mem_to_reg,
                branch,
                illegal,
                exp_alu_control,
                exp_alu_src,
                exp_reg_write,
                exp_mem_write,
                exp_mem_to_reg,
                exp_branch,
                exp_illegal
            );
        end
    end
endtask

initial begin
    errors = 0;
    tests = 0;

    // ADD
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SUB
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0100000;
    #1;
    check(4'b0001, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // AND
    opcode = 7'b0110011;
    funct3 = 3'b111;
    funct7 = 7'b0000000;
    #1;
    check(4'b0010, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // OR
    opcode = 7'b0110011;
    funct3 = 3'b110;
    funct7 = 7'b0000000;
    #1;
    check(4'b0011, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // XOR
    opcode = 7'b0110011;
    funct3 = 3'b100;
    funct7 = 7'b0000000;
    #1;
    check(4'b0100, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLT
    opcode = 7'b0110011;
    funct3 = 3'b010;
    funct7 = 7'b0000000;
    #1;
    check(4'b0101, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLL
    opcode = 7'b0110011;
    funct3 = 3'b001;
    funct7 = 7'b0000000;
    #1;
    check(4'b0110, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SRL
    opcode = 7'b0110011;
    funct3 = 3'b101;
    funct7 = 7'b0000000;
    #1;
    check(4'b0111, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SRA
    opcode = 7'b0110011;
    funct3 = 3'b101;
    funct7 = 7'b0100000;
    #1;
    check(4'b1000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLTU
    opcode = 7'b0110011;
    funct3 = 3'b011;
    funct7 = 7'b0000000;
    #1;
    check(4'b1100, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // ADDI
    opcode = 7'b0010011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // ANDI
    opcode = 7'b0010011;
    funct3 = 3'b111; 
    funct7 = 7'b1111000; // arbitrary 7 bits since ANDI ignores these
    #1; 
    check(4'b0010, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // ORI
    opcode = 7'b0010011;
    funct3 = 3'b110;
    funct7 = 7'b0000000;
    #1;
    check(4'b0011, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // XORI
    opcode = 7'b0010011;
    funct3 = 3'b100;
    funct7 = 7'b0000000;
    #1;
    check(4'b0100, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLTI
    opcode = 7'b0010011;
    funct3 = 3'b010;
    funct7 = 7'b0000000;
    #1;
    check(4'b0101, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLLI
    opcode = 7'b0010011;
    funct3 = 3'b001;
    funct7 = 7'b0000000;
    #1;
    check(4'b0110, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SRLI
    opcode = 7'b0010011;
    funct3 = 3'b101;
    funct7 = 7'b0000000;
    #1;
    check(4'b0111, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SRAI
    opcode = 7'b0010011;
    funct3 = 3'b101;
    funct7 = 7'b0100000;
    #1;
    check(4'b1000, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLTIU
    opcode = 7'b0010011;
    funct3 = 3'b011;
    funct7 = 7'b0000000;
    #1;
    check(4'b1100, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

    // LW
    opcode = 7'b0000011;
    funct3 = 3'b010;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0);

    // LB; not currently supported
    opcode = 7'b0000011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

    // SW
    opcode = 7'b0100011;
    funct3 = 3'b010;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0);

    // SB; not currently supported
    opcode = 7'b0100011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

    // BEQ
    opcode = 7'b1100011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0001, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0);

    // BNE; not currently supported
    opcode = 7'b1100011;
    funct3 = 3'b001;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

    // SLLI with illegal funct7; shift encodings require instr[31:25] = 0000000
    opcode = 7'b0010011;
    funct3 = 3'b001;
    funct7 = 7'b0100000;   
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

    // R-type funct7=0100000 with funct3 that is neither SUB (000) nor SRA (101)
    opcode = 7'b0110011;
    funct3 = 3'b001;     
    funct7 = 7'b0100000;
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

    // MUL: valid M-extension instruction, unsupported by current core
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000001;
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

    // Garbage opcode
    opcode = 7'b1111111;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);


    $display("%0d/%0d passed", tests - errors, tests);
    $finish;
end

endmodule