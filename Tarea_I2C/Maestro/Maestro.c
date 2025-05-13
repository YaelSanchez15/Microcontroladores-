#include <16F887.h>
#use delay(clock=20M, crystal=20000000)
#use I2C(MASTER, SDA=PIN_C4, SCL=PIN_C3, SLOW)        // Configuración del bus I2C
#use standard_io(B)

#define boton_1 PIN_B0                                 // Pin del pulsador 1
#define boton_2 PIN_B1                                 // Pin del pulsador 2

void enviar_dato_i2c(int8 address, int8 data);         // Declaración de la función para enviar datos por I2C

void main()
{
   set_tris_b(0x03);                                   // RB0 y RB1 como entradas, otros como salidas
   
   while(true)
   {
      if(!input(boton_1))                              // Si se presiona el pulsador 1 (asumiendo pull-up)
      {
         while(!input(boton_1));                       // Espera hasta que se suelte el botón
         delay_ms(50);                                 // Anti-rebote
         enviar_dato_i2c(0xA0, 0x10);                 // Envia el dato 0x10 por I2C al esclavo
      }
      
      if(!input(boton_2))                              // Si se presiona el pulsador 2 (asumiendo pull-up)
      {
         while(!input(boton_2));                       // Espera hasta que se suelte el botón
         delay_ms(50);                                 // Anti-rebote
         enviar_dato_i2c(0xA0, 0x20);                  // Envia el dato 0x20 por I2C al esclavo
      }
   }
}

void enviar_dato_i2c(int8 address, int8 data)         // Función de envío de datos por I2C
{
   i2c_start();                                       // Iniciar comunicación
   i2c_write(address);                                // Dirección
   i2c_write(data);                                   // Dato
   i2c_stop();                                        // Detener comunicación
   delay_ms(50);                                      // Retardo
}
