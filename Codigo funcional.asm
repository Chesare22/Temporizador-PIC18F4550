#include <p18f4550.inc>

    
;----sección de datos---------------
    ;-----------palabra de configuracion----------------
     ; CONFIG1L
  CONFIG  PLLDIV = 5            ; PLL Prescaler Selection bits (Divide by 5 (20 MHz oscillator input))
  CONFIG  CPUDIV = OSC1_PLL2    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
  CONFIG  USBDIV = 1            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes directly from the primary oscillator block with no postscale)

; CONFIG1H
  CONFIG  FOSC = INTOSC_HS      ; Oscillator Selection bits (Internal oscillator, HS oscillator used by USB (INTHS))
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = ON            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOR = OFF             ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown-out Reset Voltage bits (Minimum setting 2.05V)
  CONFIG  VREGEN = OFF          ; USB Voltage Regulator Enable bit (USB voltage regulator disabled)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = OFF           ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = OFF           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled)
  CONFIG  ICPRT = OFF           ; Dedicated In-Circuit Debug/Programming Port (ICPORT) Enable bit (ICPORT disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM is not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM is not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)
;-----------------------------------------------------------------------------------------------------
;----sección de datos---------------
    UDATA_ACS
    
;Macro de actualizacion de datos
mandoDatos MACRO valor, direccion
 ;Aqui se realiza el mandado de datos a la pantalla
 Local esperaParte1, esperaParte2
 
 movf SSPBUF, W, 0
 movlw direccion
 movwf SSPBUF, 0
 
 ;Verifico si el SSPBUF se haya llenado
esperaParte1: 
 btfss SSPSTAT, BF,0
 bra esperaParte1
 
 movf SSPBUF, W,0
 movf valor, 0 ; valor
 movwf SSPBUF, 0
 bcf PORTB, 3, 0
 
esperaParte2:
 btfss SSPSTAT, BF,0
 bra esperaParte2
 
 bsf PORTB, 3 , 0 ;Pongo en uno el pint 3 del puerto B para hacer el envio
 movf SSPBUF, W, 0
 
 ENDM
 
 
;Variables necesarias para que el código y las funcionen chambeen
minutos	    RES 1
segundos    RES 1
decimas	    RES 1
digito	    RES 1
altoBajo    RES 1
;La variable estado es exclusiva del bloque principal
estado	    RES 1
;tempVale0 únicamente va a valer 1 si tanto minutos, segundos y décimas valen cero
;Va a servir para la transición de los estados 8 y 9 al 2
tempVale0   RES 1
;Las siguientes variables son las que guardan los valores que se pueden perder al surgir una interrupción
W_TEMP	    RES 1
STATUS_TEMP RES 1
BSR_TEMP    RES 1
    
max res 1
min res 1
maxD res 1
 ;----Las variables de abajo van a ser globales---------
minutodec RES 1 ;Primera parte del minuto
segundodec RES 1 ;Primera parte del segundo
minutounidad RES 1 ;Segunda parte del minuto
segundounidad RES 1 ;Segunda parte del segundo
nueve RES 1	;Esta  no
valor RES 1
    

;-----Sección de código-------
RES_VECT CODE 0X00
 ;Configuracion de la frecuencia de oscilacion
   movlw b'01110011'
   movwf OSCCON, 0
 bra inicio
 
 ORG 0x08
 goto interrupcion

inicio:
    
;-----------Antes que nada, las notas importantes--------
;El timer0 nos dice si ya pasaron 3 segundos
;El timer1 nos dice si ya pasó una décima de segundo
;El botón principal se conecta al pin 2 del puerto B
;El botón de aumentar se conecta al pin 0 del puerto D
;El botón de decrementar se conecta al pin 1 del puerto D
    
;Primero inicio las variables en 0
  clrf minutos, 0
  clrf segundos, 0
  clrf decimas, 0
  clrf estado, 0
  clrf digito, 0
  clrf altoBajo, 0
  
  ;----Ahora nuestro código va a estar en el estado 8 (o sea, con el temporizador corriendo)------
  
  
