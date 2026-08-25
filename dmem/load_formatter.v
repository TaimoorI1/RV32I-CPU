module load_formatter(
    input [31:0] dmem_data,
    input [1:0] addr_offset,
    input [2:0] funct3,

    output reg [31:0] load_data,
    output reg misaligned
);

reg [7:0] selected_byte;
reg [15:0] selected_halfword;


always @(*) begin 
    // default
    selected_byte = 8'b0; 
    selected_halfword = 16'b0;
    misaligned = 1'b0;
    load_data = 32'b0;



    case (funct3) 

        3'b000 : begin // LB
            case (addr_offset)
                2'b00 : selected_byte = dmem_data[7:0];
                2'b01 : selected_byte = dmem_data[15:8];
                2'b10 : selected_byte = dmem_data[23:16];
                2'b11 : selected_byte = dmem_data[31:24];
            endcase
            load_data = {{24{selected_byte[7]}}, selected_byte};
        end

        3'b001 : begin // LH
            case (addr_offset)
                2'b00 : selected_halfword = dmem_data[15:0];
                2'b10 : selected_halfword = dmem_data[31:16];
                default : misaligned = 1'b1;
            endcase
            if (misaligned == 1'b0) load_data = {{16{selected_halfword[15]}}, selected_halfword};
        end

        3'b010 : begin // LW
            if (addr_offset == 2'b00) load_data = dmem_data[31:0];
            else misaligned = 1'b1;
        end

        3'b100 : begin // LBU
            case (addr_offset)
                2'b00 : selected_byte = dmem_data[7:0];
                2'b01 : selected_byte = dmem_data[15:8];
                2'b10 : selected_byte = dmem_data[23:16];
                2'b11 : selected_byte = dmem_data[31:24];
            endcase
            load_data = {{24{1'b0}}, selected_byte};
        end

        3'b101 : begin // LHU
            case (addr_offset)
                2'b00 : selected_halfword = dmem_data[15:0];
                2'b10 : selected_halfword = dmem_data[31:16];
                default : misaligned = 1'b1;
            endcase
            if (misaligned == 1'b0) load_data = {{16{1'b0}}, selected_halfword};
        end

    endcase

end

endmodule