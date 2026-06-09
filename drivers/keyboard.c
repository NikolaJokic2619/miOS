#include "keyboard.h"
#include "../cpu/irq.h"
#include "../drivers/ports.h"
#include "../drivers/screen.h"

static int is_extended = 0;
static int shift_pressed = 0;

static const char scancode_ascii[] = {
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
  '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',   
    0,  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',   0,   
 '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',   0, '*',   0, ' '
};


static const char scancode_ascii_shift[] = {
    0,  27, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '\b',
  '\t', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', '\n',   
    0,  'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~',   0,   
  '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?',   0, '*',   0, ' '
};

void keyboard_callback(__attribute__((unused)) registers_t *regs)
{
    uint8_t scancode = inb(KEYBOARD_DATA_PORT);

    //Handle extended scan code prefix
    if (scancode == 0xE0) {
        is_extended = 1;
        return; 
    }

    //Handle key release
    if (scancode & 0x80) {
        uint8_t released_scancode = scancode & ~0x80;
        
        // Track if Left Shift (0x2A) or Right Shift (0x36) is released
        if (released_scancode == 0x2A || released_scancode == 0x36) {
            shift_pressed = 0;
        }
        
        is_extended = 0; // Clear the extended flag on release
        return; 
    }
    
    //Process extended keys
    if (is_extended) {
        switch(scancode) {
            case 0x48: print("[Up]");    break;
            case 0x50: print("[Down]");  break;
            case 0x4B: print("[Left]");  break;
            case 0x4D: print("[Right]"); break;
        }
        is_extended = 0;
        return;
    }

    //Track if Left Shift (0x2A) or Right Shift (0x36) is being held down
    if (scancode == 0x2A || scancode == 0x36) {
        shift_pressed = 1;
        return;
    }

    //Translate standard text characters
    if (scancode < sizeof(scancode_ascii)) {
        char ascii = shift_pressed ? scancode_ascii_shift[scancode] : scancode_ascii[scancode];
        
        if (ascii != 0) {
            char str[2] = {ascii, '\0'};
            print(str);
        }
    }
}

void keyboard_init(void)
{
    irq_register_handler(1, keyboard_callback);
}
