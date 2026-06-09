[bits 32]
[extern irq_handler]

%macro irq_stub 2
global irq_stub_%1
irq_stub_%1:
    push dword 0        
    push dword %2       ; IDT vector number 
    jmp irq_common_stub
%endmacro

irq_common_stub:
    pusha               ; Save edi, esi, ebp, esp, ebx, edx, ecx, eax
 
    mov ax, ds
    push eax            ; Save current data segment descriptor
 
    mov ax, 0x10  
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
 
    mov eax, esp        ; esp points to the start of our registers_t frame
    push eax            
    call irq_handler
    add esp, 4          
 
    pop eax             ; Restore data segment descriptor
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
 
    popa              
    add esp, 8          ; Clean up pushed dummy error code and vector number
    iret

; Generate IRQ stubs 0 to 15 mapped to IDT vectors 32 to 47
irq_stub 0, 32
irq_stub 1, 33
irq_stub 2, 34
irq_stub 3, 35
irq_stub 4, 36
irq_stub 5, 37
irq_stub 6, 38
irq_stub 7, 39
irq_stub 8, 40
irq_stub 9, 41
irq_stub 10, 42
irq_stub 11, 43
irq_stub 12, 44
irq_stub 13, 45
irq_stub 14, 46
irq_stub 15, 47

global irq_stub_table
irq_stub_table:
%assign i 0
%rep    16
    dd irq_stub_%+i
%assign i i+1
%endrep
