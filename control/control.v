module control (
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7_5, 

    output reg reg_write,
    output reg alu_src,
    output reg [3:0] alu_control,
    output reg mem_to_reg,
    output reg mem_write,
    output reg branch,
    output reg illegal
);

always @(*) begin
    reg_write = 1'b0;
    alu_src = 1'b0;
    alu_control = 4'b0000;
    mem_to_reg = 1'b0;
    mem_write = 1'b0;
    branch = 1'b0;
    illegal = 1'b0;

   case (opcode)
        7'b0110011 : begin
            // signals true for all R-type operations
            reg_write = 1'b1;
            alu_src = 1'b0;
            case (funct3)
                3'b000 : alu_control = funct7_5 ? 4'b0001 : 4'b0000; // SUB : ADD
                3'b111 : alu_control = 4'b0010; // AND 
                3'b110 : alu_control = 4'b0011; // OR
                3'b100 : alu_control = 4'b0100; // XOR
                3'b010 : alu_control = 4'b0101; // SLT
                3'b001 : alu_control = 4'b0110; // SLL
                3'b101 : alu_control = funct7_5 ? 4'b1000 : 4'b0111; // SRA : SRL
                3'b011 : alu_control = 4'b1100; // SLTU
            endcase
        end

        7'b0010011 : begin
            // signals true for all I-type operations
            reg_write = 1'b1;
            alu_src = 1'b1;
            case (funct3)
                3'b000 : alu_control = 4'b0000; // ADDI
                3'b110 : alu_control = 4'b0011; // ORI
                3'b100 : alu_control = 4'b0100; // XORI
                3'b010 : alu_control = 4'b0101; // SLTI
                3'b001 : alu_control = 4'b0110; // SLLI
                3'b101 : alu_control = funct7_5 ? 4'b1000 : 4'b0111; // SRAI : SRLI
                3'b011 : alu_control = 4'b1100; // SLTIU
            endcase
        end

        7'b0000011 : begin // lw operations 
            reg_write = 1'b1;
            alu_src = 1'b1;
            mem_write = 1'b0;
            mem_to_reg = 1'b1;
            alu_control = 4'b0000;
        end

        7'b0100011 : begin // sw operations
            reg_write = 1'b0;
            alu_src = 1'b1;
            mem_write = 1'b1;
            mem_to_reg = 1'b0;
            alu_control = 4'b0000;
        end

        7'b1100011 : begin // B-type operations
            reg_write = 1'b0;
            alu_src = 1'b0;
            mem_write = 1'b0;
            mem_to_reg = 1'b0;
            alu_control = 4'b0001;
            branch = 1'b1;
        end

        default : illegal = 1'b1;

   endcase

end 

endmodule
