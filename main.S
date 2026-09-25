.section .bss
.align 8
displayBuff:
    .zero 8
procBuff:
    .zero 8
h:
    .zero 8
w:
    .zero 8
orgTerm:
    .zero 57
bSize:
    .zero 8
.section .text
.globl _start
_loop1: //while (x6) - Simple loop to write out the top and bottom outline of the box
    mov x0, 1
    adr x1, charLib
    mov x2, 3
    svc 0 //write(1, "─", 3)
    subs x6, x6, #1 //x6--
    b.ne _loop1 //if (!x6) break;
    ret
_getNeighbors: //Function to get the number of alive neighbors for any given cell
    mov x0, xzr //x0 = n = 0
    mov x1, #-1 //x1 = dy = -1
_loop6: //while (dy < 2)
    add x3, x1, x12 //x3 = dy + y
    cmp x3, #0
    b.lt _loop6c //if (x3 < 0) continue
    adrp x4, h
    ldr x4, [x4, :lo12:h]
    sub x4, x4, #1 //x4 = h - 1
    cmp x3, x4
    b.gt _loop6c //if (x3 > x4) continue
    mov x2, #-1 //x2 = dx = -1
_loop7: //while (dx < 2)
    add x4, x2, x9 //x4 = dx + x
    cmp x1, #0
    b.ne _loop7c2 //if (!dy)
    cmp x2, #0
    b.eq _loop7c //if (dx) continue
_loop7c2:
    cmp x4, #0
    b.lt _loop7c //if ((dx + x) < 0) continue
    adrp x13, w
    ldr x13, [x13, :lo12:w]
    sub x13, x13, #1 //x13 = w - 1
    cmp x4, x13
    b.gt _loop7c //if ((dx + x) > x13) continue
    adrp x13, w
    ldr x13, [x13, :lo12:w]
    madd x14, x3, x13, x4 //x14 = j = (dy + y) * w + (dx + x)
    mov x4, #8
    udiv x4, x14, x4 //x4 = j / 8
    and x5, x14, #7 //x5 = j % 8
    mov x13, #1
    lsl x5, x13, x5 //x5 = 1 << (j % 8)
    adrp x13, displayBuff
    ldr x14, [x13, :lo12:displayBuff] //x14 = displayBuff
    add x4, x4, x14 //x4 = &displayBuff[j / 8]
    ldrb w4, [x4] //w4 = displayBuff[j / 8]
    and w4, w4, w5 //w4 = w4 & (1 << (j % 8))
    cmp w4, #0
    cinc x0, x0, ne //if (w4) x0++
_loop7c:
    add x2, x2, #1
    cmp x2, #2
    b.ne _loop7 //if (x2 == 2) break;
_loop6c:
    add x1, x1, #1
    cmp x1, #2
    b.ne _loop6 //if (x1 == 2) break;
    ret
_memcpy: //memcpy(displayBuff, procBuff, bSize) - This bit its AI but I rewrote it cuz its 11 and im tired. Literally just memcpy
    adrp x1, procBuff
    ldr x0, [x1, :lo12:procBuff] //x0 = procBuff
    adrp x2, displayBuff
    ldr x1, [x2, :lo12:displayBuff] //x1 = displayBuff
    adrp x3, bSize
    add x3, x3, :lo12:bSize
    ldr x2, [x3] //x2 = bSize
_loop8:
    cmp x2, #16
    b.lt _loop9c //if (x2 < 16) break
    ldr q0, [x0], #16 //q0 = x0; x0 += 16
    str q0, [x1], #16 //*x1 = q0; x1 += 16
    sub x2, x2, #16 //x2 -= 16
    b _loop8
_loop9c:
    cbnz x2, _loop9 //if (!x2) return
    ret
_loop9:
    ldrb w3, [x0], #1 //w3 = x0++
    strb w3, [x1], #1 //*x1++ = w3
    sub x2, x2, #1 //x2--
    b _loop9c
_atoi: //x1 = atoi(x0) - Simple string to int function. Pretty self explanitory in my opinion so im not gonna comment it :)
    mov x1, xzr
    mov x3, #10
_loop10:
    mov x2, xzr
    ldrb w2, [x0], #1
    cmp x2, #0
    b.eq _loop10c
    sub x2, x2, #48
    madd x1, x1, x3, x2
    b _loop10
