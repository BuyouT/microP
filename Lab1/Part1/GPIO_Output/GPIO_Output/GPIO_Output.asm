/*
 * GPIO_Output.asm
 *
 *  Created: 5/19/2015 12:44:33 PM
 *   Author: Ricardo Stefano Reyna
 */ 

 /*
 * GPIO_Output.asm
 *
 *  Modified: 4 Sept 14
 *  Authors: Dr. Schwartz, Colin Watson
 
 This program will show how to initialize a GPIO port on the Atmel 
 (Port Q for this example) and demonstrate various ways to write to 
 a GPIO port.  The output will blink LEDs at the top of the uTinkerer 
 PCB.  PortQ3 - PortQ0 are the LEDs labeled D6-D9 at the top of the 
 uTinkerer PCB.
 *****/

;Definitions for all the registers in the processor. ALWAYS REQUIRED.
;View the contents of this file in the Processor "Solution Explorer" 
;   window under "Dependencies"
.include "ATxmega128A1Udef.inc"

.ORG 0x0000					;Code starts running from address 0x0000.
	rjmp MAIN				;Relative jump to start of program.

.ORG 0x0100					;Start program at 0x0100 so we don't overwrite 
							;  vectors that are at 0x0000-0x00FD 
MAIN:
	ldi R16, 0xF			;load a four bit value(PORTQ is only four bits)
	sts PORTQ_DIRSET, R16	;set all the GPIO's in the four bit PORTQ as outputs

	ldi R16, 0xA			;values we will use to change the state of 
							;  the PORTQ GPIO's
	ldi R17, 0xF

	;The following code shows different ways to write to the GPIO pins.
	;   Each has a different advantage.

	sts PORTQ_OUT, R16		;send the value in R16 to the PORTQ pins	
; This instruction sends the value in R16 to the PORTQ pins. Since the LEDs 
; are wired active-low, an R16 = 0x0A = 0b0000 1010, and the uTinkerer 
; board uses the low four bits of PortQ for the LEDs, the LEDs (bits 3 to 0) are 
; Off, On, Off, On.  PortQ = 0x0A. 	

	sts PORTQ_OUTSET, R17	;each R17 bit that is 1 will set corresponding PORTQ pin
; This instruction sets (i.e., makes 1) each of the bits that are a one in R17.  
; Since the value in R17 - 0x0F = 0b00001111, the instruction will set all four of 
; the low bits of PortQ, so PortQ = 0x0F, i.e., PortQ = PortQ + 0x0F = 0x0F.  
; (The four LEDs will be off.) 

	sts PORTQ_OUTCLR, R16	;each R16 bit that is 1 will clear corresponding PORTQ pin
; This instruction clears (i.e., makes 0) each of the bits that are a one in R17.  
; Since the value in R16 = 0x0A = 0b0000 1010, the instruction will clear all the 
; bits with a 1 in them, so PortQ = 0x0F, i.e., 
; PortQ = PortQ * /(0x0A) = PortQ * 0xF5 = 0x0F * 0xF5 = 0x05 = 
;       = 0b0000 1111 * 0b1111 0101 = 0b0000 0101.  (LEDs 3 and 1 will be on.) 

LOOP:
	sts PORTQ_OUTTGL, R16			;toggle the state of all the pins in PORTQ	
; This instruction toggles (i.e., complements) each of the bits that are a one in R16.  
; So if PortQ = 0x05 = 0101, and R16 = 0x0A = 0x1010, then the first time the 
; instruction is run PortQ = 0xF.  The second time the instruction is run PortQ = 0x5.
; The PortQ values will continue to toggle between 0xF and 0x5.  (LEDs 2 and 0 will be
; off, and 3 and 1 will oscillate between off and on.) 

	rjmp LOOP						;repeat forever!

