.section .text
.globl _start

_start:
    addi x1, x0, 10
    addi x2, x0, 20
    addi x3, x0, 30
    xor x4, x1, x2
    slt x5, x1, x2
    addi x6, x0, -8
    srai x7, x6, 1
    sw x1, 0(x2)
    lw x8, 0(x2)
    addi x9, x0, 3
    addi x10, x0, 0
    addi x11, x0, 0

loop:
    addi x10, x10, 10
    addi x9, x9, -1
    beq x9, x11, done
    beq x0, x0, loop

done:
    addi x12, x0, 99
    addi x14, x0, 55

    jal x13, jal_target
    addi x14, x0, 111
    addi x14, x0, 222

jal_target:
    addi x15, x0, 77
    addi x16, x0, 108
    addi x18, x0, 66
    jalr x17, 1(x16)
    addi x18, x0, 111
    addi x18, x0, 222

    addi x19, x0, 88
    lui x20, 0x12345
    auipc x21, 0x1
    andi x22, x1, 6
    ori x23, x1, 5
    xori x24, x1, 15
    slti x25, x6, 1
    sltiu x26, x6, 1
    slli x27, x1, 3
    srli x28, x6, 2
    sb x15, 1(x2)
    sh x20, 2(x2)
    lb x29, 7(x2)
    lh x30, 6(x2)
    lbu x31, 7(x2)
    lhu x11, 6(x2)
    lh x12, 5(x2)

    .word 0x000000FF

halt:
    beq x0, x0, halt
    