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
wire [3:0] alu_control;
wire mem_write; 
wire [31:0] dmem_read_data;
wire mem_to_reg;
wire zero;
wire [31:0] branch_target;
wire take_branch;
wire branch;


// PC sends byte address to imem, imem outputs the instruction
fetch fetch_inst (
    .clk(clk),
    .reset(reset),
    .pc(pc),
    .branch_target(branch_target),
    .take_branch(take_branch),
    .instr(instr)
);

assign branch_target = pc + imm;
assign take_branch = branch & zero;


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
wire [31:0] wb_data = mem_to_reg ? dmem_read_data : alu_result;

// regfile reads rs1/rs2, outputs rd1, rd2
regfile regfile_inst (
    .clk(clk),
    .ra1(rs1),
    .ra2(rs2),
    .wa(rd),
    .wd(wb_data),
    .we(reg_write),
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
    .funct7_5(funct7[5]),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .alu_control(alu_control),
    .mem_to_reg(mem_to_reg),
    .mem_write(mem_write),
    .branch(branch),
    .illegal(illegal)
);

dmem dmem_inst (
    .clk(clk),
    .addr(alu_result), 
    .write_data(rd2),
    .mem_write(mem_write),
    .read_data(dmem_read_data)
);

endmodule
