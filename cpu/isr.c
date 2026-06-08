#include "isr.h"
#include "idt.h"

/* Human-readable names for the 32 CPU exception vectors */
static const char *exception_messages[32] = {
    "Division By Zero",           /*  0 */
    "Debug",                      /*  1 */
    "Non-Maskable Interrupt",     /*  2 */
    "Breakpoint",                 /*  3 */
    "Overflow",                   /*  4 */
    "Bound Range Exceeded",       /*  5 */
    "Invalid Opcode",             /*  6 */
    "Device Not Available",       /*  7 */
    "Double Fault",               /*  8 */
    "Coprocessor Segment Overrun",/*  9 */
    "Invalid TSS",                /* 10 */
    "Segment Not Present",        /* 11 */
    "Stack-Segment Fault",        /* 12 */
    "General Protection Fault",   /* 13 */
    "Page Fault",                 /* 14 */
    "Reserved",                   /* 15 */
    "x87 Floating-Point",         /* 16 */
    "Alignment Check",            /* 17 */
    "Machine Check",              /* 18 */
    "SIMD Floating-Point",        /* 19 */
    "Virtualization Exception",   /* 20 */
    "Control Protection",         /* 21 */
    "Reserved",                   /* 22 */
    "Reserved",                   /* 23 */
    "Reserved",                   /* 24 */
    "Reserved",                   /* 25 */
    "Reserved",                   /* 26 */
    "Reserved",                   /* 27 */
    "Hypervisor Injection",       /* 28 */
    "VMM Communication",          /* 29 */
    "Security Exception",         /* 30 */
    "Reserved",                   /* 31 */
};

void isr_init(void)
{
    for (int i = 0; i < 32; i++)
        idt_set_gate(i, isr_stub_table[i]);
}

static void panic_print(const char *msg)
{
    volatile unsigned short *vga = (volatile unsigned short *)0xB8000;
    unsigned char color = 0x4F; 
 

    for (int i = 0; i < 80; i++)
        vga[i] = (unsigned short)(color << 8 | ' ');
 
    const char *prefix = "EXCEPTION: ";
    for (int i = 0; prefix[i]; i++)
        vga[i] = (unsigned short)(color << 8 | (unsigned char)prefix[i]);
 
    
    int col = 11;
    for (int i = 0; msg[i] && col < 80; i++, col++)
        vga[col] = (unsigned short)(color << 8 | (unsigned char)msg[i]);
}


void exception_handler(registers_t *regs)
{
    const char *msg = (regs->int_no < 32) ? exception_messages[regs->int_no] : "Unknown Exception";
 
    panic_print(msg);
 
    while(1) {
        __asm__ volatile ("cli; hlt");
    }
}
