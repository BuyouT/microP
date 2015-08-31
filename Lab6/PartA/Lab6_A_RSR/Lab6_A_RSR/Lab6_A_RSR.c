/*
 * Lab6_A_RSR.c
 *
 * Created: 7/13/2015 4:51:58 PM
 *  Author: stefano92
 Lab 6 part A
 Name: Ricardo Stefano Reyna
 Section#: 75C9
 TA: Khaled Hassan
 Description: This program is to check my name on the LCD.
 */ 


#include <avr/io.h>
#include "ebi_driver.h"
#define F_CPU 2000000
#define CS0_Start 0x4000
#define CS1_Start 0x1B0000
#define LCD_COM 0x1B1000
#define LCD_DAT 0x1B1001


void init_EBI();
void init_lcd();
void check_BF();
void out_string(char *str);

int main(void)
{
	char *name = "Stefano Reyna";
	init_EBI();
	init_lcd();
	
	out_string(name); //Print
	__far_mem_write(LCD_COM, 0x06);
	check_BF();
	
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


void init_lcd() {
	check_BF();
	__far_mem_write(LCD_COM,0x38);
	check_BF();
	__far_mem_write(LCD_COM,0x0F);
	check_BF();
	__far_mem_write(LCD_COM,0x01);
	check_BF();
	
}

void check_BF() {
	volatile uint8_t temp_val = 0;
	while (1) {
		temp_val = __far_mem_read(LCD_COM);
		if ((temp_val & 0x80) == 0x00) {
			break;
		}
	}
}

void out_string(char *str){
	int cntr = 0;
	//go through each char until null
	while(*str!= 0) {
		check_BF();
		//go to the next line when ends the line
		if(cntr == 16)
		{
			__far_mem_write(LCD_COM, 0xC0); 
			check_BF();
		}
		check_BF();
		__far_mem_write(LCD_DAT,*str); 
		str++; 
		cntr++;
	}
	check_BF();
}