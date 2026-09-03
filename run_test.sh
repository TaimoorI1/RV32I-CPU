#!/bin/sh
set -e

# test 1: control unit

iverilog -o control_test \
    control/control_tb.v \
    control/control.v

vvp control_test > control_result.txt
cat control_result.txt

# test 2: immediate generator

iverilog -o imm_gen_test \
    decode/imm_gen.v \
    decode/imm_gen_tb.v

vvp imm_gen_test > imm_gen_result.txt
cat imm_gen_result.txt

# test 3: data memory

iverilog -o dmem_test \
    dmem/dmem_tb.v \
    dmem/dmem.v

vvp dmem_test > dmem_result.txt
cat dmem_result.txt


# test 4: store formatter

iverilog -o store_formatter_test \
    dmem/store_formatter_tb.v \
    dmem/store_formatter.v

vvp store_formatter_test > store_formatter_result.txt
cat store_formatter_result.txt

# test 5: load formatter

iverilog -o load_formatter_test \
    dmem/load_formatter_tb.v \
    dmem/load_formatter.v

vvp load_formatter_test > load_formatter_result.txt
cat load_formatter_result.txt

# test 6: branch

iverilog -o branch_unit_test \
    branch/branch_unit_tb.v \
    branch/branch_unit.v

vvp branch_unit_test > branch_unit_result.txt
cat branch_unit_result.txt

# test 7: CPU branch integration

iverilog -o cpu_branch_test \
    cpu/cpu_branch_tb.v \
    cpu/cpu.v \
    fetch/fetch.v \
    pc/pc.v \
    imem/imem.v \
    decode/decode.v \
    decode/imm_gen.v \
    regfile/regfile.v \
    alu/alu.v \
    control/control.v \
    dmem/dmem.v \
    dmem/store_formatter.v \
    dmem/load_formatter.v \
    branch/branch_unit.v

vvp cpu_branch_test > cpu_branch_result.txt
cat cpu_branch_result.txt

make hex

# test 8: full CPU

iverilog -o cpu_test \
    cpu/cpu_tb.v \
    cpu/cpu.v \
    fetch/fetch.v \
    pc/pc.v \
    imem/imem.v \
    decode/decode.v \
    decode/imm_gen.v \
    regfile/regfile.v \
    alu/alu.v \
    control/control.v \
    dmem/dmem.v \
    dmem/store_formatter.v \
    dmem/load_formatter.v \
    branch/branch_unit.v

vvp cpu_test > cpu_result.txt
cat cpu_result.txt

# verdict

if grep -q "FAIL" \
    control_result.txt \
    imm_gen_result.txt \
    dmem_result.txt \
    store_formatter_result.txt \
    load_formatter_result.txt \
    branch_unit_result.txt \
    cpu_branch_result.txt \
    cpu_result.txt; then

    echo "REGRESSION FAILED"
    exit 1
fi

echo "REGRESSION PASSED"