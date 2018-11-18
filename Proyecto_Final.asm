;*******************************************************************************
; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
#include "p16f887.inc"

; CONFIG1
; __config 0xE0F4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
;*******************************************************************************
GPR_VAR        UDATA
W2	    RES     1
STATUS2	    RES     1
DELAY1	    RES	    1
DELAY2	    RES	    1
PAQUETE	    RES	    1
RECIBO	    RES	    1
MANDAR	    RES	    1
EXTRA	    RES	    1
PERIODO	    RES	    1
CONT_PWM1   RES	    1
CONT_PWM2   RES	    1
    
;*******************************************************************************
   
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED
ISR       CODE    0x0004           ; interrupt vector location
  PUSH:
    MOVWF W2
    SWAPF STATUS,W
    MOVWF STATUS2
  ISR:
    NOP
  POP:
    SWAPF STATUS2,W
    MOVWF STATUS
    SWAPF W2,F
    SWAPF W2,W
    RETFIE
;*******************************************************************************
;--------------------------SUBRUTINAS DE INTERRUPCION---------------------------


;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************
MAIN_PROG CODE                      ; let linker place main program
 
START
 CALL PINES
 CALL LIMPIAR
 CALL OSCILADOR
 CALL ADC_CONF
 CALL CEREAL
 CALL TIMER0
 CALL TIMER1
 CALL PWM_2
 CALL PWM_1
 
 BCF STATUS, 6
 BCF STATUS, 5	;BANCO 0
 
 MANUAL:
    ;---------------POT 1-----------------
    CALL AN_0
    CALL ENVIO
    CALL RETRASAR	
    BTFSC PIR1, RCIF
    CALL RECIBIR_DEF
    MOVF EXTRA, W
    MOVWF CCPR1L
    ;---------------POT 2-----------------
    CALL AN_1
    CALL ENVIO
    CALL RETRASAR
    BTFSC PIR1, RCIF
    CALL RECIBIR_DEF
    MOVF EXTRA, W
    MOVWF CCPR2L
    ;---------------POT 3-----------------
    CALL AN_2
    CALL ENVIO
    CALL RETRASAR
    
    ;---------------POT 4-----------------
    CALL AN_3
    CALL ENVIO
    CALL RETRASAR
    
    ;BTFSC PIR1, RCIF
    ;CALL RECIBIR_DEF
    
    GOTO MANUAL
;*******************************************************************************
;-----------------------------SUBRUTINAS PRINCIPAL------------------------------
ENVIO
    BSF ADCON0, GO
    BTFSC ADCON0, GO	;ESPERA LA CONVERSION
    GOTO $-1
    MOVF ADRESH, W
    MOVWF TXREG		;MANDA EL VALOR CONVERTIDO
    BCF PIR1, ADIF
    BTFSS PIR1, TXIF	;ESPERA A QUE SE MANDE
    GOTO $-1
    RETURN
;
CH_AN0
    BCF ADCON0, 5
    BCF ADCON0, 4
    BCF ADCON0, 3
    BCF ADCON0, 2	;SELECCIONO CANAL DE ENTRADA AN0
    RETURN
;    
CH_AN1
    BCF ADCON0, 5
    BCF ADCON0, 4
    BCF ADCON0, 3
    BSF ADCON0, 2	;SELECCIONO CANAL DE ENTRADA AN1
    RETURN
;    
CH_AN2
    BCF ADCON0, 5
    BCF ADCON0, 4
    BSF ADCON0, 3
    BCF ADCON0, 2	;SELECCIONO CANAL DE ENTRADA AN2
    RETURN
;    
CH_AN3
    BCF ADCON0, 5
    BCF ADCON0, 4
    BSF ADCON0, 3
    BSF ADCON0, 2	;SELECCIONO CANAL DE ENTRADA AN3
    RETURN
