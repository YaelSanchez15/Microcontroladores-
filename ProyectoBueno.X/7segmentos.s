PROCESSOR 16F887  
    
; CONFIG1
    CONFIG  FOSC = XT		  ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
    CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
    CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
    CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
    CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
    CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
    CONFIG  BOREN = ON            ; Brown Out Reset Selection bits (BOR enabled)
    CONFIG  IESO = ON             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
    CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
    CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
    CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
    CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.

  
#include <xc.inc>
    
    psect	    resetvector,abs,class=CODE,delta=2
    
    dato    equ 0x20    ;Almacnara el valor de entrada del puerto A
    fib1    equ 0x21    ;Sumador de la serie
    fib2    equ 0x22    ;Sumador de la serie
    fib3    equ 0x23    ;Para calcular el tercer valor de la serie
    fib4    equ 0x24	;Almacena el primer valor de la serie
    fib5    equ 0x25	;Almacena el segundo valor de la serie
    fib6    equ 0x26	;Almacena el tercer valor de la serie
    fib7    equ 0x27	;Almacena el cuarto valor de la serie
    fib8    equ 0x28	;Almacena el quinto valor de la serie
    fib9    equ 0x29	;Almacena el sexto valor de la serie
    fib10   equ 0x30	;Almacena el septimo valor de la serie
    fib11   equ 0x31	;Almacena el octavo valor de la serie
    fib12   equ 0x32	;Almacena el noveno valor de la serie
    fib13   equ 0x33	;Almacena el decimo valor de la serie
    fib14   equ 0x34	;Almacena el decimo primer valor de la serie
    fib15   equ	0x35	;Almacena el decimo segundo valor de la serie
    fib16   equ	0x36	;Almacena el decimo tercero valor de la serie
    fib17   equ 0x37	;Almacena el decimo cuarto valor de la serie
    resta    equ 0x38	;Valor para restar n veces (en la division)
    resultado equ	0x39	;(Resultado de restar n veces)
    unidades equ 0x40		;unidades del numero 
    decenas  equ	0x41	;decenas del numero 
    centenas  equ	0x42	;centenas del numero 
    numerador equ 0x43		;numerador de la division
    suma1	    equ 0x44	;Almacena el valor contenido en una direccion
    tiempo	    equ 0x47   ;Tiempo
 
; Vectores de reset y de inicio de programa
   org  0
   goto Inicio
   org  5

Inicio:
    bsf STATUS, 5       ; Banco 1
    movlw 0xFF          ; Configura PORTA como entrada
    movwf TRISA         
    movlw 0x00          ; Configura PORTB, C y D como salida
    movwf TRISB
    movwf TRISC
    movwf TRISD
    movlw	0x17	    ;Guarda 0x17 en el registro W
    movwf	OPTION_REG  ;Configuramos OPTION_REG para usar el Timer0
    bcf STATUS, 5       ; Banco 0

    bsf STATUS, 5       ; Banco 3
    bsf STATUS, 6       
    clrf ANSEL          ; Desactiva entradas analógicas
    clrf ANSELH         
    bcf STATUS, 5       ; Banco 1
    bcf STATUS, 6       
    clrf PORTC		 ;Limpia los puerto C, B y D
    clrf PORTB
    clrf PORTD
    movlw 0x0D		
    movwf dato		;Carga el 13 a dato para calcular los primeros 14 valores (0-13)
    call calcular_fibonacci ;calcular los primeros 14 valores y almacenarlos en la memoria
    
