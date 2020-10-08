; Minimal example of using ca65 to build SNES ROM.
;
; ca65 ca65.s
; ld65 -C lorom128.cfg -o ca65.smc ca65.o

.p816   ; 65816 processor
.i16    ; X/Y are 16 bits
.a8     ; A is 8 bits

.include "snes.inc"
.include "charmap.inc"

.segment "HEADER"        ; +$7FE0 in file
.byte "CA65 EXAMPLE" ; ROM name

.segment "ROMINFO"       ; +$7FD5 in file
.byte $30            ; LoROM, fast-capable
.byte 0              ; no battery RAM
.byte $07            ; 128K ROM
.byte 0,0,0,0
.word $AAAA,$5555    ; dummy checksum and complement

.segment "CODE"
   jmp start

VRAM_CHARSET   = $0000 ; must be at $1000 boundary
VRAM_BG1       = $1000 ; must be at $0400 boundary
VRAM_BG2       = $1400 ; must be at $0400 boundary
VRAM_BG3       = $1800 ; must be at $0400 boundary
VRAM_BG4       = $1C00 ; must be at $0400 boundary
START_X        = 9
START_Y        = 14
START_TM_ADDR  = VRAM_BG1 + 32*START_Y + START_X
TICK_TM_ADDR   = VRAM_BG1 + 32*(START_Y+1) + START_X

hello_str: .asciiz "Hello, World!"

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

   ; Set palette to black background and 3 shades of red
   stz CGADD ; start with color 0 (background)
   stz CGDATA ; None more black
   stz CGDATA
   lda #$10 ; Color 1: dark red
   sta CGDATA
   stz CGDATA
   lda #$1F ; Color 2: neutral red
   sta CGDATA
   stz CGDATA
   lda #$1F  ; Color 3: light red
   sta CGDATA
   lda #$42
   sta CGDATA

   ; Setup Graphics Mode 0, 8x8 tiles all layers
   stz BGMODE
   lda #>VRAM_BG1
   sta BG1SC ; BG1 at VRAM_BG1, only single 32x32 map (4-way mirror)
   lda #((>VRAM_CHARSET >> 4) | (>VRAM_CHARSET & $F0))
   sta BG12NBA ; BG 1 and 2 both use char tiles

   ; Load character set into VRAM
   lda #$80
   sta VMAIN   ; VRAM stride of 1 word
   ldx #VRAM_CHARSET
   stx VMADDL
   ldx #0
@charset_loop:
   lda NESfont,x
   stz VMDATAL
   sta VMDATAH
   inx
   cpx #(128*8)
   bne @charset_loop

   ; Place string tiles in background
   ldx #START_TM_ADDR
   stx VMADDL
   ldx #0
@string_loop:
   lda hello_str,x
   beq @enable_display
   sta VMDATAL
   lda #$20 ; priority 1
   sta VMDATAH
   inx
   bra @string_loop

@enable_display:
   ; Show BG1
   lda #$01
   sta TM
   ; Maximum screen brightness
   lda #$0F
   sta INIDISP

   ; enable NMI for Vertical Blank
   lda #$80
   sta NMITIMEN

   stz $00

game_loop:
   wai ; Pause until next interrupt complete (i.e. V-blank processing is done)
   ; Do something
   inc $00
   ldx #TICK_TM_ADDR
   stx VMADDL
   lda $00
   and #$0F
   ora #$30
   sta VMDATAL
   lda #$20 ; priority 1
   sta VMDATAH

   jmp game_loop


nmi:
   rep #$10        ; X/Y 16-bit
   sep #$20        ; A 8-bit
   pha
   phx
   phy
   ; Do stuff that needs to be done during V-Blank
   lda RDNMI ; reset NMI flag
   ply
   plx
   pla
irq:
   rti

.include "charset.asm"

.segment "VECTORS"
.word 0, 0, 0, 0, 0, 0, 0, 0
.word 0, 0, 0, 0, 0
.word nmi   ; NMI
.word start ; Reset
.word irq   ; IRQ
