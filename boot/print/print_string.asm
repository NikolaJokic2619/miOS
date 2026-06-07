; ---------------------------------------------|
; print_string                                 |
; Input: SI = pointer to null-terminated string|
; Output: prints string to screen              |
; ---------------------------------------------|

print_string:
    pusha
        
.loop:
    lodsb
    test al, al
    jz .done
        
    mov ah, 0x0e
    mov bh, 0x00
        
    int 0x10
    
    jmp .loop
        
.done:
    popa
    ret
