#include "isr.h"
#include "idt.h"
#include "../drivers/ports.h"
#include "../drivers/screen.h"

/* ISR externs */
#define ISR(n) extern void isr##n()
ISR(0);  ISR(1);  ISR(2);  ISR(3);  ISR(4);  ISR(5);  ISR(6);  ISR(7);
ISR(8);  ISR(9);  ISR(10); ISR(11); ISR(12); ISR(13); ISR(14); ISR(15);
ISR(16); ISR(17); ISR(18); ISR(19); ISR(20); ISR(21); ISR(22); ISR(23);
ISR(24); ISR(25); ISR(26); ISR(27); ISR(28); ISR(29); ISR(30); ISR(31);
#undef ISR

/* IRQ externs */
#define IRQ(n) extern void irq##n()
IRQ(0);  IRQ(1);  IRQ(2);  IRQ(3);  IRQ(4);  IRQ(5);  IRQ(6);  IRQ(7);
IRQ(8);  IRQ(9);  IRQ(10); IRQ(11); IRQ(12); IRQ(13); IRQ(14); IRQ(15);
#undef IRQ

/* registered handlers */
typedef void (*irq_handler_t)(registers_t *);
static irq_handler_t irq_handlers[16] = {0};

void irq_register(int irq, irq_handler_t handler)
{
    irq_handlers[irq] = handler;
}

static void pic_remap(void)
{
    port_byte_out(0x20, 0x11);
    port_byte_out(0xA0, 0x11);
    port_byte_out(0x21, 0x20); /* IRQ0-7  -> INT 32-39 */
    port_byte_out(0xA1, 0x28); /* IRQ8-15 -> INT 40-47 */
    port_byte_out(0x21, 0x04);
    port_byte_out(0xA1, 0x02);
    port_byte_out(0x21, 0x01);
    port_byte_out(0xA1, 0x01);
    port_byte_out(0x21, 0x01); /* mask IRQ0 */
    port_byte_out(0xA1, 0x00);
}

void isr_install(void)
{
    idt_set_gate(0,  (uint32_t)isr0);
    idt_set_gate(1,  (uint32_t)isr1);
    idt_set_gate(2,  (uint32_t)isr2);
    idt_set_gate(3,  (uint32_t)isr3);
    idt_set_gate(4,  (uint32_t)isr4);
    idt_set_gate(5,  (uint32_t)isr5);
    idt_set_gate(6,  (uint32_t)isr6);
    idt_set_gate(7,  (uint32_t)isr7);
    idt_set_gate(8,  (uint32_t)isr8);
    idt_set_gate(9,  (uint32_t)isr9);
    idt_set_gate(10, (uint32_t)isr10);
    idt_set_gate(11, (uint32_t)isr11);
    idt_set_gate(12, (uint32_t)isr12);
    idt_set_gate(13, (uint32_t)isr13);
    idt_set_gate(14, (uint32_t)isr14);
    idt_set_gate(15, (uint32_t)isr15);
    idt_set_gate(16, (uint32_t)isr16);
    idt_set_gate(17, (uint32_t)isr17);
    idt_set_gate(18, (uint32_t)isr18);
    idt_set_gate(19, (uint32_t)isr19);
    idt_set_gate(20, (uint32_t)isr20);
    idt_set_gate(21, (uint32_t)isr21);
    idt_set_gate(22, (uint32_t)isr22);
    idt_set_gate(23, (uint32_t)isr23);
    idt_set_gate(24, (uint32_t)isr24);
    idt_set_gate(25, (uint32_t)isr25);
    idt_set_gate(26, (uint32_t)isr26);
    idt_set_gate(27, (uint32_t)isr27);
    idt_set_gate(28, (uint32_t)isr28);
    idt_set_gate(29, (uint32_t)isr29);
    idt_set_gate(30, (uint32_t)isr30);
    idt_set_gate(31, (uint32_t)isr31);

    pic_remap();

    idt_set_gate(32, (uint32_t)irq0);
    idt_set_gate(33, (uint32_t)irq1);
    idt_set_gate(34, (uint32_t)irq2);
    idt_set_gate(35, (uint32_t)irq3);
    idt_set_gate(36, (uint32_t)irq4);
    idt_set_gate(37, (uint32_t)irq5);
    idt_set_gate(38, (uint32_t)irq6);
    idt_set_gate(39, (uint32_t)irq7);
    idt_set_gate(40, (uint32_t)irq8);
    idt_set_gate(41, (uint32_t)irq9);
    idt_set_gate(42, (uint32_t)irq10);
    idt_set_gate(43, (uint32_t)irq11);
    idt_set_gate(44, (uint32_t)irq12);
    idt_set_gate(45, (uint32_t)irq13);
    idt_set_gate(46, (uint32_t)irq14);
    idt_set_gate(47, (uint32_t)irq15);

    idt_install();
    __asm__ volatile("sti");
}

void irq_handler(registers_t *regs)
{
    int irq = regs->int_no - 32;

    /* print the actual int_no */
    char buf[3];
    buf[0] = '0' + (regs->int_no / 10);
    buf[1] = '0' + (regs->int_no % 10);
    buf[2] = 0;
    print(buf);

    if (irq_handlers[irq])
        irq_handlers[irq](regs);
    else
        print("NO_HANDLER");

    if (regs->int_no >= 40) {
        port_byte_out(0xA0, 0x20);
    }
    port_byte_out(0x20, 0x20);
}


void isr_handler(registers_t *regs)
{
    (void)regs;
    print("EXPECTION");
    while (1) {}
}



