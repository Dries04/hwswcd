#include "tcnt.h"
#include "sensor.h"

#define QOI_OP_INDEX 0x00 // 00xxxxxx
#define QOI_OP_DIFF  0x40 // 01xxxxxx
#define QOI_OP_LUMA  0x80 // 10xxxxxx
#define QOI_OP_RUN   0xC0 // 11xxxxxx
#define QOI_OP_RGB   0xFE
#define QOI_OP_RGBA  0xFF

#define OUTPORT 0x80000000
#define OUT_REG0_ADDRESS (OUTPORT + 0*4)
#define LED (*(volatile unsigned int *) OUT_REG0_ADDRESS)

//extern unsigned int sw_mult(unsigned int x, unsigned int y);

unsigned int Multiply(unsigned int a, unsigned int b) {
    unsigned int result = 0;

    while (b > 0) {
        if (b & 1) { 
            result += a;
        }
        a <<= 1; 
        b >>= 1; 
    }

    return result;
}

void irq_handler(unsigned int cause) {
    if (cause & 4) {

    }

    TCNT_CR = 0x17;
    TCNT_CR = 0x7;
}

unsigned char closest_difference(unsigned char current, unsigned char prev) {
    signed char diff = (current >= prev) ? current - prev : 256 - (prev - current);
    return diff;
}

unsigned char pixel_hash(unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    return (Multiply(r, 3) + Multiply(g, 5) + Multiply(b, 7) + Multiply(a, 11)) & 0x3F;
}

int main(void) {
    
    TCNT_CMP = 0xFFFD40;
    TCNT_start();

    unsigned char r_prev = 0, g_prev = 0, b_prev = 0, a_prev = 255;
    int run = 0;
    unsigned int running_array[64];
    int i;

    for (i = 0; i < 64; i++) {
        running_array[i] = 0;
    }

    // int C_WIDTH = SENSOR_get_width();
    // int C_HEIGHT = SENSOR_get_height();

    int C_WIDTH = 0x4B; // Placeholder for actual width
    int C_HEIGHT = 0x32; // Placeholder for actual height

    // Write header directly to LED
    LED = 'q'; LED = 'o'; LED = 'i'; LED = 'f';
    LED = 0x00; LED = 0x00; LED = 0x00; 
    LED = C_WIDTH;
    LED = 0x00; LED = 0x00; LED = 0x00; 
    LED = C_HEIGHT;
    LED = 0x03; LED = 0x00;

    for (i = 0; i < C_HEIGHT; i++) {

        for (int j = 0; j < C_WIDTH; j++) {

            unsigned int pixeldata = SENSOR_fetch();
            unsigned char r_cur = (pixeldata >> 24) & 0xFF;
            unsigned char g_cur = (pixeldata >> 16) & 0xFF;
            unsigned char b_cur = (pixeldata >> 8) & 0xFF;
            unsigned char a_cur = pixeldata & 0xFF;

            if (r_cur == r_prev && g_cur == g_prev && b_cur == b_prev && a_cur == a_prev) {
                run++;
                if (run == 62) {
                    LED = (QOI_OP_RUN | (run - 1));
                    run = 0;
                }
            } else {
                if (run > 0) {
                    LED = (QOI_OP_RUN | (run - 1));
                    run = 0;
                }

                unsigned char index = pixel_hash(r_cur, g_cur, b_cur, a_cur);
                unsigned int current_pixel = (r_cur << 24) | (g_cur << 16) | (b_cur << 8) | a_cur;

                if (running_array[index] == current_pixel) {
                    LED = QOI_OP_INDEX | index;
                } else {
                    running_array[index] = current_pixel;

                    // int dr = r_cur - r_prev;
                    // int dg = g_cur - g_prev;
                    // int db = b_cur - b_prev;

                    // if (dr < -128) dr += 256;
                    // else if (dr > 127) dr -= 256;

                    // if (dg < -128) dg += 256;
                    // else if (dg > 127) dg -= 256;

                    // if (db < -128) db += 256;
                    // else if (db > 127) db -= 256;

                    signed char dr = closest_difference(r_cur, r_prev);
                    signed char dg = closest_difference(g_cur, g_prev);
                    signed char db = closest_difference(b_cur, b_prev);


                    if ((dr >= -2 && dr <= 1) && (dg >= -2 && dg <= 1) && (db >= -2 && db <= 1) && (a_cur == a_prev)) {
                        //LED = QOI_OP_DIFF | ((dr + 2) << 4) | ((dg + 2) << 2) | (db + 2);
                        LED = 0b01000000 | ((dr + 2) << 4) | ((dg + 2) << 2) | (db + 2);

                    } else if (dg >= -32 && dg <= 31) {


                        signed char dr_dg = dr - dg;
                        signed char db_dg = db - dg;

                        if ((dr_dg >= -8 && dr_dg <= 7) && (db_dg >= -8 && db_dg <= 7) && (a_cur == a_prev)) {

                            LED = QOI_OP_LUMA | (dg + 32);
                            LED = ((dr_dg + 8) << 4) | (db_dg + 8);
                        } else {

                            LED = (QOI_OP_RGB);
                            LED = (r_cur);
                            LED = (g_cur);
                            LED = (b_cur);
                        }
                    } else {

                        LED = (QOI_OP_RGB);
                        LED = (r_cur);
                        LED = (g_cur);
                        LED = (b_cur);
                    }
                }
		
                r_prev = r_cur;
                g_prev = g_cur;
                b_prev = b_cur;
                a_prev = a_cur;
            }
        }
    }

    // Flush any remaining run
    if (run > 0) {
        LED = QOI_OP_RUN | (run - 1);
    }

    // End marker: 7x 0x00, 1x 0x01
    for (i = 0; i < 7; i++) LED = 0;
    LED = 1;

    TCNT_stop();

    return 0;
}
