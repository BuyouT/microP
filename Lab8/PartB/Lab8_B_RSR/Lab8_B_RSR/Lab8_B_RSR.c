/*
 * Lab8_B_RSR.c
 *
 * Created: 7/27/2015 7:01:52 PM
 *  Author: stefano92
 Lab 8 part B
 Name: Ricardo Stefano Reyna
 Section#: 75C9
 TA: Khaled Hassan
 Description: This program will display 10 different functions depending on the button pressed for the remote.
 */ 


#include <avr/io.h>
#include <avr/interrupt.h>
#include "ebi_driver.h"
#define F_CPU 2000000
#define CS0_Start 0x4000
#define CS1_Start 0x1B0000
#define LCD_COM 0x1B1000
#define LCD_DAT 0x1B1001

uint16_t keypressed [10][100];
uint16_t temp[100];
volatile int index = 0;

void init_EBI();
void init_lcd();
void check_BF();
void out_string(char *str);
void init_timer();
void init_SP();
void soundStop();
void init_remote();
void k_init();
char get_key();
void delay();
void delay2();

void check_button(char button);
void record_key(int button);
int out_compare();

int main(void)
{
	init_EBI();
	init_lcd();
	k_init();
	init_remote();
	
	char input = '&';
	
	while(1)
    {	
		char assoc_key = '&';
		__far_mem_write(LCD_COM, 0x01);
		check_BF();
		out_string("1) Record a key");
		__far_mem_write(LCD_COM, 0xC0);
		check_BF();
		out_string("2) Play");
		input = get_key();
		
		switch(input) {
			case '1':
				//record
				__far_mem_write(LCD_COM, 0x01);
				check_BF();
				out_string("Record:");
				__far_mem_write(LCD_COM, 0xC0);
				check_BF();
				out_string("Press keypad");
				delay();
				while (assoc_key != '&')
				{
					assoc_key = get_key();
				}
				__far_mem_write(LCD_COM, 0x01);
				check_BF();
				TCE1_CTRLB = TC0_CCAEN_bm;
				out_string("Press remote");
				delay();
				check_button(assoc_key);
				break;
			case '2':
				//play something
				break;
			default:
				delay2();
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

void k_init(){
	PORTF_PIN4CTRL = 0x18;
	PORTF_PIN5CTRL = 0x18;
	PORTF_PIN6CTRL = 0x18;
	PORTF_PIN7CTRL = 0x18;
	PORTF_DIRSET = 0x0F; //Low bits are outputs
	PORTF_DIRCLR = 0xF0; //High bits are inputs
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
		return '4';
	}
	if(key == 0xBE){
		return '7';
	}
	if(key == 0x7E){
		return '*';
	}
	
	PORTF_OUT = 0x0D;
	asm("nop");
	key = PORTF_IN;
	if(key == 0xED){
		return '2';
	}
	if(key == 0xDD){
		return '5';
	}
	if(key == 0xBD){
		return '8';
	}
	if(key == 0x7D){
		return '0';
	}
	PORTF_OUT = 0x0B;
	asm("nop");
	key = PORTF_IN;
	if(key == 0xEB){
		return '3';
	}
	if(key == 0xDB){
		return '6';
	}
	if(key == 0xBB){
		return '9';
	}
	if(key == 0x7B){
		return '#';
	}
	PORTF_OUT = 0x07;
	asm("nop");
	key = PORTF_IN;
	if(key == 0xE7){
		return 'A';
	}
	if(key == 0xD7){
		return 'B';
	}
	if(key == 0xB7){
		return 'C';
	}
	if(key == 0x77){
		return 'D';
	}
	
	return '&';
}

/*
void init_timer() {
	TCE1.CTRLA = 0x05;
	TCE1.CTRLB = 0x10;
	TCE1.INTCTRLA = 0x02;
	TCE1.INTCTRLB = 0x00;
	
	PMIC_CTRL = 0x02;
	
	sei();
}

void init_SP() {
	PORTE.DIRSET = 0x01;	//making portE pin2 as an output
	TCE0_CNT = 0x00;		//this is where the count is stored, we are resetting it. (CNT=PER)
	TCE0_CTRLA = 0x00;		//setting clk to on
	TCE0_CTRLB = 0x11;		//enables CCA (FRQ mode, see 14.8.2), frequency mode
}*/

/*
void soundStop(int num) {
	TCE1.CNT = 0x00;
	TCE1.PER = num;
	//Setting the PER depending on the time passed in
	while (TCE1.PER > TCE1.CNT)
	{
		TCE0.CTRLA = 0x01;
	}
}

//Interrupt for the timer
ISR(TCE1_OVF_vect) {
	TCE0.CTRLA = 0x00;
}*/

void init_remote() {
	cli();
	PORTE_DIRCLR = 0x10;	//making portE pin 1 as input
	TCE1_CTRLA = 0x01;     //TC_CLKSEL_DIV1_gc;
	TCE1_CTRLB = 0x10;     // TC1_CCABV_bm | TC_WGMODE_NORMAL_gc;	//enable CCA to capture value
	TCE1_CTRLD = TC_EVACT_CAPT_gc | TC_EVSEL_CH0_gc;	//setting event capture and IC mode
	
	TCE1_INTCTRLB = TC_CCAINTLVL_LO_gc;
	
	PORTE_PIN4CTRL = PORT_ISC_BOTHEDGES_gc;
	PMIC_CTRL = 0x01;    //PMIC_LOLVLEN_bm;
	
	EVSYS_CH0MUX = EVSYS_CHMUX_PORTE_PIN4_gc;
	TCE1_PER = 0x7FFF;	//less than 0x8000, 1 is falling; 0 is failing
	
	sei();
}

ISR(TCE1_CCA_vect){
	asm volatile("nop");
	TCE1_CNT = 0x00;
	temp[index] = TCE1_CCA;
	index++;
	asm volatile("nop");
}

void check_button(char button) {
	char c = button;
	int nice = c - '0';
	if (nice < 10 || nice >= 0) {
		record_key(nice);
	}
}

void record_key(int	button) {
	for (int i = 0; i < 100; i++) {
		keypressed[button][i] = temp[i];
	}		
}

int out_compare() {
	int num = -1;
	int flag = 0;
	int max = 0;
	float error = 0;
	
	for (int i = 0; i < 10; i++) {
		for (int j = 0; j < 100; j++)
		{
			error = (((float)keypressed[i][j] - (float)temp[j])/(float)keypressed[i][j]);
			//absolute value
			if (error < 0) {
				error = (-1 * error);
			}
			//check if it's within the range
			if (error < 0.25) {
				++flag;
			}
		}
		if (flag > max) {
			max = flag;
			num = i;
		}
		flag = 0;
	}
	
	return num;
}

void delay () {
	volatile uint32_t ticks;            // Volatile prevents compiler optimization
	for(ticks=0;ticks<=100000;ticks++);  // Convenient delay
}

void delay2 () {
	volatile uint32_t ticks;            // Volatile prevents compiler optimization
	for(ticks=0;ticks<=10000;ticks++);  // Convenient delay
}