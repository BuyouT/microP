/*
 * Lab5_A_RSR.asm
 *
 *  Created: 7/2/2015 1:26:06 PM
 *   Author: stefano92
 Lab 5 part A
 Name: Ricardo Stefano Reyna
 Section#: 75C9
 TA: Khaled Hassan
 Description: This program will count the number of interrupts and display them on the LED
 */ 


.include "atxmega128a1udef.inc"
.include "EBI_STUFF.asm"
.include "Delay.asm"

.org 0x0000
	rjmp MAIN

.org PORTE_INT0_VECT		;place code at the interrupt vector for the PORTE_INT0 interrupt
	rjmp EXT_INT_ISR			;jump to our interrupt routine 

.org 0x0200
MAIN:
	STACK_STUFF	;Initialize stack

	EBI_INIT	;Initialize EBI

	CS0_INIT	;Initialize CS0

/////////////////////////START PROGRAM///////////////////

	ldi r17, 0x00
	rcall INIT_INTERRUPT	;call our subroutine to initialize our interrupt
	nop

LOOP:
 	rjmp LOOP				;loop forver while our interrupt fires

INIT_INTERRUPT:
	ldi r16, 0x01			;select PORTE_PIN0 as the interrupt source
	sts PORTE_INT0MASK, r16			
	sts PORTE_DIRCLR, r16	;PIN0 as input 
	
	ldi r16, 0x01			;select the external interrupt as a low level 
	sts PORTE_INTCTRL, r16	;  priority interrupt 
;	Probably inappropriately cleared the INT1 interrupt level pins 

	ldi	R16, 0x01			;select low level pin for external interrupt 
	sts	PORTE_PIN0CTRL, r16	;  (rising edge)
;	Probably inappropriately cleared pins 7, 5, 4, 3

	ldi r16, 0x01
	sts PMIC_CTRL, r16		;turn on low level interrupts
;	Also effected pins 7-1
	sei						;turn on the global interrupt flag LAST! 
	ret

EXT_INT_ISR:
	call WASTE
	push r16
	in r16, CPU_SREG
	push r16
	nop			;dummy instruction to put a breakpoint on
	inc r17
	st X, r17				;Number of interrupts
	ldi	r16, 0x01
	sts PORTE_INTFLAGS, r16	; Clear the PORTE_INTFLAGS
	pop r16
	out CPU_SREG, r16 
	pop	r16
	reti		;return from the interrupt routine

