;Simple program to initialize stuff
.set IOPORT = 0x4000
.set SRAMPORT = 0x1B0000

.macro STACK_STUFF
	ldi r16, 0xFF
	out CPU_SPL, r16			;initialize low byte of stack pointer
	ldi r16, 0x3F
	out CPU_SPH, r16			;initialize high byte of stack pointer
.endmacro

.macro EBI_INIT
	ldi r16, 0x17
	sts PORTH_DIR, r16 //set port pins as outputs for RE and ALE and WE

	ldi r16, 0x13
	sts PORTH_OUT, r16 //WE and RE is active low so it must be set

	ldi r16, 0xFF
	sts PORTJ_DIR, r16 //set datalines as outputs
	sts PORTK_DIR, r16 //set address lines as outputs

	ldi r16, 0x01
	sts EBI_CTRL, r16 //turn on 3 port SRAM ALE1 EBI
.endmacro

.macro CS0_INIT
	ldi ZH, HIGH(EBI_CS0_BASEADDR) //all the set up for CS0, since EBI won't work without it
	ldi ZL, LOW(EBI_CS0_BASEADDR)
	ldi r16, ((IOPORT>>8) & 0xF0)
	st Z+, r16
	ldi r16, ((IOPORT>>16) & 0xFF)
	st Z, r16
	ldi r16, 0x11
	sts EBI_CS0_CTRLA, r16
	ldi XH, HIGH(IOPORT)
	ldi XL, LOW(IOPORT)
.endmacro

.macro CS1_INIT
	ldi ZH, HIGH(EBI_CS1_BASEADDR) //set up CS1 for the SRAM
	ldi ZL, LOW(EBI_CS1_BASEADDR)
	ldi r16, ((SRAMPORT>>8) & 0xF0)
	st Z+, r16
	ldi r16, ((SRAMPORT>>16) & 0xFF)
	st Z, r16

	ldi r16, 0b00011101
	sts EBI_CS1_CTRLA, r16
.endmacro

