/*
 * delay_37.asm
 *
 *  Created: 6/2/2015 11:33:43 PM
 *   Author: stefano92
 */ 

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
.org 0xF00
WASTE:
	push r16
	push r17
	ldi r16, 0x00
	ldi r17, 0x00
EXTRA:
	inc r16
	cpi r16, 74		;change this number
	brne DELAY_10ms
	pop r16
	pop 17
	ret
DELAY_10ms:
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
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	inc r17		;increase r18
	cpi r17, 0xFF	;check if r18 is 28
	brne DELAY_10ms	;if not loop
	rjmp EXTRA