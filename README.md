# micromite_projects
Minimal PIC32 set up on a breadboard (with MMBASIC firmware) is connected to a DS1302 Real Time Clock to update MMBASIC's TIME$ and DATE$ system variables.

Project 1: Connect an DS1302 RTC (Real Time Clock, as part of the VMA301 module
           from a company called Velleman) to a Micromite running MMBASIC MkII.
           Use it to set the Micromite's internal clock variables DATE$ and 
           TIME$ to the correct, current values.

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
