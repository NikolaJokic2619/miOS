[bits 32]

global _start
extern kernel_main

section .text.entry

_start:
    mov esp, 0x90000
    call kernel_main
	
	jmp $
