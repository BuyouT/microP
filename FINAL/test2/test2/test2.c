/*
 * final_RSR.c
 *
 * Created: 8/4/2015 10:59:13 AM
 *  Author: stefano92
 25% duty cycle of 370Hz, after 200 periods of the waveform output 4744 Rocks!. 
 No clearing LCD. new line between messages on the terminal. run at 19.2Hz
 */ 


#include <avr/io.h>
#include <avr/interrupt.h>
#include "ebi_driver.h"
#define F_CPU 2000000
#define CS0_Start 0x4000
#define CS1_Start 0x1B0000
#define LCD_COM 0x1B1000
#define LCD_DAT 0x1B1001

static const int BSEL = 44;
static const int BSCALE = -3; //19400Hz
static const int CR = 0x0D;
static const int LF = 0x0A;

void init_EBI();
void init_lcd();
void check_BF();
void out_string(char *str);
void init_timer();
void init_SP();
void k_init();
char get_key();

void init_usart();
void init_GPIO();
char IN_CHAR();
void OUT_CHAR(char temp);
void OUT_USTRING(char *temp);
void delay();

int main(void)
{	
	init_EBI();
	init_lcd();
	init_timer();
	init_usart();
	init_GPIO();
	
	char *schwartz = "4744 Rocks!";
	
    while(1)
    {	
		TCE1.CCA = 2702;
		__far_mem_write(LCD_COM, 0x02);
		check_BF();
        out_string(schwartz);
		//Ugly I know but it works
		OUT_CHAR('4');
		OUT_CHAR('7');
		OUT_CHAR('4');
		OUT_CHAR('4');
		OUT_CHAR(' ');
		OUT_CHAR('R');
		OUT_CHAR('o');
		OUT_CHAR('c');
		OUT_CHAR('k');
		OUT_CHAR('s');
		OUT_CHAR('!');
		OUT_CHAR(CR);
		OUT_CHAR(LF);
		//End of this BS
		soundStop(200);
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

void init_timer() {
	TCE1.CTRLA = 0x01;
	TCE1.CTRLB = 0x01;
	TCE1.INTCTRLA = 0x02;
	TCE1.INTCTRLB = 0x01;
	
	PMIC_CTRL = 0x02;
	
	sei();
}

void soundStop(int num) {
	TCE1.CNT = 0x00;
	TCE1.PER = num;
	//Setting the PER depending on the time passed in
	while (TCE1.PER > TCE1.CNT)
	{
		TCE1.CTRLA = 0x01;
		
	}
}

ISR(TCE1_CCA_vect) {
	TCE1.CTRLA = 0x00;
}


void init_usart() {
	USARTD0_CTRLA = 0x10;
	USARTD0_CTRLB = 0x18;
	USARTD0_CTRLC = 0x03;
	USARTD0_BAUDCTRLA = (BSEL & 0xFF);
	USARTD0_BAUDCTRLB = ((BSCALE << 4) & 0xF0) | ((BSEL >> 8) & 0x0F);
	PMIC_CTRL = 0x01;
	sei();
}

void init_GPIO() {
	PORTD_DIRSET = 0x08;
	PORTD_OUTSET = 0x08;
	PORTD_DIRCLR = 0x04;
	PORTQ_DIRSET = 0x0A;
	PORTQ_OUTCLR = 0x0A;
}

char IN_CHAR() {
	char ctemp = 0x00;
	int itemp = 0;
	while ((itemp & 0x80) != 0x80) {
		itemp = USARTD0_STATUS;
	}
	
	ctemp = USARTD0_DATA;
	
	return ctemp;
}

void OUT_CHAR(char temp) {
	int itemp = 0;
	while ((itemp & 0x20) != 0x20) {
		itemp = USARTD0_STATUS;
	}
	
	USARTD0_DATA = temp;
}

void OUT_USTRING(char *temp) {
	//go through each char until null
	while(*temp != 0x00) {
		//go to the next line when ends the line
		OUT_CHAR(temp);
		temp++;
	}
}

void delay () {
	volatile uint32_t ticks;            // Volatile prevents compiler optimization
	for(ticks=0;ticks<=50000;ticks++);  // Convenient delay
}