#include "arduino.h"

#include <msp430.h>
#include <legacymsp430.h>

volatile unsigned long mcu_ms = 0;

void uptime_init() {

	// Get the controller clock
	// Set up the timer
	WDTCTL = WDTPW | WDTCNTCL;
	WDTCTL = WDTPW | WDTCNTCL | WDTSSEL;
	WDTCTL = WDTPW | WDTHOLD;
	// Start the timer, clock/8192 interval
	WDTCTL = WDTPW | WDTCNTCL | WDTTMSEL | WDTIS0;
	// We can also later use this for PWM output

}

interrupt(TIMER0_A0_VECTOR) clockctl_isr(void) {

	mcu_ms++;

}

unsigned long micros() {

	// These calculations are bogus. We need to fix this so we know the click.
	return (mcu_ms * 10);

}

unsigned long millis() {

	// These calculations are bogus. We need to fix this so we know the click.
	return (mcu_ms / 100);

}
