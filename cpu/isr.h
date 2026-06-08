#ifndef ISR_H
#define ISR_H
 
#include <stdint.h>
#include "idt.h"

typedef struct {
    uint32_t edi, esi, ebp, esp;
    uint32_t ebx, edx, ecx, eax;
 
    uint32_t int_no;
    uint32_t err_code;
 
    uint32_t eip;
    uint32_t cs;
    uint32_t eflags;
} __attribute__((packed)) registers_t;

extern uint32_t isr_stub_table[32];

void isr_init(void);

void exception_handler(registers_t *regs);
 
#endif
