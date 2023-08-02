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

'Array to capture read from DS1302 registers
DIM INTEGER INPUT_DATA(7)

'Taken from DS1302 datasheet
DIM INTEGER COMMAND_READ_SEC(7)   = (1,0,0,0,0,0,0,1)
DIM INTEGER COMMAND_READ_MIN(7)   = (1,0,0,0,0,0,1,1)
DIM INTEGER COMMAND_READ_HOUR(7)  = (1,0,0,0,0,1,0,1)
DIM INTEGER COMMAND_READ_DATE(7)  = (1,0,0,0,0,1,1,1)
DIM INTEGER COMMAND_READ_MONTH(7) = (1,0,0,0,1,0,0,1)
DIM INTEGER COMMAND_READ_YEAR(7)  = (1,0,0,0,1,1,0,1)


REM **** PROGRAM ****

PRINT "Reading from DS1302 RTC"

READ_TRANSFER COMMAND_READ_SEC()
DIM STRING SECONDS = FORMAT_INPUT$()
  
READ_TRANSFER COMMAND_READ_MIN()
DIM STRING MINUTES = FORMAT_INPUT$()

READ_TRANSFER COMMAND_READ_HOUR()
DIM STRING HOURS = FORMAT_INPUT$()

READ_TRANSFER COMMAND_READ_DATE()
DIM STRING DATE = FORMAT_INPUT$()

READ_TRANSFER COMMAND_READ_MONTH()
DIM STRING MONTH = FORMAT_INPUT$()

READ_TRANSFER COMMAND_READ_YEAR()
DIM STRING YEAR = FORMAT_INPUT$()

DIM STRING T$ = HOURS + ":" + MINUTES + ":" + SECONDS
DIM STRING D$ = MONTH + "-" + DATE + "-20" + YEAR

TIME$ = T$
DATE$ = D$

PRINT "Updated current system TIME$ and DATE$"
PRINT "TIME$ now = " TIME$
PRINT "DATE$ now = " DATE$

END 



SUB READ_TRANSFER COMMAND_BYTE_READ_REG%()

  SETPIN DAT, DOUT
  PAUSE MS_PAUSE

  ' initialize READ transfer
  PIN(DAT)  = 0  
  PIN(SCLK) = 0  :  ' SCLK must be 0 before initiating transfer
  PIN(RST)  = 0
  PAUSE MS_PAUSE

  ' begin transfer
  PIN(RST)  = 1  :   ' This intiates transfer, setting ~RST to 1
  PAUSE MS_PAUSE

  ' send command byte to READ from DS1302 register
  FOR I = 7 TO 0 STEP -1
    PIN(DAT) = COMMAND_BYTE_READ_REG%(I)
    PAUSE MS_PAUSE
    PIN(SCLK) = 1
    PAUSE MS_PAUSE
    IF I <> 0 THEN   ' DON'T SET CLOCK TO 0 AFTER LAST COMMAND BIT
      PIN(SCLK) = 0
      PAUSE MS_PAUSE
    ENDIF
  NEXT I 
  
  SETPIN DAT, DIN, PULLUP
  PAUSE MS_PAUSE

  ' read data coming in from DS1302
  FOR I = 7 TO 0 STEP -1
    IF I <> 7 THEN
      PIN(SCLK) = 1
      PAUSE MS_PAUSE
    ENDIF
    PIN(SCLK) = 0
    PAUSE MS_PAUSE
    INPUT_DATA(I) = PIN(DAT)
    PAUSE MS_PAUSE
  NEXT I

END SUB


FUNCTION FORMAT_INPUT$()

  LOCAL X = 0
  LOCAL STRING S$ = ""

  X = X + INPUT_DATA(0)*8
  X = X + INPUT_DATA(1)*4
  X = X + INPUT_DATA(2)*2
  X = X + INPUT_DATA(3)*1
  X = X * 10
  X = X + INPUT_DATA(4)*8
  X = X + INPUT_DATA(5)*4
  X = X + INPUT_DATA(6)*2
  X = X + INPUT_DATA(7)*1
  
  IF X < 10 THEN
      S$ = "0"
  ENDIF

  S$ = S$ + STR$(X)

  FORMAT_INPUT$ = S$ 

END FUNCTION