_loop10c:
    ret
_start: //Entry point
    ldr x0, [sp] //x0 = argc
    cmp x0, #2
    b.lt _s3 //if (argc >= 2)
    b.ne _s2 //if (argc == 2)
    ldr x0, [sp, #16] //x0 = argv[1]
    bl _atoi
    adrp x0, h
    add x0, x0, :lo12:h
    str x1, [x0] //h = atoi(argv[1])
    adrp x0, w
    add x0, x0, :lo12:w
    str x1, [x0] //w = atoi(argv[1])
    b _s4
_s2: //if (argc >= 3)
    ldr x0, [sp, #16] //x0 = argv[1]
    bl _atoi
    adrp x0, h
    add x0, x0, :lo12:h
    str x1, [x0] //h = atoi(argv[1])
    ldr x0, [sp, #24] //x0 = argv[2]
    bl _atoi
    adrp x0, w
    add x0, x0, :lo12:w
    str x1, [x0] //w = atoi(argv[2])
    b _s4
_s3: //if (argc < 2)
    adrp x1, h
    add x1, x1, :lo12:h
    mov x0, #24
    str x0, [x1] //h = 24
    adrp x1, w
    add x1, x1, :lo12:w
    mov x0, #40
    str x0, [x1] //w = 40
_s4:
    mov x8, 0x1D
    mov x0, xzr
    mov x1, 0x5401
    adrp x2, orgTerm
    add x2, x2, :lo12:orgTerm
    svc 0 //ioctl(0, TCGETS, &orgTerm) - Retrieve default console state
    sub sp, sp, #64 //sp = struct termios raw - Creating a temporary console configuration for code execution
    adrp x0, orgTerm
    add x0, x0, :lo12:orgTerm //x0 = orgTerm - Loading original terminal state for editing
    ldr w1, [x0]
    mov w2, #-1331
    and w1, w1, w2
    str w1, [sp] //raw.c_iflag &= ~(IXON | ICRNL | BRKINT | INPCK | ISTRIP)
    ldr w1, [x0, #4]
    and w1, w1, #-2
    str w1, [sp, #4] //raw.c_oflag &= ~(OPOST)
    ldr w1, [x0, #8]
    orr w1, w1, #48
    str w1, [sp, #8] //raw.c_cflag |= (CS8)
    ldr w1, [x0, #12]
    mov w2, #-32780
    and w1, w1, w2
    str w1, [sp, #12] //raw.c_lflag &= ~(ECHO | ICANON | ISIG | IEXTEN)
    ldrh w1, [x0, #16]
    strh w1, [sp, #16]
    add x0, x0, #17
    ldp q0, q1, [x0]
    mov w1, #1
    mov v0.b[6], w1 //raw.c_cc[VMIN] = 1  AI
    mov v0.b[5], wzr //raw.c_cc[VTIME] = 0
    str q0, [sp, #17]
    str q1, [sp, #33]
    ldr w1, [x0, #32]
    str w1, [sp, #49]
    ldr w1, [x0, #36]
    str w1, [sp, #53]
    mov x8, 0x1D
    mov x0, xzr
    mov x1, 0x5404
    mov x2, sp
    svc 0 //ioctl(0, TCSETSF, &raw) - Sets the console to the new configuration
    add sp, sp, #64
    adrp x1, w
    ldr x1, [x1, :lo12:w]
    adrp x2, h
    ldr x2, [x2, :lo12:h]
    mul x1, x1, x2 //x1 = w * h
    and x2, x1, #7 //x2 = x1 % 8
    mov x0, #8
    udiv x1, x1, x0 //x1 /= 8
    cmp x2, #0 //if (x2)
    cinc x1, x1, ne //x1++
    adrp x0, bSize
    add x0, x0, :lo12:bSize
    str x1, [x0] //bSize = x1 - Calculating minimum buffer size to fit all cells. Simplifies to (int) ceil(((double) w * h) / 8)
    mov x8, 0xDE
    mov x0, 0
    mov x2, #3
    mov x3, 0x22
    mov x4, #-1
    mov x5, 0
    svc 0
    adrp x1, displayBuff
    str x0, [x1, :lo12:displayBuff] //displayBuff = mmap(NULL, bSize, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0) - Creates the buffer to be used to display the "old state"
    mov x8, 0xDE
    mov x0, 0
    adrp x2, bSize
    add x2, x2, :lo12:bSize
    ldr x1, [x2]
    mov x2, #3
    svc 0
    adrp x1, procBuff
    str x0, [x1, :lo12:procBuff] //procBuff = mmap(NULL, bSize, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0) - Creates the buffer to process the next tick from the "old state"
    mov w1, #2 //This bit till line 175 is a hardcoded begining state for the program. Will be updated later
    strb w1, [x0]
    mov w1, #4
    strb w1, [x0, #5]
    mov w1, #7
    strb w1, [x0, #10]
    mov w1, #64
    strb w1, [x0, #9]
    mov w1, #32
    strb w1, [x0, #14]
    mov w1, #224
    strb w1, [x0, #19]
    mov x8, 0x40
    mov x0, #1
    adr x1, intro
    mov x2, introLen
    svc 0 //write(1, &intro, introLen) - Writes out ANSI console setup + header
    adrp x6, w
    ldr x6, [x6, :lo12:w]
    bl _loop1
    mov x0, #1
    adr x1, charLib + 8
    mov x2, #5
    svc 0 //write(1, "┐\r\n", 5)
    adrp x7, h
    ldr x7, [x7, :lo12:h]
    mov x6, #2
    udiv x7, x7, x6 //x7 = h / 2
    adrp x6, h
    ldr x6, [x6, :lo12:h]
    and x6, x6, #1 //x6 = h % 1
    add x7, x7, x6 //x7 += x6
_loop2: //while (x7) - Given that each character in the console can fix two cells vertically, this loop builds the box to have a terminal height that is half of the number of rows the box can fit
    mov x0, #1
    adr x1, charLib + 3
    mov x2, #3
    svc 0 //write(1, "│", 3)
    adrp x6, w
    ldr x6, [x6, :lo12:w] //x6 = w
_loop3: //while (x6) - Whitespace for where the actual cells will go
    mov x0, #1
    adr x1, charLib + 25
    mov x2, #1
    svc 0 //write(1, " ", 1)
    subs x6, x6, #1 //x6--
    b.ne _loop3
    mov x0, #1
    adr x1, charLib + 3
    mov x2, #5
    svc 0 //write(1, "│\r\n", 5)
    subs x7, x7, #1 //x7--
    b.ne _loop2
    mov x0, #1
    adr x1, charLib + 13
    mov x2, #3
    svc 0 //write(1, "└", 3)
    adrp x6, w
    ldr x6, [x6, :lo12:w]
    bl _loop1
    mov x0, #1
    adr x1, charLib + 16
    mov x2, #9
    svc 0 //write(1, "┘", 3)
_main_loop: //At this point, all preparations are done for console data that wont change. This label marks the game loop
    bl _memcpy
    adrp x6, h
    ldr x6, [x6, :lo12:h]
    mov x7, #2
    udiv x6, x6, x7 // x6 = h / 2
    mov x7, xzr // x7 = y = 0
_loop4: //while (y < x6) - The ASM version of a for loop that goes through every row in the terminal, not by actual rows
    mov x9, xzr // x9 = x = 0
_loop5: //while (x < w) - Another for loop that goes through every column
    mov x11, #2
    mul x10, x7, x11 //x10 = y * 2
    adrp x11, w
    ldr x11, [x11, :lo12:w]
    madd x10, x10, x11, x9 //x10 = i = (x10 * w) + x - i is the position in the buffer (if you pretend the buffers data is one bit wide) of the upper cell
    adrp x1, displayBuff
    ldr x0, [x1, :lo12:displayBuff] //x0 = displayBuff
    mov x1, #8
    udiv x1, x10, x1 //x1 = i / 8 - The actual position in the buffer for the upper cell (data only goes down to 1 byte wide)
    add x1, x1, x0 //x1 = &displayBuff[x1]
    ldr x0, [x1] //x0 = displayBuff[x1]
    and x1, x10, #7 //x1 = i % 8 - The position in the 1 byte space where the cell bit is
    mov x2, #1
    lsl x1, x2, x1 //x1 = 1 << x1
    and x0, x0, x1 //x0 = displauBuff[x1] & (1 << x1) - Extracts the state of the upper cell, all other bits are 0
    cmp x0, 0
    mov x2, #2
    csel x11, x2, xzr, ne //x11 = a = x0 ? 2 : 0 - If the upper cell is alive, initialize a with 2 (aka 1 << 1), if not start with 0
    adrp x1, displayBuff
    ldr x0, [x1, :lo12:displayBuff] //x0 = displayBuff
    adrp x12, w
    ldr x12, [x12, :lo12:w]
    add x12, x12, x10 //x10 = i + w - This is the bit position in the buffer of the lower cell. This next bit is the exact same as above just for the lower cell
    mov x1, #8
    udiv x1, x12, x1 //x1 = (i + w) / 8
    add x1, x1, x0 //x1 = &displayBuff[x1]
    ldr x0, [x1] //x0 = displayBuff[x1]
    and x1, x12, #7 //x1 = (i + w) % 8
    mov x2, #1
    lsl x1, x2, x1 //x1 = 1 << x1
    and x0, x0, x1 //x0 = displauBuff[x1] & (1 << x1)
    cmp x0, 0
    cinc x11, x11, ne //a += x0 ? 1 : 0 - Increments a if the lower cell is alive
    cmp x11, #3
    b.ne _b1 //if (a == 3) - Checks if both cells are alive
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 26
    mov x2, #3
    svc 0 //write(1, "█", 3)
    b _b4
_b1:
    cmp x11, #2
    b.ne _b2 //if (a == 2) - Checks if top cell is alive
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 29
    mov x2, #3
    svc 0 //write(1, "▀", 3)
    b _b4
_b2:
    cbz x11, _b3 //if (a == 1) - Checks if bottom cell is alove
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 32
    mov x2, #3
    svc 0 //write(1, "▄", 3)
    b _b4
_b3: //if (!a) - Default behaviour for if both are dead
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 25
    mov x2, #1
    svc 0 //write(1, " ", 1)
_b4: //This label marks the begining of the update/tick logic
    mov x12, #2
    mul x12, x12, x7 //x12 = 2 * y - Remember, y is h / 2 so you have to * 2 to get the actual y coordinate
    bl _getNeighbors //x0 = n = getNeighbors(x9, x12) - Gets the neighbors of the upper cell
    and x12, x11, #2 //x12 = a & 2 - Checks if the upper cell is alive
    cmp x12, #0
    b.ne _b5 //if (!x12) - Branches if the upper cell is alive, otherwise continue
    cmp x0, #3
    b.ne _b7 //if (n == 3) - If there are 3 neighbors, continue. Otherwise jump to checking the lower cell
    b _b6 //The program has determined that the cell should be flipped
_b5:
    cmp x0, #2
    b.lt _b6 //if (n < 2) - If there are less than 2 neighbors, flip the cell. Otherwise continue
    cmp x0, #3
    b.le _b7 //if (n <= 3) - If there are 3 or less cells, jump to checking the lower cell. Otherwise flip the cell
_b6: //If the program reaches this label, the upper cell will be flipped
    adrp x1, procBuff
    ldr x0, [x1, :lo12:procBuff] //x0 = procBuff
    mov x1, #8
    udiv x1, x10, x1 //x1 = i / 8
    add x0, x0, x1 //x0 = &procBuff[x1]
    and x1, x10, #7 //x1 = i % 8
    mov x2, #1
    lsl x1, x2, x1 // x1 = 1 << (i % 8)
    ldrb w2, [x0] //w2 = *x0
    eor w1, w2, w1 //w1 ^= w2 - XOR the cell. If the cell was alive, its now dead, and vice versa
    strb w1, [x0] //*x0 = w1
_b7: //_b7 to _b9 are the exact same as _b4 to _b6, just for the lower cell
    mov x12, #2
    mul x12, x12, x7 //x12 = y * 2
    add x12, x12, #1 //x12 = y * 2 + 1
    adrp x1, h
    ldr x1, [x1, :lo12:h]
    cmp x12, x1
    b.ge _b10 //if (x12 < h)
    adrp x1, w
    ldr x1, [x1, :lo12:w]
    add x10, x10, x1 //x10 = i + w
    bl _getNeighbors //x0 = n = getNeighbors(x9, x12)
    and x12, x11, #1 //x12 = a & 1
    cmp x12, #0
    b.ne _b8 //if (x12)
    cmp x0, #3
    b.ne _b10 //if (n == 3)
    b _b9 //flip cell
_b8:
    cmp x0, #2
    b.lt _b9 //if (n < 2) flip cell
    cmp x0, #3
    b.le _b10 //if (n <= 3) dont flip cell
_b9:
    adrp x1, procBuff
    ldr x0, [x1, :lo12:procBuff] //x0 = procBuff
    mov x1, #8
    udiv x1, x10, x1 //x1 = (i + w) / 8
    add x0, x0, x1 //x0 = &procBuff[x1]
    and x1, x10, #7 //x1 = (i + w) % 8
    mov x2, #1
    lsl x1, x2, x1 //x1 = 1 << ((i + w) % 8)
    ldrb w2, [x0] //w2 = *x0
    eor w1, w2, w1 //w1 ^= w2
    strb w1, [x0] //*x0 = w1
_b10:
    add x9, x9, #1 //x9++
    adrp x1, w
    ldr x1, [x1, :lo12:w]
    cmp x9, x1
    b.lt _loop5 //if (x9 == w) break - The condition check for the inner for loop (interating though all the x values)
    mov x8, 0x40
    mov x0, #1
    adr x1, charLib + 35
    mov x2, #8
    svc 0 //write(1, "\x1b[1B\x1b[2G", 8)
    add x7, x7, #1 //x7++
    cmp x7, x6
    b.lt _loop4 //if (x7 >= x6) break - The condition check for the outer for loop (interating though all the y values)
    mov x8, 0x40 //Update logic is done!
    mov x0, #1
    adr x1, charLib + 19
    mov x2, #6
    svc 0 //write(1, "\x1b[3;2f", 6)
    ldr x9, time
    ldr x10, time + 8
    stp x9, x10, [sp, #-16]! //*sp = time - ppoll updates the time struct input, so I just make a temporary one on the stack. lil bit of AI was here sry
    mov x8, 0x49
    adr x0, fds
    mov x1, #1
    mov x2, sp
    mov x3, 0
    mov x4, 0
    svc 0 //ppoll([{fd=0, events=POLLIN}], 1, {tv_sec=0, tv_nsec=150000000}, NULL, 0) - Waits 150 msec for an input into the console from the user, otherwise continues the loop
    cbz x0, _main_loop //if (x0) break - If there was an input, exit the loop
_exit: //Cleanup code to exit the program
    mov x8, 0x40
    mov x0, 1
    adr x1, outro
    mov x2, outroLen
    svc 0 //write(1, &outro, outroLen) - ANSI cleanup for the console
    mov x8, 0xD7
    adrp x1, displayBuff
    ldr x0, [x1, :lo12:displayBuff]
    adrp x2, bSize
    add x2, x2, :lo12:bSize
    ldr x1, [x2]
    svc 0 //munmap(displayBuff, bSize) - Unmapping the display buffer
    adrp x1, procBuff
    ldr x0, [x1, :lo12:procBuff]
    adrp x2, bSize
    add x2, x2, :lo12:bSize
    ldr x1, [x2]
    svc 0 //munmap(procBuff, bSize) - Unmapping the processing buffer
    mov x8, 0x1D
    mov x0, xzr
    mov x1, 0x5404
    adrp x2, orgTerm
    add x2, x2, :lo12:orgTerm
    svc 0 //ioctl(0, TCSETSF, &orgTerm) - Reverting the console back to its original state
    mov x8, 0x5D
    mov x0, xzr
    svc 0 //exit(0) - Successful exit
    brk #0 //Undefined crash
.section .data
time: //{tv_sec=0, tv_nsec=150000000} - Timing struct for ppoll
    .dword 0
    .dword 150000000
intro:
    .ascii "\x1b[?1049h\x1b[3J\x1b[2J\x1b[H\x1b[?25lMedatur76's Game of Assembly\r\n┌"
introLen = . - intro
outro:
    .ascii "\x1b[3J\x1b[2J\x1b[H\x1b[?25h\x1b[?1049l"
outroLen = . - outro
charLib:
    .ascii "─│\r\n┐\r\n└┘\x1b[3;2f █▀▄\x1b[1B\x1b[2G"
fds: //[{fd=0, events=POLLIN}] - Technically the "list" of fds for ppoll
    .word 0
    .word 1
