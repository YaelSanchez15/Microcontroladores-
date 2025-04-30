/***********************************************************************
* UART0_MASTER_PIC16F887_XC8.c
* UART PIC TO PIC COMMUNICATION
* WHEN THE PUSH BUTTON AT THE RB7 OF MASTER PIC IS PRESSED, TOGGLE THE
* LED AT RB7 OF SLAVE PIC.
* MODIFIED FOR PIC16F887
**********************************************************************/
#include <xc.h>
#define _XTAL_FREQ 4000000 // Declare internal OSC Freq as 4MHz

// Configuration bits for PIC16F887
#pragma config FOSC = INTRC_NOCLKOUT // Internal oscillator, no clock out
#pragma config WDTE = OFF           // Watchdog Timer disabled
#pragma config PWRTE = OFF          // Power-up Timer disabled
#pragma config MCLRE = ON           // MCLR/VPP pin function is MCLR
#pragma config CP = OFF             // Program memory code protection is off
#pragma config CPD = OFF            // Data memory code protection is off
#pragma config BOREN = ON           // Brown-out Reset enabled
#pragma config IESO = ON           // Internal/External Switchover enabled
#pragma config FCMEN = ON           // Fail-Safe Clock Monitor enabled
#pragma config LVP = OFF            // Low-voltage programming disabled

void USARTWriteChr(unsigned char c) {
    while(!PIR1bits.TXIF); // Wait until TX buffer is empty
    TXREG = c;
}

void main(void) {
    // Initialize oscillator
    OSCCONbits.IRCF = 0b110; // Set internal oscillator to 4MHz
    
    
    // PORTB configuration
    TRISB = 0xFF;  // PORTB as input
    OPTION_REGbits.nRBPU = 0; // Enable PORTB internal pull-up resistors
    
    // UART configuration
    SPBRG = 25;    // For 9600 baud at 4MHz with BRGH=1
    TXSTAbits.TXEN = 1; // Transmit enable
    TXSTAbits.BRGH = 1; // High baud rate select
    RCSTAbits.SPEN = 1; // Serial port enable
    
    while(1) {
        USARTWriteChr(PORTB); // Transmit PORTB bits
        __delay_ms(100);
    }
}