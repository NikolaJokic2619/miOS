#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>

#define PIT_CHANNEL0 0x40
#define PIT_COMMAND  0x43
#define PIT_BASE_FREQ 1193182

void timer_init(uint32_t frequency_hz);
uint32_t timer_get_ticks(void);
void timer_sleep(uint32_t s);

#endif