;Configuro todo lo que necesito
  call configEntrada		;Confirugo que pueda recibir datos de los botones
  call configurarDriver		;Configuro todo lo necesario para poder mandarle datos al driver
  call configTimer0		;Habilito su interrupción, le asigno prioridad alta y bajo la bandera. NO LO PRENDO
  call configTimer1		;Habilito su interrupción, le asigno prioridad alta y bajo la bandera. NO LO PRENDO
  call iniciarMinMax
  call prenderPantalla		;Prendo la pantalla
  call actualizarDatos		;Mando los valores iniciales a la pantalla
  
  ;Apenas se prenda va a empezar a tomar 1 minuto
  movlw .2
  movwf estado, 0
  call prenderTimer1
  call esperarTimer1
  ;--------------------------
  
  call activarInterrupciones	;Activo interrupciones
 
  
  
;Ciclo sin fin que espera a que se genere una interrupción
espero:
    bra espero
  
    movlw 0x10
;Bloque de código que nos dice qué hacer en caso de interrupciones.
;Primero vemos en qué estado estamos
;Después checamos qué activó la interrupción
;Si la interrupción activada no nos interesa, regresamos a donde estábamos
interrupcion:
  ;Antes que nada, guardamos los datos necesarios
  movwf  W_TEMP 		; Salva el contenido del registro W 
  movff STATUS, STATUS_TEMP	;Salva el contenido del registro STATUS
  movff BSR, BSR_TEMP		;Salva el contenido del registro BSR


    
  ;Checo si estamos en el estado 0
  ;Continúo en caso contrario
  movlw d'0'
  CPFSEQ estado
  bra continuar0
  ;----------Si llego a esta línea, estoy en el estado 0---------
  ;Ahora debo checar la causa de la interrupción
  ;¿Fue por el botón principal?
  btfsc PORTB, 2, 0
  bra E0IP	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;Ninguna otra interrupción me interesa, así que me regreso
  bra regresar
  
continuar0:
  ;Checo si estamos en el estado 1
  ;Continúo en caso contrario
  movlw d'1'
  CPFSEQ estado
  bra continuar1
  ;----------Si llego a esta línea, estoy en el estado 1---------
  ;Ahora debo checar la causa de la interrupción
  ;¿Fue el timer 0?
  btfsc INTCON, TMR0IF, 0
  bra E1IT0	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;Ninguna otra interrupción me interesa, así que me regreso
  bra regresar
  
continuar1:
  ;Checo si estamos en el estado 2
  ;Continúo en caso contrario
  movlw d'2'
  CPFSEQ estado
  bra continuar2
  ;----------Si llego a esta línea, estoy en el estado 2---------
  ;Ahora debo checar la causa de la interrupción
  ;¿Fue el timer1?
  btfsc PIR1, TMR1IF, 0
  bra E2IT1	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;¿Fue el botón principal?
  btfsc PORTB, 2, 0
  bra E2IP	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;Ninguna otra interrupción me interesa, así que me regreso
  bra regresar
  
continuar2:
  ;Checo si estamos en el estado 3
  ;Continúo en caso contrario
  movlw d'3'
  CPFSEQ estado
  bra continuar3
  ;----------Si llego a esta línea, estoy en el estado 3---------
  ;Ahora debo checar la causa de la interrupción
  ;¿Fue el timer 0?
  btfsc INTCON, TMR0IF, 0
  bra E3IT0	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;Ninguna otra interrupción me interesa, así que me regreso
  bra regresar
  
continuar3:
  ;Checo si estamos en el estado 4
  ;Continúo en caso contrario
  movlw d'4'
  CPFSEQ estado
  bra continuar4
;----------Si llego a esta línea, estoy en el estado 4---------
  ;Ahora debo checar la causa de la interrupción
  ;¿Fue el timer1?
  btfsc PIR1, TMR1IF, 0
  bra E4IT1	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;¿Fue el botón principal?
  btfsc PORTB, 2, 0
  bra E4IP	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;Ninguna otra interrupción me interesa, así que me regreso
  bra regresar
  
continuar4:
  ;Checo si estamos en el estado 5
  ;Continúo en caso contrario
  movlw d'5'
  CPFSEQ estado
  bra continuar5
  ;----------Si llego a esta línea, estoy en el estado 5---------
  ;Ahora debo checar la causa de la interrupción
  ;¿Fue el timer0?
  btfsc INTCON, TMR0IF, 0
  bra E5IT0	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;Ninguna otra interrupción me interesa, así que me regreso
  bra regresar
  
