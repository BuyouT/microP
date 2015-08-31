/*
 * Lab5_C_RSR.asm
 *
 *  Created: 7/6/2015 11:03:15 PM
 *   Author: stefano92
 Lab 5 part C
 Name: Ricardo Stefano Reyna
 Section#: 75C9
 TA: Khaled Hassan
 Description: This program will print strings of my favorite stuff
 */ 

.include "atxmega128a1udef.inc"
.include "EBI_STUFF.asm"


.equ BSel = 983		
.equ BScale = -7	;14400Hz

.equ CR = 0x0D
.equ LF = 0x0A
.equ ESC = 0x1B

.org 0x1000
MENU: .db "Stefano's favorite:", CR, LF, "1. Movie", CR, LF, "2. Book", CR, LF, "3. Food", CR, LF, "4. Ice Cream/Yogurt flavor", CR, LF, "5. Pizza Topping", CR, LF, "6. Redisplay Menu", CR, LF, "ESC: exit", CR, LF, 0x00
OP1: .db "Stefano's favorite movie is Fight Club", CR, LF, 0x00
OP2: .db "Stefano's favorite book is Chronicles of a Death Fortold", CR, LF, 0x00
OP3: .db "Stefano's favorite food is rice", CR, LF, 0x00
OP4: .db "Stefano's favorite ice cream/yogurt flavor is chocolate", CR, LF, 0x00
OP5: .db "Stefano's favorite pizza topping is pineapple", CR, LF, 0x00
OP6: .db "Done!", 0x00

.org 0x0000
	rjmp MAIN

.org 0x0200
MAIN:
	
	STACK_STUFF

	rcall INIT_USART
	rcall INIT_GPIO
	
LOOP:
	ldi ZL, low(MENU << 1)
	ldi ZH, high(MENU << 1) 
	rcall OUT_STRING

GETCHAR:
	rcall IN_CHAR
	cpi R16, ESC	;If ESC
	breq EXIT
	cpi R16, 0x31	;If 1
	breq MOVIE
	cpi R16, 0x32	;If 2
	breq BOOK
	cpi R16, 0x33	;If 3
	breq FOOD
	cpi R16, 0x34	;If 4
	breq ICEYO
	cpi R16, 0x35	;If 5
	breq PIZZA
	cpi R16, 0x36	;If 6
	breq LOOP
	rjmp GETCHAR

;OPTIONS
EXIT:
	ldi ZL, low(OP6 << 1)
	ldi ZH, high(OP6 << 1)
	call OUT_STRING
DONE:
	rjmp DONE

MOVIE:
	ldi ZL, low(OP1 << 1)
	ldi ZH, high(OP1 << 1)
	rcall OUT_STRING
	rjmp LOOP
BOOK:
	ldi ZL, low(OP2 << 1)
	ldi ZH, high(OP2 << 1)
	rcall OUT_STRING
	rjmp LOOP
FOOD:
	ldi ZL, low(OP3 << 1)
	ldi ZH, high(OP3 << 1)
	rcall OUT_STRING
	rjmp LOOP
ICEYO:
	ldi ZL, low(OP4 << 1)
	ldi ZH, high(OP4 << 1)
	rcall OUT_STRING
	rjmp LOOP
PIZZA:
	ldi ZL, low(OP5 << 1)
	ldi ZH, high(OP5 << 1)
	rcall OUT_STRING
	rjmp LOOP

;OUTSTR
OUT_STRING:
	push r16

WRITE:
	lpm r16, Z+		;reads each char
	cpi r16, 0x00
	breq STOPW
	rcall OUT_CHAR
	rjmp WRITE		;Write to console

STOPW:
	pop r16
	ret


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

TX_POLL:
	lds R17, USARTD0_STATUS		;load status register
	sbrs R17, 5					;proceed to writing out the char if
								;  the DREIF flag is set
	rjmp TX_POLL				;else go back to polling
	sts USARTD0_DATA, R16		;send the character out over the USART
	pop R17

	ret

;INITUSART
INIT_USART:
	ldi R16, 0x18				
	sts USARTD0_CTRLB, R16		;turn on TXEN, RXEN lines

	ldi R16, 0x03
	sts USARTD0_CTRLC, R16		;Set Parity to none, 8 bit frame, 1 stop bit

	ldi R16, (BSel & 0xFF)		;select only the lower 8 bits of BSel
	sts USARTD0_BAUDCTRLA, R16	;set baudctrla to lower 8 bites of BSel 

	ldi R16, ((BScale << 4) & 0xF0) | ((BSel >> 8) & 0x0F)							
	sts USARTD0_BAUDCTRLB, R16	;set baudctrlb to BScale | BSel. Lower 
								;  4 bits are upper 4 bits of BSel 
								;  and upper 4 bits are the BScale. 
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

