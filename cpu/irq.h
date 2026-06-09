#ifndef IRQ_H
#define IRQ_H

#include "isr.h"

typedef void (*irq_handler_t)(registers_t *regs);

void irq_init(void);
void irq_register_handler(int irq, irq_handler_t handler);

extern uint32_t irq_stub_table[16];

#endif
