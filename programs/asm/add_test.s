.section .text
.globl _start

_start:
    addi x1, x0, 7
    addi x2, x0, 5
    add x3, x1, x2
    

halt:
    beq x0, x0, halt
    