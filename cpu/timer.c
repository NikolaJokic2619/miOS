#include "timer.h"
#include "irq.h"
#include "pic.h"
#include "../drivers/ports.h"


static volatile uint32_t ticks = 0;
static uint32_t ticks_per_sec = 0;

static void timer_callback(__attribute__((unused)) registers_t *regs)
{
    ticks++;
}

void timer_init(uint32_t frequency_hz)
{
    ticks_per_sec = frequency_hz;

    uint32_t divisor = PIT_BASE_FREQ / frequency_hz;

    outb(PIT_COMMAND, 0x36);

    outb(PIT_CHANNEL0, (uint8_t)(divisor & 0xFF));
    outb(PIT_CHANNEL0, (uint8_t)((divisor >> 8) & 0xFF));

    irq_register_handler(0, timer_callback);
}

uint32_t timer_get_ticks(void)
{
    return ticks;
}


void timer_sleep(uint32_t s)
{   
    IRQ_set_mask(1);
    
    uint32_t ticks_to_wait = (ticks_per_sec * s);
    uint32_t start = ticks;
    while ((ticks - start) < ticks_to_wait) {
        __asm__ volatile ("hlt");
    }  

    while (inb(0x64) & 0x01)
        inb(0x60);
    
    IRQ_clear_mask(1);
}
