#include <termios.h>
#include <unistd.h>
#include <sys/mman.h>
#include <poll.h>
#include <stdlib.h>
#include <string.h>

struct termios orig_termios;

void disable_raw_mode(void) {
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);
}


void enable_raw_mode(void) {
    tcgetattr(STDIN_FILENO, &orig_termios);
    atexit(disable_raw_mode);

    struct termios raw = orig_termios;

    raw.c_lflag &= ~(ECHO | ICANON | ISIG | IEXTEN);
    raw.c_iflag &= ~(IXON | ICRNL | BRKINT | INPCK | ISTRIP);
    raw.c_oflag &= ~(OPOST);
    raw.c_cflag |= (CS8);

    raw.c_cc[VMIN]  = 1;  // read returns as soon as 1 byte is available
    raw.c_cc[VTIME] = 0;

    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}

unsigned char *displayBuff, *procBuff;

struct pollfd fds = {STDIN_FILENO, POLLIN, 0};

int main() {
    displayBuff = mmap(NULL, 13, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
    procBuff = mmap(NULL, 13, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);

    *procBuff = 2;
    procBuff[1] = 1 << 5;
    procBuff[2] = 7 << 5;

    enable_raw_mode();

    write(1, "\x1b[?1049h\x1b[3J\x1b[2J\x1b[H\x1b[?25lKiernan's Game of C\r\n┌────────────────────┐\r\n│                    │\r\n│                    │\r\n│                    │\r\n│                    │\r\n│                    │\r\n│                    │\r\n│                    │\r\n│                    │\r\n│                    │\r\n│                    │\r\n└────────────────────┘\x1b[3;2f", 466);

    while (!poll(&fds, 1, 100)) {
        memcpy(displayBuff, procBuff, 13);
        for (int y = 0; y < 10; y++) {
            for (int x = 0; x < 10; x++) {
                int i = y*10+x;
                if (displayBuff[i / 8] & (1 << (i % 8))) {
                    write(1, "██", 6);
                } else {
                    write(1, "  ", 2);
                }
                int n = 0;
                for (int dy = -1; dy < 2; dy++) {
                    if ((y + dy) > 9 || (y + dy) < 0) continue;
                    for (int dx = -1; dx < 2; dx++) {
                        if (!(dx || dy)) continue;
                        if ((x + dx) > 9 || (x + dx) < 0) continue;
                        int j = (y + dy) * 10 + (x + dx);
                        n += displayBuff[j / 8] & (1 << (j % 8)) ? 1 : 0;
                    }
                }
                if ((procBuff[i / 8] & (1 << (i % 8)) && (n < 2 || n > 3)) || (!(procBuff[i / 8] & (1 << (i % 8))) && n == 3)) procBuff[i / 8] ^= (1 << (i % 8));
            }
            write(1, "\x1b[1B\x1b[2G", 8);
        }
        write(1, "\x1b[3;2f", 6);
    }

    write(1, "\x1b[3J\x1b[2J\x1b[H\x1b[?25h\x1b[?1049l", 25);

    munmap(displayBuff, 13);
    munmap(procBuff, 13);
    return 0;
}