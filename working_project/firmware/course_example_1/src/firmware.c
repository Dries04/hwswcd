int main(void) {
    unsigned char r[C_HEIGHT][C_WIDTH];
    unsigned char g[C_HEIGHT][C_WIDTH];
    unsigned char b[C_HEIGHT][C_WIDTH];
    unsigned char a[C_HEIGHT][C_WIDTH];

    unsigned char r_prev = 0, g_prev = 0, b_prev = 0, a_prev = 255;
    int run = 0;
    unsigned int running_array[64];
    int i;

    for (i = 0; i < 64; i++) {
        running_array[i] = 0;
    }

    initialise(r, g, b, a);

    // Write header directly to LED
    LED = 'q'; LED = 'o'; LED = 'i'; LED = 'f';
    LED = 0; LED = 0; LED = 0; LED = C_WIDTH;
    LED = 0; LED = 0; LED = 0; LED = C_HEIGHT;
    LED = 3; LED = 0;

    for (i = 0; i < C_HEIGHT; i++) {
        for (int j = 0; j < C_WIDTH; j++) {
            unsigned char r_cur = r[i][j];
            unsigned char g_cur = g[i][j];
            unsigned char b_cur = b[i][j];
            unsigned char a_cur = 255;

            if (r_cur == r_prev && g_cur == g_prev && b_cur == b_prev && a_cur == a_prev) {
                run++;
                if (run == 62) {
                    LED = QOI_OP_RUN | (run - 1);
                    run = 0;
                }
            } else {
                if (run > 0) {
                    LED = QOI_OP_RUN | (run - 1);
                    run = 0;
                }

                unsigned char index = pixel_hash(r_cur, g_cur, b_cur, a_cur);
                unsigned int current_pixel = ((unsigned int)r_cur << 24) | ((unsigned int)g_cur << 16) | ((unsigned int)b_cur << 8) | a_cur;

                if (running_array[index] == current_pixel) {
                    LED = QOI_OP_INDEX | index;
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
                        LED = QOI_OP_DIFF | ((dr + 2) << 4) | ((dg + 2) << 2) | (db + 2);
                    } else if (dg >= -32 && dg <= 31) {
                        int dr_dg = dr - dg;
                        int db_dg = db - dg;

                        if ((dr_dg >= -8 && dr_dg <= 7) && (db_dg >= -8 && db_dg <= 7)) {
                            LED = QOI_OP_LUMA | (dg + 32);
                            LED = ((dr_dg + 8) << 4) | (db_dg + 8);
                        } else {
                            LED = QOI_OP_RGB;
                            LED = r_cur;
                            LED = g_cur;
                            LED = b_cur;
                        }
                    } else {
                        LED = QOI_OP_RGB;
                        LED = r_cur;
                        LED = g_cur;
                        LED = b_cur;
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

    return 0;
}
