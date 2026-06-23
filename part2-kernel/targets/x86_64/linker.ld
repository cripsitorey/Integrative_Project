ENTRY(start)

SECTIONS {
    /* Load the kernel at 1 MB physical address */
    . = 1M;

    .boot :
    {
        /* Multiboot2 header must be within first 32 KB of the image */
        KEEP(*(.multiboot_header))
    }

    .text :
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(COMMON)
        *(.bss)
    }
}
