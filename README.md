# RV32I CPU

An RV32I CPU built in Verilog.

It started as a way for me to understand how modern proprietary processors work beneath the software layer, and has grown into a working CPU with an increasingly rigorous verification setup.

## What works

The CPU currently supports the main RV32I integer instruction types:

- arithmetic and logical operations
- immediate operations
- signed and unsigned loads
- byte, halfword, and word stores
- conditional branches
- `JAL` and `JALR`
- `LUI` and `AUIPC`
- `FENCE` as a no-op

Unsupported instruction encodings are detected as illegal and prevented from causing register, memory, branch, or jump side effects.

The design is split into individual modules for the ALU, control unit, register file, instruction and data memory, immediate generation, load/store formatting, branching, and instruction fetch.

## Verification

The CPU is tested using self-checking Verilog testbenches at both the component and full-CPU level.

The control unit is exhaustively tested across all **131,072** possible `opcode`, `funct3`, and `funct7` combinations. The sweep checks whether each encoding is accepted or rejected correctly and verifies that illegal instructions cannot create architectural side effects.

Assembly test programs are compiled into instruction-memory images and executed on the full CPU.

The CPU also exposes an architectural retirement trace containing:

- PC and instruction
- next PC
- register writeback
- memory write enable and byte mask
- memory address and write data

A Python reference model parses this trace and independently tracks architectural register and memory state. The CPU's retired behavior can then be checked instruction by instruction against the model.

The differential checker is currently being extended across the full implemented instruction set.

## Running the tests

Requires:

- Icarus Verilog
- GNU Make
- RISC-V GNU binutils

From the repository root:

```bash
sh run_test.sh
```