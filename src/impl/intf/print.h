#pragma once

#include <stddef.h>
#include <stdint.h>

struct Framebuffer {
    uint32_t *pixels;
    uint64_t width;
    uint64_t height;
    uint64_t pitch_bytes;
};

void print_init(const Framebuffer& fb);
void print_clear();
void print_char(char c);
void print_str(const char *s);
void print_set_color(uint32_t fg, uint32_t bg);
