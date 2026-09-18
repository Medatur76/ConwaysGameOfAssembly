#include <termios.h>
#include <unistd.h>
#include <sys/mman.h>
#include <poll.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

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

void draw(struct point points[], unsigned long nPoints) {
    for (unsigned long i = 0; i < nPoints; i++) procBuff[(points[i].y*w + points[i].x) / 8] |= 1 << ((points[i].y*w + points[i].x) % 8);
}

int main(int argc, char *argv[]) {

    w = 24, h = 18;
    int bSize = (int)ceil(((double) w * h) / 8);

    displayBuff = mmap(NULL, bSize, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
    procBuff = mmap(NULL, bSize, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);

    //Glider
    struct point defaultState[] = {[0] = {.x = 1, .y = 0},[1] = {.x = 2, .y = 1},[2] = {.x = 0, .y = 2},[3] = {.x = 1, .y = 2},[4] = {.x = 2, .y = 2}};
    //Pulsar

    draw(defaultState, sizeof(defaultState) / sizeof(defaultState[0]));

    enable_raw_mode();

    write(1, "\x1b[?1049h\x1b[3J\x1b[2J\x1b[H\x1b[?25lKiernan's Game of C\r\n┌", 49);

    for (int i = 0; i < w; i++) write(1, "─", 3);
    write(1, "┐\r\n", 5);
    for (int i = 0; i < ceil((double) h / 2); i++) {
        write(1, "│", 3);
        for (int j = 0; j < w; j++) write(1, " ", 1);
        write(1, "│\r\n", 5);
    }
    write(1, "└", 3);
    for (int i = 0; i < w; i++) write(1, "─", 3);
    write(1, "┘\x1b[3;2f", 9);

    while (1) {
        memcpy(displayBuff, procBuff, bSize);
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
                int n = getNeighbors(x, y*2);
                if ((a & 2 && (n < 2 || n > 3)) || (!(a & 2) && n == 3)) procBuff[i / 8] ^= (1 << (i % 8));
                if ((y*2+1) < h) {
                    n = getNeighbors(x, y*2+1);
                    if ((a & 1 && (n < 2 || n > 3)) || (!(a & 1) && n == 3)) procBuff[(i+w) / 8] ^= (1 << ((i+w) % 8));
                }
            }
            write(1, "\x1b[1B\x1b[2G", 8);
        }
        write(1, "\x1b[3;2f", 6);

        if(poll(&fds, 1, 500) && (fds.revents & POLLIN)) {
            //Will need this to be dynamic OR as big as the biggest input I wish to process
            char in;
            read(STDIN_FILENO, &in, 1);
            if (in == 0x0A || in == 0x0D) break;
        }
    }

    write(1, "\x1b[3J\x1b[2J\x1b[H\x1b[?25h\x1b[?1049l", 25);

    munmap(displayBuff, 13);
    munmap(procBuff, 13);
    return 0;
}