typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instr;
    logic        valid;
} ifid_t;

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instr;
    logic        valid;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [31:0] rd1;
    logic [31:0] rd2;
    logic [4:0]  rd;
    logic [2:0]  funct3;
    logic [31:0] imm;
    logic        reg_write;
    logic        alu_src;
    logic [3:0]  alu_control;
    logic [2:0]  wb_select;
    logic        store_en;
    logic        branch;
    logic        jump;
    logic        jump_reg;
    logic        illegal;
} idex_t;

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instr;
    logic        valid;
    logic        illegal;

    logic [4:0]  rd;
    logic        reg_write;
    logic [2:0]  wb_select;

    logic [31:0] alu_result;
    logic [31:0] store_data;
    logic [3:0]  write_enable;
    
    logic [2:0]  funct3;
    logic [31:0] imm;
    logic [31:0] pc_relative_target;
    logic [31:0] next_pc;
    logic [31:0] pc_plus_4;
} exmem_t;

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instr;
    logic        valid;
    logic        illegal;

    logic [4:0]  rd;
    logic        reg_write;
    logic [31:0] wb_data;

    logic [31:0] next_pc;

    logic [3:0]  write_enable;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
} memwb_t;

module cpu_pipe (
    input clk,
    input reset,
    output illegal,

    output reg retire_valid,
    output reg [31:0] retire_pc,
    output reg [31:0] retire_instr,

    output reg retire_rd_we,
    output reg [4:0] retire_rd_addr,
    output reg [31:0] retire_rd_data,

    output reg retire_mem_we,
    output reg [3:0] retire_mem_wmask,
    output reg [31:0] retire_mem_addr,
    output reg [31:0] retire_mem_wdata,

    output reg [31:0] retire_next_pc
);

wire [31:0] if_instr;
wire [6:0] opcode;
wire [4:0] rd, rs1, rs2;
wire [2:0] funct3;
wire [6:0] funct7;
wire [31:0] imm;
wire [31:0] rd1, rd2;
wire [31:0] id_rd1;
wire [31:0] id_rd2;
wire [31:0] alu_result;
wire [31:0] if_pc;
wire [31:0] next_pc;
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

ifid_t ifid;
idex_t idex;
exmem_t exmem;
memwb_t memwb;

wire instr_valid;
assign instr_valid = !reset;

