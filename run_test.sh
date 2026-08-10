#!/bin/sh
set -e

# test 1: control unit

iverilog -o control_test \
    control/control_tb.v \
    control/control.v

vvp control_test > control_result.txt
cat control_result.txt


# test 2: full CPU

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
    dmem/dmem.v

vvp cpu_test > cpu_result.txt
cat cpu_result.txt


# test 3: immediate generator

iverilog -o imm_gen_test \
    decode/imm_gen.v \
    decode/imm_gen_tb.v

vvp imm_gen_test > imm_gen_result.txt
cat imm_gen_result.txt


# verdict

if grep -q "FAIL" control_result.txt cpu_result.txt imm_gen_result.txt; then
    echo "REGRESSION FAILED"
    exit 1
fi

echo "REGRESSION PASSED"