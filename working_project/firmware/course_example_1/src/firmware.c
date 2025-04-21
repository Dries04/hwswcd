#include "tcnt.h"

#define C_WIDTH 8
#define C_HEIGHT 8

#define QOI_OP_INDEX 0x00 // 00xxxxxx
#define QOI_OP_DIFF  0x40 // 01xxxxxx
#define QOI_OP_LUMA  0x80 // 10xxxxxx
#define QOI_OP_RUN   0xC0 // 11xxxxxx
#define QOI_OP_RGB   0xFE
#define QOI_OP_RGBA  0xFF

#define OUTPORT 0x80000000
#define LED (*(volatile unsigned int *) OUTPORT)

extern unsigned int sw_mult(unsigned int x, unsigned int y);

void irq_handler(unsigned int cause) {
}

void initialise(unsigned char r[C_HEIGHT][C_WIDTH], unsigned char g[C_HEIGHT][C_WIDTH], unsigned char b[C_HEIGHT][C_WIDTH], unsigned char a[C_HEIGHT][C_WIDTH]) {
    unsigned char w, h;
    for (h = 0; h < 4; h++) {
        for (w = 0; w < 4; w++) {
            r[h][w] = 255; g[h][w] = 0; b[h][w] = 0; a[h][w] = 255;
        }
        for (w = 4; w < C_WIDTH; w++) {
            r[h][w] = 0; g[h][w] = 255; b[h][w] = 0; a[h][w] = 255;
        }
    }
    for (h = 4; h < C_HEIGHT; h++) {
        for (w = 0; w < 4; w++) {
            r[h][w] = 0; g[h][w] = 0; b[h][w] = 255; a[h][w] = 255;
        }
        for (w = 4; w < C_WIDTH; w++) {
            r[h][w] = 127; g[h][w] = 127; b[h][w] = 127; a[h][w] = 255;
        }
    }
}

unsigned char pixel_hash(unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    return (sw_mult(r, 3) + sw_mult(g, 5) + sw_mult(b, 7) + sw_mult(a, 11)) & 0x3F;
}

int main(void) {
    unsigned char r[C_HEIGHT][C_WIDTH];
    unsigned char g[C_HEIGHT][C_WIDTH];
    unsigned char b[C_HEIGHT][C_WIDTH];
    unsigned char a[C_HEIGHT][C_WIDTH];

    unsigned char r_prev, g_prev, b_prev, a_prev;
    int run;
    unsigned int running_array[64];
    static unsigned char encoded[1024];
    unsigned char *p;
    int i;

    r_prev = 0;
    g_prev = 0;
    b_prev = 0;
    a_prev = 255;
    run = 0;
    p = encoded;

    for (i = 0; i < 64; i++) {
        running_array[i] = 0;
    }

    initialise(r, g, b, a);

    // Write header
    *p++ = 'q'; *p++ = 'o'; *p++ = 'i'; *p++ = 'f';
    *p++ = 0; *p++ = 0; *p++ = 0; *p++ = C_WIDTH;
    *p++ = 0; *p++ = 0; *p++ = 0; *p++ = C_HEIGHT;
    *p++ = 3; *p++ = 0;

    // Output the header immediately
    unsigned char *q = encoded;
    for (i = 0; i < 14; i++) {
        LED = *q++;
    }


    for (i = 0; i < C_HEIGHT; i++) {
        int j;
        for (j = 0; j < C_WIDTH; j++) {
            unsigned char r_cur = r[i][j];
            unsigned char g_cur = g[i][j];
            unsigned char b_cur = b[i][j];
            unsigned char a_cur = 255;

            if (r_cur == r_prev && g_cur == g_prev && b_cur == b_prev && a_cur == a_prev) {
                run++;
                if (run == 62) {
                    *p = QOI_OP_RUN | (run - 1);
                    p++;
                    run = 0;
                }
            } else {
                if (run > 0) {
                    *p = QOI_OP_RUN | (run - 1);
                    p++;
                    run = 0;
                }

                unsigned char index = pixel_hash(r_cur, g_cur, b_cur, a_cur);
                unsigned int current_pixel = ((unsigned int)r_cur << 24) | ((unsigned int)g_cur << 16) | ((unsigned int)b_cur << 8) | a_cur;

                if (running_array[index] == current_pixel) {
                    *p = QOI_OP_INDEX | index;
                    p++;
                } else {
                    running_array[index] = current_pixel;

                    int dr = (int)r_cur - (int)r_prev;
                    int dg = (int)g_cur - (int)g_prev;
                    int db = (int)b_cur - (int)b_prev;

                    if (dr < -128) dr += 256;
                    else if (dr > 127) dr -= 256;

                    if (dg < -128) dg += 256;
                    else if (dg > 127) dg -= 256;

                    if (db < -128) db += 256;
                    else if (db > 127) db -= 256;

                    if ((dr >= -2 && dr <= 1) && (dg >= -2 && dg <= 1) && (db >= -2 && db <= 1)) {
                        *p = QOI_OP_DIFF | ((dr + 2) << 4) | ((dg + 2) << 2) | (db + 2);
                        p++;
                    } else if (dg >= -32 && dg <= 31) {
                        int dr_dg = dr - dg;
                        int db_dg = db - dg;

                        if ((dr_dg >= -8 && dr_dg <= 7) && (db_dg >= -8 && db_dg <= 7)) {
                            *p++ = QOI_OP_LUMA | (dg + 32);
                            *p++ = ((dr_dg + 8) << 4) | (db_dg + 8);
                        } else {
                            *p++ = QOI_OP_RGB;
                            *p++ = r_cur;
                            *p++ = g_cur;
                            *p++ = b_cur;
                        }
                    } else {
                        *p++ = QOI_OP_RGB;
                        *p++ = r_cur;
                        *p++ = g_cur;
                        *p++ = b_cur;
                    }
                }

                r_prev = r_cur;
                g_prev = g_cur;
                b_prev = b_cur;
                a_prev = a_cur;
            }
        }
    }

    if (run > 0) {
        *p = QOI_OP_RUN | (run - 1);
        p++;
    }

    for (i = 0; i < 7; i++) {
        *p = 0;
        p++;
    }
    *p = 1;
    p++;

    for (i = 14; i < (p - encoded); i++) {
        LED = encoded[i]; // Output each encoded byte to OUTPORT
    }
    

    return 0;
}