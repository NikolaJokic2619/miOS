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
CFLAGS = -ffreestanding -fno-pic -nostdlib -I$(DRIVERS_DIR) -I$(CPU_DIR)

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
#─────────────────────────────────────────────────────────────────────────────
# Link kernel binary
# ─────────────────────────────────────────────────────────────────────────────
$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/entry.o    \
                          $(BUILD_DIR)/kernel.o   \
                          $(BUILD_DIR)/screen.o   \
                          $(BUILD_DIR)/idt.o      \
                          $(BUILD_DIR)/isr.o      \
                          $(BUILD_DIR)/isr_asm.o  \
                          $(BUILD_DIR)/pic.o
	$(LD) -m elf_i386 -Ttext=0x1000 --oformat binary $^ -o $@

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
