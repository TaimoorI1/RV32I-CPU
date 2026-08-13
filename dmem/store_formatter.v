module store_formatter (
    input [31:0] addr,
    input [2:0] funct3,
    input [31:0] rd2,

    output reg [31:0] store_data,
    output reg [3:0] write_enable,
    output reg misaligned
);

always @(*) begin
    
    //defaults
    store_data = 32'b0;
    write_enable = 4'b0000;
    misaligned = 1'b0;
    
    case (funct3)

        // SB
        3'b000 : begin
            store_data = {24'b0, rd2[7:0]} << (addr[1:0] * 8);
            write_enable = 4'b0001 << addr[1:0];
        end

        // SH
        3'b001: begin
            if (addr[0] == 1'b0) begin
                store_data = {16'b0, rd2[15:0]} << (addr[1:0] * 8);
                write_enable = 4'b0011 << addr[1:0];
            end 
            else misaligned = 1'b1;
        end

        // SW 
        3'b010: begin
            if (addr[1:0] == 2'b00) begin
                store_data = rd2;
                write_enable = 4'b1111;
            end
            else misaligned = 1'b1;
        end

        default : begin
        end
    endcase

end

endmodule