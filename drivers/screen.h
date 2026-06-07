#ifndef SCREEN_H
#define SCREEN_H

#define VIDEO_ADDRESS   0xb8000
#define MAX_ROWS        25
#define MAX_COLS        80
#define WHITE_ON_BLACK  0x0f

/* VGA cursor-control I/O ports */
#define REG_SCREEN_CTRL 0x3D4
#define REG_SCREEN_DATA 0x3D5

/* Print a single character at (col, row).
   Pass col=-1, row=-1 to use the current cursor position. */
void print_char(char character, int col, int row, char attribute_byte);

/* Print a null-terminated string starting at (col, row).
   Pass col=-1, row=-1 to continue from the current cursor. */
void print_at(const char *message, int col, int row);

/* Print at the current cursor position. */
void print(const char *message);

/* Fill the screen with spaces and home the cursor. */
void clear_screen(void);

#endif /* SCREEN_H */
