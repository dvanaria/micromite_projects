# micromite_projects
A "Micromite" is a PIC32 (specifically a PIC32MX170F256B microcontroller) loaded with special firmware called MMBASIC. 

This firmware takes the PIC32's available 256 KB of Flashable ROM and 64 KB of Static RAM to present a BASIC operating environment (complete with code editor) and yielding the following specs, reminiscent of an 80s era home microcomputer:

    50 MHz CPU
    59 KB Flashable ROM (for your BASIC program's source code)
    52 KB Static RAM (for your BASIC program's data and variable allocation)

MMBASIC is a modern BASIC interpreter and embedded OS created by Geoff Graham in 2014. This firmware allows working on embedded/microcontroller projects using a beginner-friendly language: a modernized BASIC language that is similar to GW-BASIC from back in the day. 

From Wikipedia: 

    "MMBasic was designed to mimic the original Microsoft BASIC (also known as MBASIC, BASICA 
     or GW-BASIC) which was supplied with the Tandy TRS-80, Commodore 64 and the early IBM 
     personal computers."  

And from Geoff Graham's website: 

    "MMBasic is a Microsoft BASIC compatible implementation of the BASIC language with floating 
     point, integer and string variables, arrays, long variable names, a built in program editor 
     and many other features." 

    "Using MMBasic you can use communications protocols, measure voltages, detect digital inputs 
    and drive output pins.  Special features include the ability to use touch sensitive LCD 
    displays, temperature sensors, distance sensors and more."

    **You can use the Micromite as the intelligence inside any project that requires a medium speed 
    microcontroller but without the hassle of programming in a complex language."** 

The projects in this repository relate to a minimal breadboard setup that has just a PIC32 chip, a battery pack to supply power, and an FTDI chip that allows a USB connection to a modern computer. ![image](https://github.com/dvanaria/micromite_projects/assets/14303838/2ea1959f-071b-4436-a6c3-5d56a6057c80)

The MMBASIC software running on the microcontroller is interfaced using a terminal emulator such as TeraTerm running on the connected computer. The terminal is connected via a 38400 baud connection, and since this is a text-only display interface, none of the graphics commands of MMBASIC are available with this particular (breadboard) setup.

**********************   
PROJECT LIST:

    Project 1: Connect an DS1302 RTC (Real Time Clock, as part of the VMA301 module
               from a company called Velleman) to a Micromite running MMBASIC MkII.
               Use it to set the Micromite's MMBASIC system variables DATE$ and 
               TIME$ to the correct, current values, instead of them being reset
               to the PIC32's internal clock/timer upon each power-on cycle.

               April 29, 2023

        The PIC32 has an internal clock that is reset to January 1, 2000,
        midnight when you power it on. 
        When starting up the Micromite, you can view the two functions in 
        MMBASIC that can tap into that time:
            > PRINT DATE$
            01-01-2000
            > PRINT TIME$
            00:00:10

        There are RTC modules that can be connected to the PIC32 and polled
        to find out the actual date and time (since it's battery backed memory
        keeps track of it when power is off). 

        The Micromite manuals recommend certain RTC chips that MMBASIC supports
        with library I2C functions. The only module I have has an RTC chip
        (the DS1302) which isn't on the supported list, but the datasheet is
        available online (12 pages) and has all the information needed to write
        a program from scratch that "bit bangs" the input/output pins for the
        desired results.

     Lessons learned from this project:

            1. Something as simple as an RTC has a datasheet that is 12 pages
               long. This is just the nature of embedded systems. This chip,
               that only keeps track of the time and date, a basic counter,
               has a complete internal structure, with 31 bytes of RAM, 7 
               registers, a control unit, a shift register to load for all
               read/writes to the outside world, and so on. 
            2. What made this project difficult was the fact that this
               chip uses a proprietary "simple 3-wire communication" protocol
               that is not 3-wire-SPI (even though that's what it appeared to
               be at first and threw me off for a day or two). It comes down
               to exact edge timing on the input clock signal (SCLK) to read
               and write data, with strange nuances like sending data on the
               rising edge of the clock signal and reading data on the FALLING
               edge.
            3. I got reacquainted with TheBackShed forum and all the helpful
               people there. They helped jump start me (pointing out things 
               like this is NOT a simple SPI protocol, and you have to run a
               wire from the VMA301 module to ground on the Micromite).
            4. I learned about several different communication protocols like
               UART, SPI, I2C.
            5. I learned how to read a datasheet and the details of timing
               diagrams, and how to be careful about bit-ordering (and a 
               refresher on how arrays are indexed in BASIC).
            6. With perseverance, I was able to trouble-shoot my way through
               to a working solution, a demo program that wrote to one of the
               registers (YEAR) and then read that byte back in to see if it
               was really captured.
            7. With that demo finalized, I realized it was only a matter of
               time (and effort) to work up a general read/write solution and
               get my original goal accomplished. 
            8. The most difficult challenge was figuring out digital input and
               output on the Micromite itself, how that works (and learned 
               about the need for pullup resistors on input pins). I went down 
               a rabbit hole of trying to tie the DAT pin from the VMA301 to 
               two different pins on the PIC32: pin 2 for output and pin 26 for 
               input. This turned out to be both a successful solution and also 
               not needed at all.
               I learned you can switch a pin from OUTPUT to INPUT in the 
               middle of the same program.
            9. Learned BCD, and that each digit is encoded in 4 bits but 
               limited to 0000 to 1001 (0 to 9), so its a bit wasteful.

    SOLUTION4.BAS - First working code that successfully wrote to a DS1302 reg
                    and then read back in it's value.

    SOLUTION5.BAS - Generalizing functions to READ and WRITE.

        * How to pass an array to a Subroutine or Function? Critical for this
          program.

              DIM INTEGER MLIST(7) = (1,0,1,0,1,0,1,0)
 
              SUB PRINT_LIST LX%()
                FOR I = 0 TO 7
                  PRINT LX%(I)
                NEXT I
              END SUB

              PRINT_LIST MLIST()

    DS1302_SETTIME.BAS - Final program, asks the user time/date and writes that
                         into to the RTC chip.

    DS1302_GETTIME.BAS - Final program, updates DATE$ and TIME$ variables
                         (actually functions) with the data stored in the RTC.
