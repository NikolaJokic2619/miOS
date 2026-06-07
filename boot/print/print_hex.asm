; --------------------------------------------|
; print_hex                                   |
; Input : AX = 16-bit value                   |
; Output: prints 4 hex digits                 |
; --------------------------------------------|

print_hex:
    pusha
    mov cx, 4

.next_digit:
    rol ax, 4
    mov bx, ax
    and bx, 0x000f
    
    cmp bl, 9
    jg .letter
    
    add bl, '0'
    jmp .print
   
.letter:
    add bl, 'A' - 10
   
.print:
    push ax
    mov al, bl
    call print_char
    pop ax
    
    loop .next_digit
    
    mov ah, 0x0e
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    
    popa
    ret
