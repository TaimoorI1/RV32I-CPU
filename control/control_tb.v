module control_tb;

reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;

wire reg_write;
wire alu_src;
wire [3:0] alu_control;
wire store_en;
wire [2:0] wb_select;
wire branch;
wire jump;
wire jump_reg;
wire illegal;

integer op_i;
integer f3_i;
integer f7_i;
reg sweep_exp_illegal;

integer errors;
integer tests;

control dut (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .alu_control(alu_control),
    .store_en(store_en),
    .wb_select(wb_select),
    .branch(branch),
    .jump(jump),
    .jump_reg(jump_reg),
    .illegal(illegal)
);


task check;
    input [3:0] exp_alu_control;
    input exp_alu_src;
    input exp_reg_write;
    input exp_store_en;
    input [2:0] exp_wb_select;
    input exp_branch;
    input exp_jump;
    input exp_jump_reg;
    input exp_illegal;
    begin
        tests = tests + 1;

        if (!(alu_control === exp_alu_control &&
              alu_src === exp_alu_src &&
              reg_write === exp_reg_write &&
              store_en === exp_store_en &&
              wb_select === exp_wb_select &&
              branch === exp_branch &&
              jump === exp_jump &&
              jump_reg === exp_jump_reg && 
              illegal === exp_illegal
            )) begin

            errors = errors + 1;

            $display(
                "FAIL: opcode=%b funct3=%b funct7=%b | got ctrl=%b src=%b wr=%b se=%b m2r=%b br=%b j=%b jr=%b illegal=%b | expected ctrl=%b src=%b wr=%b se=%b m2r=%b br=%b j=%b jr=%b illegal=%b",
                opcode,
                funct3,
                funct7,
                alu_control,
                alu_src,
                reg_write,
                store_en,
                wb_select,
                branch,
                jump,
                jump_reg,
                illegal,
                exp_alu_control,
                exp_alu_src,
                exp_reg_write,
                exp_store_en,
                exp_wb_select,
                exp_branch,
                exp_jump,
                exp_jump_reg,
                exp_illegal
            );
        end
    end
endtask

