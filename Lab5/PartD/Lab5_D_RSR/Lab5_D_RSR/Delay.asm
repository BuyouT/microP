;This one takes r19 as an input
.LIST
.org 0xF00
WASTE:
	push r16
	push r17
	ldi r16, 0x00
	ldi r17, 0x00
EXTRA:
	inc r16
	cp r16, r19		;change this number
	brne DELAY_10ms
	pop r17
	pop r16
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