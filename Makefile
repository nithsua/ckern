CC = clang++
CFLAGS = -c -I src/intf --target=x86_64-elf --ffreestanding -mno-red-zone -std=c++20 -Wall -Wextra

kernel_source_files := $(shell find src/impl/kernel -name *.cpp)
kernel_object_files := $(patsubst src/impl/kernel/%.cpp, build/kernel/%.o, $(x86_64_cpp_source_files))

x86_64_cpp_source_files := $(shell find src/impl/x86_64 -name *.cpp)
x86_64_cpp_object_files := $(patsubst src/impl/x86_64/%.cpp, build/x86_64/%.o, $(x86_64_cpp_source_files))

x86_64_asm_source_files := $(shell find src/impl/x86_64 -name *.asm)
x86_64_asm_object_files := $(patsubst src/impl/x86_64/%.asm, build/x86_64/%.o, $(x86_64_asm_source_files))

x86_64_object_files := $(x86_64_cpp_object_files) $(x86_64_asm_object_files)

$(kernel_object_files): build/kernel/%.o : src/impl/kernel/%.cpp
	mkdir -p $(dir $@) && \
	build/kernel/%.o: src/impl/kernel/%.cpp
		$(CC) $(CFLAGS) $< -o $@

$(x86_64_cpp_object_files): build/x86_64/%.o : src/impl/x86_64/%.cpp
	mkdir -p $(dir $@) && \
	build/x86_64/%.o: src/impl/x86_64/%.cpp
		$(CC) $(CFLAGS) $< -o $@

$(x86_64_asm_object_files): build/x86_64/%.o : src/impl/x86_64/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/x86_64/%.o, src/impl/x86_64/%.asm, $@) -o $@

.PHONY: build-x86_64
build-x86_64: $(kernel_object_files) $(x86_64_object_files)
	mkdir -p dist/x86_64
	mkdir -p targets/x86_64/iso/boot/limine
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(kernel_object_files) $(x86_64_object_files)
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin
	cp /opt/homebrew/share/limine/limine-bios.sys targets/x86_64/iso/boot/limine/
	cp /opt/homebrew/share/limine/limine-bios-cd.bin targets/x86_64/iso/boot/limine/
	xorriso -as mkisofs \
			-b boot/limine/limine-bios-cd.bin \
			-no-emul-boot -boot-load-size 4 -boot-info-table \
			targets/x86_64/iso -o dist/x86_64/kernel.iso
	limine bios-install dist/x86_64/kernel.iso
