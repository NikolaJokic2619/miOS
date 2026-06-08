;----------------------------------------------|
; disk_load                                    |
; Inputs:                                      |
;   AL = number of sectors                     |
;   CH = cylinder                              |
;   CL = sector (starts at 1)                  |
;   DH = head                                  |
;   ES:BX = destination buffer                 |
;                                              |
;   Reads sectors using BIOS                   |      
;----------------------------------------------|

disk_load:
    pusha
    
    mov ah, 0x02	
	mov al, 0x30		
	mov dl, 0 		
	mov dh, 0 		
	mov ch, 0 		
	mov cl, 2		

	;mov bx, 0x0
	;mov es, bx
	mov bx, KERNEL_OFFSET
	int 0x13
	jc .disk_error
    
    cmp al, 0x30
    jne .disk_error 
    
    mov si, disk_read_msg
    call print_string
    
    popa 
    ret
    
.disk_error:
    mov si, disk_error_msg
    call print_string
    jmp $
