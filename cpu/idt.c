#include "idt.h"

static idt_gate_t     idt[IDT_ENTRIES];
static idt_register_t idt_reg;

void idt_set_gate(int n, uint32_t handler)
{
    idt[n].low_offset  = handler & 0xFFFF;
    idt[n].selector    = 0x08;        /* your CODE_SEG from gdt.asm */
    idt[n].always0     = 0;
    idt[n].flags       = 0x8E;
    idt[n].high_offset = (handler >> 16) & 0xFFFF;
}

void idt_install()
{
    idt_reg.limit = (sizeof(idt_gate_t) * IDT_ENTRIES) - 1;
    idt_reg.base  = (uint32_t)&idt;

    __asm__ volatile ("lidt (%0)" : : "r"(&idt_reg));
}