continuar5:
  ;Checo si estamos en el estado 6
  ;Continúo en caso contrario
  movlw d'6'
  CPFSEQ estado
  bra continuar6
  ;----------Si llego a esta línea, estoy en el estado 6---------
  ;Ahora debo checar la causa de la interrupción
  ;¿Fue el timer1?
  btfsc PIR1, TMR1IF, 0
  bra E6IT1	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;¿Fue el botón principal?
  btfsc PORTB, 2, 0
  bra E6IP	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;Ninguna otra interrupción me interesa, así que me regreso
  bra regresar
  
continuar6:
  ;Checo si estamos en el estado 7
  ;Continúo en caso contrario
  movlw d'7'
  CPFSEQ estado
  bra continuar7
  ;----------Si llego a esta línea, estoy en el estado 7---------
  ;Ahora debo checar la causa de la interrupción
  ;¿Fue el timer0?
  btfsc INTCON, TMR0IF, 0
  bra E7IT0	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;Ninguna otra interrupción me interesa, así que me regreso
  bra regresar
  
continuar7:
  ;Checo si estamos en el estado 8
  ;Continúo en caso contrario
  movlw d'8'
  CPFSEQ estado
  bra continuar8
  ;----------Si llego a esta línea, estoy en el estado 8---------
  ;Ahora debo checar la causa de la interrupción
  ;¿Fue el timer1?
  btfsc PIR1, TMR1IF, 0
  bra E8IT1	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;¿Fue por el botón principal?
  btfsc PORTB, 2, 0
  bra E8IP	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  
  bra regresar
  
continuar8:
  ;Checo si estamos en el estado 9
  ;Continúo en caso contrario
  movlw d'9'
  CPFSEQ estado
  bra continuar9
  ;----------Si llego a esta línea, estoy en el estado 9---------
  ;Ahora debo checar la causa de la interrupción
  ;¿Fue el timer0?
  btfsc INTCON, TMR0IF, 0
  bra E9IT0	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;¿Fue el timer1?
  btfsc PIR1, TMR1IF, 0
  bra E9IT1	    ;Línea que se ejecuta si sí fue
		    ;Salto si no
  ;Ninguna otra interrupción me interesa, así que me regreso
  bra regresar
  
continuar9:
  ;Si llegué aquí es porque surgió una cosa rara y no estoy en ningún estado
  ;Jamás debería estar acá, por eso reinicio los datos
  ;Es un colchón por si todo falla
  
  ;Regreso al estado 0
  clrf estado
  ;Apago los timers
  call apagarTimer0
  call apagarTimer1
  ;Reinicio los valores de minuto, segundo y décima
  clrf minutos, 0
  clrf segundos, 0
  clrf decimas, 0
  ;Ahora me regreso a donde estaba
  bra regresar
  
;Aquí se restauran los valores que se pueden perder al hacer interrupciones
;Posteriormente regresamosa lo que estábamos haciendo antes de la interrupción
regresar:
  movff BSR_TEMP, BSR 		; restaura el registro BSR
  movf  W_TEMP, W 		; restaura el contenido del registro WREG
  movff STATUS_TEMP, STATUS 	; restaura el registro STATUS
  retfie 1
  
  
;-----Aclaraciones sobre la notación------
  ;Las siguientes banderas nos indican qué hacer en caso de que haya ocurrido tal interrupción en tal estado
  ;Van a tener la forma EnIm
  ;Donde n es el número de estado, y m la interrupción generada
  ;Interrupciones posibles: Por timer0 (T0), timer1 (T1), botón principal (P), botón aumentar (A) y botón decrementar (D)
