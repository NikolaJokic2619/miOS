[org 0x7c00]
[bits 16]

KERNEL_OFFSET equ 0x1000
NUM_SECTORS equ 18

start:
	cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov bp, 0x9000
    mov sp, bp
    sti
    
    mov [BOOT_DRIVE], dl

    mov ah, 0x00
    mov al, 0x03
    int 0x10

    cld         
    mov si, welcome_msg
	call print_string
	
	mov si, switching_to_pm_msg
	call print_string

	call disk_load
	call switch_to_pm

	jmp $

BOOT_DRIVE db 0

%include "../print/print_string.asm"
%include "../disk/disk_load.asm"
%include "../data/data.asm"
%include "../pmode/gdt.asm"
%include "../pmode/switch_to_pm.asm"
%include "../pmode/print_string_pm.asm"
%include "../pmode/load_kernel.asm"

[bits 32]

BEGIN_PM:
    mov ebx, pm_msg
    call print_string_pm
    
    jmp KERNEL_OFFSET
    
    jmp $

times 510 -($ - $$) db 0
dw 0xaa55
