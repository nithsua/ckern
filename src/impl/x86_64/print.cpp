#include "print.h"
#include "font.h"

namespace {

Framebuffer g_fb{};
size_t g_col = 0;
size_t g_row = 0;
uint32_t g_fg = 0x00FFFFFF;
uint32_t g_bg = 0x00000000;

constexpr size_t FONT_W = 8;
constexpr size_t FONT_H = 16;

inline uint32_t* pixel_at(size_t x, size_t y) {
    auto* base = reinterpret_cast<uint8_t*>(g_fb.pixels);
    auto* row_base = base + y * g_fb.pitch_bytes;
    return reinterpret_cast<uint32_t*>(row_base) + x;
}

void draw_glyph(char c, size_t cell_x, size_t cell_y) {
    const uint8_t *glyph;
    if (c >= 0x20 && c < 0x7F) {
        glyph = font8x16[c - 0x20];
    } else {
        glyph = font8x16[0x7F - 0x20];
    }

    size_t px_x = cell_x * FONT_W;
    size_t px_y = cell_y * FONT_H;

    for (size_t r = 0; r < FONT_H; r++) {
        uint8_t bits = glyph[r];
        for (size_t c2 = 0; c2 < FONT_W; c2++) {
            bool on = (bits >> (FONT_W - 1 - c2)) & 1;
            *pixel_at(px_x + c2, px_y + r) = on ? g_fg : g_bg;
        }
    }
}

void advance_row() {
    g_col = 0;
    g_row++;
    if ((g_row + 1) * FONT_H > g_fb.height) {
        g_row = 0;
    }
}

}

void print_init(const Framebuffer& fb) {
    g_fb = fb;
    g_col = 0;
    g_row = 0;
}

void print_clear() {
    for (size_t y = 0; y < g_fb.height; y++) {
        for (size_t x = 0; x < g_fb.width; x++) {
            *pixel_at(x, y) = g_bg;
        }
    }
    g_col = 0;
    g_row = 0;
}

void print_char(char c) {
    if (c == '\n') {
        advance_row();
        return;
    }
    if ((g_col + 1) * FONT_W > g_fb.width) {
        advance_row();
    }
    draw_glyph(c, g_col, g_row);
    g_col++;
}

void print_str(const char *s) {
    while (*s) print_char(*s++);
}

void print_set_color(uint32_t fg, uint32_t bg) {
    g_fg = fg;
    g_bg = bg;
}
