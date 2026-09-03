SOURCES = $(wildcard programs/asm/*.s)
HEXES = $(SOURCES:.s=.hex)

hex: $(HEXES)

programs/asm/%.hex: programs/asm/%.s
	riscv64-elf-as -march=rv32i -mabi=ilp32 -o $(@:.hex=.o) $<
	riscv64-elf-ld -m elf32lriscv -Ttext=0x0 -o $(@:.hex=.elf) $(@:.hex=.o)
	riscv64-elf-objcopy -O verilog --verilog-data-width=4 -j .text $(@:.hex=.elf) $@