ENTRY(start)

MEMORY 
{
	ROM (rx) : ORIGIN = 0x00000000, LENGTH = 2k
	RAM (rwx) : ORIGIN = 0x00000800, LENGTH = 2k
}
SECTIONS {
	/* this part has to go into the IMEM */
	.text : {
		. = 0x000000;
		*(.init);
		*(.text*);
	} > ROM

	/* this part has to go into the DMEM */
	.data : {
        . = 0x000;
		*(.data);
	} > RAM

	.rodata : {
        . = 0x400;
		*(.rodata);
		. = ALIGN(4);
		FILL(0xFF)
	} > RAM

    .padding ALIGN(4) : {
        . = ALIGN(4);
        . += 0x4; /* Voeg 256 bytes padding toe */
    } > RAM

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