;---Descripción de los estados---
  ;0 No hago nada, es el estado inicial. Muestra ceros en la pantalla
  ;1 Es cuando se apretó el botón principal. Aquí valido que se haya apretado el suficiente tiempo
    ;Si no se apreta el suficiente tiempo regresamos al estado 0
    ;Si sí, pasamos al siguiente estado
  ;2 Es cuando puedo configurar los minutos
    ;Cada décima de segundo pregunto si hay algún botón apretado
  ;3 Es el estado que decide si corremos el temporizador o nos movemos al estado que configura segundos
    ;El resultado depende de qué tanto tiempo se aprete el botón principal
  ;4 Es cuando puedo configurar los segundos
    ;Cada décima de segundo pregunto si hay algún botón apretado
  ;5 Es el estado que decide si corremos el temporizador o nos movemos al estado que configura décimas de segundo
    ;El resultado depende de qué tanto tiempo se aprete el botón principal
  ;6 Es cuando puedo configurar las décimas de segundo
    ;Cada décima de segundo pregunto si hay algún botón apretado
  ;7 Es el estado que decide si corremos el temporizador o nos movemos al estado que configura minutos
    ;El resultado depende de qué tanto tiempo se aprete el botón principal
  ;8 Aquí está encendido el temporizador
  ;9 También está encendido pero es posible apagarlo si se apreta el botón principal el tiempo suficiente
    ;Si se apaga, regresamos al estado de configurar minutos
  
  ;Después de cada acción que modifique los datos de minuto, segundo o decimas actualizo los datos de la pantalla
    
E0IP:
  ;Pongo que el siguiente estado sea el 1
  movlw d'01'
  movwf estado, 0
  ;Configuro que haya una interrupción del timer0 dentro de 3 segundos
  call esperarTimer0
  bra regresar
E1IT0:
  ;Apago timer0
  call apagarTimer0
  ;¿El botón principal sigue apretado?
  btfsc PORTB, 2, 0
  bra E1IT0SI	;Línea que se ejecuta si sí
  bra E1IT0NO	;Línea que se ejecuta si no
E1IT0SI:
  ;Pongo que el siguiente estado sea el 2 y prendo el timer1
  movlw d'06'
  movwf estado, 0
  ;Prendo el Timer 1
  call prenderTimer1
  ;Programo una interrupción para dentro de una décima
  call esperarTimer1
  bra regresar
E1IT0NO:
  ;Pongo que el siguiente estado sea el 0
  movlw d'00'
  movwf estado, 0
  bra regresar
E2IA:
  call aumento_minuto
  call actualizarDatos ;Actualizo los datos de la pantalla
  bra regresar
E2ID:
  call disminuyo_minuto
  call actualizarDatos ;Actualizo los datos de la pantalla
  bra regresar
E2IP:
  ;Pongo que el siguiente estado sea el 3
  movlw d'03'
  movwf estado, 0
  ;Configuro que haya una interrupción del timer0 dentro de 3 segundos
  call esperarTimer0	;Esta función también prende el timer0
  bra regresar
E3IT0:
  ;Apago timer0
  call apagarTimer0
  ;¿El botón principal sigue apretado?
  btfsc PORTB, 2, 0
  bra E3IT0SI	;Línea que se ejecuta si sí
  bra E3IT0NO	;Línea que se ejecuta si no
E3IT0SI:
  ;Pongo que el siguiente estado sea el 8
  movlw d'08'
  movwf estado, 0
  bra regresar
E3IT0NO:
  ;Pongo que el siguiente estado sea el 4
  movlw d'04'
  movwf estado, 0
  bra regresar
E4IA:
  call aumento_segundos
  call actualizarDatos ;Actualizo los datos de la pantalla
  bra regresar
E4ID:
  call disminuyo_segundos
  call actualizarDatos ;Actualizo los datos de la pantalla
  bra regresar
E4IP:
  ;Pongo que el siguiente estado sea el 5
  movlw d'05'
  movwf estado, 0
  ;Configuro que haya una interrupción del timer0 dentro de 3 segundos
  call esperarTimer0
  bra regresar
E5IT0:
  ;Apago timer0 y demás
  call apagarTimer0
  ;¿El botón principal sigue apretado?
  btfsc PORTB, 2, 0
  bra E5IT0SI	;Línea que se ejecuta si sí
  bra E5IT0NO	;Línea que se ejecuta si no
E5IT0SI:
  ;Pongo que el siguiente estado sea el 8
  movlw d'08'
  movwf estado, 0
  bra regresar
E5IT0NO:
  ;Pongo que el siguiente estado sea el 6
  movlw d'06'
  movwf estado, 0
  bra regresar
E6IA:
  call aumento_deciseg
  call actualizarDatos ;Actualizo los datos de la pantalla
  bra regresar
E6ID:
  call disminuyo_deciseg
  call actualizarDatos ;Actualizo los datos de la pantalla
  bra regresar