function expected_illegal;
    input [6:0] op;
    input [2:0] f3; 
    input [6:0] f7;

    begin
        expected_illegal = 1'b1;

        case (op)
            7'b0110011 : begin
                case (f7)
                    7'b0000000 : expected_illegal = 1'b0;

                    7'b0100000 : begin
                        case (f3)
                            3'b000 : expected_illegal = 1'b0;
                            3'b101 : expected_illegal = 1'b0;
                        endcase
                    end
                endcase
            end

            7'b0010011 : begin
                case (f3)
                    3'b000 : expected_illegal = 1'b0;
                    3'b010 : expected_illegal = 1'b0;
                    3'b011 : expected_illegal = 1'b0;
                    3'b100 : expected_illegal = 1'b0;
                    3'b110 : expected_illegal = 1'b0;
                    3'b111 : expected_illegal = 1'b0;

                    3'b001 : begin
                        if (f7 == 7'b0000000)
                            expected_illegal = 1'b0;
                    end

                    3'b101 : begin
                        if ((f7 == 7'b0000000) ||
                            (f7 == 7'b0100000))
                            expected_illegal = 1'b0;
                    end
                endcase
            end

            7'b0000011 : begin
                if (f3 == 3'b000 || f3 == 3'b001 || f3 == 3'b010 || f3 == 3'b100 || f3 == 3'b101) 
                    expected_illegal = 1'b0;
            end

            7'b0100011 : begin 
                if (f3 == 3'b000 || f3 == 3'b001 || f3 == 3'b010) 
                    expected_illegal = 1'b0;
            end

            7'b1100011 : begin
                if (f3 == 3'b000) 
                    expected_illegal = 1'b0;
            end

            7'b1101111 : begin // JAL 
                expected_illegal = 1'b0;
            end 

             7'b1100111 : begin // JALR
                if (f3 == 3'b000) expected_illegal = 1'b0;
            end 

            7'b0110111 : begin // LUI
                expected_illegal = 1'b0;
            end

            7'b0010111 : begin // AUIPC
                expected_illegal = 1'b0;
            end 

        endcase
    end
endfunction




initial begin
    errors = 0;
    tests = 0;

    // ADD
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);


    // SUB
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0100000;
    #1;
    check(4'b0001, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // AND
    opcode = 7'b0110011;
    funct3 = 3'b111;
    funct7 = 7'b0000000;
    #1;
    check(4'b0010, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // OR
    opcode = 7'b0110011;
    funct3 = 3'b110;
    funct7 = 7'b0000000;
    #1;
    check(4'b0011, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // XOR
    opcode = 7'b0110011;
    funct3 = 3'b100;
    funct7 = 7'b0000000;
    #1;
    check(4'b0100, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLT
    opcode = 7'b0110011;
    funct3 = 3'b010;
    funct7 = 7'b0000000;
    #1;
    check(4'b0101, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);


    // SLL
    opcode = 7'b0110011;
    funct3 = 3'b001;
    funct7 = 7'b0000000;
    #1;
    check(4'b0110, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SRL
    opcode = 7'b0110011;
    funct3 = 3'b101;
    funct7 = 7'b0000000;
    #1;
    check(4'b0111, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SRA
    opcode = 7'b0110011;
    funct3 = 3'b101;
    funct7 = 7'b0100000;
    #1;
    check(4'b1000, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLTU
    opcode = 7'b0110011;
    funct3 = 3'b011;
    funct7 = 7'b0000000;
    #1;
    check(4'b1100, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // ADDI
    opcode = 7'b0010011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // ANDI
    opcode = 7'b0010011;
    funct3 = 3'b111; 
    funct7 = 7'b1111000; // arbitrary 7 bits since ANDI ignores these
    #1; 
    check(4'b0010, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // ORI
    opcode = 7'b0010011;
    funct3 = 3'b110;
    funct7 = 7'b0000000;
    #1;
    check(4'b0011, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // XORI
    opcode = 7'b0010011;
    funct3 = 3'b100;
    funct7 = 7'b0000000;
    #1;
    check(4'b0100, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLTI
    opcode = 7'b0010011;
    funct3 = 3'b010;
    funct7 = 7'b0000000;
    #1;
    check(4'b0101, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLLI
    opcode = 7'b0010011;
    funct3 = 3'b001;
    funct7 = 7'b0000000;
    #1;
    check(4'b0110, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SRLI
    opcode = 7'b0010011;
    funct3 = 3'b101;
    funct7 = 7'b0000000;
    #1;
    check(4'b0111, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SRAI
    opcode = 7'b0010011;
    funct3 = 3'b101;
    funct7 = 7'b0100000;
    #1;
    check(4'b1000, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SLTIU
    opcode = 7'b0010011;
    funct3 = 3'b011;
    funct7 = 7'b0000000;
    #1;
    check(4'b1100, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // LB
    opcode = 7'b0000011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0);

    // LH
    opcode = 7'b0000011;
    funct3 = 3'b001;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0);

    // LW
    opcode = 7'b0000011;
    funct3 = 3'b010;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0);

    // LBU
    opcode = 7'b0000011;
    funct3 = 3'b100;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0);

    // LHU
    opcode = 7'b0000011;
    funct3 = 3'b101;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0);

    // SB
    opcode = 7'b0100011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b0, 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SH
    opcode = 7'b0100011;
    funct3 = 3'b001;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b0, 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // SW
    opcode = 7'b0100011;
    funct3 = 3'b010;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b1, 1'b0, 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

    // BEQ
    opcode = 7'b1100011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0001, 1'b0, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0);

    // BNE; not currently supported
    opcode = 7'b1100011;
    funct3 = 3'b001;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1);

    // SLLI with illegal funct7; shift encodings require instr[31:25] = 0000000
    opcode = 7'b0010011;
    funct3 = 3'b001;
    funct7 = 7'b0100000;   
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1);

    // Legal JAL
    opcode = 7'b1101111;
    funct3 = 3'b111;
    funct7 = 7'b0110100; 
    #1;
    check(4'b0000, 1'b0, 1'b1, 1'b0, 2'b10, 1'b0, 1'b1, 1'b0, 1'b0);

    // Legal JALR
    opcode = 7'b1100111;
    funct3 = 3'b000;
    funct7 = 7'b0110100; 
    #1;
    check(4'b0000, 1'b1, 1'b1, 1'b0, 2'b10, 1'b0, 1'b1, 1'b1, 1'b0);

     // Illegal JALR
    opcode = 7'b1100111;
    funct3 = 3'b100; // funct3 must be 3'b000
    funct7 = 7'b0110100; 
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1);

    // LUI
    opcode = 7'b0110111;
    funct3 = 3'b000; // irrelevant
    funct7 = 7'b0000000;  // irrelevant
    #1;
    check(4'b0000, 1'b0, 1'b1, 1'b0, 3'b011, 1'b0, 1'b0, 1'b0, 1'b0);

    // AUIPC
    opcode = 7'b0010111;
    funct3 = 3'b000; // irrelevant
    funct7 = 7'b0000000;  // irrelevant
    #1;
    check(4'b0000, 1'b0, 1'b1, 1'b0, 3'b100, 1'b0, 1'b0, 1'b0, 1'b0);


    // R-type funct7=0100000 with funct3 that is neither SUB (000) nor SRA (101)
    opcode = 7'b0110011;
    funct3 = 3'b001;     
    funct7 = 7'b0100000;
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1);

    // MUL: valid M-extension instruction, unsupported by current core
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000001;
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1);

    // Garbage opcode
    opcode = 7'b1111111;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #1;
    check(4'b0000, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1);

    for (op_i = 0; op_i < 128; op_i = op_i + 1) begin
        for (f3_i = 0; f3_i < 8; f3_i = f3_i + 1) begin
            for (f7_i = 0; f7_i < 128; f7_i = f7_i + 1) begin

                opcode = op_i;
                funct3 = f3_i;
                funct7 = f7_i;

                #1;

                sweep_exp_illegal = expected_illegal(opcode, funct3, funct7);

                tests = tests + 1;
                if (illegal !== sweep_exp_illegal) begin
                    errors = errors + 1;
                    $display("SWEEP FAIL: opcode:%b | funct3:%b | funct7:%b | actual:%b | expected:%b", opcode, funct3, funct7, illegal, sweep_exp_illegal);
                end
                
                if (sweep_exp_illegal && (reg_write || store_en || branch || jump || jump_reg)) begin  
                    errors = errors + 1;
                    $display("UNSAFE ILLEGAL: opcode=%b funct3=%b funct7=%b | rw=%b se=%b br=%b j=%b jr= %b",
                    opcode, funct3, funct7, reg_write, store_en, branch, jump, jump_reg);
                end

                if (reg_write && store_en) begin
                    errors = errors + 1;
                    $display("WRITE CONFLICT: reg_write and store_en both enabled | opcode=%b funct3=%b funct7=%b", opcode, funct3, funct7);
                end

            end
        end
    end

    $display("%0d/%0d passed", tests - errors, tests);
    $finish;
end

endmodule