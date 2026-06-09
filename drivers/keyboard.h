#ifndef KEYBOARD_H
#define KEYBOARD_H

#include "../cpu/isr.h"

// The I/O port for the PS/2 keyboard controller data buffer
#define KEYBOARD_DATA_PORT 0x60

void keyboard_init(void);
void keyboard_callback(registers_t *regs);

#endif