E6IP:
  ;Pongo que el siguiente estado sea el 7
  movlw d'07'
  movwf estado, 0
  ;Configuro que haya una interrupción del timer0 dentro de 3 segundos
  call esperarTimer0
  bra regresar
E7IT0:
  ;Apago timer0 y demás
  call apagarTimer0
  ;¿El botón principal sigue apretado?
  btfsc PORTB, 2, 0
  bra E7IT0SI	;Línea que se ejecuta si sí
  bra E7IT0NO	;Línea que se ejecuta si no
E7IT0SI:
  ;Pongo que el siguiente estado sea el 8
  movlw d'08'
  movwf estado, 0
  bra regresar
E7IT0NO:
  ;Pongo que el siguiente estado sea el 2
  movlw d'02'
  movwf estado, 0
  bra regresar
E8IT1:
  ;Checo si el temporizador está en ceros
  call checarSi0
  btfsc tempVale0, 0, 0
  bra voyEstado0    ;Línea que se ejecuta si está en ceros
		    ;Salta si no
  ;Programo que dentro de una décima de segundo se levante la bandera
  call esperarTimer1
  ;Hago lógica del temporizador cuando pasa una décima de segundo
  call reducirTemporizador
  call actualizarDatos ;Actualizo los datos de la pantalla
  bra regresar
voyEstado0:
  ;Pongo que el siguiente estado sea el 2 (el que me permite configurar minutos)
  movlw .2
  movwf estado, 0
  ;Apago el timer0
  call apagarTimer0
  ;Programo que dentro de una décima de segundo se desborde el timer1
  call esperarTimer1
  bra regresar
E8IP:
  ;Pongo que el siguiente estado sea el 9
  movlw d'09'
  movwf estado, 0
  ;Configuro que haya una interrupción del timer0 dentro de 3 segundos
  call esperarTimer0
  call esperarTimer1
  bra regresar
E9IT0:
  ;Apago timer0 y demás
  call apagarTimer0
  ;¿El botón principal sigue apretado?
  btfsc PORTB, 2, 0
  bra E9IT0SI	;Línea que se ejecuta si sí
  bra E9IT0NO	;Línea que se ejecuta si no
E9IT0SI:
  ;Pongo que el siguiente estado sea el 2
  movlw d'06'
  movwf estado, 0
  bra regresar
E9IT0NO:
  ;Pongo que el siguiente estado sea el 8
  movlw d'08'
  movwf estado, 0
  bra regresar
E9IT1:
  ;Checo si el temporizador está en ceros
  call checarSi0
  btfsc tempVale0, 0, 0
  bra voyEstado0
  ;Programo que dentro de una décima de segundo se levante la bandera
  call esperarTimer1
  ;Hago lógica del temporizador cuando pasa una décima de segundo
  call reducirTemporizador
  call actualizarDatos ;Actualizo los datos de la pantalla
  bra regresar
  
E2IT1:
  ;Primero configuro que dentro de una décima de segundo vuelva a interrumpirse
  call esperarTimer1
  ;Checo si hay algún botón apretado
  ;¿Es el botón de aumentar?
  btfsc PORTD, 0, 0
  bra  E2IA	;Línea que se ejecuta si sí es
  ;Si no es, pregunto si fue el botón de disminuir
  btfsc PORTD, 1, 0
  bra E2ID	;Línea que se ejecuta si sí es
  ;En caso de que ningún botón esté apretado, me regreso
  bra regresar
E4IT1:
  ;Primero configuro que dentro de una décima de segundo vuelva a interrumpirse
  call esperarTimer1
  ;Checo si hay algún botón apretado
  ;¿Es el botón de aumentar?
  btfsc PORTD, 0, 0
  bra  E4IA	;Línea que se ejecuta si sí es
  ;Si no es, pregunto si fue el botón de disminuir
  btfsc PORTD, 1, 0
  bra E4ID	;Línea que se ejecuta si sí es
  ;En caso de que ningún botón esté apretado, me regreso
  bra regresar
