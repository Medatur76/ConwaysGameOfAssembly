.section .bss
.align 8
displayBuff:
    .zero 8
procBuff:
    .zero 8
.section .text
.globl _start
_loop1:
    mov x0, 1
    adr x1, charLib
    mov x2, 3
    svc 0
    subs x6, x6, #1
    b.ne _loop1
    ret
_start:
    mov x8, 0xDE
    mov x0, 0
    mov x1, #13
    mov x2, #3
    mov x3, 0x22
    mov x4, #-1
    mov x5, 0
    svc 0
    adrp x1, displayBuff
    str x0, [x1, :lo12:displayBuff]
    mov x8, 0xDE
    mov x0, 0
    mov x1, #13
    svc 0
    adrp x1, procBuff
    str x0, [x1, :lo12:procBuff]
    mov x8, 0x40
    mov x0, #1
    adr x1, intro
    mov x2, introLen
    svc 0
    mov x6, w
    bl _loop1
    mov x0, #1
    adr x1, charLib + 8
    mov x2, #5
    svc 0
    mov x7, h
    mov x6, #2
    udiv x7, x7, x6
    mov x6, h
    mov x0, #1
    and x6, x6, x0
    add x7, x7, x6
_loop2:
    mov x0, #1
    adr x1, charLib + 3
    mov x2, #3
    svc 0
    mov x6, w
_loop3:
    mov x0, #1
    adr x1, charLib + 25
    mov x2, #1
    svc 0
    subs x6, x6, #1
    b.ne _loop3
    mov x0, #1
    adr x1, charLib + 3
    mov x2, #5
    svc 0
    subs x7, x7, #1
    b.ne _loop2
    mov x0, #1
    adr x1, charLib + 13
    mov x2, #3
    svc 0
    mov x6, w
    bl _loop1
    mov x0, #1
    adr x1, charLib + 16
    mov x2, #9
    svc 0
_main_loop:
    ldr x9, time
    ldr x10, time + 8
    stp x9, x10, [sp, #-16]!
    mov x8, 0x49
    adr x0, fds
    mov x1, #1
    mov x2, sp
    mov x3, 0
    mov x4, 0
    svc 0
    cbz x0, _main_loop
_exit:
    mov x8, 0x40
    mov x0, 1
    adr x1, outro
    mov x2, outroLen
    svc 0
    mov x8, 0xD7
    adrp x1, displayBuff
    ldr x0, [x1, :lo12:displayBuff]
    mov x1, #13
    svc 0
    adrp x1, procBuff
    ldr x0, [x1, :lo12:procBuff]
    mov x1, #13
    svc 0
    mov x8, 0x5D
    mov x0, xzr
    svc 0
    brk #0
.section .data
intro:
    .ascii "\x1b[?1049h\x1b[3J\x1b[2J\x1b[H\x1b[?25lKiernan's Game of Assembly\r\n┌"
introLen = . - intro
outro:
    .ascii "\x1b[3J\x1b[2J\x1b[H\x1b[?25h\x1b[?1049l"
outroLen = . - outro
charLib:
    .ascii "─│\r\n┐\r\n└┘\x1b[3;2f █▀▄\x1b[1B\x1b[2G"
h = 10
w = 11
fds:
    .word 0
    .word 1
time:
    .dword 0
    .dword 150000000
