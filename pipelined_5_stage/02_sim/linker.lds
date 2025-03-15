
OUTPUT_ARCH("riscv")

ENTRY(_start)

MEMORY
{
    IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 32k   /* 32k size for instruction memory */
    DMEM (rwx) : ORIGIN = 0x00008000, LENGTH = 32k   /* 32k size for data memory */
}

SECTIONS
{
    . = 0x00000000;
    .startup : 
    {
        startup.o(.text) 
    } > IMEM

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
        . = 0x00000400; 
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
    }
}