E6IT1:
  ;Primero configuro que dentro de una décima de segundo vuelva a interrumpirse
  call esperarTimer1
  ;Checo si hay algún botón apretado
  ;¿Es el botón de aumentar?
  btfsc PORTD, 0, 0
  bra  E6IA	;Línea que se ejecuta si sí es
  ;Si no es, pregunto si fue el botón de disminuir
  btfsc PORTD, 1, 0
  bra E6ID	;Línea que se ejecuta si sí es
  ;En caso de que ningún botón esté apretado, me regreso
  bra regresar
  
  ;Función reducirTemporizador
 ;Cuando se llame, va a reducir el valor de las décimas en uno
reducirTemporizador:
    movlw 0
    cpfseq decimas, 0	;Checo si las décimas valen cero
    bra dnc		;Línea que se ejecuta si no vale cero
    bra dc		;Línea que se ejecuta si sí vale cero
    
dc:
    movlw 9
    movwf decimas, 0	;Si vale cero, primero cambio el valor de décimas a 9
    movlw 0
    cpfseq segundos, 0	;Ahora checo si segundos vale cero
    bra snc		;Línea que se ejecuta si no vale cero
    bra seg_c		;Línea que se ejecuta si sí vale cero
    
seg_c:
    movlw .59		    ;Si segundos vale cero, le asigno el valor de 59
    movwf segundos, 0
    call disminuyo_minuto   ;Y reduzo en 1 el valor de minutos
    return
    
dnc:
    call disminuyo_deciseg  ;Si las décimas no valen cero, decremento en 1 su valor
    return
    
snc:
    call disminuyo_segundos ;Si los segundos no valen cero, decremento en 1 su valor
    return
    
;------------------------------------------------------------------------------
activarInterrupciones:
    bsf INTCON, 7, 0   ;Activo las interrupciones
    bsf INTCON, GIEL, 0
    bsf RCON, IPEN, 0
    return
;------------------------------------------------------------------------------
configurarDriver:
    bcf TRISC, 7 , 0
    bcf TRISB, 1 , 0
    bcf TRISB, 3 , 0
   
   ;Configuro el status del buffer
   movlw b'11000000'
   movwf SSPSTAT, 0
   ;Configuro el control del buffer
   movlw b'00100000'
   movwf SSPCON1, 0
   return
;------------------------------------------------------------------------------
configEntrada:
    bsf INTCON3, INT2IE ;Habilidar interrupcion en rb2
    bsf INTCON2, INTEDG2 ;Que sea para flanco alto
    bsf INTCON3, INT2IP ;Que sea de alta prioridad
    bsf TRISD, 0 ;entrada pin0 port d
    bsf TRISD, 1 ;entrada pin1 port d
    bsf TRISB, 2 ;entrada pin2 port b
    movlw 0x0F
    movwf ADCON1, 0 ;Confirugo los puertos A y B como entrada o salida digital
    return
    
checarSi0:
    ;Lo que va a hacer esto es checar si tanto minutos, segundos y décimas valen cero
    ;El resultado de nuestra consulta se guarda en la variable tempVale0
    ;Se va a iniciar con cero, y únicamente cambia a uno al cumplir con las condiciones necesarias
    movlw 0
    movwf tempVale0, 0
    ;Checo si minutos vale cero
    cpfseq minutos, 0
    return  ;Línea que se ejecuta si no vale cero
	    ;Si sí vale cero, continúo
    ;Checo si segundos vale cero
    cpfseq segundos, 0
    return	;Línea que se ejecuta si no vale cero
		;Si sí vale cero, continúo
    cpfseq decimas, 0
    return	;Línea que se ejecuta si no vale cero
		;Si sí vale cero, continúo
    ;Indico que los 3 valores sí valen cero
    movlw 1
    movwf tempVale0, 0
    ;Fin de la función
    return
    
iniciarMinMax: 
    movlw .59   ;Mueve a w el valor de 60  
    movwf max, 0 ;Mueve lo que hay en w a la direccion
    movlw 0      ;Mueve a w el valor de 0    
    movwf min, 0 ;Mueve lo que hay en w a el direccion 
    movlw .9     ;Mueve a w el valor de 10
    movwf maxD, 0 ;Mueve lo que hay en w a la direccion
    movlw 9
    movwf nueve, 0
    clrf minutounidad
    clrf minutodec
    clrf segundodec
    clrf segundounidad
    return
   
