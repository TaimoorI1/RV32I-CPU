module control (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7, 

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
            alu_src = 1'b0;
            case (funct7) 
                7'b0000000 : begin
                    // signals true for all R-type operations with funct7 = 7'b0000000
                    reg_write = 1'b1;
                    case (funct3)
                        3'b000 : alu_control = 4'b0000; // ADD
                        3'b111 : alu_control = 4'b0010; // AND 
                        3'b110 : alu_control = 4'b0011; // OR
                        3'b100 : alu_control = 4'b0100; // XOR
                        3'b010 : alu_control = 4'b0101; // SLT
                        3'b001 : alu_control = 4'b0110; // SLL
                        3'b101 : alu_control = 4'b0111; // SRL
                        3'b011 : alu_control = 4'b1100; // SLTU
                    endcase
                end
                
                7'b0100000 : begin
                    case (funct3)
                        3'b000 : begin
                            reg_write = 1'b1; 
                            alu_control = 4'b0001; // SUB
                        end

                        3'b101 : begin
                            reg_write = 1'b1; 
                            alu_control = 4'b1000; // SRA
                        end

                        default : illegal = 1'b1;
                    endcase
                end

                default : illegal = 1'b1;
            endcase
        end

        7'b0010011 : begin
            case (funct3)
                3'b000 : begin reg_write = 1'b1; alu_src = 1'b1; alu_control = 4'b0000; end // ADDI
                3'b111 : begin reg_write = 1'b1; alu_src = 1'b1; alu_control = 4'b0010; end // ANDI
                3'b110 : begin reg_write = 1'b1; alu_src = 1'b1; alu_control = 4'b0011; end // ORI
                3'b100 : begin reg_write = 1'b1; alu_src = 1'b1; alu_control = 4'b0100; end // XORI
                3'b010 : begin reg_write = 1'b1; alu_src = 1'b1; alu_control = 4'b0101; end // SLTI
                3'b011 : begin reg_write = 1'b1; alu_src = 1'b1; alu_control = 4'b1100; end // SLTIU

                3'b001 : begin
                    if (funct7 == 7'b0000000) begin
                        reg_write = 1'b1;
                        alu_src = 1'b1;
                        alu_control = 4'b0110; // SLLI
                    end
                    else illegal = 1'b1; 
                end

                3'b101 : begin
                    if (funct7 == 7'b0000000) begin
                        reg_write = 1'b1; 
                        alu_src = 1'b1;
                        alu_control = 4'b0111; // SRLI
                    end
                    else if (funct7 == 7'b0100000) begin
                        reg_write = 1'b1; 
                        alu_src = 1'b1;
                        alu_control = 4'b1000; // SRAI
                    end
                    else 
                        illegal = 1'b1; 
                end

                default : illegal = 1'b1;
            endcase
        end

        7'b0000011 : begin // lw operations 
            case (funct3)
                3'b010 : begin
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    mem_write = 1'b0;
                    mem_to_reg = 1'b1;
                    alu_control = 4'b0000;
                end

                default : illegal = 1'b1;
            endcase
        end
        

        7'b0100011 : begin // sw operations
            case (funct3)
                3'b010 : begin
                    reg_write = 1'b0;
                    alu_src = 1'b1;
                    mem_write = 1'b1;
                    mem_to_reg = 1'b0;
                    alu_control = 4'b0000;
                end

                default : illegal = 1'b1;
            endcase
        end
            

        7'b1100011 : begin // B-type operations
            case (funct3)
                3'b000 : begin
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

        default : illegal = 1'b1;

   endcase

end 

endmodule
