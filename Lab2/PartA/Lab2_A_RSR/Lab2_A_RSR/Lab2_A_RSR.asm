/*
 * Lab2_A_RSR.asm
 *
 *  Created: 5/28/2015 4:06:55 PM
 *   Author: stefano92
 Lab 2 Part a
 Name: Ricardo Stefano Reyna
 Section#: 75C9
 TA: Khaled Hassan
 Description: This program writes to port E and reads from port F
 */ 

.NOLIST
.include "ATxmega128A1Udef.inc"

.LIST
.org 0x0000		;code starts at this address
	rjmp MAIN	;go to MAIN

.org 0x200
MAIN:
	sts PORTF_DIR, r16		;set port F as input
	lds r16, PORTF_IN		;load value of port F into r16
	sts PORTE_DIRSET, r16	;Set port E as output
	sts PORTE_OUT, r16		;send value of r16 to port E
	rjmp MAIN				;go to main