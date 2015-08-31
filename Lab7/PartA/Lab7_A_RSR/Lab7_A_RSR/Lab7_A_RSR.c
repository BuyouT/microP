/*
 * Lab7_A_RSR.c
 *
 * Created: 7/20/2015 4:20:45 PM
 *  Author: stefano92
 Lab 6 part A
 Name: Ricardo Stefano Reyna
 Section#: 75C9
 TA: Khaled Hassan
 Description: This program is to check the timer and check the output sound.
 */ 


#include <avr/io.h>
#include <avr/interrupt.h>
#include "ebi_driver.h"
#define F_CPU 2000000
#define CS0_Start 0x4000
#define CS1_Start 0x1B0000
#define LCD_COM 0x1B1000
#define LCD_DAT 0x1B1001

void init_switch();
void init_EBI();
void delay();
void delay2();

int main(void)
{
	init_EBI();
	init_switch();
	
	uint8_t input_check;
	
	while(1) {
		//Checks when the switch is on or off
		input_check = PORTE.IN & 0x80;
		__far_mem_write(CS0_Start, 0x04);
		if(input_check == 0x80) {
			//TCE0.CTRLB = 0x11;
			delay2();
			__far_mem_write(CS0_Start, 0x00);
			delay2();
		}
		
		else {
			//TCE0.CTRLB = 0x01;
			delay();
			__far_mem_write(CS0_Start, 0x00);
			delay();
		}
	}
	
	return 0;
}

void init_EBI() {
	PORTH_DIR = 0x37;
	PORTH_OUT = 0x33;
	PORTK_DIR = 0xFF;
	
	EBI.CTRL = EBI_SRMODE_ALE1_gc | EBI_IFMODE_3PORT_gc;            // ALE1 multiplexing, 3 port configuration

	EBI.CS0.BASEADDRH = (uint8_t) (CS0_Start>>16) & 0xFF;
	EBI.CS0.BASEADDRL = (uint8_t) (CS0_Start>>8) & 0xFF;            // Set CS0 range to 0x004000 - 0x004FFF
	EBI.CS0.CTRLA = EBI_CS_MODE_SRAM_gc | EBI_CS_ASPACE_4KB_gc;	    // SRAM mode, 4k address space

	// BASEADDR is 16 bit (word) register. C interface allows you to set low and high parts with 1
	// instruction instead of the previous two
	EBI.CS1.BASEADDR = (uint16_t) (CS1_Start>>8) & 0xFFFF;          // Set CS1 range to 0x1B0000 - 0x1BFFFF
	EBI.CS1.CTRLA = EBI_CS_MODE_SRAM_gc | EBI_CS_ASPACE_64KB_gc;
}


void init_switch() {
	PORTE.DIRCLR = 0x80;
}

void delay () {
	volatile uint32_t ticks;            // Volatile prevents compiler optimization
	for(ticks=0;ticks<=50000;ticks++);  // Convinient delay
}

void delay2 () {
	volatile uint32_t ticks;            // Volatile prevents compiler optimization
	for(ticks=0;ticks<=25000;ticks++);  // Convinient delay
}