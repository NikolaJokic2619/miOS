; Strings used for writing messages

welcome_msg: db 'Welcome to miOS bootloader!', 0x0D, 0x0A, 0
disk_read_msg: db 'Disk successfully read', 0x0D, 0x0A, 0
disk_error_msg: db 'Error reading disk', 0x0D, 0x0A, 0
switching_to_pm_msg: db 'Switching to 32-bit protected mode', 0x0D, 0x0A, 0
pm_msg: db 'Successfully entered 32-bit mode', 0x0A , 0
