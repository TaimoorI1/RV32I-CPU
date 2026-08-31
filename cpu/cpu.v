module cpu (
    input clk,
    input reset,
    output illegal
);

wire [31:0] instr;
wire [6:0] opcode;
wire [4:0] rd, rs1, rs2;
wire [2:0] funct3;
wire [6:0] funct7;
wire [31:0] imm;
wire [31:0] rd1, rd2;
wire [31:0] alu_result;
wire [31:0] pc;
wire reg_write;
wire alu_src;
wire reg_write_final;
wire [3:0] alu_control;
wire [3:0] write_enable; 
wire store_en;
wire [31:0] dmem_read_data;
wire [31:0] store_data;
wire misaligned;
wire [2:0] wb_select;
wire zero;
wire [31:0] redirect_target;
wire redirect_valid;
wire branch;
wire jump;
wire jump_reg;
wire [31:0] pc_relative_target;
wire [31:0] jalr_target;
wire [31:0] load_data;
wire load_misaligned;
wire branch_taken;

assign pc_relative_target = pc + imm; 
assign jalr_target = {alu_result[31:1], 1'b0};

assign redirect_valid = (branch & branch_taken) | jump;
assign redirect_target = jump_reg ? jalr_target : pc_relative_target;

assign reg_write_final = (reg_write && !(wb_select == 3'b001 && load_misaligned));

wire [31:0] pc_plus_4;
assign pc_plus_4 = pc + 32'd4;


// PC sends byte address to imem, imem outputs the instruction
fetch fetch_inst (
    .clk(clk),
    .reset(reset),
    .pc(pc),
    .redirect_target(redirect_target),
    .redirect_valid(redirect_valid),
    .instr(instr)
);

// instruction goes to decode, which deconstructs rs1, rs2, rd, imm
decode decode_inst (
    .instr(instr),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7)
);

// mux for wd in regfile
wire [31:0] wb_data;

assign wb_data = 
    (wb_select == 2'b00) ? alu_result : 
    (wb_select == 2'b01) ? load_data : 
    (wb_select == 2'b10) ? pc_plus_4 : 
    (wb_select == 3'b011) ? imm :
    (wb_select == 3'b100) ? pc_relative_target : 
                           32'b0;


// regfile reads rs1/rs2, outputs rd1, rd2
regfile regfile_inst (
    .clk(clk),
    .ra1(rs1),
    .ra2(rs2),
    .wa(rd),
    .wd(wb_data),
    .we(reg_write_final),
    .rd1(rd1),
    .rd2(rd2)
);


// ALU computes, result written back to rd at clock edge
wire [31:0] alu_b = alu_src ? imm : rd2;

alu alu_inst (
    .a(rd1),
    .b(alu_b),
    .alu_op(alu_control),
    .result(alu_result),
    .zero(zero)
);

imm_gen imm_gen_inst (
    .instr(instr),
    .out(imm)
);

control control_inst (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .alu_control(alu_control),
    .wb_select(wb_select),
    .store_en(store_en),
    .branch(branch),
    .jump(jump),
    .jump_reg(jump_reg),
    .illegal(illegal)
);

dmem dmem_inst (
    .clk(clk),
    .addr(alu_result), 
    .store_data(store_data),
    .write_enable(write_enable),
    .read_data(dmem_read_data)
);

load_formatter load_formatter_inst (
    .dmem_data(dmem_read_data),
    .addr_offset(alu_result[1:0]),
    .funct3(funct3),
    .load_data(load_data),
    .misaligned(load_misaligned)
);


store_formatter store_formatter_inst (
    .addr(alu_result),
    .funct3(funct3),
    .rd2(rd2),
    .store_en(store_en),
    .store_data(store_data),
    .write_enable(write_enable),
    .misaligned(misaligned)
);

branch_unit branch_unit_inst (
    .rd1(rd1),
    .rd2(rd2),
    .funct3(funct3),
    .branch_taken(branch_taken)
);

endmodule