;Función separacion_segundo:
;Separo los dígitos en decimal de la variable segundos.
;Deja las decenas en la variable segundodec
;Deja las unidades en la variable segundounidad
;Todo esto lo hago sin modificar el valor de la variable segundos
;Algoritmo:
;Primero le asigno el valor de la variable "segundos" a "segundounidad" e igualo "segundodec" a cero.
;Va a haber un ciclo que compara si la variable "segundounidad" es mayor a 9.
;En caso de que sea mayor que 9, se le resta 10 a "segundounidad" y se suma 1 a "segundodec"
;Si no es mayor que 9, salgo del ciclo y acabo el algoritmo.
separacion_segundo:
    movf segundos, 0, 0
    movwf segundounidad, 0
    movlw 0
    movwf segundodec, 0
    bra ciclo_segundo
    
ciclo_segundo:
    movf nueve, 0, 0
    cpfsgt segundounidad,0
    return
    bra sumadecena_segundo
sumadecena_segundo:
    incf segundodec,1,0
    movlw -0x0A
    addwf segundounidad,1,0
    bra ciclo_segundo 
   
;Función separacion_minuto:
;Separo los dígitos en decimal de la variable minutos.
;Deja las decenas en la variable minutodec
;Deja las unidades en la variable minutounidad
;Todo esto lo hago sin cambiar el valor de la variable minutos
;Algoritmo:
;Primero le asigno el valor de la variable "minutos" a "minutounidad" e igualo "minutodec" a cero.
;Va a haber un ciclo que compara si la variable "minutounidad" es mayor a 9.
;En caso de que sea mayor que 9, se le resta 10 a "minutounidad" y se suma 1 a "minutodec"
;Si no es mayor que 9, salgo del ciclo y acabo el algoritmo.
separacion_minuto:
    movf minutos,0, 0
    movwf minutounidad,0
    movlw 0
    movwf minutodec,0
    bra ciclo_minuto
ciclo_minuto:
    movf nueve,0, 0
    cpfsgt minutounidad,0
    return
    bra sumadecena_minuto
sumadecena_minuto:
    incf minutodec,1,0
    movlw -0x0A
    addwf minutounidad,1,0
    bra ciclo_minuto
    
aumento_minuto: ;Ésta funcion aumenta 1 la variable 'minuto' por cada vez que se aprete el boton 
    movf minutos, 0, 0      ;mueve lo que hay en la dirrecion a W
    cpfseq max, 0       ;Compara lo que hay en W y lo compara lo que hay en la direccion de max, si es igual brinca
    incf minutos, 1, 0   ;incrementa lo que hay en la direccion 
    return  
disminuyo_minuto:   ;Ésta funcion disminuye 1 la variable 'minuto' por cada vez que se aprete el boton
    movf minutos, 0, 0    ;mueve a w lo que hay en la direcion de minuto
    cpfseq min, 0     ;Compara lo que hay en W y lo compara lo que hay en la direccion de min, si es igual brinca
    decf minutos, 1, 0 ;decrementa lo que hay en la direccion de minuto
    return  
aumento_segundos:   ;Ésta funcion aumenta 1 la variable 'segundo' por cada vez que se aprete el boton
    movf segundos, 0, 0    ;mueve lo que hay en la dirrecion a W
    cpfseq max, 0      ;Compara lo que hay en W y lo compara lo que hay en la direccion de min, si es igual brinca 
    incf segundos, 1, 0 ;incremta lo que hay en la direccion
    return    
disminuyo_segundos: ;Ésta funcion disminuye 1 la variable 'segundo' por cada vez que se aprete el boton
    movf segundos, 0, 0
    cpfseq min, 0
    decf segundos, 1, 0
    return  
aumento_deciseg:    ;Ésta funcion aumenta 1 la variable 'deciseg' por cada vez que se aprete el boton
    movf decimas, 0, 0
    cpfseq maxD, 0
    incf decimas, 1, 0
    return
disminuyo_deciseg:  ;Ésta funcion disminuye 1 la variable 'deciseg' por cada vez que se aprete el boton
    movf decimas, 0, 0
    cpfseq min, 0
    decf decimas, 1, 0
    return
    
configTimer0:
 ;----------------------Configuracion del Timer 0------------------------------
