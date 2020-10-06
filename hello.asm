; Minimal example of using ca65 to build SNES ROM.
;
; ca65 ca65.s
; ld65 -C lorom128.cfg -o ca65.smc ca65.o

.p816   ; 65816 processor
.i16    ; X/Y are 16 bits
.a8     ; A is 8 bits

.include "snes.inc"

.segment "HEADER"        ; +$7FE0 in file
.byte "CA65 EXAMPLE" ; ROM name

.segment "ROMINFO"       ; +$7FD5 in file
.byte $30            ; LoROM, fast-capable
.byte 0              ; no battery RAM
.byte $07            ; 128K ROM
.byte 0,0,0,0
.word $AAAA,$5555    ; dummy checksum and complement

.segment "CODE"

start:
   clc             ; native mode
   xce
   rep #$10        ; X/Y 16-bit
   sep #$20        ; A 8-bit

   ; Clear registers
   ldx #$33
@loop:
   stz INIDISP,x
   stz NMITIMEN,x
   dex
   bpl @loop

   ; Set background color to $0000
   lda #$00
   sta CGDATA
   sta CGDATA

   ; Maximum screen brightness
   lda #$0F
   sta INIDISP

   ; enable NMI for Vertical Blank
   lda #$80
   sta NMITIMEN

game_loop:
   wai ; Pause until next interrupt complete (i.e. V-blank processing is done)
   ; Do something
   jmp game_loop



nmi:
   ; Do stuff that needs to be done during V-Blank
   lda RDNMI ; reset NMI flag
irq:
   rti

.segment "VECTORS"
.word 0, 0, 0, 0, 0, 0, 0, 0
.word 0, 0, 0, 0, 0
.word nmi   ; NMI
.word start ; Reset
.word irq   ; IRQ
