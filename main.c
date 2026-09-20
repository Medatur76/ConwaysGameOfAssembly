#include <termios.h>
#include <unistd.h>
#include <sys/mman.h>
#include <poll.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

#define min(a, b) (a) < (b) ? (a) : (b)
#define max(a, b) (a) > (b) ? (a) : (b)

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
int w, h;

int getNeighbors(int x, int y) {
    int n = 0;
    for (int dy = -1; dy < 2; dy++) {
        if ((y + dy) > h - 1 || (y + dy) < 0) continue;
        for (int dx = -1; dx < 2; dx++) {
            if (!(dx || dy)) continue;
            if ((x + dx) > w - 1 || (x + dx) < 0) continue;
            int j = (y + dy) * w + (x + dx);
            n += displayBuff[j / 8] & (1 << (j % 8)) ? 1 : 0;
        }
    }
    return n;
}

struct pollfd fds = {STDIN_FILENO, POLLIN, 0};

struct point {int x; int y;};

void drawPoints(struct point points[], unsigned long nPoints) {
    for (unsigned long i = 0; i < nPoints; i++) procBuff[(points[i].y*w + points[i].x) / 8] |= 1 << ((points[i].y*w + points[i].x) % 8);
}

void drawBox() {
    write(1, "┌", 3);
    for (int i = 0; i < w; i++) write(1, "─", 3);
    write(1, "┐\r\n", 5);
    for (int i = 0; i < ceil((double) h / 2); i++) {
        write(1, "│", 3);
        for (int j = 0; j < w; j++) write(1, " ", 1);
        write(1, "│\r\n", 5);
    }
    write(1, "└", 3);
    for (int i = 0; i < w; i++) write(1, "─", 3);
    write(1, "┘", 3);
}

int main() {
    w = 40, h = 24;
    int bSize = (int)ceil(((double) w * h) / 8);

    displayBuff = mmap(NULL, bSize, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
    procBuff = mmap(NULL, bSize, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);

    //Glider
    struct point defaultState[] = {
        [0] = {.x = 1, .y = 0},
        [1] = {.x = 2, .y = 1},
        [2] = {.x = 0, .y = 2},
        [3] = {.x = 1, .y = 2},
        [4] = {.x = 2, .y = 2},
        [5] = {.x = w-2, .y = 1},
        [6] = {.x = w-3, .y = 2},
        [7] = {.x = w-1, .y = 3},
        [8] = {.x = w-2, .y = 3},
        [9] = {.x = w-3, .y = 3}
    };

    drawPoints(defaultState, sizeof(defaultState) / sizeof(defaultState[0]));

    enable_raw_mode();

    write(1, "\x1b[?1049h\x1b[3J\x1b[2J\x1b[H\x1b[?25lMedatur76's Game of C\r\n", 48);

    drawBox();

    bool paused = true, overwrite = true;
    struct point cursor = {0,0};

    write(1, "\x1b[0J\r\n\nUse the arrow keys to move the cursor\r\nPress enter to flip the selected cell\r\nPress space to resume the game\x1b[2;0f", 121);
    while (1) {
        memcpy(displayBuff, procBuff, bSize);
        drawBox();
        write(1, "\x1b[3;2f", 6);
        if (paused && overwrite) displayBuff[(cursor.y*w + cursor.x) / 8] ^= 1 << ((cursor.y*w + cursor.x) % 8);
        for (int y = 0; y < (h / 2); y++) {
            for (int x = 0; x < w; x++) {
                int i = y*2*w+x;
                int a = ((displayBuff[i / 8] & (1 << (i % 8))) ? 2 : 0) + ((displayBuff[(i + w) / 8] & (1 << ((i + w) % 8))) ? 1 : 0);
                if (a == 3) {
                    write(1, "█", 3);
                } else if (a == 2) {
                    write(1, "▀", 3);
                } else if (a) {
                    write(1, "▄", 3);
                } else {
                    write(1, " ", 1);
                }
                if (paused) continue;
                int n = getNeighbors(x, y*2);
                if ((a & 2 && (n < 2 || n > 3)) || (!(a & 2) && n == 3)) procBuff[i / 8] ^= (1 << (i % 8));
                if ((y*2+1) < h) {
                    n = getNeighbors(x, y*2+1);
                    if ((a & 1 && (n < 2 || n > 3)) || (!(a & 1) && n == 3)) procBuff[(i+w) / 8] ^= (1 << ((i+w) % 8));
                }
            }
            write(1, "\x1b[1B\x1b[2G", 8);
        }

        if (paused || (poll(&fds, 1, 150) && (fds.revents & POLLIN))) {
            //Will need this to be dynamic OR as big as the biggest input I wish to process
            char in;
            read(STDIN_FILENO, &in, 1);
            overwrite = true;
            if (in == 0x20) {
                if (paused ^= 1) {
                    write(1, "\x1b[0J\r\n\nUse the arrow keys to move the cursor\r\nPress enter to flip the selected cell\r\nPress space to resume the game", 115);
                } else {
                    write(1, "\x1b[0J\r\n\nPress space to pause the game\r\nPress enter to exit", 57);
                }
            } else if (in == 0x1B && read(STDIN_FILENO, &in, 1) && in == 0x5B && read(STDIN_FILENO, &in, 1)) {
                switch (in) {
                    case 0x41:
                        cursor.y = max(cursor.y - 1, 0);
                        break;
                    case 0x42:
                        cursor.y = min(cursor.y + 1, h - 1);
                        break;
                    case 0x43:
                        cursor.x = min(cursor.x + 1, w - 1);
                        break;
                    case 0x44:
                        cursor.x = max(cursor.x - 1, 0);
                        break;
                    default:
                        break;
                }
            } else if (in == 0x0A || in == 0x0D) {
                if (paused) {
                    procBuff[(cursor.y*w + cursor.x) / 8] ^= 1 << ((cursor.y*w + cursor.x) % 8);
                    overwrite = false;
                } else break;
            }
        }

        write(1, "\x1b[2;0f", 6);
    }

    write(1, "\x1b[3J\x1b[2J\x1b[H\x1b[?25h\x1b[?1049l", 25);

    munmap(displayBuff, bSize);
    munmap(procBuff, bSize);
    return 0;
}