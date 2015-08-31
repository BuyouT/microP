/*
 * Lab4_A_RSR.asm
 *
 *  Created: 6/15/2015 4:33:15 PM
 *   Author: stefano92
 Lab 4 part A
 Name: Ricardo Stefano Reyna
 Section#: 75C9
 TA: Khaled Hassan
 Description: This program will read from the keypad and echo in the LEDs
 */ 

.NOLIST
.include "ATxmega128A1Udef.inc"

.set IOPORT = 0x4000
.set IPORTEND = 0x4FFF 

.LIST
.org 0x0000		
	rjmp MAIN	;go to MAIN

.org 0x200
MAIN:
	ldi r16, 0xFF
	out CPU_SPL, r16
	ldi r16, 0x3F
	out CPU_SPH, r16 //init stack pointer

	ldi r16, 0x17
	sts PORTH_DIR, r16 //set port pins as outputs for RE and ALE and WE

	ldi r16, 0x13
	sts PORTH_OUT, r16 //WE and RE is active low so it must be set

	ldi r16, 0xFF
	sts PORTJ_DIR, r16 //set datalines as outputs
	sts PORTK_DIR, r16 //set address lines as outputs

	ldi r16, 0x01
	sts EBI_CTRL, r16 //turn on 3 port SRAM ALE1 EBI

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

/*|~~~~~~~~~~~~~~~~~~~~~~~~~
  |PROGRAM OF THE KEYBOARD
  |~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	ldi r16, 0b011000
	sts PORTF_PIN4CTRL, r16
	sts PORTF_PIN5CTRL, r16
	sts PORTF_PIN6CTRL, r16
	sts PORTF_PIN7CTRL, r16
PARTA:
	rcall KEYPAD //this will overwrite r18, will not exit until an input is recieved
	st X, r18 //Hold r18
	rjmp PARTA

KEYPAD:
	push r16
	push r17
	ldi r18, 0xFF //fill 18 with a value that can't get returned.  Notice it does not get pushed onto the stack!!!
	ldi r16, 0x0F
	sts PORTF_DIR, r16 //make sure the lower four bits are outputs and the upper are inputs

	ldi r16, 0x0E	//column 1
	sts PORTF_OUT, r16 //make the first column low and others high
	NOP
	NOP
	lds r17, PORTF_IN
	SBRS r17, 4	//row 1
	ldi r18, 0x1
	SBRS r17, 5 //row 2
	ldi r18, 0x4
	SBRS r17, 6 //row 3
	ldi r18,  0x7
	SBRS r17, 7 //row 4
	ldi r18, 0xE

	ldi r16, 0x0D //column 2
	sts PORTF_OUT, r16
	NOP
	NOP
	lds r17, PORTF_IN
	SBRS r17, 4	//row 1
	ldi r18, 0x2
	SBRS r17, 5	//row 2
	ldi r18, 0x5
	SBRS r17, 6	//row 3
	ldi r18,  0x8
	SBRS r17, 7	//row 4
	ldi r18, 0x0

	ldi r16, 0x0B //column 3
	sts PORTF_OUT, r16
	NOP
	NOP
	lds r17, PORTF_IN
	SBRS r17, 4	//row 1
	ldi r18, 0x3
	SBRS r17, 5	//row 2
	ldi r18, 0x6
	SBRS r17, 6	//row 3
	ldi r18,  0x9
	SBRS r17, 7	//row 4
	ldi r18, 0xF

	ldi r16, 0x07 // column 4
	sts PORTF_OUT, r16
	NOP
	NOP
	lds r17, PORTF_IN
	SBRS r17, 4	//row 1
	ldi r18, 0xA
	SBRS r17, 5	//row 2
	ldi r18, 0xB
	SBRS r17, 6	//row 3
	ldi r18,  0xC
	SBRS r17, 7	//row 4
	ldi r18, 0xD

DONE:
	pop r17
	pop r16
	RET