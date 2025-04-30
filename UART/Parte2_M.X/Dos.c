/***********************************************************************
* UART0_SLAVE_PIC16F887_XC8.c
* UART PIC TO PIC COMMUNICATION
* WHEN THE PUSHBUTTON AT THE RB7 OF MASTER PIC IS PRESSED, TOGGLE THE
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

char USARTReadChr() {
    while(!PIR1bits.RCIF); // Wait until data is received
    return RCREG;
}

void main(void) {
    // Initialize oscillator
    OSCCONbits.IRCF = 0b110; // Set internal oscillator to 4MHz
    
    // Disable comparators
   
    
    // PORTB configuration
    TRISB = 0x00;  // PORTB as output
    PORTB = 0x00;   // Clear PORTB
    
    // UART configuration
    SPBRG = 25;    // For 9600 baud at 4MHz with BRGH=1
    TXSTAbits.TXEN = 1; // Transmit enable (though we're only receiving)
    TXSTAbits.BRGH = 1; // High baud rate select
    RCSTAbits.SPEN = 1; // Serial port enable
    RCSTAbits.CREN = 1; // Continuous receive enable
    
    while(1) {
        PORTB = USARTReadChr(); // Update PORTB with received data
        __delay_ms(100);
    }
}