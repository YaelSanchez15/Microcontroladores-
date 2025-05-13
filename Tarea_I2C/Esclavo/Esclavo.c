#include <16F887.h>
#use delay(clock=20M, crystal=20000000)
#use I2C(SLAVE, SDA=PIN_C4, SCL=PIN_C3, address=0xA0, SLOW)  // Configuración como esclavo I2C
#use standard_io(B)

#define led_1 PIN_B0                                        // Pin del led

int8 dato_recibido;                                         // Almacena el dato que envía el maestro

#INT_SSP                                                   // Interrupción por I2C
void interrupcion_i2c()
{
   if(i2c_poll())                                          // Verifica si se han recibido datos por I2C
   {
      dato_recibido = i2c_read();                          // Lee el dato recibido por I2C y lo almacena
   }
}

void main()
{
  
   setup_timer_0(RTCC_INTERNAL|RTCC_DIV_1);                // Configura Timer0
   setup_timer_1(T1_DISABLED);                             // Deshabilita Timer1
   setup_timer_2(T2_DISABLED,0,1);                         // Deshabilita Timer2
   setup_adc_ports(NO_ANALOGS);                            // Deshabilita ADC
   setup_adc(ADC_OFF);                                     // Apaga ADC
   setup_CCP1(CCP_OFF);                                    // Deshabilita CCP1
   setup_CCP2(CCP_OFF);                                    // Deshabilita CCP2
   
   enable_interrupts(INT_SSP);                             // Habilita la interrupción por I2C
   enable_interrupts(GLOBAL);                              // Habilita las interrupciones globales
   
   output_b(0x00);                                         // Inicializa PORTB
   set_tris_b(0x00);                                       // Configura PORTB como salidas (excepto RB0 si es entrada)
   output_low(led_1);                                      // Inicializa el led apagado
   
   while(true)
   {
      if(dato_recibido == 0x10)                            // Si el dato recibido es 0x10
      {
         output_high(led_1);                               // Enciende el led
      }
      if(dato_recibido == 0x20)                            // Si el dato recibido es 0x20
      {
         output_low(led_1);                                // Apaga el led
      }
   }
}
