from dataclasses import dataclass


@dataclass
class RetireRecord:
    pc: int
    instr: int
    next_pc: int

    rd_we: bool
    rd: int
    rd_data: int

    mem_we: bool
    mem_mask: int
    mem_addr: int
    mem_data: int


def parse_retire_line(line):
    parts = line.split()

    fields = {}

    for field in parts[1:]:
        name, value = field.split("=")
        fields[name] = value

    record = RetireRecord(
        pc=int(fields["pc"], 16),
        instr=int(fields["instr"], 16),
        next_pc=int(fields["next_pc"], 16),

        rd_we=bool(int(fields["rd_we"])),
        rd=int(fields["rd"], 16),
        rd_data=int(fields["rd_data"], 16),

        mem_we=bool(int(fields["mem_we"])),
        mem_mask=int(fields["mem_mask"], 16),
        mem_addr=int(fields["mem_addr"], 16),
        mem_data=int(fields["mem_data"], 16),
    )

    return record

regs = [0] * 32
pc = 0
memory = {}

def signed32(value):
            if value & 0x80000000:
                return value - 0x100000000
            return value


with open("retire_trace.txt", "r") as trace_file:
    for line in trace_file:
        if not line.startswith("RETIRE "):
            continue

        record = parse_retire_line(line)

        instr = record.instr
        opcode = instr & 0x7F
        rd = (instr >> 7) & 0x1F
        funct3 = (instr >> 12) & 0x7
        funct7 = (instr >> 25) & 0x7F
        rs1 = (instr >> 15) & 0x1F
        rs2 = (instr >> 20) & 0x1F

        raw_imm12 = (instr >> 20) & 0xFFF
        imm12 = raw_imm12

        imm_11_5 = (instr >> 25) & 0x7F
        imm_4_0 = (instr >> 7) & 0x1F
        store_imm = (imm_11_5 << 5) | imm_4_0

        branch_imm_12 = (instr >> 31) & 0x1
        branch_imm_11 = (instr >> 7) & 0x1
        branch_imm_10_5 = (instr >> 25) & 0x3F
        branch_imm_4_1 = (instr >> 8) & 0xF

        jal_imm_20 = (instr >> 31) & 0x1
        jal_imm_10_1 = (instr >> 21) & 0x3FF
        jal_imm_11 = (instr >> 20) & 0x1
        jal_imm_19_12 = (instr >> 12) & 0xFF

        branch_imm = (
            (branch_imm_12 << 12)
            | (branch_imm_11 << 11)
            | (branch_imm_10_5 << 5)
            | (branch_imm_4_1 << 1)
        )

        jal_imm = (
            (jal_imm_20 << 20)
            | (jal_imm_19_12 << 12)
            | (jal_imm_11 << 11)
            | (jal_imm_10_1 << 1)
        )

        if store_imm & 0x800:
            store_imm -= 0x1000

        if branch_imm & 0x1000:
            branch_imm -= 0x2000

        if jal_imm & 0x100000:
            jal_imm -= 0x200000

        shamt = raw_imm12 & 0x1F
        shift_type = (raw_imm12 >> 5) & 0x7F

        if imm12 & 0x800:
            imm12 -= 0x1000

        if opcode == 0x13 and funct3 == 0x0:
            expected_rd_data = (regs[rs1] + imm12) & 0xFFFFFFFF
            instr_name = "ADDI"
            
        elif opcode == 0x33 and funct3 == 0x4 and funct7 == 0x00:
            expected_rd_data = (regs[rs1] ^ regs[rs2]) & 0xFFFFFFFF
            instr_name = "XOR"

        elif opcode == 0x33 and funct3 == 0x2 and funct7 == 0x00:
            expected_rd_data = 1 if signed32(regs[rs1]) < signed32(regs[rs2]) else 0
            instr_name = "SLT"

        elif opcode == 0x13 and funct3 == 0x5 and shift_type == 0x20:
            expected_rd_data = (signed32(regs[rs1]) >> shamt) & 0xFFFFFFFF
            instr_name = "SRAI"

        elif opcode == 0x23 and funct3 == 0x2:
            expected_mem_we = True
            expected_mem_mask = 0xF
            expected_mem_addr = (regs[rs1] + store_imm) & 0xFFFFFFFF
            expected_mem_data = regs[rs2]
            instr_name = "SW"

        elif opcode == 0x03 and funct3 == 0x2:
            expected_addr = (regs[rs1] + imm12) & 0xFFFFFFFF

            expected_rd_data = (
                memory.get(expected_addr, 0)
                | (memory.get(expected_addr + 1, 0) << 8)
                | (memory.get(expected_addr + 2, 0) << 16)
                | (memory.get(expected_addr + 3, 0) << 24)
            )

            expected_rd_data &= 0xFFFFFFFF
            instr_name = "LW" 

        elif opcode == 0x63:
            if funct3 == 0x0:
                branch_taken = regs[rs1] == regs[rs2]
                instr_name = "BEQ"

            elif funct3 == 0x1:
                branch_taken = regs[rs1] != regs[rs2]
                instr_name = "BNE"

            elif funct3 == 0x4:
                branch_taken = signed32(regs[rs1]) < signed32(regs[rs2])
                instr_name = "BLT"

            elif funct3 == 0x5:
                branch_taken = signed32(regs[rs1]) >= signed32(regs[rs2])
                instr_name = "BGE"

            elif funct3 == 0x6:
                branch_taken = regs[rs1] < regs[rs2]
                instr_name = "BLTU"

            elif funct3 == 0x7:
                branch_taken = regs[rs1] >= regs[rs2]
                instr_name = "BGEU"

            else:
                print("Unsupported branch:", hex(instr))
                break

            if branch_taken:
                expected_next_pc = (record.pc + branch_imm) & 0xFFFFFFFF
            else:
                expected_next_pc = (record.pc + 4) & 0xFFFFFFFF

        elif opcode == 0x6F:
            expected_rd_data = (record.pc + 4) & 0xFFFFFFFF
            expected_next_pc = (record.pc + jal_imm) & 0xFFFFFFFF
            instr_name = "JAL"

        elif opcode == 0x67 and funct3 == 0x0:
            expected_rd_data = (record.pc + 4) & 0xFFFFFFFF
            expected_next_pc = (regs[rs1] + imm12) & 0xFFFFFFFF
            expected_next_pc &= ~1
            instr_name = "JALR"

        else:
            print("Unsupported instruction:", hex(instr))
            break

        if instr_name == "SW":
            if expected_mem_we != record.mem_we:
                print("MEM_WE MISMATCH")
                print("expected:", expected_mem_we)
                print("actual:  ", record.mem_we)
                break

            if expected_mem_mask != record.mem_mask:
                print("MEM_MASK MISMATCH")
                print("expected:", hex(expected_mem_mask))
                print("actual:  ", hex(record.mem_mask))
                break

            if expected_mem_addr != record.mem_addr:
                print("MEM_ADDR MISMATCH")
                print("expected:", hex(expected_mem_addr))
                print("actual:  ", hex(record.mem_addr))
                break

            if expected_mem_data != record.mem_data:
                print("MEM_DATA MISMATCH")
                print("expected:", hex(expected_mem_data))
                print("actual:  ", hex(record.mem_data))
                break

            memory[expected_mem_addr] = expected_mem_data & 0xFF
            memory[expected_mem_addr + 1] = (expected_mem_data >> 8) & 0xFF
            memory[expected_mem_addr + 2] = (expected_mem_data >> 16) & 0xFF
            memory[expected_mem_addr + 3] = (expected_mem_data >> 24) & 0xFF

        elif opcode == 0x63:
            if expected_next_pc != record.next_pc:
                print("NEXT_PC MISMATCH")
                print("instruction:", instr_name)
                print("pc:      ", hex(record.pc))
                print("expected:", hex(expected_next_pc))
                print("actual:  ", hex(record.next_pc))
                break

        elif instr_name == "JAL" or instr_name == "JALR":
            if expected_rd_data != record.rd_data:
                print("RD_DATA MISMATCH")
                print("expected:", hex(expected_rd_data))
                print("actual:  ", hex(record.rd_data))
                break

            if expected_next_pc != record.next_pc:
                print("NEXT_PC MISMATCH")
                print("expected:", hex(expected_next_pc))
                print("actual:  ", hex(record.next_pc))
                break

            if rd != 0:
                regs[rd] = expected_rd_data

        else:
            if expected_rd_data != record.rd_data:
                print("MISMATCH")
                print("expected:", hex(expected_rd_data))
                print("actual:  ", hex(record.rd_data))
                break

            if rd != 0:
                regs[rd] = expected_rd_data
        
        print(instr_name, "passed:", hex(instr))