;    
RETRASAR ;DELAY DE 50ms
    MOVLW .55
    MOVWF DELAY1
    MAS:	
	MOVLW .54
	MOVWF DELAY2
    SEGUIR:    
	DECFSZ DELAY2
	GOTO SEGUIR
    DECFSZ DELAY1
    GOTO MAS
    RETURN
;    
RECIBIR_DEF
    BCF CCP2CON, DC2B0
    BCF CCP2CON, DC2B1
    MOVF RCREG, W
    MOVWF RECIBO
    BTFSC RECIBO, 0
    BSF CCP2CON, DC2B0
    BTFSC RECIBO, 1
    BSF CCP2CON, DC2B1
    RRF	RECIBO, F
    RRF	RECIBO, W
    ANDLW B'00111111'
    MOVWF EXTRA
    RETURN    
;*******************************************************************************
;--------------------------CONFIGURACION-INICIAL--------------------------------
PINES
    BCF STATUS, 6
    BSF STATUS, 5	;BANCO 1
    CLRF TRISC
    CLRF TRISD
    CLRF TRISB
    CLRF TRISA		;SALIDAS
    BSF TRISA, 0
    BSF TRISA, 1
    BSF TRISA, 2
    BSF TRISA, 3	;ENTRADAS
    
    BSF STATUS, 6
    BSF STATUS, 5	;BANCO 3
    CLRF ANSEL 
    CLRF ANSELH
    BSF ANSEL, 0	;LA ENTRADA ES EL AN0-PORTA 0
    BSF ANSEL, 1	;LA ENTRADA ES EL AN1-PORTA 1
    BSF ANSEL, 2	;LA ENTRADA ES EL AN2-PORTA 2
    BSF ANSEL, 3	;LA ENTRADA ES EL AN3-PORTA 3
    RETURN

LIMPIAR
    BCF STATUS, 6
    BCF STATUS, 5	;BANCO 0
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    CLRF W2
    CLRF STATUS2
    CLRF DELAY1
    CLRF PAQUETE
    CLRF RECIBO
    CLRF MANDAR
    BCF PIR1, 6		;BANDERA DEL ADC
    RETURN
    
OSCILADOR
   BCF STATUS, 6
   BSF STATUS, 5	;BANCO 1

   BCF OSCCON, 6
   BSF OSCCON, 5
   BSF OSCCON, 4	;OSCILADOR A 500kHz
   RETURN
   
ADC_CONF
    BCF STATUS, 6
    BCF STATUS, 5	;BANCO 0
    BCF ADCON0, 7
    BSF ADCON0, 6	;FOSC/8
    
    BCF ADCON0, 5
    BCF ADCON0, 4
    BCF ADCON0, 3
    BCF ADCON0, 2	;SELECCIONO CANAL DE ENTRADA AN0
    
    BCF STATUS, 6
    BSF STATUS, 5	;BANCO 1
    BCF ADCON1, 7	;UTILIZA ADRESSH COMO PRINCIPAL
    BCF ADCON1, 5
    BCF ADCON1, 4	;VOLTAJE DE REFERENCIA VSS Y VDD

    BCF STATUS, 6
    BCF STATUS, 5	;BANCO 0
    BSF ADCON0, 0	;ADC HABILITADO
    RETURN
   
CEREAL
    BCF STATUS, 6
    BSF STATUS, 5	;BANCO 1
    BCF	TXSTA, SYNC     ;ASINCR�NO
    BSF	TXSTA, BRGH	;LOW SPEED
    
    BSF STATUS, 6
    BSF STATUS, 5	;BANCO 3
    BSF	BAUDCTL, BRG16	;16 BAURD RATE GENERATOR
    
    BCF STATUS, 6
    BSF STATUS, 5	;BANCO 1
    MOVLW .12	    
    MOVWF SPBRG		;BAUDRATE CALCULADO
    CLRF SPBRGH
    
    BCF STATUS, 6
    BCF STATUS, 5	;BANCO 0
    BSF	RCSTA, SPEN	;HABILITAR SERIAL PORT
    BCF	RCSTA, RX9	;SOLO MANEJAREMOS 8BITS DE DATOS
    BSF	RCSTA, CREN	;HABILITAMOS LA RECEPCI�N 
    
    BCF STATUS, 6
    BSF STATUS, 5	;BANCO 1
    BSF	TXSTA, TXEN	;HABILITO LA TRANSMISION
    RETURN
    