;TMR0ON bit para prender, T08BIT configutra 8 o 16 bits T0CS selecciona fuente de reloj
;T0SE fuente externa, PSA selecciona prescaler T0PS2 valor del prescaler
 
 
 ;TMR0ON=0, STOPS TIMER
 ;T08BIT=0, Configured as a 16-bit timer/counter
 ;T0CS=0, Internal instruction cycle clock
 ;T0SE=0, Increment on high-to-low transition on T0CKI pin
 ;PSA=0, Timer0 Prescaler is asigned
 ;T0PS2:T0PS0=111, 1:256 Prescaler value

 movlw b'00000111'
 movwf T0CON,0
 
 bsf INTCON, TMR0IE       ; Activo la interrupcion del timer0
 bsf INTCON2, TMR0IP	  ; Le doy al timer0 prioridad alta de interrupción
 bcf INTCON,TMR0IF        ; Bajo la bandera
 
 return
 
prenderTimer0: 
    bsf T0CON, TMR0ON

    return
    
apagarTimer0: 
    bcf T0CON, TMR0ON

    return
    
    
configTimer1:
    ;Que sea una sola operación de 16 bits
    ;Usamos el oscilador del timer1
    ;Ponemos un prescaler de 8
    ;Activamos el oscilador del timer 1
    ;Usamos el reloj interno
    ;No prendemos timer1
    movlw b'11111000'
    movwf T1CON, 0
    
    ;Para las interrupciones
    bsf PIE1, TMR1IE	;Activamos interrupciones
    bcf PIR1, TMR1IF	;Bajamos la bandera
    bsf IPR1, TMR1IP	;Asigno prioridad alta a las interrupciones
    return

prenderTimer1: 
    bsf T1CON, TMR1ON	;Prendo timer 1
    return
 
apagarTimer1: 
    bcf T1CON, TMR1ON	;Apago timer 1
    return

    
esperarTimer0:
    movlw high .53818  ;	    11,718 es la cuenta que debe ser para poder hacer 3 segundos
    movwf TMR0H, 0
    movlw low .53818
    movwf TMR0L, 0
    bcf INTCON, TMR0IF	    ;Bajo la bandera del timer0
    call prenderTimer0	    ;Prendo el timer0
    return
    
    
esperarTimer1:
    movlw high .53036 ; Muevo la parte alta del valor de inicio a w. Nuestra cuenta es 12,500 usando el prescalar 8 y ciclo de reloj 1mhz
    movwf TMR1H, 0 ; Muevo el valor de w a la parte alta del registro usando memoria reducida
    movlw low .53036; Muevo la parte baja del valor de inicio a w
    movwf TMR1L, 0 ; Muevo el valor de w a la parte baja del registro usando memoria reducida
    bcf	PIR1, TMR1IF;Bajamos la bandera del timer 1
    return
    
actualizarDatos:
    ;Ponemos un espacio en blanco en el dígito 7
    movlw 0x0F
    movwf valor, 0
    mandoDatos valor, 0x08
    call separacion_minuto
    mandoDatos minutodec , 0x07  ;Se manda la primera parte del minuto
    mandoDatos minutounidad, 0x06 ;Se manda la segunda parte del minuto
    ;Ponemos un espacio en blanco en el dígito 4
    movlw 0x0F
    movwf valor, 0
    mandoDatos valor, 0x05
    call separacion_segundo
    mandoDatos segundodec , 0x04; Se manda la primera parte del segundo
    mandoDatos segundounidad, 0x03; Se manda la segunda parte del segundo
    ;Mando un espacio en blanco en el dígito 1
    movlw 0x0F
    movwf valor, 0
    mandoDatos valor, 0x02
    ;Mando las decimas
    mandoDatos decimas , 0x01; Mando la decima.
    return
    
prenderPantalla:
    ;Mando la instrucción para prender la pantalla
    movlw 0x01
    movwf valor, 0
    mandoDatos valor, 0x0C
    ;Le mando al Max qué dígitos se van a prender
    movlw 0x07
    movwf valor, 0
    mandoDatos valor, 0x0B
    ;Indico la intensidad
    movlw 0x0A
    movwf valor, 0
    mandoDatos valor, 0x0A
    ;Mando la instrucción para que decodifique los datos usando el Code B
    movlw 0x0FF
    movwf valor, 0
    mandoDatos valor, 0x09
    return
    
    
  END

    



    


