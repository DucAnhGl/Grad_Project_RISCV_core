OUTPUT_ARCH("riscv")

ENTRY(_mystart)

MEMORY
{
    IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 64k   /* 32k size for instruction memory */
    DMEM (rwx) : ORIGIN = 0x00010000, LENGTH = 64k   /* 64k size for data memory */
}

SECTIONS
{
    . = 0x00000000;
    .text :
    {
        *(.text)
    } > IMEM

    .data :
    {
        . = 0x00000000;
        *(.data)
    } > DMEM

    .rodata :
    {
        . = 0x00008000; 
        . = ALIGN(4);          /* Align to 4-byte boundaries */
        FILL(0xFF);            /* Fill the rest of the space with 0xFF */
    } > DMEM

    /DISCARD/ :
    {
        *(.note*);
        *(.iplt*);
        *(.igot*);
        *(.rel*);
        *(.comment);
        *(.riscv.attributes);
        *(.debug);
    }
}