ciclo:
    call leer_puerto_A	;Lee el dato del puerto A
    movf suma1, W	;El  valor obtenido del apuntador se almacena en numerador
    movwf numerador	
    movlw 0x64		    ;Carga 100 en W para las restas sucesivas
    call obtener_division   ;Para centenas
    movf resultado, W	    ;El reultado se almacena en centenas
    movwf centenas
    movlw 0x64		    ;Carga 100 en W 
    addwf numerador, F      ;Suma 100 a numerador para reponer la ultima resta negativa
    movlw 0x0A		    ;Carga 10 en W para las restas sucesivas
    call obtener_division   ;Para centenas
    movf resultado, W	    ;El reultado se almacena en decenas
    movwf decenas
    movlw 0x0A		      ;Carga 10 en W 
    addwf numerador, F        ;Suma 10 a numerador para reponer la ultima resta negativa
    call escribir_puerto_B
    call escribir_puerto_C
    call escribir_puerto_D
    goto ciclo

leer_puerto_A:
    movf PORTA, W       ; Lee el valor de PORTA
    movwf dato          ; Almacena el valor en 'dato'
    movlw 0x24		;Almacena 0x24 en w
    addwf dato, W	;Suma ox24 a dato (0x24 es el inicio de la memoria donde estan los valores de la serie)
    movwf FSR		;Apunta a la direccion 
    movf INDF, w	;Guarda el valor que hay en la direccion en W
    movwf suma1		;Guarda el valor en suma1
    return

calcular_fibonacci:
    movlw 0x24		;Almacena 0x24 en W (0x24 es donde inicia la memoria para almacenar los resultados de la serie)
    movwf FSR		;Apunta a la direccion 0x24
    movlw 0x00          ; Inicializa fib1 = 0
    movwf fib1		;fib1 guarda el valor 0x00 (valor inicial)
    movlw 0x00		; Inicializa fib2 = 1
    movwf fib2		; Inicializa fib1 = 0
    movf fib2, 0	; Carga el valor de fib2 (0x01) en W
    addwf fib1, w	; Suma fib1 (0x02) con W (0x01). Resultado: W = 0x03
    movwf fib1		;Carga el resultado de la suma a fib1
    movwf numerador	;Craga el reultado de la suma a numerador
    movwf INDF		;Craga el resultado de la suma a la direccion 0x24
    incf  FSR		;Incrementa el valor del apuntador
    call escribir_puerto_D  ;Llama a la rutina para escribir en el puerto D
    movlw 0x00		    ;Coloca un cero en decenas y centenas
    movwf decenas
    movwf centenas
    call escribir_puerto_B  ;Llama a la rutina para escribir en el puerto B
    call escribir_puerto_C  ;Llama a la rutina para escribir en el puerto C
    call retardo	    ;Genera un retardo para el siguiente numero
    movf dato, W        ; Carga el valor de 'dato' en W
    btfsc STATUS, 2     ; Si dato es 0, salta (Fibonacci(0) = 0)
    return
    
    movlw 0x00          ; Inicializa fib1 = 0
    movwf fib1	    
    movlw 0x01          ; Inicializa fib2 = 1
    movwf fib2
    movf fib2, 0	; Carga el valor de fib2 (0x01) en W
    addwf fib1, w	; Suma fib1 (0x02) con W (0x01). Resultado: W = 0x03
    movwf fib1		;Guarda el valor en fib1
    movwf numerador	;Guarda el valor en numerador
    movwf INDF		;Guarda el resultado en la direccion 0x25
    incf  FSR		;Incrementa el valor del apuntador
    call escribir_puerto_D  ;Llama a la rutina para escribir en el puerto D
    call retardo	    ;Genera un retado para el sigioente numero
    decfsz dato, F      ; Decrementa dato y salta si es cero
    goto fib_loop       ; Si no es cero, entra en el bucle
    return

