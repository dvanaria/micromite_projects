' Updates MMBASIC's DATE$ and TIME$ using a connection to a DS1302 RTC,
'   which holds the current time/date in a battery backed IC.
'
' 4 connections from the DS1302 to the PIC32 are needed:
'   RST  -> pin 6
'   SCLK -> pin 4
'   DAT  -> pin 2
'   GND  -> ground
'
' The DS1302 uses a non-standard, 3-wire serial communication system.
'   Obtain the datasheet for exact details on the architecture of this
'   chip, register formats, opcodes, etc. 
'
' FORMAT OF DATE$ AND TIME$ (functions in MMBASIC):
'   DATE$ = 01-01-2000
'   TIME$ = 01:19:34
'
' Darron Vanaria
' dvanaria@gmail.com
' May 2, 2023


'Names for each DS1302 signal connected to a PIC32 pin (value = pin number)
CONST DAT  = 2
CONST SCLK = 4
CONST RST  = 6

SETPIN DAT,  DOUT
SETPIN SCLK, DOUT
SETPIN RST,  DOUT

'Time to pause to generate waveforms
'This implementation controls the clock pulse manually
DIM INTEGER MS_PAUSE = 3

'Payload to write to DS1302 registers
DIM INTEGER OUTPUT_DATA(7) 

'Taken from DS1302 datasheet
DIM INTEGER COMMAND_WRITE_SEC(7)   = (1,0,0,0,0,0,0,0)
DIM INTEGER COMMAND_WRITE_MIN(7)   = (1,0,0,0,0,0,1,0)
DIM INTEGER COMMAND_WRITE_HOUR(7)  = (1,0,0,0,0,1,0,0)
DIM INTEGER COMMAND_WRITE_DATE(7)  = (1,0,0,0,0,1,1,0)
DIM INTEGER COMMAND_WRITE_MONTH(7) = (1,0,0,0,1,0,0,0)
DIM INTEGER COMMAND_WRITE_YEAR(7)  = (1,0,0,0,1,1,0,0)


REM **** PROGRAM ****
PRINT "Program to set DS1302's time and date"
PRINT
ENTER_TIME
ENTER_DATE
END 


SUB WRITE_TRANSFER COMMAND_BYTE_WRITE_REG%()

  SETPIN DAT, DOUT
  PAUSE MS_PAUSE

  ' initialize WRITE transfer
  PIN(DAT)  = 0  
  PIN(SCLK) = 0  :  ' SCLK must be 0 before initiating transfer
  PIN(RST)  = 0
  PAUSE MS_PAUSE

  ' begin transfer
  PIN(RST)  = 1  :   ' This intiates transfer, setting ~RST to 1
  PAUSE MS_PAUSE

  ' send command byte to WRITE to DS1302's registers
  FOR I = 7 to 0 STEP -1
    PIN(DAT)  = COMMAND_BYTE_WRITE_REG%(I)
    PAUSE MS_PAUSE
    PIN(SCLK) = 1
    PAUSE MS_PAUSE
    PIN(SCLK) = 0
    PAUSE MS_PAUSE
  NEXT I  

  ' write to DS1302 register
  FOR I = 7 to 0 STEP -1
    PIN(DAT)  = OUTPUT_DATA(I)
    PAUSE MS_PAUSE
    PIN(SCLK) = 1
    PAUSE MS_PAUSE
    PIN(SCLK) = 0
    PAUSE MS_PAUSE
  NEXT I  

  ' end transfer
  PIN(RST)  = 0  :  ' This ENDS transfer, setting ~RST to 0
  PAUSE MS_PAUSE

END SUB


SUB ENTER_TIME
  LOCAL INTEGER DONE = 0
  LOCAL INTEGER HH = 00
  LOCAL INTEGER MM = 00
  LOCAL INTEGER SS = 00
  LOCAL STRING S$ 
  DO WHILE DONE <> 1
    PRINT "Enter current time in format HH:MM:SS"
    INPUT S$
    HH = VAL( MID$(S$,1,2) )
    MM = VAL( MID$(S$,4,2) )
    SS = VAL( MID$(S$,7,2) )
    IF (HH < 25 AND MM < 60 AND SS < 60) THEN
      DONE = 1
    ELSE
      PRINT "  VALID VALUES ARE HH: 00 TO 23"
      PRINT "                   MM: 00 TO 59"
      PRINT "                   SS: 00 TO 59"
    ENDIF 
  LOOP

  SET_OUTPUT_BCD HH
  WRITE_TRANSFER COMMAND_WRITE_HOUR()

  SET_OUTPUT_BCD MM
  WRITE_TRANSFER COMMAND_WRITE_MIN()

  SET_OUTPUT_BCD SS
  WRITE_TRANSFER COMMAND_WRITE_SEC()

  PRINT "Time written to DS1302 RTC"
  PRINT

END SUB


SUB ENTER_DATE
  LOCAL INTEGER DONE = 0
  LOCAL INTEGER MM = 00
  LOCAL INTEGER DD = 00
  LOCAL INTEGER YY = 00
  LOCAL STRING S$ 
  DO WHILE DONE <> 1
    PRINT "Enter current date in format DD-MM-YYYY"
    INPUT S$
    DD = VAL( MID$(S$,1,2) )
    MM = VAL( MID$(S$,4,2) )
    YY = VAL( MID$(S$,9,2) )

    IF (MM < 13 AND DD < 32) THEN
      DONE = 1
    ELSE
      PRINT "  VALID VALUES ARE MM: 01 TO 12"
      PRINT "                   DD: 01 TO 31"
      PRINT "                   77: 00 TO 99"
    ENDIF 
  LOOP

  SET_OUTPUT_BCD MM
  WRITE_TRANSFER COMMAND_WRITE_MONTH()

  SET_OUTPUT_BCD DD
  WRITE_TRANSFER COMMAND_WRITE_DATE()

  SET_OUTPUT_BCD YY
  WRITE_TRANSFER COMMAND_WRITE_YEAR()

  PRINT "Date written to DS1302 RTC"
  PRINT

END SUB


SUB SET_OUTPUT_BCD X
    
    LOCAL INTEGER HIGH = INT(X/10)
    LOCAL INTEGER LOW = X - (HIGH*10)

    FOR I = 0 TO 7
        OUTPUT_DATA(I) = 0
    NEXT I

    IF HIGH > 7 THEN
        OUTPUT_DATA(0) = 1
        HIGH = HIGH - 8
    ENDIF

    IF HIGH > 3 THEN
        OUTPUT_DATA(1) = 1
        HIGH = HIGH - 4
    ENDIF
  
    IF HIGH > 1 THEN
        OUTPUT_DATA(2) = 1
        HIGH = HIGH - 2
    ENDIF
  
    IF HIGH > 0 THEN
        OUTPUT_DATA(3) = 1
        HIGH = HIGH - 1
    ENDIF


    IF LOW > 7 THEN
        OUTPUT_DATA(4) = 1
        LOW = LOW - 8
    ENDIF

    IF LOW > 3 THEN
        OUTPUT_DATA(5) = 1
        LOW = LOW - 4
    ENDIF
  
    IF LOW > 1 THEN
        OUTPUT_DATA(6) = 1
        LOW = LOW - 2
    ENDIF
  
    IF LOW > 0 THEN
        OUTPUT_DATA(7) = 1
        LOW = LOW - 1
    ENDIF

END SUB