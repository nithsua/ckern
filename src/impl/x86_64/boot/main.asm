global start
extern framebuffer_request

section .text
bits 64
start:
    cli

    mov rax, framebuffer_request
    mov rax, [rax + 40]        ; response offset
    test rax, rax
    jz .hang

    mov rbx, [rax + 16]        ; framebuffers array
    mov rbx, [rbx]             ; first framebuffer
    mov rdi, [rbx]             ; fb address
    mov rcx, [rbx + 24]        ; pitch

    ; Fill 100x100 green square
    mov r9, 100
.row:
    mov rsi, rdi
    mov r8, 100
.col:
    mov dword [rsi], 0x0000FF00
    add rsi, 4
    dec r8
    jnz .col
    add rdi, rcx
    dec r9
    jnz .row

.hang:
    cli
    hlt
    jmp .hang
