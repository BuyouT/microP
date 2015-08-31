/*
 * Lab6_quiz.c
 *
 * Created: 7/16/2015 3:46:23 PM
 *  Author: stefano92
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
void init_AD();
void check_BF();
void out_string(char *str);
void k_init();
char get_key();
void delay();

int main(void)
{
	init_EBI();
	init_lcd();
	init_AD();
	k_init();
	
	char *ec = "Stefano in jap:";
	char *name =  "Khaled is great";
	char *schartz = "and so am I!";
	char ck = '1';
	char lk = '3';
	int powah = 1;
	char ck2 = '7';
	while (1) {
		if (ck == '&') {
			ck = lk;
		}
		do {
			ck = get_key();
			if (ck == '3' || ck == '4') {
				break;
			}
		} while (ck == lk);
		switch (ck) {
			case '1': //function 1
				__far_mem_write(LCD_COM, 0x02);
				check_BF();
				out_string(name);
				__far_mem_write(LCD_COM, 0x06);
				check_BF();
				lk = '1';
				break;
			case '2': //function 2
				__far_mem_write(LCD_COM, 0xC0);
				check_BF();
				out_string(schartz);
				__far_mem_write(LCD_COM, 0x06);
				check_BF();
				lk = '2';
				break;
			case '3': //function 3
				__far_mem_write(LCD_COM, 0x10);
				check_BF();
				ck2 = ck;
				while (1) {
					ck2 = get_key();
					if (ck2 == '&') {
						break;
					}
				}
				lk = '3';
				break;
			case '4': //function 4
				__far_mem_write(LCD_COM, 0x1C);
				check_BF();
				ck2 = ck;
				while (1) {
					ck2 = get_key();
					if (ck2 == '&') {
						break;
					}
				}
				lk = '4';
				break;
			case '5': //function 5
				__far_mem_write(LCD_COM, 0x01);
				check_BF();
				lk = '5';
				break;
			default:
				break;
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


void init_lcd() {
	check_BF();
	__far_mem_write(LCD_COM,0x38);
	check_BF();
	__far_mem_write(LCD_COM,0x0F);
	check_BF();
	__far_mem_write(LCD_COM,0x01);
	check_BF();
	
}

void init_AD() {
	ADCB_CTRLA = 0x01; //channel 0 enabled and enable ADC
	ADCB_CTRLB = 0x0C; //Free-run and u8-bit
	ADCB_REFCTRL = 0x30; //AREFB
	ADCB_PRESCALER = 0x07; //512
	ADCB_CH0_CTRL = 0x81; //Take reading from channel 0
	PORTB_DIR = 0x01;
	ADCB_CH0_MUXCTRL = 0x20; //PIN4
}

void k_init(){
	PORTF_PIN4CTRL = 0x18;
	PORTF_PIN5CTRL = 0x18;
	PORTF_PIN6CTRL = 0x18;
	PORTF_PIN7CTRL = 0x18;
	PORTF_DIRSET = 0x0F; //Low bits are outputs
	PORTF_DIRCLR = 0xF0; //High bits are inputs
}

void check_BF() {
	volatile uint8_t temp_val = 0;
	while(1) {
		temp_val = __far_mem_read(LCD_COM);
		if((temp_val & 0x80) == 0x00) {
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


char get_key(){
	uint8_t key;
	PORTF_OUT = 0x0E;
	asm("nop");
	key = PORTF_IN;
	if(key == 0xEE){
		return '1';
	}
	if(key == 0xDE){
		return '4'; //Change to 4 later
	}
	if(key == 0xBE){
		return '7';
	}
	if(key == 0x7E){
		return '#'; //Change to * later
	}
	
	PORTF_OUT = 0x0D;
	asm("nop");
	key = PORTF_IN;
	if(key == 0xED){
		return '2'; //Change to 2 later
	}
	if(key == 0xDD){
		return '5';
	}
	if(key == 0xBD){
		return '@'; //change to 8 later
	}
	if(key == 0x7D){
		return '0'; //Change to 0 later
	}
	PORTF_OUT = 0x0B;
	asm("nop");
	key = PORTF_IN;
	if(key == 0xEB){
		return '3';
	}
	if(key == 0xDB){
		return '7'; //Change to 6 later
	}
	if(key == 0xBB){
		return '@'; //Change to 9 later
	}
	if(key == 0x7B){
		return '#';
	}
	PORTF_OUT = 0x07;
	asm("nop");
	key = PORTF_IN;
	if(key == 0xE7){
		return '@'; //Change to A later
	}
	if(key == 0xD7){
		return '@'; //Change to B later
	}
	if(key == 0xB7){
		return '@'; //Change to C later
	}
	if(key == 0x77){
		return '@'; //Change to D later
	}
	
	return '&';
}

void delay() {
	volatile uint32_t ticks; //Volatile prevents compiler optimization
	for(ticks=0;ticks<=10000;ticks++); //convenient delay
}
