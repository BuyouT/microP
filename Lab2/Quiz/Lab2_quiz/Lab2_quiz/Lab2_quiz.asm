/*
 * Lab2_quiz.asm
 *
 *  Created: 6/4/2015 3:40:03 PM
 *   Author: stefano92
 */ 

.NOLIST
.include "ATxmega128A1Udef.inc"

.LIST
.org 0x0000		;code starts at this address
	rjmp MAIN	;go to MAIN

MAIN:
	sts PORTF_DIR, r16		;set port F as input
LOOP:
	lds r16, PORTF_IN		;load value of port F into r20
	mov r17, r16
	andi r17, 0x01
	cpi r17, 0x00
	breq INV
	andi r16, 0xF0
	sts PORTE_DIRSET, r16	;Set port E as output
	sts PORTE_OUT, r16		;port E contains the value of r16
	rjmp LOOP
INV:
	com r16
	andi r16, 0xF0
	sts PORTE_DIRSET, r16	;Set port E as output
	sts PORTE_OUT, r16		;port E contains the value of r16
	rjmp LOOP