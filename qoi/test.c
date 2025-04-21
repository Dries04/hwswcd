#include <stdio.h>

// Type definitions (replace stdint.h)
typedef unsigned char  uint8_t;
typedef unsigned int   uint32_t;

// Constants
#define QOI_OP_INDEX 0x00
#define QOI_OP_DIFF  0x40
#define QOI_OP_LUMA  0x80
#define QOI_OP_RUN   0xC0
#define QOI_OP_RGB   0xFE
#define QOI_OP_RGBA  0xFF

// Mask
#define QOI_MASK_2   0xC0

// Pixel struct
typedef struct {
    uint8_t r, g, b, a;
} Pixel;

// Index array
Pixel index_array[64];

// Pixel comparison (RGB)
int rgb_equal(const Pixel *a, const Pixel *b) {
    return (a->r == b->r) && (a->g == b->g) && (a->b == b->b);
}

// Pixel comparison (RGBA)
int rgba_equal(const Pixel *a, const Pixel *b) {
    return rgb_equal(a, b) && (a->a == b->a);
}

// Hash function (for index)
int pixel_hash(const Pixel *px) {
    return (px->r * 3 + px->g * 5 + px->b * 7 + px->a * 11) % 64;
}

// Write a byte to output buffer
void write_byte(uint8_t **p, uint8_t byte) {
    **p = byte;
    (*p)++;
}

// Write RGB pixel chunk
void write_pixel_rgb(uint8_t **p, const Pixel *px) {
    write_byte(p, QOI_OP_RGB);
    write_byte(p, px->r);
    write_byte(p, px->g);
    write_byte(p, px->b);
}

// Write RGBA pixel chunk
void write_pixel_rgba(uint8_t **p, const Pixel *px) {
    write_byte(p, QOI_OP_RGBA);
    write_byte(p, px->r);
    write_byte(p, px->g);
    write_byte(p, px->b);
    write_byte(p, px->a);
}

// QOI encode function (no stdlib, no struct return, no pass-by-value)
void qoi_encode(Pixel *pixels, int count, uint8_t *out) {
    Pixel prev = {0, 0, 0, 255}; // Initial previous pixel: black, opaque
    int run = 0;
    uint8_t *p = out;

    for (int i = 0; i < count; i++) {
        Pixel *px = &pixels[i];

        if (rgba_equal(px, &prev)) {
            run++;
            if (run == 62 || i == count - 1) {
                write_byte(&p, QOI_OP_RUN | (run - 1));
                run = 0;
            }
        } else {
            if (run > 0) {
                write_byte(&p, QOI_OP_RUN | (run - 1));
                run = 0;
            }

            int index_pos = pixel_hash(px);
            if (rgba_equal(&index_array[index_pos], px)) {
                write_byte(&p, QOI_OP_INDEX | index_pos);
            } else {
                index_array[index_pos] = *px;

                if (px->a == prev.a) {
                    int vr = (int)(px->r) - (int)(prev.r);
                    int vg = (int)(px->g) - (int)(prev.g);
                    int vb = (int)(px->b) - (int)(prev.b);

                    if (vr > -3 && vr < 2 &&
                        vg > -3 && vg < 2 &&
                        vb > -3 && vb < 2) {
                        write_byte(&p, QOI_OP_DIFF | ((vr + 2) << 4) | ((vg + 2) << 2) | (vb + 2));
                    } else {
                        int vg2 = vg;
                        int vgr = vr - vg2;
                        int vgb = vb - vg2;

                        if (vg2 > -33 && vg2 < 32 &&
                            vgr > -9 && vgr < 8 &&
                            vgb > -9 && vgb < 8) {
                            write_byte(&p, QOI_OP_LUMA | (vg2 + 32));
                            write_byte(&p, ((vgr + 8) << 4) | (vgb + 8));
                        } else {
                            write_pixel_rgb(&p, px);
                        }
                    }
                } else {
                    write_pixel_rgba(&p, px);
                }
            }

            prev = *px;
        }
    }

    // Write 7 zero bytes + 1 for QOI stream end marker
    for (int i = 0; i < 7; i++) {
        write_byte(&p, 0);
    }
    write_byte(&p, 1); // Final end marker

    // Print the output buffer
    for (uint8_t *ptr = out; ptr < p; ptr++) {
        printf("%02X ", *ptr);
    }
}