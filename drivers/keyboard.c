#include "keyboard.h"
#include "screen.h"
#include "ports.h"
#include "../cpu/isr.h"

static const char scancode_map[] = {
    0,   0,  '1','2','3','4','5','6','7','8','9','0','-','=', 0,  0,
   'q','w','e','r','t','y','u','i','o','p','[',']','\n', 0, 'a','s',
   'd','f','g','h','j','k','l',';','\'','`', 0, '\\','z','x','c','v',
   'b','n','m',',','.','/', 0,  0,  0, ' '
};

static void keyboard_callback(registers_t *regs)
{
    (void)regs;
    uint8_t scancode = port_byte_in(0x60);
    print("K");
}

void keyboard_install(void)
{
    irq_register(1, keyboard_callback);
}
