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
.segment "ZEROPAGE"
GlobalValue:                   ; Exmaple of a value stored in ZP.
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
.word NonMaskableInterrupt      ; $FFFA
.word ResetInterrupt            ; $FFFC
.word IrqInterrupt              ; $FFFE


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
    sei                        ; Disable IRQs.
    cld                        ; Disable decimal mode (not supported on Ricoh CPU)
    
    lda #0                     ; Load zero into accumulator for subsequent use.
    sta $2000                  ; Disable NMI
    sta $2001                  ; Disable rendering
    sta $4015                  ; Disable APU sound
    sta $4010                  ; Disable DMC IRQs.

    lda #$40
    sta $4017                  ; Disable APU frame IRQ
 
    ldx #$FF
    txs                        ; Initialize stack pointer

@VBlank1:                      ; Wait for first vertical blank to ensure that the
    bit $2002                  ; PPU is ready. Note: there is a race condition that
    bpl @VBlank1               ; involving this operation that is addressed in
                               ; games by waiting twice. More explanation of this
                               ; is warranted when I understand the details.

    ldx #$00                   ; Clear RAM. We start by initializing the index
    lda #$00                   ; register (x) with zero, and also load zero into the
@ZeroMemLoop:                  ; the accumulator. Following that, we loop through 
    sta $0000, x               ; each value of x, storing the zero contained in the
    sta $0100, x               ; accumulator to offsets in memory that are exactly
    sta $0200, x               ; 256 bytes apart. When the loop is complete, the
    sta $0300, x               ; entire range from [$0000, $0800) will be zeroed.
    sta $0400, x               
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne @ZeroMemLoop

    ldx #$00                   ; Similarly, we need to "walk" through memory to
    lda #$FE                   ; move all sprites off-screen by poking off-screen
@HideSpriteLoop:               ; positions into their positions. The memory we are
    sta $0200, x               ; writing to is the $0200 region used for performing
    inx                        ; DMA with the PPU. Note: we could have omitted the
    bpl @HideSpriteLoop        ; first 'ldx' instruction here since it would already
                               ; have held the value of zero after the ZeroMemLoop.
                               ; It has been left in for clarity here.

@VBlank2:                      ; Wait for the second vertical blank. Due to the
    bit $2002                  ; work done to zero memory between this and the first
    bpl @VBlank2               ; "vertical blank wait", we know the PPU is ready.

@LoadPalette:                  ; Load the palette. We start by reading the PPU
    lda $2002                  ; status register ($2002) to reset the high/low
    lda #$3F                   ; address latch. Next, we write the high and low
    sta $2006                  ; bytes of the target address $3F00. Finally, we
    lda #$00                   ; initialize X to zero. The @LoadPaletteLoop 
    sta $2006                  ; sequence writes the palette entries in order,
    ldx #$0                    ; incrementing x each time. When the comparison
@LoadPaletteLoop:              ; tells us that x reaches the value of 32, we
    lda Palette1, x            ; know that we've written all palette entries
    sta $2007                  ; and we can break out of the loop.
    inx
    cpx #$20
    bne @LoadPaletteLoop

    ;
    ; TODO(tdial): Initial one-time setup here.
    ;

    lda #%10001000             ; Load flags to enable NMI's
    sta $2000                  ; Enable NMI
    jmp Main                   ; Done. Transfer control to Main.


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
; Palette Data
;
.segment "CODE"
Palette1:
    ; Background Palette #1
    .byte $0F, $31, $32, $33, $0F, $35, $36, $37
    .byte $0F, $39, $3A, $3B, $0F, $3D, $3E, $0F
    
    ; Sprite Palette #1
    .byte $0F, $1C, $15, $14, $0F, $02, $38, $3C
    .byte $0F, $1C, $15, $14, $0F, $02, $38, $3C


;
; The TILES section is where we locate static resources for the background.
;
.segment "TILES"


;
; The OAM section is where we locate data for sprite data that is to be
; transferred to the PPU via direct memory access (DMA.)
.segment "OAM"

