#include "print.h"
#include "tcnt.h"

#define LED_BASEAxDDRESS 0x80000000
#define LED_REG0_ADDRESS (LED_BASEAxDDRESS + 0*4)
#define LED              (*(volatile unsigned int *) LED_REG0_ADDRESS)


#define C_WIDTH 8
#define C_HEIGHT 8

#define QOI_OP_INDEX 0x00 // 00xxxxxx
#define QOI_OP_DIFF  0x40 // 01xxxxxx
#define QOI_OP_LUMA  0x80 // 10xxxxxx
#define QOI_OP_RUN   0xC0 // 11xxxxxx
#define QOI_OP_RGB   0xFE
#define QOI_OP_RGBA  0xFF


int one_sec_bool = 0;
void irq_handler(unsigned int cause) {

    if (cause & 4) {
        LED = 0xFFFFFFFF;
    }

    one_sec_bool++;


    TCNT_CR = 0x17;
    TCNT_CR = 0x7;

}

typedef struct {
    unsigned char r, g, b, a;
} Pixel;

int rgb_equal(Pixel a, Pixel b) {
    return a.r == b.r && a.g == b.g && a.b == b.b;
}

unsigned char pixel_hash(Pixel px) {
    return (px.r * 3 + px.g * 5 + px.b * 7 + px.a * 11) % 64;
}

void write_byte(unsigned char **p, unsigned char byte) {
    *(*p)++ = byte;
}

void write_3(unsigned char **p, unsigned char r, unsigned char g, unsigned char b) {
    write_byte(p, QOI_OP_RGB);
    write_byte(p, r);
    write_byte(p, g);
    write_byte(p, b);
}

void write_4(unsigned char **p, unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    write_byte(p, QOI_OP_RGBA);
    write_byte(p, r);
    write_byte(p, g);
    write_byte(p, b);
    write_byte(p, a);
}

void initialise(unsigned char r[C_WIDTH][C_HEIGHT], unsigned char g[C_WIDTH][C_HEIGHT], unsigned char b[C_WIDTH][C_HEIGHT], unsigned char a[C_WIDTH][C_HEIGHT]) {
    unsigned char w, h;
    for (h = 0; h < C_HEIGHT / 2; h++) {
        for (w = 0; w < C_WIDTH / 2; w++) {
            r[h][w] = 255; g[h][w] = 0; b[h][w] = 0; a[h][w] = 255;
        }
        for (w = C_WIDTH / 2; w < C_WIDTH; w++) {
            r[h][w] = 0; g[h][w] = 255; b[h][w] = 0; a[h][w] = 255;
        }
    }
    for (h = C_HEIGHT / 2; h < C_HEIGHT; h++) {
        for (w = 0; w < C_WIDTH / 2; w++) {
            r[h][w] = 0; g[h][w] = 0; b[h][w] = 255; a[h][w] = 255;
        }
        for (w = C_WIDTH / 2; w < C_WIDTH; w++) {
            r[h][w] = 127; g[h][w] = 127; b[h][w] = 127; a[h][w] = 255;
        }
    }
}

