#include "print.h"
#include <cstddef>
#include <cstdint>

const static size_t NUM_COLS = 80;
const static size_t NUM_ROWS = 25;

struct Char {
  uint8_t character;
  uint8_t color;

  Char(uint8_t character, uint8_t color) : character(character), color(color) {}

  // Add this specific function
  void operator=(const Char &other) volatile {
    character = other.character;
    color = other.color;
  }

  Char(const volatile Char &other) {
    character = other.character;
    color = other.color;
  }
};

volatile Char *buffer = reinterpret_cast<volatile Char *>(0xb8000);
std::size_t col = 0;
std::size_t row = 0;
uint8_t color = PRINT_COLOR_WHITE | PRINT_COLOR_BLACK << 4;

void clear_row(size_t row) {
  Char empty = Char(' ', color);

  for (size_t col = 0; col < NUM_COLS; col++) {
    buffer[col + (NUM_COLS * row)] = empty;
  }
}

void print_newline() {
  col = 0;

  if (row < NUM_ROWS - 1) {
    row++;
    return;
  }

  for (size_t row = 1; row < NUM_ROWS; row++) {
    for (size_t col = 0; col < NUM_COLS; col++) {
      Char character = buffer[col + NUM_COLS * row];
      buffer[col + NUM_COLS * (row - 1)] = character;
    }
  }

  clear_row(NUM_COLS - 1);
}

void print_char(char character) {
  if (character == '\n') {
    print_newline();
    return;
  }

  if (col > NUM_COLS) {
    print_newline();
  }

  buffer[col + (NUM_COLS * row)] = Char(character, color);

  col++;
}

void print_str(char *str) {
  for (size_t i = 0; 1; i++) {
    char character = str[i];

    if (character == '\0') {
      return;
    }

    print_char(character);
  }
}

void print_clear() {
  for (size_t i = 0; i < NUM_ROWS; i++) {
    clear_row(i);
  }
}

void print_set_color(uint8_t foreground, uint8_t background) {
    color = foreground + (background << 4);
}
