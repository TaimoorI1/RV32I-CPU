module imm_gen(
    input [31:0] instr ,
    output reg [31:0] out
);

    wire [6:0] opcode = instr[6:0];

    always @(*) begin 
        case (opcode)
            7'b0010011: out = {{20{instr[31]}}, instr[31:20]};
            7'b0100011: out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b0000011: out = {{20{instr[31]}}, instr[31:20]};
            7'b1100011: out = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            7'b1101111: out = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            7'b1100111: out = {{20{instr[31]}}, instr[31:20]};
            7'b0110111: out = {instr[31:12], 12'b0}; // LUI
            7'b0010111: out = {instr[31:12], 12'b0}; // AUIPC
            default: out = 32'b0;
        endcase
    end 


endmodule
