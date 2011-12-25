;*******************************************************************************
;   MSP430F21x2 Demo - ADC10, DTC Sample A10 64x, 1.5V, Repeat Single, DCO
;
;   Description: Use DTC to sample A10 64 times with reference to internal 1.5v.
;   Vref Software writes to ADC10SC to trigger sample burst. In Mainloop MSP430
;   waits in LPM0 to save power until ADC10 conversion complete, ADC10_ISR(DTC)
;   will force exit from LPM0 in Mainloop on reti. (ADC10OSC/4)/64
;   determines sample time which needs to be greater than 30us for temperature
;   sensor. DTC transfers conversion code to RAM 200h - 280h. P1.0 set at start
;   of conversion burst, reset oncompletion. Temperature sensor offset and slope
;   will vary from device to device per datasheet tolerance.
;
;                MSP430F21x2
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;            |A10          P1.0|-->LED
;
;  JL Bile
;  Texas Instruments Inc.
;  May 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x21x2.h"
;-------------------------------------------------------------------------------
 			.text							;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #025Fh,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupADC10  mov.w   #INCH_10+ADC10DIV_3+CONSEQ_2,&ADC10CTL1 ;
            mov.w   #SREF_1+ADC10SHT_3+MSC+REFON+ADC10ON+ADC10IE,&ADC10CTL0 ;
            mov.w   #30,&TACCR0             ; Delay to allow Ref to settle
            bis.w   #CCIE,&TACCTL0          ; Compare-mode interrupt.
            mov.w   #TACLR+MC_1+TASSEL_2,&TACTL; up mode, SMCLK
            bis.w   #LPM0+GIE,SR            ; Enter LPM0, enable interrupts
            bic.w   #CCIE,&TACCTL0          ; Disable timer interrupt
            mov.b   #040h,&ADC10DTC1        ; 64 conversions
SetupP1     bis.b   #001h,&P1DIR            ; P1.0 output
                                            ;
Mainloop    bic.w   #ENC,&ADC10CTL0         ;
busy_test   bit     #BUSY,&ADC10CTL1        ; ADC10 core inactive?
            jnz     busy_test               ;
            mov.w   #0200h,&ADC10SA         ; Data buffer start
            bis.b   #001h,&P1OUT            ; P1.0 = 1
            bis.w   #ENC+ADC10SC,&ADC10CTL0 ; Start sampling
            bis.w   #CPUOFF+GIE,SR          ; LPM0, ADC10_ISR will force exit
            bic.b   #001h,&P1OUT            ; P1.0 = 0
            jmp     Mainloop                ; Again
                                            ;
;-------------------------------------------------------------------------------
TA0_ISR;    ISR for TACCR0
;-------------------------------------------------------------------------------
            clr.w   &TACTL                  ; Clear Timer_A control registers
            bic.w   #LPM0,0(SP)             ; Exit LPM0 on reti
            reti                            ;
;-------------------------------------------------------------------------------
ADC10_ISR;  Exit LPM0 on reti
;-------------------------------------------------------------------------------
            bic.w   #LPM0,0(SP)             ; Exit LPM0 on reti
            reti                            ;
                                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".int05"            	; ADC10 Vector
            .short  ADC10_ISR
            .sect   ".int09"          		; Timer_A0 Vector
            .short  TA0_ISR
            .sect   ".reset"	            ; POR, ext. Reset
            .short  RESET
            .end
            