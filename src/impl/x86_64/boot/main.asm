global start
extern kernel_main

section .text
bits 64
start:
    cli
    and rsp, -16
    call kernel_main
.hang:
    cli
    hlt
    jmp .hang
