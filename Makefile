CC = clang++
CFLAGS = -c -I src/intf --target=x86_64-elf -ffreestanding -Isrc/impl/intf -mno-red-zone -std=c++20 -Wall -Wextra

kernel_source_files := $(shell find src/impl/kernel -name *.cpp)
kernel_object_files := $(patsubst src/impl/kernel/%.cpp, build/kernel/%.o, $(kernel_source_files))

x86_64_cpp_source_files := $(shell find src/impl/x86_64 -name *.cpp)
x86_64_cpp_object_files := $(patsubst src/impl/x86_64/%.cpp, build/x86_64/%.o, $(x86_64_cpp_source_files))

x86_64_asm_source_files := $(shell find src/impl/x86_64 -name *.asm)
x86_64_asm_object_files := $(patsubst src/impl/x86_64/%.asm, build/x86_64/%.o, $(x86_64_asm_source_files))

x86_64_object_files := $(x86_64_cpp_object_files) $(x86_64_asm_object_files)

$(kernel_object_files): build/kernel/%.o : src/impl/kernel/%.cpp
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@

$(x86_64_cpp_object_files): build/x86_64/%.o : src/impl/x86_64/%.cpp
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@

$(x86_64_asm_object_files): build/x86_64/%.o : src/impl/x86_64/%.asm
	mkdir -p $(dir $@)
	nasm -f elf64 $< -o $@

OVMF_CODE := /opt/homebrew/share/qemu/edk2-x86_64-code.fd

.PHONY: build-x86_64
build-x86_64: $(kernel_object_files) $(x86_64_object_files)
	mkdir -p dist/x86_64
	mkdir -p targets/x86_64/iso/boot/limine
	mkdir -p targets/x86_64/iso/EFI/BOOT
	x86_64-elf-ld -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(kernel_object_files) $(x86_64_object_files)
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin
	cp /opt/homebrew/share/limine/limine-bios.sys targets/x86_64/iso/boot/limine/
	cp /opt/homebrew/share/limine/limine-bios-cd.bin targets/x86_64/iso/boot/limine/
	cp /opt/homebrew/share/limine/limine-uefi-cd.bin targets/x86_64/iso/boot/limine/
	cp /opt/homebrew/share/limine/BOOTX64.EFI targets/x86_64/iso/EFI/BOOT/
	xorriso -as mkisofs -R -r -J \
			-b boot/limine/limine-bios-cd.bin \
			-no-emul-boot -boot-load-size 4 -boot-info-table \
			--efi-boot boot/limine/limine-uefi-cd.bin \
			-efi-boot-part --efi-boot-image \
			--protective-msdos-label \
			targets/x86_64/iso -o dist/x86_64/kernel.iso
	limine bios-install dist/x86_64/kernel.iso

.PHONY: run
run: build-x86_64
	qemu-system-x86_64 \
		-drive if=pflash,format=raw,readonly=on,file=$(OVMF_CODE) \
		-cdrom dist/x86_64/kernel.iso \
		-m 256M
