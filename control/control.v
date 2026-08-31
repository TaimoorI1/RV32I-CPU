module control (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7, 

    output reg reg_write,
    output reg alu_src,
    output reg [3:0] alu_control,
    output reg [2:0] wb_select,
    output reg store_en,
    output reg branch,
    output reg jump,
    output reg jump_reg,
    output reg illegal
);

always @(*) begin
    reg_write = 1'b0;
    alu_src = 1'b0;
    alu_control = 4'b0000;
    wb_select = 2'b00;
    store_en = 1'b0;
    branch = 1'b0;
    jump = 1'b0;
    jump_reg = 1'b0;
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

        7'b0000011 : begin // load operations 
            case (funct3)

                3'b000 : begin // lb
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    store_en = 1'b0;
                    wb_select = 2'b01;
                    alu_control = 4'b0000;
                end

                3'b001 : begin // lh
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    store_en = 1'b0;
                    wb_select = 2'b01;
                    alu_control = 4'b0000;
                end 

                3'b010 : begin // lw
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    store_en = 1'b0;
                    wb_select = 2'b01;
                    alu_control = 4'b0000;
                end

                 3'b100 : begin // lbu
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    store_en = 1'b0;
                    wb_select = 2'b01;
                    alu_control = 4'b0000;
                end

                3'b101 : begin // lhu
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    store_en = 1'b0;
                    wb_select = 2'b01;
                    alu_control = 4'b0000;
                end

                default : illegal = 1'b1;
            endcase
        end
        

        7'b0100011 : begin // store operations
            case (funct3)
                3'b000 : begin // sb
                    reg_write = 1'b0;
                    alu_src = 1'b1;
                    store_en = 1'b1;
                    wb_select = 2'b00;
                    alu_control = 4'b0000;
                end

                3'b001 : begin // sh
                    reg_write = 1'b0;
                    alu_src = 1'b1;
                    store_en = 1'b1;
                    wb_select = 2'b00;
                    alu_control = 4'b0000;
                end

                3'b010 : begin // sw
                    reg_write = 1'b0;
                    alu_src = 1'b1;
                    store_en = 1'b1;
                    wb_select = 2'b00;
                    alu_control = 4'b0000;
                end

                default : illegal = 1'b1;
            endcase
        end
            

        7'b1100011 : begin // B-type operations
            case (funct3)
                3'b000, // beq
                3'b001, // bne
                3'b100, // blt
                3'b101, // bge
                3'b110, // bltu
                3'b111: begin // bgeu
                    reg_write   = 1'b0;
                    alu_src     = 1'b0;
                    store_en    = 1'b0;
                    wb_select   = 2'b00;
                    alu_control = 4'b0001;
                    branch      = 1'b1;
                end


                default : illegal = 1'b1;
            endcase
        end

        7'b1101111 : begin // JAL 
            reg_write = 1'b1;
            store_en = 1'b0;
            wb_select = 2'b10;
            branch = 1'b0;
            jump = 1'b1;
            jump_reg = 1'b0;
        end

        7'b1100111 : begin // JALR 
            if (funct3 == 3'b000) begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                alu_control = 4'b0000;
                store_en = 1'b0;
                wb_select = 2'b10;
                branch = 1'b0;
                jump = 1'b1;
                jump_reg = 1'b1;
            end

            else illegal = 1'b1;
        end

        7'b0110111 : begin // LUI
            reg_write =  1'b1;
            alu_src = 1'b0;
            alu_control = 4'b0000;
            store_en = 1'b0;
            wb_select = 3'b011; // imm
            branch = 1'b0;
            jump = 1'b0;
            jump_reg = 1'b0;
        end

        7'b0010111 : begin // AUIPC
            reg_write = 1'b1;
            alu_src = 1'b0;
            alu_control = 4'b0000;
            store_en = 1'b0;
            wb_select = 3'b100;
            branch = 1'b0;
            jump = 1'b0;
            jump_reg = 1'b0;
        end
        
        default : illegal = 1'b1;

   endcase

end 

endmodule
