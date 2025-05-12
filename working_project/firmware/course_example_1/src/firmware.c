#include "tcnt.h"
#include "sensor.h"
#include "qoi_chunk.h"

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

// unsigned int Multiply(unsigned int a, unsigned int b) {
//     unsigned int result = 0;

//     while (b > 0) {
//         if (b & 1) { 
//             result += a;
//         }
//         a <<= 1; 
//         b >>= 1; 
//     }

//     return result;
// }

void irq_handler(unsigned int cause) {
    // if (cause & 4) {

    // }

    TCNT_CR = 0x17;
    TCNT_CR = 0x7;
}

// unsigned char closest_difference(unsigned char current, unsigned char prev) {
//     signed char diff = (current >= prev) ? current - prev : 256 - (prev - current);
//     return diff;
// }

// unsigned char pixel_hash(unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
//     return (Multiply(r, 3) + Multiply(g, 5) + Multiply(b, 7) + Multiply(a, 11)) & 0x3F;
// }

int main(void) {
    
    TCNT_CMP = 0xFFFD40;
    TCNT_start();

    unsigned char r_prev = 0, g_prev = 0, b_prev = 0;
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

            if (r_cur == r_prev && g_cur == g_prev && b_cur == b_prev) {
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

                unsigned int sum = 0;

                // r * 3 = (r << 1) + r
                sum += (r_cur << 1) + r_cur;

                // g * 5 = (g << 2) + g
                sum += (g_cur << 2) + g_cur;

                // b * 7 = (b << 3) - b
                sum += (b_cur << 3) - b_cur;

                unsigned char index = sum & 0x3F;
                unsigned int current_pixel = (r_cur << 24) | (g_cur << 16) | (b_cur << 8);
                if (running_array[index] == current_pixel) {
                    LED = QOI_OP_INDEX | index;
                } else {
                    running_array[index] = current_pixel;

                    // signed char dr = (r_cur >= r_prev) ? r_cur - r_prev : 256 - (r_prev - r_cur);
                    // signed char dg = (g_cur >= g_prev) ? g_cur - g_prev : 256 - (g_prev - g_cur);
                    // signed char db = (b_cur >= b_prev) ? b_cur - b_prev : 256 - (b_prev - b_cur);

                    unsigned char dr_unsigned = r_cur - r_prev;
                    unsigned char dg_unsigend = g_cur - g_prev;
                    unsigned char db_unsigned = b_cur - b_prev;

                    signed char dr = (signed char)dr_unsigned;
                    signed char dg = (signed char)dg_unsigend;
                    signed char db = (signed char)db_unsigned;




                    // LED = 0xF00DBA00;
                    //werkende versie, enkel de eerste paar pixels zijn niet correct, ergens een probleem met undefined behavior
                    unsigned int chunk_result;

                    chunk_result = chunk_fetch();
                    if (chunk_result == 0x00000001){
                        LED = QOI_OP_DIFF | ((dr + 2) << 4) | ((dg + 2) << 2) | (db + 2);
                    }else if (chunk_result == 0x00000002){
                        LED = QOI_OP_LUMA | (dg + 32);
                            signed char dr_dg = dr - dg;
                            signed char db_dg = db - dg;
                        LED = ((dr_dg + 8) << 4) | (db_dg + 8);
                    }else if (chunk_result == 0x00000003){
                        LED = (QOI_OP_RGB);
                        LED = (r_cur);
                        LED = (g_cur);
                        LED = (b_cur);
                    }else if (chunk_result == 0x00000004){
                        LED = (QOI_OP_RGB);
                        LED = (r_cur);
                        LED = (g_cur);
                        LED = (b_cur);
                    }else{
                        //LED = chunk_result;
                        LED = 0xEAE;
                    }

                    //  if ((dr >= -2 && dr <= 1) && (dg >= -2 && dg <= 1) && (db >= -2 && db <= 1)) {

                    //      //LED = QOI_OP_DIFF | ((dr + 2) << 4) | ((dg + 2) << 2) | (db + 2);
                    //      LED = 0b01000000 | ((dr + 2) << 4) | ((dg + 2) << 2) | (db + 2);

                    //  } else if (dg >= -32 && dg <= 31) {

                    //      signed char dr_dg = dr - dg;
                    //      signed char db_dg = db - dg;

                    //      if ((dr_dg >= -8 && dr_dg <= 7) && (db_dg >= -8 && db_dg <= 7)) {
                    //          LED = QOI_OP_LUMA | (dg + 32);
                    //          LED = ((dr_dg + 8) << 4) | (db_dg + 8);
                    //      } else {

                    //          LED = (QOI_OP_RGB);
                    //          LED = (r_cur);
                    //          LED = (g_cur);
                    //          LED = (b_cur);
                    //      }
                    //  } else {

                    //      LED = (QOI_OP_RGB);
                    //      LED = (r_cur);
                    //      LED = (g_cur);
                    //      LED = (b_cur);
                    //  }
                }
		
                r_prev = r_cur;
                g_prev = g_cur;
                b_prev = b_cur;
            }
        }
    }

    // Flush any remaining run
    if (run > 0) {
        LED = QOI_OP_RUN | (run - 1);
    }

    // Write end marker
    LED = 0x00;
    LED = 0x00;
    LED = 0x00;
    LED = 0x00;
    LED = 0x00;
    LED = 0x00;
    LED = 0x00;
    LED = 0x01;

    TCNT_stop();

    return 0;
}
