# /*
#  * Lab5_quiz.asm
#  *
#  *  Created: 7/9/2015 3:46:59 PM
#  *   Author: stefano92
#  */

 .include "atxmega128a1udef.inc"
.include "EBI_STUFF.asm"

.equ BSel = 27		
.equ BScale = -3	;28800Hz

.org 0x0000
	rjmp MAIN


.org 0x0200
MAIN:
	
	STACK_STUFF	;Initialize stack

	EBI_INIT	;Initialize EBI

	CS0_INIT	;Initialize CS0

	rcall INIT_USART
	rcall INIT_GPIO

	

LOOP:
	rcall IN_CHAR
	rcall OUT_CHAR
	rjmp LOOP

;INCHAR
IN_CHAR:
	push r17
RX_POLL:
	lds r16, USARTD0_STATUS		;load the status register
	sbrs r16, 7					;proceed to reading in a char if
								;  the receive flag is set
	rjmp RX_POLL				;else continue polling
	lds r16, USARTD0_DATA		;read the character into R16

	pop r17
	ret

;OUTCHAR
OUT_CHAR:
	push R17
	push r18

TX_POLL:
	lds R17, USARTD0_STATUS		;load status register
	sbrs R17, 5					;proceed to writing out the char if
								;  the DREIF flag is set
	rjmp TX_POLL				;else go back to polling
# 	ldi r18, 0x20
# 	cpi r16, 0x41
# 	brlt NOTIT
# 	cpi r16, 0x5B
# 	brge LOWS
# 	add r16, r18
# 	rjmp NOTIT
# LOWS:
# 	cpi r16, 0x61
# 	brlt NOTIT
# 	cpi r16, 0x7B
# 	brge NOTIT
# 	subi r16, 0x20
# NOTIT:
	sts USARTD0_DATA, R16		;send the character out over the USART
	pop r18
	pop R17

	ret

;INITUSART
INIT_USART:

	;ldi r16, 0x10				
	;sts USARTD0_CTRLA, r16		;turn on low level
	ldi r16, 0x18				
	sts USARTD0_CTRLB, r16		;turn on TXEN, RXEN lines

	ldi r16, 0x03
	sts USARTD0_CTRLC, r16		;Set Parity to none, 8 bit frame, 1 stop bit

	ldi r16, (BSel & 0xFF)		;select only the lower 8 bits of BSel
	sts USARTD0_BAUDCTRLA, r16	;set baudctrla to lower 8 bites of BSel 

	ldi r16, ((BScale << 4) & 0xF0) | ((BSel >> 8) & 0x0F)							
	sts USARTD0_BAUDCTRLB, r16	;set baudctrlb to BScale | BSel. Lower 
								;  4 bits are upper 4 bits of BSel 
								;  and upper 4 bits are the BScale. 

	;ldi r16, 0x01
	;sts PMIC_CTRL, r16	;turn low level interrupts ON
	;sei					;set the global interrupt flag to enable interrupt
	ret

;INITGPIO
INIT_GPIO:
	ldi R16, 0x08	
	sts PortD_DIRSET, R16	;Must set PortD_PIN3 as output for TX pin 
							;  of USARTD0					
	sts PortD_OUTSET, R16	;set the TX line to default to '1' as 
							;  described in the documentation
	ldi R16, 0x04
	sts PortD_DIRCLR, R16	;Set RX pin for input
	
	ldi R16, 0xA			; PortQ bits 1 and 3 enable and select
	sts PORTQ_DIRSET, R16	;   the PortD bits 2 and 3 serial pins 
	sts PORTQ_OUTCLR, R16   ;   to be connected to the USB lines
	ret
