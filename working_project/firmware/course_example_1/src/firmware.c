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
#define OUT_REG0_ADDRESS (OUTPORT + 0*4)
#define LED (*(volatile unsigned int *) OUT_REG0_ADDRESS)

extern unsigned int sw_mult(unsigned int x, unsigned int y);

void irq_handler(unsigned int cause) {
}

void initialise(unsigned char r[C_WIDTH][C_HEIGHT], unsigned char g[C_WIDTH][C_HEIGHT], unsigned char b[C_WIDTH][C_HEIGHT], unsigned char a[C_WIDTH][C_HEIGHT]) {
    unsigned char w, h;

    for(h = 0; h < C_HEIGHT/2; h++) {
        for(w = 0; w < C_WIDTH/2; w++) {
            r[h][w] = 255; g[h][w] = 0; b[h][w] = 0; a[h][w] = 255;
        }
        for(w = C_WIDTH/2; w < C_WIDTH; w++) {
            r[h][w] = 0; g[h][w] = 255; b[h][w] = 0; a[h][w] = 255;
        }
    }
    for(h = C_HEIGHT/2; h < C_HEIGHT; h++) {
        for(w = 0; w < C_WIDTH/2; w++) {
            r[h][w] = 0; g[h][w] = 0; b[h][w] = 255; a[h][w] = 255;
        }
        for(w = C_WIDTH/2; w < C_WIDTH; w++) {
            r[h][w] = 127; g[h][w] = 127; b[h][w] = 127; a[h][w] = 255;
        }
    }
}


unsigned char pixel_hash(unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    return (sw_mult(r, 3) + sw_mult(g, 5) + sw_mult(b, 7) + sw_mult(a, 11)) & 0x3F;
}

int main(void) {

    unsigned char r_prev = 0, g_prev = 0, b_prev = 0, a_prev = 255;
    int run = 0;
    unsigned int running_array[64];
    int i;

    for (i = 0; i < 64; i++) {
        running_array[i] = 0;
    }

    unsigned char r[C_HEIGHT][C_WIDTH];
    unsigned char g[C_HEIGHT][C_WIDTH];
    unsigned char b[C_HEIGHT][C_WIDTH];
    unsigned char a[C_HEIGHT][C_WIDTH];

    initialise(r, g, b, a);

    // Write header directly to LED
    LED = 'q'; LED = 'o'; LED = 'i'; LED = 'f';
    LED = 0x00; LED = 0x00; LED = 0x00; LED = C_WIDTH;
    LED = 0x00; LED = 0x00; LED = 0x00; LED = C_HEIGHT;
    LED = 0x03; LED = 0x00;

    LED = 0x21; // test for refresh
    LED = 0x22; // test for refresh

    for (i = 0; i < C_HEIGHT; i++) {

        LED = 0x23; // test for refresh
        LED = 0x99; // test for refresh
        LED = i; // test for refresh
        LED = 0x88; // test for refresh

        for (int j = 0; j < C_WIDTH; j++) {
            LED = 0x99; // test for refresh
            LED = j; // test for refresh
            LED = 0x88; // test for refresh
            LED = r[i][j]; // test for refresh
            LED = 0x77; // test for refresh

            unsigned char r_cur = r[i][j];


            unsigned char g_cur = g[i][j];
            unsigned char b_cur = b[i][j];
            unsigned char a_cur = 255;

            LED = 0x24; // test for refresh

            LED = r_cur; // test for refresh
            LED = 0x99; // test for refresh
            LED = g_cur; // test for refresh
            LED = 0x88; // test for refresh
            LED = b_cur; // test for refresh
            LED = 0x77; // test for refresh

            LED = a_cur; // test for refresh
            LED = 0x66; // test for refresh

            if (r_cur == r_prev && g_cur == g_prev && b_cur == b_prev && a_cur == a_prev) {
                LED = 0x25;
                run++;
                if (run == 62) {
                    LED = 0x50; // test for refresh
                    LED = (unsigned int) (QOI_OP_RUN | (run - 1));
                    run = 0;
                }
            } else {
                LED = 0x26; // test for refresh
                if (run > 0) {
                    LED = 0x51; // test for refresh
                    LED = (unsigned int) (QOI_OP_RUN | (run - 1));
                    run = 0;
                }

                unsigned char index = pixel_hash(r_cur, g_cur, b_cur, a_cur);
                unsigned int current_pixel = ((unsigned int)r_cur << 24) | ((unsigned int)g_cur << 16) | ((unsigned int)b_cur << 8) | a_cur;

                if (running_array[index] == current_pixel) {
                    LED = 0x52; // test for refresh
                    LED = (unsigned int) (QOI_OP_INDEX | index);
                } else {
                    LED = 0x27; // test for refresh
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
                        LED = 0x53; // test for refresh
                        LED = (unsigned int) (QOI_OP_DIFF | ((dr + 2) << 4) | ((dg + 2) << 2) | (db + 2));
                    } else if (dg >= -32 && dg <= 31) {
                        int dr_dg = dr - dg;
                        int db_dg = db - dg;

                        if ((dr_dg >= -8 && dr_dg <= 7) && (db_dg >= -8 && db_dg <= 7)) {
                            LED = 0x55; // test for refresh
                            LED = (unsigned int) (QOI_OP_LUMA | (dg + 32));
                            LED = (unsigned int) ((dr_dg + 8) << 4) | (db_dg + 8);
                        } else {
                            LED = 0x56; // test for refresh
                            LED = (unsigned int) (QOI_OP_RGB);
                            LED = (unsigned int) (r_cur);
                            LED = (unsigned int) (g_cur);
                            LED = (unsigned int) (b_cur);
                        }
                    } else {
                        LED = 0x57; // test for refresh
                        LED = (unsigned int) (QOI_OP_RGB);
                        LED = (unsigned int) (r_cur);
                        LED = (unsigned int) (g_cur);
                        LED = (unsigned int) (b_cur);
                    }
                }
		
		LED = 0x58;// test for refresh
                r_prev = r_cur;
                g_prev = g_cur;
                b_prev = b_cur;
                a_prev = a_cur;
            }
        }
    }

    // Flush any remaining run
    if (run > 0) {
        LED = 0x58; // test for refresh
        LED = (unsigned int) (QOI_OP_RUN | (run - 1));
    }

    // End marker: 7x 0x00, 1x 0x01
    for (i = 0; i < 7; i++) LED = 0;
    LED = 1;

    return 0;
}
