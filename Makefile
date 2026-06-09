ASM = nasm
CC  = i686-elf-gcc
LD  = i686-elf-ld

SRC_DIR     = boot/src
BOOT_DIR    = boot
KERNEL_DIR  = kernel
DRIVERS_DIR = drivers
CPU_DIR     = cpu
BUILD_DIR   = build

# Compiler flags shared across all C files
# Included "." so relative paths like "../drivers/ports.h" resolve perfectly from any directory
CFLAGS = -ffreestanding -fno-pic -nostdlib -I. -I$(DRIVERS_DIR) -I$(CPU_DIR) -Wall -Wextra

# ─────────────────────────────────────────────────────────────────────────────
# Top-level targets
# ─────────────────────────────────────────────────────────────────────────────
all: $(BUILD_DIR)/main_floppy.img

# ─────────────────────────────────────────────────────────────────────────────
# Floppy image
# ─────────────────────────────────────────────────────────────────────────────
$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/main.bin
	cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/main_floppy.img
	truncate -s 1440k $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main.bin: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	cat $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin > $(BUILD_DIR)/main.bin

# ─────────────────────────────────────────────────────────────────────────────
# Bootloader
# ─────────────────────────────────────────────────────────────────────────────
$(BUILD_DIR)/boot.bin: $(SRC_DIR)/main.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) -I$(BOOT_DIR)/src/ -I$(BOOT_DIR)/ $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/boot.bin

# ─────────────────────────────────────────────────────────────────────────────
# Kernel objects
# ─────────────────────────────────────────────────────────────────────────────
$(BUILD_DIR)/entry.o: $(KERNEL_DIR)/entry.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) -f elf32 $(KERNEL_DIR)/entry.asm -o $(BUILD_DIR)/entry.o

$(BUILD_DIR)/kernel.o: $(KERNEL_DIR)/kernel.c
	$(CC) $(CFLAGS) -c $(KERNEL_DIR)/kernel.c -o $(BUILD_DIR)/kernel.o

# ─────────────────────────────────────────────────────────────────────────────
# Driver objects
# ─────────────────────────────────────────────────────────────────────────────
$(BUILD_DIR)/screen.o: $(DRIVERS_DIR)/screen.c
	$(CC) $(CFLAGS) -c $(DRIVERS_DIR)/screen.c -o $(BUILD_DIR)/screen.o

# FIXED: Changed target from screen.o to keyboard.o
$(BUILD_DIR)/keyboard.o: $(DRIVERS_DIR)/keyboard.c
	$(CC) $(CFLAGS) -c $(DRIVERS_DIR)/keyboard.c -o $(BUILD_DIR)/keyboard.o

# ─────────────────────────────────────────────────────────────────────────────
# CPU objects
# ─────────────────────────────────────────────────────────────────────────────
$(BUILD_DIR)/idt.o: $(CPU_DIR)/idt.c
	$(CC) $(CFLAGS) -c $(CPU_DIR)/idt.c -o $(BUILD_DIR)/idt.o

$(BUILD_DIR)/isr.o: $(CPU_DIR)/isr.c
	$(CC) $(CFLAGS) -c $(CPU_DIR)/isr.c -o $(BUILD_DIR)/isr.o

$(BUILD_DIR)/isr_asm.o: $(CPU_DIR)/isr.asm
	$(ASM) -f elf32 $(CPU_DIR)/isr.asm -o $(BUILD_DIR)/isr_asm.o

$(BUILD_DIR)/pic.o: $(CPU_DIR)/pic.c
	$(CC) $(CFLAGS) -c $(CPU_DIR)/pic.c -o $(BUILD_DIR)/pic.o
	
$(BUILD_DIR)/irq_asm.o: $(CPU_DIR)/irq.asm
	$(ASM) -f elf32 $(CPU_DIR)/irq.asm -o $(BUILD_DIR)/irq_asm.o
	
$(BUILD_DIR)/irq.o: $(CPU_DIR)/irq.c
	$(CC) $(CFLAGS) -c $(CPU_DIR)/irq.c -o $(BUILD_DIR)/irq.o

$(BUILD_DIR)/timer.o: $(CPU_DIR)/timer.c
	$(CC) $(CFLAGS) -c $(CPU_DIR)/timer.c -o $(BUILD_DIR)/timer.o
# ─────────────────────────────────────────────────────────────────────────────
# Link kernel binary
# ─────────────────────────────────────────────────────────────────────────────
# Notice: entry.o stays at the very top so execution hits your setup assembly entry first!
KERNEL_OBJS = $(BUILD_DIR)/entry.o    \
              $(BUILD_DIR)/kernel.o   \
              $(BUILD_DIR)/screen.o   \
              $(BUILD_DIR)/keyboard.o \
              $(BUILD_DIR)/idt.o      \
              $(BUILD_DIR)/isr.o      \
              $(BUILD_DIR)/isr_asm.o  \
              $(BUILD_DIR)/pic.o      \
              $(BUILD_DIR)/irq.o      \
              $(BUILD_DIR)/timer.o    \
              $(BUILD_DIR)/irq_asm.o

$(BUILD_DIR)/kernel.bin: $(KERNEL_OBJS) $(KERNEL_DIR)/linker.ld
	$(LD) -m elf_i386 -T $(KERNEL_DIR)/linker.ld --oformat binary $(KERNEL_OBJS) -o $@

# ─────────────────────────────────────────────────────────────────────────────
# Run / debug
# ─────────────────────────────────────────────────────────────────────────────
run: $(BUILD_DIR)/main_floppy.img
	qemu-system-i386 -drive file=$(BUILD_DIR)/main_floppy.img,format=raw,if=floppy -no-reboot

debug: $(BUILD_DIR)/main_floppy.img
	qemu-system-i386 -drive file=$(BUILD_DIR)/main_floppy.img,format=raw,if=floppy -no-reboot -s -S

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run debug clean
