#ifndef PORTS_H
#define PORTS_H

/* Read one byte from an I/O port. */
static inline unsigned char port_byte_in(unsigned short port)
{
    unsigned char result;
    __asm__ volatile ("inb %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}

/* Write one byte to an I/O port. */
static inline void port_byte_out(unsigned short port, unsigned char data)
{
    __asm__ volatile ("outb %0, %1" : : "a"(data), "Nd"(port));
}

/* Read one word (2 bytes) from an I/O port. */
static inline unsigned short port_word_in(unsigned short port)
{
    unsigned short result;
    __asm__ volatile ("inw %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}

/* Write one word (2 bytes) to an I/O port. */
static inline void port_word_out(unsigned short port, unsigned short data)
{
    __asm__ volatile ("outw %0, %1" : : "a"(data), "Nd"(port));
}

#endif /* PORTS_H */
