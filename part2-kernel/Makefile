ARCH        = x86_64
SRC_DIR     = src
BUILD_DIR   = build
ISO_DIR     = isodir
TARGETS_DIR = targets
IMAGE_NAME  = uide-kernel-builder

ASM      = nasm
CC       = x86_64-elf-gcc
LD       = x86_64-elf-ld
ASMFLAGS = -f elf64
CFLAGS   = -ffreestanding -O2 -Wall -Wextra -mno-red-zone -mno-mmx -mno-sse -mno-sse2
LDFLAGS  = -n -T $(TARGETS_DIR)/$(ARCH)/linker.ld

OBJS = $(BUILD_DIR)/header.o \
       $(BUILD_DIR)/main.o   \
       $(BUILD_DIR)/kernel.o \
       $(BUILD_DIR)/print.o

KERNEL_BIN = $(BUILD_DIR)/kernel.bin
ISO        = kernel.iso

.PHONY: all docker-build build-kernel run clean

# Host target: build image then compile inside container
all: docker-build

docker-build:
	docker build -t $(IMAGE_NAME) .
	docker run --rm -v "$$(pwd)":/root/kernel $(IMAGE_NAME) make build-kernel

# Compile target (executed inside container)
build-kernel: $(ISO)

$(BUILD_DIR)/header.o: $(SRC_DIR)/$(ARCH)/boot/header.asm
	@mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(BUILD_DIR)/main.o: $(SRC_DIR)/$(ARCH)/boot/main.asm
	@mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(BUILD_DIR)/kernel.o: $(SRC_DIR)/$(ARCH)/kernel/kernel.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/print.o: $(SRC_DIR)/$(ARCH)/kernel/print.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_BIN): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

$(ISO): $(KERNEL_BIN)
	@mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL_BIN) $(ISO_DIR)/boot/kernel.bin
	cp $(TARGETS_DIR)/$(ARCH)/grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $@ $(ISO_DIR) 2>/dev/null
	@echo "ISO generada: $@"

run: $(ISO)
	qemu-system-x86_64 -cdrom $(ISO)

clean:
	rm -rf $(BUILD_DIR) $(ISO_DIR)
