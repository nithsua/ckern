OUTPUT_FORMAT(elf64-x86-64)
ENTRY(start)

PHDRS
{
    requests PT_LOAD FLAGS(6);
    text     PT_LOAD FLAGS(5);
}

SECTIONS
{
    . = 0xffffffff80000000;

    .limine_requests_start_marker : { KEEP(*(.limine_requests_start_marker)) } :requests
    .limine_requests              : { KEEP(*(.limine_requests))               } :requests
    .limine_requests_end_marker   : { KEEP(*(.limine_requests_end_marker))    } :requests

    . = ALIGN(0x1000);

    .text : { *(.text) } :text
    .rodata : { *(.rodata) } :text
}
