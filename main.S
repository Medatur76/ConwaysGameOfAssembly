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
_getNeighbors:
    mov x0, xzr
    mov x1, #-1
_loop6:
    add x3, x1, x12
    cmp x3, #0
    b.lt _loop6c
    mov x4, h
    sub x4, x4, #1
    cmp x3, x4
    b.gt _loop6c
    mov x2, #-1
_loop7:
    add x4, x2, x9
    cmp x1, #0
    b.ne _loop7c2
    cmp x2, #0
    b.eq _loop7c
_loop7c2:
    cmp x4, #0
    b.lt _loop7c
    mov x13, w
    sub x13, x13, #1
    cmp x4, x13
    b.gt _loop7c
    mov x13, w
    madd x14, x3, x13, x4
    mov x4, #8
    udiv x4, x14, x4
    and x5, x14, #7
    mov x13, #1
    lsl x5, x13, x5
    adrp x13, displayBuff
    ldr x14, [x13, :lo12:displayBuff]
    add x4, x4, x14
    ldrb w4, [x4]
    and w4, w4, w5
    cmp w4, #0
    cinc X0, X0, ne
_loop7c:
    add x2, x2, #1
    cmp x2, #2
    b.ne _loop7
_loop6c:
    add x1, x1, #1
    cmp x1, #2
    b.ne _loop6
    ret
//This bit its AI but I rewrote it cuz its 11 and im tired
_memcpy:
    adrp x1, procBuff
    ldr x0, [x1, :lo12:procBuff]
    adrp x2, displayBuff
    ldr x1, [x2, :lo12:displayBuff]
    mov x2, #13
_loop8:
    cmp x2, #16
    b.lt _loop9c
    // Load 16 bytes from src (x0), then increment x0 by 16
    ldr q0, [x0], #16
    // Store 16 bytes to dst (x1), then increment x1 by 16
    str q0, [x1], #16
    sub x2, x2, #16
    b _loop8
_loop9c:
    cbnz x2, _loop9
    ret
_loop9:
    // Copy remaining individual trailing bytes (1 to 15 bytes)
    ldrb w3, [x0], #1
    strb w3, [x1], #1
    sub x2, x2, #1
    b _loop9c
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
    mov w1, #2
    strb w1, [x0]
    mov w1, #16
    strb w1, [x0, #1]
    mov w1, #112
    strb w1, [x0, #2]
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
    bl _memcpy
    mov x6, h
    mov x7, #2
    udiv x6, x6, x7
    mov x7, xzr
_loop4:
    mov x9, xzr
_loop5:
    mov x11, #2
    mul x10, x7, x11
    mov x11, w
    madd x10, x10, x11, x9
    adrp x1, displayBuff
    ldr x0, [x1, :lo12:displayBuff]
    mov x1, #8
    udiv x1, x10, x1
    add x1, x1, x0
    ldr x0, [x1]
    and x1, x10, #7
    mov x2, #1
    lsl x1, x2, x1
    and x0, x0, x1
    cmp x0, 0
    mov x2, #2
    csel x11, x2, xzr, ne
    adrp x1, displayBuff
    ldr x0, [x1, :lo12:displayBuff]
    mov x12, w
    add x12, x12, x10
    mov x1, #8
    udiv x1, x12, x1
    add x1, x1, x0
    ldr x0, [x1]
    and x1, x12, #7
    mov x2, #1
    lsl x1, x2, x1
    and x0, x0, x1
    cmp x0, 0
    cinc x11, x11, ne
    cmp x11, #3
    b.ne _b1
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 26
    mov x2, #3
    svc 0
    b _b4
_b1:
    cmp x11, #2
    b.ne _b2
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 29
    mov x2, #3
    svc 0
    b _b4
_b2:
    cbz x11, _b3
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 32
    mov x2, #3
    svc 0
    b _b4
_b3:
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 25
    mov x2, #1
    svc 0
_b4:
    mov x12, #2
    mul x12, x12, x7
    bl _getNeighbors
    and x12, x11, #2
    cmp x12, #0
    b.ne _b5
    cmp x0, #3
    b.ne _b7
    b _b6
_b5:
    cmp x0, #2
    b.lt _b6
    cmp x0, #3
    b.le _b7
_b6:
    adrp x1, procBuff
    ldr x0, [x1, :lo12:procBuff]
    mov x1, #8
    udiv x1, x10, x1
    add x0, x0, x1
    and x1, x10, #7
    mov x2, #1
    lsl x1, x2, x1
    ldrb w2, [x0]
    eor w1, w2, w1
    strb w1, [x0]
_b7:
    mov x12, #2
    //Can this be one line?
    mul x12, x12, x7
    add x12, x12, #1
    cmp x12, h
    b.ge _b10
    mov x1, w
    add x10, x10, x1
    bl _getNeighbors
    and x12, x11, #1
    cmp x12, #0
    b.ne _b8
    cmp x0, #3
    b.ne _b10
    b _b9
_b8:
    cmp x0, #2
    b.lt _b9
    cmp x0, #3
    b.le _b10
_b9:
    adrp x1, procBuff
    ldr x0, [x1, :lo12:procBuff]
    mov x1, #8
    udiv x1, x10, x1
    add x0, x0, x1
    and x1, x10, #7
    mov x2, #1
    lsl x1, x2, x1
    ldrb w2, [x0]
    eor w1, w2, w1
    strb w1, [x0]
_b10:
    add x9, x9, #1
    cmp x9, w
    b.lt _loop5
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 35
    mov x2, #8
    svc 0
    add x7, x7, #1
    cmp x7, x6
    b.lt _loop4
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 19
    mov x2, #6
    svc 0
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
w = 10
fds:
    .word 0
    .word 1
time:
    .dword 0
    .dword 150000000
