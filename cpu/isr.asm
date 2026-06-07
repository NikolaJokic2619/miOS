[bits 32]
[extern isr_handler]

%macro ISR_NOERRCODE 1
    global isr%1
    isr%1:
        cli
        push byte 0
        push byte %1
        jmp isr_common
%endmacro

%macro ISR_ERRCODE 1
    global isr%1
    isr%1:
        cli
        push byte %1
        jmp isr_common
%endmacro

ISR_NOERRCODE 0   ; divide by zero
ISR_NOERRCODE 1   ; debug
ISR_NOERRCODE 2   ; non-maskable interrupt
ISR_NOERRCODE 3   ; breakpoint
ISR_NOERRCODE 4   ; overflow
ISR_NOERRCODE 5   ; bound range exceeded
ISR_NOERRCODE 6   ; invalid opcode
ISR_NOERRCODE 7   ; device not available
ISR_ERRCODE   8   ; double fault
ISR_NOERRCODE 9   ; coprocessor segment overrun
ISR_ERRCODE   10  ; invalid TSS
ISR_ERRCODE   11  ; segment not present
ISR_ERRCODE   12  ; stack fault
ISR_ERRCODE   13  ; general protection fault
ISR_ERRCODE   14  ; page fault
ISR_NOERRCODE 15
ISR_NOERRCODE 16  ; x87 floating point
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31

isr_common:
    pusha
    mov ax, ds
    push eax
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    call isr_handler
    pop eax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    popa
    add esp, 8
    sti
    iret
    
    
%macro IRQ 2
global irq%1
irq%1:
    cli
    push byte %2   ; int_no first
    push byte 0    ; err_code second
    jmp irq_common_stub
%endmacro

IRQ  0, 32
IRQ  1, 33
IRQ  2, 34
IRQ  3, 35
IRQ  4, 36
IRQ  5, 37
IRQ  6, 38
IRQ  7, 39
IRQ  8, 40
IRQ  9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46
IRQ 15, 47

extern irq_handler
irq_common_stub:
    pusha
    mov ax, ds
    push eax
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    call irq_handler
    pop eax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    popa
    add esp, 8
    sti
    iret
