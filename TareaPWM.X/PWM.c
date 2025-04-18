/*******************************************************************************
* PWM_POT_PIC16F887_XC8.c
* POT en AN3 para controlar carga en RC2 mediante PWM
* Autor: Basado en código original de Innocent Okoloko (2015)
* Adaptado para PIC16F887
* Frecuencia del oscilador: 4 MHz
******************************************************************************/
#include <xc.h>
#define _XTAL_FREQ 4000000

// Configuración del ADC
unsigned int ADC_Read() {
    ADCON0bits.CHS = 0b0011;  // Canal AN3 (pin RA3)
    __delay_us(25);           // Tiempo de adquisición
    GO_nDONE = 1;             // Inicia conversión ADC
    while(GO_nDONE);          // Espera a que termine la conversión
    return ((ADRESH << 8) | ADRESL);  // Retorna valor de 10 bits
}

void main() {
    unsigned int ADCResult;

    // Configuración de pines
    TRISA = 0b00001000;  // RA3 como entrada (AN3)
    TRISC = 0b00000000;   // RC2 como salida (PWM)
    PORTC = 0x00;         // Inicializa PORTC en 0

    // Configuración del ADC
    ADCON0 = 0b10000001;  // ADC encendido, canal AN3
    ADCON1 = 0b10000000;  // Justificación derecha, FOSC/2

    // Configuración del PWM (Timer2 + CCP2)
    PR2 = 0xFF;           // Frecuencia PWM ~15.63 kHz (4 MHz osc)
    CCP2CON = 0b00001100; // Modo PWM (CCP2 en RC2)
    T2CON = 0b00000100;   // Timer2 ON, prescaler 1:1

    while (1) {
        ADCResult = ADC_Read();  // Lee el potenciómetro (0-1023)
        
        // Ajusta el ciclo de trabajo del PWM (10 bits)
        CCPR2L = (ADCResult >> 2);         // 8 bits más significativos
        CCP2CONbits.DC2B0 = (ADCResult & 0b01);  // Bit 0 del LSB
        CCP2CONbits.DC2B1 = (ADCResult & 0b10);  // Bit 1 del LSB
    }
}