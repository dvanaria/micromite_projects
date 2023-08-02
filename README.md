# micromite_projects
A "Micromite" is a PIC32 (specifically a PIC32MX170F256B microcontroller) loaded with special firmware: MMBASIC, a modern BASIC interpreter and embedded OS created by Geoff Graham in 2014. This allows working on embedded/microcontroller projects using a beginner-friendly language, a modernized BASIC langauge that is similar to GW-BASIC from back in the day.

The projects in this repository relate to a minimal breadboard setup that has just a PIC32 chip, a battery pack to supply power, and an FTDI chip that allows a USB connection to a modern computer. The MMBASIC software running on the microcontroller is interfaced using a terminal emulator such as TeraTerm running on the connected computer. This setup is like a "modern retro computer" that has the following specs:

    59 KB of Program Memory space (held in non-volitile Flash storage)
    52 KB of Program Data space to hold program variables and data
    50 MHz processor

The terminal is connected via a 38,400 baud connection, and since this is a text-only display interface, none of the graphics commands of MMBASIC are available here.