int main(void) {
    unsigned char r[C_HEIGHT][C_WIDTH];
    unsigned char g[C_HEIGHT][C_WIDTH];
    unsigned char b[C_HEIGHT][C_WIDTH];
    unsigned char a[C_HEIGHT][C_WIDTH];

    Pixel index_array[64];  // just declare

    for (int i = 0; i < 64; i++) {
        index_array[i].r = 0;
        index_array[i].g = 0;
        index_array[i].b = 0;
        index_array[i].a = 0;
    }


    Pixel prev = {0, 0, 0, 255};
    int run = 0;

    unsigned char encoded[1024]; // enough for small image
    unsigned char *p = encoded;

    initialise(r, g, b, a);

    // Write QOI header
    write_byte(&p, 'q');
    write_byte(&p, 'o');
    write_byte(&p, 'i');
    write_byte(&p, 'f');

    // Write 32-bit big-endian width
    write_byte(&p, (C_WIDTH >> 24) & 0xFF);
    write_byte(&p, (C_WIDTH >> 16) & 0xFF);
    write_byte(&p, (C_WIDTH >> 8) & 0xFF);
    write_byte(&p, C_WIDTH & 0xFF);

    // Write 32-bit big-endian height
    write_byte(&p, (C_HEIGHT >> 24) & 0xFF);
    write_byte(&p, (C_HEIGHT >> 16) & 0xFF);
    write_byte(&p, (C_HEIGHT >> 8) & 0xFF);
    write_byte(&p, C_HEIGHT & 0xFF);

    // Channels: 4 for RGBA, 3 for RGB
    write_byte(&p, 3);

    // Colorspace: 0 = sRGB with linear alpha
    write_byte(&p, 0);


    for (unsigned char h = 0; h < C_HEIGHT; h++) {
        for (unsigned char w = 0; w < C_WIDTH; w++) {
            Pixel px = { r[h][w], g[h][w], b[h][w], 255 };

            if (rgb_equal(px, prev)) {
                run++;
                if (run == 62) {
                    write_byte(&p, QOI_OP_RUN | (run - 1));
                    run = 0;
                }
            } else {
                if (run > 0) {
                    write_byte(&p, QOI_OP_RUN | (run - 1));
                    run = 0;
                }

                unsigned char index_pos = pixel_hash(px);
                if (rgb_equal(px, index_array[index_pos])) {
                    write_byte(&p, QOI_OP_INDEX | index_pos);
                } else {
                    index_array[index_pos] = px;

                    int vr = (int)px.r;
                    int vg = (int)px.g;
                    int vb = (int)px.b;

                    int pr = (int)prev.r;
                    int pg = (int)prev.g;
                    int pb = (int)prev.b;

                    int dr = ((int)px.r - (int)prev.r + 256) % 256;
                    if (dr > 127) dr -= 256;

                    int dg = ((int)px.g - (int)prev.g + 256) % 256;
                    if (dg > 127) dg -= 256;

                    int db = ((int)px.b - (int)prev.b + 256) % 256;
                    if (db > 127) db -= 256;


                    // QOI_OP_DIFF
                    if ((dr >= -2 && dr <= 1) &&
                        (dg >= -2 && dg <= 1) &&
                        (db >= -2 && db <= 1)) {
                        
                        unsigned char diff_byte = QOI_OP_DIFF |
                            ((dr + 2) << 4) |
                            ((dg + 2) << 2) |
                            (db + 2);
                        write_byte(&p, diff_byte);
                    }
                    // QOI_OP_LUMA
                    else if ((dg >= -32 && dg <= 31)) {
                        int dr_dg = dr - dg;
                        int db_dg = db - dg;

                        if ((dr_dg >= -8 && dr_dg <= 7) &&
                            (db_dg >= -8 && db_dg <= 7)) {
                            unsigned char byte1 = QOI_OP_LUMA | (dg + 32);
                            unsigned char byte2 = ((dr_dg + 8) << 4) | (db_dg + 8);
                            write_byte(&p, byte1);
                            write_byte(&p, byte2);
                        } else {
                            write_3(&p, px.r, px.g, px.b);
                        }
                    }
                    // Fallback: QOI_OP_RGB
                    else {
                        write_3(&p, px.r, px.g, px.b);
                    }


                }
                prev = px;
            }
        }
    }

    if (run > 0) {
        write_byte(&p, QOI_OP_RUN | (run - 1));
    }

    // End marker
    for (int i = 0; i < 7; i++) write_byte(&p, 0x00);
    write_byte(&p, 0x01);

    // Output (for verification)
    for (unsigned char *i = encoded; i < p; i++) {
        //print_hex(*i, 2);
        //printf("%02X ", *i);
        LED = *i;
        
    }
    //print_str("\n");

    return 0;
}
