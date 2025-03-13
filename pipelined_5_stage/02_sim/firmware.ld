ENTRY(start)

MEMORY
{
    IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 32k   /* 32k size for instruction memory */
    DMEM (rwx) : ORIGIN = 0x00008000, LENGTH = 32k   /* 32k size for data memory */
}

SECTIONS {
    /* this part goes into the IMEM */
    .text : {
        . = 0x00000000;        /* IMEM starts at address 0x00000000 */
        *(.init);              /* Initialization code */
        *(.text*);             /* All the program code */
    } > IMEM

    /* this part goes into the DMEM */
    .data : {
        . = 0x00000000;        /* Data section starts at the beginning of DMEM */
        *(.data);              /* Initialized data section */
    } > DMEM

    /* Read-only data in the DMEM section */
    .rodata : {
        . = 0x00000400;        /* Read-only data starts at 0x00000400 in DMEM */
        *(.rodata);            /* Read-only data section */
        . = ALIGN(4);          /* Align to 4-byte boundaries */
        FILL(0xFF);            /* Fill the rest of the space with 0xFF */
    } > DMEM

    /* Discard unnecessary sections */
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
