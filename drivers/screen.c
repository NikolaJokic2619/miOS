#include "screen.h"
#include "ports.h"

static int get_screen_offset(int col, int row)
{
    return (row * MAX_COLS + col) * 2;
}



int get_cursor()
{
    int offset = 0;
    outb(REG_SCREEN_CTRL, 14);
    offset = inb(REG_SCREEN_DATA) << 8;
    outb(REG_SCREEN_CTRL, 15);
    offset |= inb(REG_SCREEN_DATA);
    
    return offset * 2;
}



void memory_copy(char* source, char* destination, int no_bytes)
{
    for(int i = 0; i < no_bytes; i++) 
    {
        destination[i] = source[i];
    }
}



int handle_scrolling(int cursor_offset)
{
    if(cursor_offset < MAX_ROWS * MAX_COLS * 2)
    {
        return cursor_offset;
    }
    
    for(int i = 1; i < MAX_ROWS; i++)
    {
        memory_copy(
        (char *)(get_screen_offset(0, i) + VIDEO_ADDRESS),
        (char *)(get_screen_offset(0, i - 1) + VIDEO_ADDRESS),
        MAX_COLS * 2
        );
    }
    
    char* last_line = (char *)(get_screen_offset(0, MAX_ROWS - 1) + VIDEO_ADDRESS);
    
    for(int i = 0; i < MAX_COLS * 2; i++)
    {
        last_line[i] = 0;
    }
    
    cursor_offset -= 2 * MAX_COLS;
    
    return cursor_offset;
}



void set_cursor(int offset) 
{
    offset /= 2;
    outb(REG_SCREEN_CTRL, 14);
    outb(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
    outb(REG_SCREEN_CTRL, 15);
    outb(REG_SCREEN_DATA, (unsigned char)(offset & 0xff));
}



void print_char(char character, int col, int row, char attribute_byte)
{
    unsigned char *vidmem = (unsigned char *) VIDEO_ADDRESS;
    
    if(!attribute_byte)
    {
        attribute_byte = WHITE_ON_BLACK;
    }
    
    int offset;
    
    if(col >= 0 && row >= 0)
    {
        offset = get_screen_offset(col, row);
    }
    else 
    {
        offset = get_cursor();
    }
    
    if(character == '\n')
    {
        int rows = offset / (2 * MAX_COLS);
        offset = get_screen_offset(MAX_COLS - 1, rows);
    }
    else
    {
        vidmem[offset] = character;
        vidmem[offset + 1] = attribute_byte;
    }
    
    offset += 2;
    offset = handle_scrolling(offset);
    
    set_cursor(offset);
}



void print_at(const char *message, int col, int row )
{
    if (col >= 0 && row >= 0) 
    {
        set_cursor(get_screen_offset(col, row));
    }

    for (int i = 0; message[i] != '\0'; i++)
        print_char(message[i], -1, -1, WHITE_ON_BLACK);
}



void print(const char* message)
{
    print_at(message, -1, -1);
}



void clear_screen()
{
    int row = 0;
    int col = 0;
    
    for (row = 0; row < MAX_ROWS; row++) 
    {
        for (col = 0; col < MAX_COLS; col++) 
        {
            print_char(' ', col, row, WHITE_ON_BLACK);
        }
    }
    
    set_cursor(0);
}














