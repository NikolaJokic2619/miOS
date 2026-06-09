#ifndef PORTS_H
#define PORTS_H

#include <stdint.h>

// Read one byte from an io port.
static inline uint8_t inb(uint16_t port)
{
    uint8_t result;
    __asm__ volatile ("inb %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}

// Write one byte to an io port.
static inline void outb(uint16_t port, uint8_t data)
{
    __asm__ volatile ("outb %0, %1" : : "a"(data), "Nd"(port));
}

//Read one word from an io port.
static inline uint16_t inw(uint16_t port)
{
    uint16_t result;
    __asm__ volatile ("inw %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}

//Write one word to an io port.
static inline void outw(uint16_t port, uint16_t data)
{
    __asm__ volatile ("outw %0, %1" : : "a"(data), "Nd"(port));
}

//Delay
static inline void io_wait(void)
{
    outb(0x80, 0);
}

#endif