fib_loop:
    movf fib2, W        ; Mueve fib2 a W
    addwf fib1, W       ; Suma fib1 + fib2
    movwf fib3          ; Almacena el resultado en fib3
    movf fib2, W        ; Mueve fib2 a W
    movwf fib1          ; fib1 = fib2
    movwf numerador	;Guarda el valor en numerador
    movwf INDF		;Guarda el resultado en la direccion establecida
    incf  FSR		;Incrementa el valor del apuntador
    movf fib3, W        ; Mueve fib3 a W
    movwf fib2          ; fib2 = fib3
    movlw 0x64		    ;Carga 100 en W para las restas sucesivas
    call obtener_division   ;Para centenas
    movf resultado, W	    ;El reultado se almacena en centenas
    movwf centenas
    movlw 0x64		    ;Carga 100 en W 
    addwf numerador, F      ;Suma 100 a numerador para reponer la ultima resta negativa
    movlw 0x0A		    ;Carga 10 en W para las restas sucesivas
    call obtener_division   ;Para centenas
    movf resultado, W	    ;El reultado se almacena en decenas
    movwf decenas
    movlw 0x0A		      ;Carga 10 en W 
    addwf numerador, F        ;Suma 10 a numerador para reponer la ultima resta negativa
    call escribir_puerto_B
    call escribir_puerto_C
    call escribir_puerto_D
    call retardo
    decfsz dato, F      ; Decrementa dato y salta si es cero
    goto fib_loop       ; Si no es cero, repite el bucle
    return

escribir_puerto_B:
   
    movf centenas, W	;Guarda el valor de las centenas en W
    andlw 0x0F		;Establece en valor maximo permitido para centenas
    call tabla_7seg	;Obtiene el valor de 7seg para colocarlo en el puerto B
    movwf PORTB         ; Escribe en PORTB
    return
    
escribir_puerto_C:
    movf decenas, W        ;Guarda el valor de las decenas en W
    andlw 0x0F		   ;Establece en valor maximo permitido para decenas
    call tabla_7seg	   ;Obtiene el valor de 7seg para colocarlo en el puerto C
    movwf PORTC		   ; Escribe  en PORTC
    return
    
escribir_puerto_D:
    movf numerador, W        ;Guarda el valor en W
    andlw 0x0F		     ;Establece en valor maximo permitido para decenas
    call tabla_7seg	     ;Obtiene el valor de 7seg para colocarlo en el puerto C
    movwf PORTD		     ;Escribe  en PORTD
    return
    
obtener_division:		
    clrf resultado	;Limpia la variable reultado
    
divi:
    subwf numerador, F	    ;Resta a numerador el valor previamente cargado en W
    btfsc STATUS, 0	    ;Revisa que no se haya producido carry y si es el caso salta la siguiente instruccion
    goto resultado_div	    ;Va a resultado_div
    return
    
resultado_div:
    incf resultado, F	   ;Incrementa el valor de resultado (establece cuantas veces se hace las restas)
    goto divi		   ;Regresa a div
    
retardo:
	movlw	0x10		    ;Guardamos en W el numero de repeticiones del programa
	movwf	tiempo		    ;Guardamos el valor en la variable tiempo
	call	delay		    ;Llamamos a la subrutina daley
	return			    ;Regresamos a la subrutina
	
    delay:			    
	bcf	INTCON,2	    ;Pone un 0 en el bit dos de INTCON
	movlw	0x3C		    ;Guarda el valor de tiempo en W
	movwf	TMR0		    ;Coloca el valor de W en TMR0
	
    delay1:
	btfss	INTCON,2	    ;Verifica si hubo desbordamiento (bit 2 con valor en 1)
	goto	delay1		    ;Repite hasta que haya desbordamiento
	decfsz	tiempo,f	    ;Decrementa tiempo y cuando es 0 salta la siguiente intruccion
	goto	delay		    ;ciclo hasta que tiempo sea cero
	return			    ;Regresamos a la surutina
	
tabla_7seg: 
    addwf PCL, F        ; Ajusta el contador de programa (PCL) según el valor en W
    retlw 0b00111111   ; 0
    retlw 0b00000110   ; 1
    retlw 0b01011011  ; 2
    retlw 0b01001111   ; 3
    retlw 0b01100110   ; 4
    retlw 0b01101101   ; 5
    retlw 0b01111101   ; 6
    retlw 0b00000111   ; 7
    retlw 0b01111111   ; 8
    retlw 0b01101111   ; 9

END