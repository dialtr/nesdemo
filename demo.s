;
; Nintendo Entertainment System - Demo Program
;
; Copyright (C) 2018 Thomas R. Dial
; All Rights Reserved
;

;
; The binary image must start with an iNES header, which includes a
; magic number, some attributes describing the size of the program
; data and character data, etc. The INES_xxx constants define
; various attributes of the header.
;

INES_MAPPER = 0                ; No memory mapper is in use.
INES_MIRROR = 1                ; 
INES_SRAM   = 0                ; No battery-backed RAM in use.

.segment "HEADER"
.byte 'N', 'E', 'S', $1A
.byte $02			; 16K Program data
.byte $01     ; 8K Character data
.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << 4)
.byte (INES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0


;
; Global variables that are accessed very frequently are stored in the
; "zero page" because access to that area can be performed quickly (and
; using less space. Specifically, a load from the zeropage area using
; the zeropage addressing mode is a two-byte instruction and requires
; 3 cycles to complete, while a standard load requires three bytes and
; 4 cycles, respectively. 
;
; This example reserves one byte in the zeropage area for a counter,
; which is referenced elsewhere via the 'GlobalCounter' label.
;
.segment "ZEROPAGE"
GlobalCounter:
.res 1
	

;
; Interrupt Vector Table
;
; This section sets up the interrupt vector table. On the NES, there are
; three interrupts. The first is the NMI (non-maskable interrupt), which
; occurs on every vertical blanking interval (and, as the name describes,
; can't be masked, although it can be disabled.) The second is the RESET
; interrupt, which occurs after power-on and when the user of the console
; presses the reset button. The last interrupt is called the IRQ, which
; can be programmed for various purposes.
;
; The interrupt vector table consists of three 16-bit pointers to the
; corresponding handler routines, and always starts at location $FFFA in
; memory. The pointer to the NMI handler is first, and is stored at $FFFA.
; The pointer to the RESET handler is second, and is stored at $FFFC.
; Finally, the address of the IRQ handler routine is stored at $FFFE.

.segment "VECTORS"
.word NonMaskableInterrupt          ; $FFFA
.word ResetInterrupt                ; $FFFC
.word IrqInterrupt                  ; $FFFE


;
; Interrupt Handler Routines
;
; The interrupt handler routines themselves are are located elsewhere
; in program memory, as denoted by the 'CODE' segment label. In this
; example, only two interrupt routines are implemented: the NMI and the
; RESET. As discussed briefly, the NMI routine runs during the vertical
; blanking interval, and is generally responsible for driving the game.
; The RESET routine is the first thing that executes when the machine
; (or virtual machine) is booted, and also when then reset button is
; pushed.
; 


;
; Non-maskable Interrupt
;
.segment "CODE" 
NonMaskableInterrupt:
    rti                        ; Return from handler.


;
; Reset Handler
;
.segment "CODE"
ResetInterrupt:
    jmp Main                   ; Transfer control to Main.


;
; IRQ Handler
;
.segment "CODE"
IrqInterrupt:
    rti                        ; Return from interupt handler.


;
; Main
;
.segment "CODE"
Main:
@Loop:
    jmp @Loop                  ; Loop forever, waiting for NMI's.



;
; The TILES section is where we locate static resources for the background.
;
.segment "TILES"


;
; The OAM section is where we locate data for sprite data that is to be
; transferred to the PPU via direct memory access (DMA.)
.segment "OAM"

