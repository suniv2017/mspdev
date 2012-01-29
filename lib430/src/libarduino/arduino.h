#ifndef __ARDUINO_H__
#define __ARDUINO_H__

#include <msp430.h>
#include <stdint.h>

#ifdef WITH_HUART
#include <huart.h>
#else
#include <suart.h>
#endif // WITH_HUART

#ifndef WORD
#define WORD unsigned int
#endif

#ifndef byte
#define byte unsigned char
#endif

// Constants
#define LOW 0
#define HIGH 1

#define INPUT 0
#define OUTPUT 1

// digital I/O
inline void pinMode(int pin, int isOutput){
	if(isOutput){
		P1DIR |= (1 << pin);
	}
	else{
		P1DIR &= (~(1 << pin));
	}
}

inline void digitalWrite(WORD pin, WORD setOrReset) {
	if (setOrReset)
		P1OUT |= ( 1 << pin);
	else
		P1OUT &= (~(1 << pin));
}

inline int digitalRead(WORD pin) {
	return (P1OUT & (1 << pin)) > 0;
}

inline int analogRead(WORD pin) {
	// Do dac conversion here
	return 0;
}

inline void analogWrite(WORD pin, int value) {
	// Setup pin for PWM via WDT.
}

inline void interrupts() {
	// Interrupt enable
}

inline void noInterrupts() {
	// Interrupt disable
}

void delayMicroseconds(unsigned int time){
	TACCR0 = time-1; // Upper limit of count for TAR
	TACTL = MC_1|ID_0|TASSEL_2|TACLR; // Set up and start Timer A
	while ((TACTL & TAIFG) == 0){ // Wait for overflow
	} // doing nothing
	TACTL &= (~TAIFG); // Clear overflow flag
}

void delayMicrosecondszz(unsigned int time){
	TACCR0 = time; // Upper limit of count for TAR
	TACTL = MC_1|ID_0|TASSEL_2|TACLR; // Set up and start Timer A
	// __low_power_mode_3 ();
	//__delay_cycles
}

inline void delayMilliseconds(unsigned int delay){
	while(delay > 60){
		delayMicroseconds(60000);
		delay -= 60;
	}
	if (delay) delayMicroseconds((delay << 10) - (delay << 4) - (delay << 3));
}

#define delay(N) delayMilliseconds(N)

void Serial_write(unsigned char val);
void uptime_init();

unsigned long millis();
unsigned long micros();


#endif // __ARDUINO_H__

