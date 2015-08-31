/*
 * Lab2_B_RSR.asm
 *
 *  Created: 5/31/2015 11:33:45 PM
 *   Author: stefano92
 Lab 2 Part b
 Name: Ricardo Stefano Reyna
 Section#: 75C9
 TA: Khaled Hassan
 Description: This program creates a delay for 200us
 */ 

 .NOLIST
.include "ATxmega128A1Udef.inc"

.LIST
.org 0x0000		;code starts at this address
	rjmp MAIN	;go to MAIN

.org 0x200
MAIN:
	ldi r16, 0x00	;load 0 into r16
	ldi r17, 0x01	;load 1 into r17
	ldi r19, 0x00	;load 0 into r19
ON:
	sts PORTE_DIRSET, r17	;Set Port E as output
	sts PORTE_OUT, r17		;give port E the value of r17
	ldi r18, 0x00			;reset r18
	inc r19					;increase r19
LOOP:
	nop			; do nothing
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	inc r18		;increase r18
	cpi r18, 28	;check if r18 is 28
	brne LOOP	;if not loop
	cpi r19, 0	;check if r19 is 0
	breq ON		;if true then go to ON
OFF:
	sts PORTE_DIRSET, r16	;Set port E as output
	sts PORTE_OUT, r16		;port E contains the value of r16
	ldi r18, 0x00			;reset r18
	dec r19					;decrease r19
	rjmp LOOP				;go to LOOP