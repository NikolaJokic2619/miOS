[bits 32]
[extern exception_handler] 

;--------------------------------------------------------------------------
; Common stub — all ISR stubs jump here after pushing vector + error code.
; Stack layout on entry to exception_handler (low → high address):
;   [esp+0 ] = edi  ─┐
;   [esp+4 ] = esi   |
;   [esp+8 ] = ebp   |  pusha
;   [esp+12] = esp   |
;   [esp+16] = ebx   |
;   [esp+20] = edx   |
;   [esp+24] = ecx   |
;   [esp+28] = eax  ─┘
;   [esp+32] = int_no   (pushed by stub)
;   [esp+36] = err_code (pushed by stub or CPU)
;   [esp+40] = eip  ─┐
;   [esp+44] = cs    |  pushed by CPU on interrupt
;   [esp+48] = eflags┘
;--------------------------------------------------------------------------

%macro isr_no_err_stub 1
isr_stub_%1:
    push dword 0
    push dword %1       ; vector number
    jmp isr_common_stub
%endmacro

%macro isr_err_stub 1
isr_stub_%1:
    push dword %1       ; vector number (CPU already pushed error code)
    jmp isr_common_stub
%endmacro

isr_common_stub:
    pusha               ; save edi,esi,ebp,esp,ebx,edx,ecx,eax
 
    mov ax, ds
    push eax            ; save ds
 
    mov ax, 0x10        ; kernel data segment
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
 
    mov eax, esp        
    push eax            
    call exception_handler
    add esp, 4          
 
    pop eax             
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
 
    popa              
    add esp, 8          ; pop int_no and err_code
    iret

isr_no_err_stub 0
isr_no_err_stub 1
isr_no_err_stub 2
isr_no_err_stub 3
isr_no_err_stub 4
isr_no_err_stub 5
isr_no_err_stub 6
isr_no_err_stub 7
isr_err_stub    8
isr_no_err_stub 9
isr_err_stub    10
isr_err_stub    11
isr_err_stub    12
isr_err_stub    13
isr_err_stub    14
isr_no_err_stub 15
isr_no_err_stub 16
isr_err_stub    17
isr_no_err_stub 18
isr_no_err_stub 19
isr_no_err_stub 20
isr_no_err_stub 21
isr_no_err_stub 22
isr_no_err_stub 23
isr_no_err_stub 24
isr_no_err_stub 25
isr_no_err_stub 26
isr_no_err_stub 27
isr_no_err_stub 28
isr_no_err_stub 29
isr_err_stub    30
isr_no_err_stub 31

global isr_stub_table
isr_stub_table:
%assign i 0
%rep    32
    dd isr_stub_%+i
%assign i i+1
%endrep
