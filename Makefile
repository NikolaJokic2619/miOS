ASM = nasm
CC = i686-elf-gcc
LD = i686-elf-ld

SRC_DIR     = boot/src
BOOT_DIR    = boot
KERNEL_DIR  = kernel
DRIVERS_DIR = drivers
BUILD_DIR   = build

all: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/main.bin
	cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/main_floppy.img
	truncate -s 1440k $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main.bin: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	cat $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin > $(BUILD_DIR)/main.bin

$(BUILD_DIR)/boot.bin: $(SRC_DIR)/main.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) -I$(BOOT_DIR)/src/ -I$(BOOT_DIR)/ $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/entry.o: $(KERNEL_DIR)/entry.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) -f elf32 $(KERNEL_DIR)/entry.asm -o $(BUILD_DIR)/entry.o

$(BUILD_DIR)/kernel.o: $(KERNEL_DIR)/kernel.c
	$(CC) -ffreestanding -fno-pic -nostdlib -I$(DRIVERS_DIR) -c $(KERNEL_DIR)/kernel.c -o $(BUILD_DIR)/kernel.o

$(BUILD_DIR)/screen.o: $(DRIVERS_DIR)/screen.c
	$(CC) -ffreestanding -fno-pic -nostdlib -I$(DRIVERS_DIR) -c $(DRIVERS_DIR)/screen.c -o $(BUILD_DIR)/screen.o
	
$(BUILD_DIR)/idt.o: cpu/idt.c
	$(CC) -ffreestanding -fno-pic -nostdlib -I drivers/ -c cpu/idt.c -o $(BUILD_DIR)/idt.o

$(BUILD_DIR)/isr.o: cpu/isr.c
	$(CC) -ffreestanding -fno-pic -nostdlib -I drivers/ -c cpu/isr.c -o $(BUILD_DIR)/isr.o

$(BUILD_DIR)/isr_asm.o: cpu/isr.asm
	$(ASM) -f elf32 cpu/isr.asm -o $(BUILD_DIR)/isr_asm.o

$(BUILD_DIR)/keyboard.o: $(DRIVERS_DIR)/keyboard.c
	$(CC) -ffreestanding -fno-pic -nostdlib -I$(DRIVERS_DIR) -Icpu -c $(DRIVERS_DIR)/keyboard.c -o $(BUILD_DIR)/keyboard.o

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/entry.o $(BUILD_DIR)/kernel.o \
                          $(BUILD_DIR)/screen.o $(BUILD_DIR)/idt.o \
                          $(BUILD_DIR)/isr.o $(BUILD_DIR)/isr_asm.o \
                          $(BUILD_DIR)/keyboard.o
	$(LD) -m elf_i386 -Ttext=0x1000 --oformat binary $^ -o $@

run: $(BUILD_DIR)/main_floppy.img
	qemu-system-i386 -drive file=$(BUILD_DIR)/main_floppy.img,format=raw,if=floppy -no-reboot

clean:
	rm -rf $(BUILD_DIR)
