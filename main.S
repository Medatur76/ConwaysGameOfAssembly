.intel_syntax noprefix
.bss
//.align 8
forwardBuffer:
    .zero 8
rearBuffer:
    .zero 8
headerBuffer:
    .zero 8
.text
.global _start
//Default state 10 x 10
_start:
    mov rax, 9
    xor rdi, rdi
    mov rsi, 13
    mov rdx, 0x03
    mov r10, 0x22
    mov r8, -1
    xor r9, r9
    syscall
    mov qword ptr [forwardBuffer], rax

    mov rax, 9
    xor rdi, rdi
    mov rsi, 13
    mov rdx, 0x03
    mov r10, 0x22
    mov r8, -1
    xor r9, r9
    syscall
    mov qword ptr [rearBuffer], rax

    mov rax, 9
    xor rdi, rdi
    //Calculate this later
    mov rsi, 2
    mov rdx, 0x03
    mov r10, 0x22
    mov r8, -1
    xor r9, r9
    syscall
    mov qword ptr [headerBuffer], rax

    mov dword ptr [headerBuffer], 0x2020

    mov rax, 1
    mov rdi, 1
    lea rsi, initMessage
    lea rdx, initMesLen
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, headerBuffer
    mov rdx, 2
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, title
    lea rdx, titleLen
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, headerBuffer
    mov rdx, 2
    syscall

_loop:

    mov rsi, qword ptr [forwardBuffer]
    mov rdi, qword ptr [rearBuffer]
    mov rcx, 13
    rep movsq

    mov rax, 7
    lea rdi, fds
    mov rsi, 1
    mov rdx, 100
    syscall

    test rax, rax
    //js error
    jz _loop

    xor rax, rax
    xor rdi, rdi
    lea rsi, forwardBuffer
    mov rdx, 1
    syscall

    mov rax, 11
    lea rdi, forwardBuffer
    mov rsi, 13
    syscall

    mov rax, 11
    lea rdi, rearBuffer
    mov rsi, 13
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, exitMessage
    lea rdx, exitMesLen
    syscall

    mov rax, 0x3c
    xor rdi, rdi
    syscall

    ud2
.data
initMessage: 
    .ascii "\x1b[?1049h\x1b[?25l\x1b[3J\x1b[2J\x1b[H"
.set initMesLen, . - initMessage
exitMessage:
    .ascii "\x1b[3J\x1b[2J\x1b[H\x1b[?25h\x1b[?1049l"
.set exitMesLen, . - exitMessage
fds:
    .int 0
    .word 0x0001
    .word 0
title:
    .ascii "Kiernan's Game of Assembly"
.set titleLen, . - title
