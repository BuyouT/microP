/*
 * Lab4_B_RSR.asm
 *
 *  Created: 6/16/2015 3:27:02 PM
 *   Author: stefano92
 Lab 4 part B
 Name: Ricardo Stefano Reyna
 Section#: 75C9
 TA: Khaled Hassan
 Description: This program will read from the keypad and echo in the LEDs
 */ 

.include "atxmega128a1udef.inc"
.set SRAMPORT = 0x1B0000

.org 0x0000
	rjmp MAIN

.dseg
.org 0x2300
Table1: .byte 200

.org 0x2700
Table2: .byte 200
.cseg

.org 0x100
MAIN:

	ldi r16, 0b00110111
	sts PORTH_DIR, r16 //set port pins as outputs for RE and ALE and WE CS1 and CS0

	ldi r16, 0b00110011
	sts PORTH_OUT, r16 //WE and RE is active low so it must be set

	ldi r16, 0xFF
	sts PORTJ_DIR, r16 //set datalines as outputs
	sts PORTK_DIR, r16 //set address lines as outputs

	ldi r16, 0x01
	sts EBI_CTRL, r16 //turn on 3 port SRAM ALE1 EBI

//CS1 STUFF

	ldi ZH, HIGH(EBI_CS1_BASEADDR) //set up CS1 for the SRAM
	ldi ZL, LOW(EBI_CS1_BASEADDR)
	ldi r16, ((SRAMPORT>>8) & 0xF0)
	st Z+, r16
	ldi r16, ((SRAMPORT>>16) & 0xFF)
	st Z, r16

	ldi r16, 0b00011101
	sts EBI_CS1_CTRLA, r16

PARTB1a:
	ldi r16, 0x1B		//RAMP Y for the SRAM
	out CPU_RAMPY, r16
	ldi YH, 0x30
	ldi YL, 0x00

	ldi r16, 0xAA

WRITEAA:
	st Y+, r16
	cpi YH, 0xB0
	brne WRITEAA
		
PARTB2a:
	ldi r16, 0x1B		//RAMP Y for the SRAM
	out CPU_RAMPY, r16
	ldi YH, 0x2F
	ldi YL, 0xFF
	ldi r17, 0x00

	ldi XL, low(Table1)		;load low bits of the table in X
	ldi XH, high(Table1)	;load high bits of the table in X

CHECKAA:
	ld r16, Y+ //Pre-increment
	ld r16, Y
	cpi YH, 0xB0
	breq PARTB1b
	cpi r16, 0xAA
	breq CHECKAA
	st X+, YL
	st X+, YH
	cpi r17, 100
	breq PARTB1b
	inc r17
	rjmp CHECKAA

PARTB1b: 
	ldi r16, 0x1B		//RAMP Y for the SRAM
	out CPU_RAMPY, r16
	ldi YH, 0x00
	ldi YL, 0x30

	ldi r16, 0x55

WRITE55:
	st Y+, r16
	cpi YH, 0xB0
	brne WRITE55

PARTB2b:
	ldi r16, 0x1B		//RAMP Y for the SRAM
	out CPU_RAMPY, r16
	ldi YH, 0x2F
	ldi YL, 0xFF

	ldi XL, low(Table2)		;load low bits of the table in X
	ldi XH, high(Table2)	;load high bits of the table in X

CHECK55:
	ld r16, Y+ //Pre-increment
	ld r16, Y
	cpi YH, 0xB0
	breq DONE
	cpi r16, 0x55
	breq CHECK55
	st X+, YL
	st X+, YH
	cpi r17, 100
	breq DONE
	inc r17
	rjmp CHECK55

DONE: rjmp DONE