assign pc_relative_target = idex.pc + idex.imm; 
assign jalr_target = {alu_result[31:1], 1'b0};

assign redirect_valid = idex.valid && !idex.illegal && ((idex.branch & branch_taken) | idex.jump);
assign redirect_target = idex.jump_reg ? jalr_target : pc_relative_target;

assign reg_write_final = (exmem.reg_write && !(exmem.wb_select == 3'b001 && load_misaligned) && exmem.valid && !exmem.illegal);

wire [31:0] pc_plus_4;
assign pc_plus_4 = idex.pc + 4;

assign next_pc = redirect_valid ? redirect_target : pc_plus_4;

logic flush;
assign flush = redirect_valid;

logic stall;
assign stall = idex.valid && idex.reg_write && idex.rd != 0 && (idex.rd == rs1 || idex.rd == rs2);


// PC sends byte address to imem, imem outputs the instruction
fetch fetch_inst (
    .clk(clk),
    .reset(reset),
    .pc(if_pc),
    .redirect_target(redirect_target),
    .stall(stall),
    .redirect_valid(redirect_valid),
    .instr(if_instr)
);

always_ff @(posedge clk) begin
    if (reset)
        ifid <= '0;
    else if (flush)
        ifid <= '0;
    else if (stall)
        ifid <= ifid;
    else
        ifid <= {if_pc, if_instr, instr_valid};
end

// instruction goes to decode, which deconstructs rs1, rs2, rd, imm
decode decode_inst (
    .instr(ifid.instr),
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
    (exmem.wb_select == 2'b00) ? exmem.alu_result : 
    (exmem.wb_select == 2'b01) ? load_data : 
    (exmem.wb_select == 2'b10) ? exmem.pc_plus_4 : 
    (exmem.wb_select == 3'b011) ? exmem.imm :
    (exmem.wb_select == 3'b100) ? exmem.pc_relative_target : 32'b0;


// regfile reads rs1/rs2, outputs rd1, rd2
regfile regfile_inst (
    .clk(clk),
    .ra1(rs1),
    .ra2(rs2),
    .wa(memwb.rd),
    .wd(memwb.wb_data),
    .we(memwb.reg_write),
    .rd1(rd1),
    .rd2(rd2)
);

assign id_rd1 =
    (reg_write_final && exmem.rd == rs1 && exmem.rd != 0) ? wb_data :
    (memwb.reg_write && memwb.rd == rs1 && memwb.rd != 0) ? memwb.wb_data :
    rd1;

assign id_rd2 =
    (reg_write_final && exmem.rd == rs2 && exmem.rd != 0) ? wb_data :
    (memwb.reg_write && memwb.rd == rs2 && memwb.rd != 0) ? memwb.wb_data :
    rd2;


// ALU computes, result written back to rd at clock edge
wire [31:0] alu_b = idex.alu_src ? idex.imm : idex.rd2;

alu alu_inst (
    .a(idex.rd1),
    .b(alu_b),
    .alu_op(idex.alu_control),
    .result(alu_result),
    .zero(zero)
);

imm_gen imm_gen_inst (
    .instr(ifid.instr),
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

    always_ff @(posedge clk) begin
        if (reset)
            idex <= '0;
        else if (flush)
            idex <= '0;
        else if (stall)
            idex <= '0;
        else begin
            idex.pc <= ifid.pc;
            idex.instr <= ifid.instr;
            idex.valid <= ifid.valid;
            idex.rs1 <= rs1;
            idex.rs2 <= rs2;
            idex.rd1 <= id_rd1;
            idex.rd2 <= id_rd2;
            idex.rd <= rd;
            idex.funct3 <= funct3;
            idex.imm <= imm;
            idex.reg_write <= reg_write;
            idex.alu_src <= alu_src;
            idex.alu_control <= alu_control;
            idex.wb_select <= wb_select;
            idex.store_en <= store_en;
            idex.branch <= branch;
            idex.jump <= jump;
            idex.jump_reg <= jump_reg;
            idex.illegal <= illegal;
    end
    end


dmem dmem_inst (
    .clk(clk),
    .addr(exmem.alu_result), 
    .store_data(exmem.store_data),
    .write_enable(exmem.write_enable),
    .read_data(dmem_read_data)
);

always_ff @(posedge clk) begin
    if (reset)
        exmem <= '0;
    else begin
        exmem.pc <= idex.pc;
        exmem.instr <= idex.instr;
        exmem.valid <= idex.valid;
        exmem.illegal <= idex.illegal;

        exmem.rd <= idex.rd;
        exmem.reg_write <= idex.reg_write;
        exmem.wb_select <= idex.wb_select;


        exmem.alu_result <= alu_result;
        exmem.store_data <= store_data;
        exmem.write_enable <= write_enable;

        exmem.funct3 <= idex.funct3;
        exmem.imm <= idex.imm;
        exmem.pc_relative_target <= pc_relative_target;
        exmem.next_pc <= next_pc;
        exmem.pc_plus_4 <= pc_plus_4;
    end
end


load_formatter load_formatter_inst (
    .dmem_data(dmem_read_data),
    .addr_offset(exmem.alu_result[1:0]),
    .funct3(exmem.funct3),
    .load_data(load_data),
    .misaligned(load_misaligned)
);


store_formatter store_formatter_inst (
    .addr(alu_result),
    .funct3(idex.funct3),
    .rd2(idex.rd2),
    .store_en(idex.store_en && idex.valid && !idex.illegal),
    .store_data(store_data),
    .write_enable(write_enable),
    .misaligned(misaligned)
);

branch_unit branch_unit_inst (
    .rd1(idex.rd1),
    .rd2(idex.rd2),
    .funct3(idex.funct3),
    .branch_taken(branch_taken)
);

always @(posedge clk) begin
    if 
        (reset || !exmem.valid || exmem.illegal) begin
        retire_valid <= 1'b0;
        retire_rd_we <= 1'b0;
        retire_mem_we <= 1'b0;
        end
    else begin
        retire_valid <= 1'b1;
        retire_pc <= exmem.pc;
        retire_instr <= exmem.instr;
        retire_next_pc <= exmem.next_pc;

        retire_rd_we <= reg_write_final && (exmem.rd != 5'd0);
        retire_rd_addr <= exmem.rd;
        retire_rd_data <= wb_data;

        retire_mem_we <= |exmem.write_enable;
        retire_mem_wmask <= exmem.write_enable;
        retire_mem_addr <= exmem.alu_result;
        retire_mem_wdata <= exmem.store_data;

    end

end

always_ff @(posedge clk) begin
    if (reset)
        memwb <= '0;
    else begin
        memwb.pc <= exmem.pc;
        memwb.instr <= exmem.instr;
        memwb.valid <= exmem.valid;
        memwb.illegal <= exmem.illegal;

        memwb.rd <= exmem.rd;
        memwb.reg_write <= reg_write_final;
        memwb.wb_data <= wb_data;

        memwb.next_pc <= exmem.next_pc;
        memwb.write_enable <= exmem.write_enable;

        memwb.mem_wdata <= exmem.store_data;
        memwb.mem_addr <= exmem.alu_result;
    
    end
end



endmodule