TIMER0
   BCF OPTION_REG, T0CS	;TIMER0 TEMPORIZADOR
   BCF OPTION_REG, PSA	;ASIGNAR PRESCALER A TIMER0

   BSF OPTION_REG, 2
   BCF OPTION_REG, 1
   BSF OPTION_REG, 0	;VALOR DE PRESCALER 64*****************
   BCF INTCON, T0IF	;BANDERA APAGADA

   BCF STATUS, 6
   BCF STATUS, 5	;BANCO 0
   MOVLW .255		;N CALCULADO***************************
   MOVWF TMR0		;TMR 2ms
   RETURN

TIMER1
   BCF T1CON, 1		;INTERNAL CLOCK
   BCF T1CON, 3		;LP OFF
   BCF T1CON, 6		;ALWAYS COUNTING
   BCF T1CON, 5
   BCF T1CON, 4		;PRESCALER 1	
   BSF T1CON, 0		;ENABLE
   BCF PIR1, TMR1IF	;BANDERA TMR1
   MOVLW b'00001011'
   MOVWF TMR1H 
   MOVLW b'11011100'
   MOVWF TMR1L
   RETURN

PWM_2
   BCF STATUS, 6
   BSF STATUS, 5	;BANCO 1
   BSF TRISC, RC2
   ;MOVLW .155
   MOVLW .77
   MOVWF PR2		;PERIODO DE PWM 20ms
   
   BCF STATUS, 6
   BCF STATUS, 5	;BANCO 0
   
   ;CCP2
   BSF CCP2CON, 3
   BSF CCP2CON, 2
   BSF CCP2CON, 1
   BSF CCP2CON, 0	;MODO PWM
   MOVLW B'00001111'
   MOVWF CCPR2L		;MSB DUTY CICLE
   BSF CCP2CON, DC2B0
   BSF CCP2CON, DC2B1	;LSB DUTY CICLE
   
   ;TIMER 2
   BCF PIR1, TMR2IF
   BSF T2CON, 0
   BSF T2CON, 1		;PRESCALER 1:16
   BSF T2CON, 2		;HABILITAMOS EL TMR2
   BTFSS PIR1, TMR2IF
   GOTO $-1
   BCF PIR1, TMR2IF
   
   BCF STATUS, 6
   BSF STATUS, 5	;BANCO 1
   BCF TRISC, RC2
   RETURN
   
PWM_1
   BCF STATUS, 6
   BSF STATUS, 5	;BANCO 1
   BSF TRISC, RC1
   MOVLW .77
   MOVWF PR2		;PERIODO DE PWM 20ms
   
   BCF STATUS, 6
   BCF STATUS, 5	;BANCO 0
   
   ;CCP1
   BCF CCP1CON, 7
   BCF CCP1CON, 6	;SINGLE OUTPUT
   
   BSF CCP1CON, 3
   BSF CCP1CON, 2
   BCF CCP1CON, 1
   BCF CCP1CON, 0	;P1A, P1C ACTIVE HIGH
   MOVLW B'00001111'
   MOVWF CCPR1L		;MSB DUTY CICLE
   BSF CCP1CON, DC1B0
   BCF CCP1CON, DC1B1	;LSB DUTY CICLE
   
   ;TIMER 2
   BCF PIR1, TMR2IF
   BSF T2CON, 0
   BSF T2CON, 1		;PRESCALER 1:16
   BSF T2CON, 2		;HABILITAMOS EL TMR2
   BTFSS PIR1, TMR2IF
   GOTO $-1
   BCF PIR1, TMR2IF
   
   BCF STATUS, 6
   BSF STATUS, 5	;BANCO 1
   BCF TRISC, RC1
   RETURN
    
    END