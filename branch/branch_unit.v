module branch_unit (
    input [31:0] rd1,
    input [31:0] rd2,
    input [2:0] funct3,

    output reg branch_taken
);

always @(*) begin 
    branch_taken = 1'b0;
    case (funct3)

        3'b000 : begin // beq
            if (rd1 == rd2) branch_taken = 1'b1;
        end

        3'b001 : begin // bne
            if (rd1 != rd2) branch_taken = 1'b1;
        end

        3'b100 : begin // blt
            if ($signed(rd1) < $signed(rd2)) branch_taken = 1'b1;
        end

        3'b101 : begin // bge
            if ($signed(rd1) >= $signed(rd2)) branch_taken = 1'b1;
        end

        3'b110 : begin // bltu
            if (rd1 < rd2) branch_taken = 1'b1;
        end

        3'b111 : begin // bgeu
            if (rd1 >= rd2) branch_taken = 1'b1;
        end

        default : branch_taken = 1'b0;

    endcase

end

endmodule