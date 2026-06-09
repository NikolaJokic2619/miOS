#include "irq.h"
#include "idt.h"
#include "pic.h"
#include "../drivers/screen.h"

static irq_handler_t irq_handlers[16] = {0};

void irq_register_handler(int irq, irq_handler_t handler) 
{
    if (irq < 16) {
        irq_handlers[irq] = handler;
    }
}

void irq_init(void)
{
    for (int i = 0; i < 16; i++) {
        idt_set_gate(32 + i, irq_stub_table[i]);
    }
}

void irq_handler(registers_t *regs)
{
    if (regs->int_no < 32 || regs->int_no > 47)
        return;
    int irq = regs->int_no - 32;

    if (irq_handlers[irq] != 0) {
        irq_handlers[irq](regs);
    }

    PIC_sendEOI(irq);
}
