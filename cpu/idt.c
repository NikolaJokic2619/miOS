#include "idt.h"

static idt_entry_t idt[IDT_ENTRIES];
static idtr_t idtr;

void idt_set_gate(int n, uint32_t handler)
{
    idt[n].isr_low    = (uint16_t)(handler & 0xFFFF);
    idt[n].isr_high   = (uint16_t)((handler >> 16) & 0xFFFF);
    idt[n].kernel_cs  = 0x08;  
    idt[n].reserved   = 0x00;
    idt[n].attributes = 0x8E;
}

void idt_init(void)
{
    for (int i = 0; i < IDT_ENTRIES; i++) {
        idt[i].isr_low    = 0;
        idt[i].isr_high   = 0;
        idt[i].kernel_cs  = 0;
        idt[i].reserved   = 0;
        idt[i].attributes = 0;
    }
 
    idtr.limit = (uint16_t)(sizeof(idt_entry_t) * IDT_ENTRIES - 1);
    idtr.base  = (uint64_t)(uintptr_t)idt;

    __asm__ volatile ("lidt %0" : : "m"(idtr));
}
