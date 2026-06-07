[bits 32]

VIDEO_MEMORY   equ 0xB8000
BYTES_PER_ROW  equ 160
WHITE_ON_BLACK equ 0x0F

cursor_pos dd 0

print_string_pm:
    pushad

    mov esi, ebx
    mov edx, [cursor_pos]
    add edx, VIDEO_MEMORY

.loop:
    lodsb
    test al, al
    jz .done

    cmp al, 0x0A
    je .newline

    mov ah, WHITE_ON_BLACK
    mov [edx], ax
    add edx, 2
    jmp .loop

.newline:
    mov eax, edx
    sub eax, VIDEO_MEMORY

    xor edx, edx
    mov ecx, BYTES_PER_ROW
    div ecx

    inc eax
    imul eax, ecx
    add eax, VIDEO_MEMORY

    mov edx, eax
    jmp .loop

.done:
    sub edx, VIDEO_MEMORY
    mov [cursor_pos], edx

    popad
    ret
