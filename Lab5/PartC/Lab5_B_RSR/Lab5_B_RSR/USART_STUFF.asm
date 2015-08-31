;Initialize USART
.macro USART_INIT
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
.endmacro

.macro OUTCHAR
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
.endmacro

.macro INCHAR
IN_CHAR:

RX_POLL:
	lds R16, USARTD0_STATUS		;load the status register
	sbrs R16, 7					;proceed to reading in a char if
								;  the receive flag is set
	rjmp RX_POLL				;else continue polling
	lds R16, USARTD0_DATA		;read the character into R16

	ret
.endmacro

.macro OUTST
OUT_STRING:
	push R16 ;I chose to use z so this sub works for program or data memory (remember to shift left if program memory)

	beginwritingstring:
		ld R16, Z+ ;at the end of this sub, z will point to one address past the end of the string
		breq donewritingstring
		call OUT_CHAR
		rjmp beginwritingstring

	donewritingstring:
		pop R16
		ret
.endmacro

.macro INST
IN_STRING:  ;be sure to have X point where you want this data to go
	push R16

	beginreadingstring:
		call IN_CHAR ;puts the character in R16
		cpi R16, 0
		breq donereadingstring 
		st X+, R16
		rjmp beginreadingstring

	donereadingstring:
	pop R16
	ret
.endmacro