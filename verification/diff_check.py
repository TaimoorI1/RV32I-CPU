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

with open("retire_trace.txt", "r") as trace_file:
    for line in trace_file:
        if not line.startswith("RETIRE "):
            continue

        record = parse_retire_line(line)

        instr = record.instr
        opcode = instr & 0x7F

        print(hex(opcode))
        break



