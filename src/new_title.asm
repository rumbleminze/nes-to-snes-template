.segment "PRGB6"

; new title card with cooler Rumbleminze logo
do_new_intro:
PHB
PHK
PLB
LDA RDNMI
:
LDA RDNMI
BPL :-
LDA #$8F
STA INIDISP

; intro screen uses mode 3
LDA #$03
STA BGMODE

LDA #$22
STA BG1SC

LDA #$44
STA BG12NBA

STZ BG1HOFS
STZ BG1HOFS

STZ BG1VOFS
STZ BG1VOFS

jsr write_palette
jsr write_tiles
jsr write_tilemap

jslb check_if_msu_is_available, $b2

LDA MSU_AVAILABLE
BEQ :+++
        LDA #130
        STA MSU_TRACK
        STZ MSU_TRACK + 1

       ; wait for NMI
        LDA RDNMI
:       LDA RDNMI
        BPL :-

        LDA #$00
:       DEC A
        BNE :-
        ; start our music
        LDA #$01
        STA MSU_CONTROL
        LDA #$AF
        STA MSU_VOLUME
:


LDA RDNMI
:
LDA RDNMI
BPL :-

LDA MSU_AVAILABLE
BEQ :+
    LDA #$01
        STA MSU_CONTROL
        LDA #$AF
        STA MSU_VOLUME
:

LDA #$0F
STA INIDISP

; drop in our logo
LDA #$F8
STA BG1VOFS
STA VOFFS_OFFSET
STZ BG1VOFS

:
LDA RDNMI
BPL :-

LDA VOFFS_OFFSET
SEC
SBC #$08
STA VOFFS_OFFSET
STA BG1VOFS
STZ BG1VOFS

BCS :-

STZ BG1VOFS
STZ BG1VOFS

STZ VOFFS_COUNTER

LDA #$04
STA RUMBLE_WAVE_FORM_PLAYING

; logo loanded, mosaic and bounce it
LDA #$81
STA MOSAIC

STZ VOFFS_OFFSET

:
LDA RDNMI
BPL :-

LDX #$00
waste_loop:
    DEX
    BNE waste_loop
    
jsr read_auto_joypad1
jslb play_rumble_wave_l, $a0
jslb send_rumble_l, $a0

LDA P1_NES_BUTTONS_TRIGGER
AND #$10
CMP #$10
BNE :+
    JMP done_animation
:

LDA VOFFS_COUNTER
AND #$01
bne going_back_down
    ; going up
    LDA VOFFS_OFFSET
    CLC
    ADC #$04  
    bra adjust
going_back_down:
    LDA VOFFS_OFFSET
    SEC
    SBC #$04

adjust:
STA VOFFS_OFFSET
STA BG1VOFS
STZ BG1VOFS

CMP #$40
BEQ :+
CMP #$00
BNE :-

:
    INC VOFFS_COUNTER
    LDA VOFFS_COUNTER
    CMP #$04
    BEQ :+

BRA :--
:
; logo landed, un-mosaic it
LDA #$01
STA MOSAIC_OFFSET
LDA #$B1
STA MOSAIC
LDA #15
STA MOSAIC_COUNTER

:
LDA RDNMI
BPL :-

LDX #$00
waste_loop_2:
    DEX
    BNE waste_loop_2

jsr read_auto_joypad1
LDA P1_NES_BUTTONS_TRIGGER
AND #$10
CMP #$10
BEQ done_animation

DEC MOSAIC_COUNTER
BNE :+
    INC MOSAIC_OFFSET
    LDA MOSAIC_OFFSET
    ASL
    TAY
    LDA mosaic_frames, Y    
    STA MOSAIC

    INY
    LDA mosaic_frames, Y
    STA MOSAIC_COUNTER
    
    BEQ linger_setup
:
BRA :--

linger_setup:
LDY #180

linger:
LDA RDNMI
:
LDA RDNMI
BPL :-

LDX #$00
waste_loop_3:
    DEX
    BNE waste_loop_3

PHY
jsr read_auto_joypad1
PLY
LDA P1_NES_BUTTONS_TRIGGER
AND #$10
CMP #$10
BEQ done_animation

DEY
BNE linger


done_animation:
    STZ MOSAIC
    STZ RUMBLE_P1
    STZ RUMBLE_WAVE_FORM_PLAYING
    STZ RUMBLE_WAVE_FORM_IDX
    STZ RUMBLE_WAVE_FORM_CTR
    LDA #$8F
    STA INIDISP
    LDA #$40
    STA BG12NBA
    LDA #$21
    STA BG1SC
    LDA #$01
    STA BGMODE

  

PLB
  LDA P1_NES_BUTTONS_TRIGGER
    AND #$10
    CMP #$10
    BEQ:+
    ; optional 2nd credit for batty, who is awesome and does a lot of MSU1 work
    ; jslb do_batty_credit, $b6
:
RTL

MOSAIC_COUNTER = $00
MOSAIC_OFFSET = $01

VOFFS_COUNTER = $02
VOFFS_OFFSET = $03

mosaic_frames:
; .byte $F1, 15
; .byte $E1, 4
; .byte $D1, 4
; .byte $C1, 4
; .byte $B1, 4
.byte $A1, 4
.byte $91, 4
.byte $81, 4
.byte $71, 4
.byte $61, 4
.byte $51, 4
.byte $41, 4
.byte $31, 4
.byte $21, 4
.byte $11, 4
.byte $00, 120
.byte $00, 0


write_palette:

    setXY16
    STZ CGADD
    LDY #$00

:   

    LDA beagle_palette, Y
    STA CGDATA
    INY
    CPY #$200
    BNE :-

    setAXY8
    RTS

write_tiles:
    LDA #$80
    STA VMAIN

    LDA #$01
    STA DMAP1

    LDA #$18
    STA BBAD1

    LDA #<beagle_tiles
    STA A1T1L

    LDA #>beagle_tiles
    STA A1T1H

    LDA #BEAGLE_BANK
    STA A1B1

    LDA #$74
    STA DAS1H
    STZ DAS1L

    LDA #$40
    STA VMADDH
    STZ VMADDL

    LDA #$02
    STA MDMAEN

    RTS

write_tilemap:
    
    LDA #$80
    STA VMAIN

    LDA #$01
    STA DMAP1

    LDA #$18
    STA BBAD1

    LDA #<beagle_tilemap
    STA A1T1L

    LDA #>beagle_tilemap
    STA A1T1H

    LDA #BEAGLE_BANK
    STA A1B1

    LDA #$08
    STA DAS1H
    STZ DAS1L

    LDA #$20
    STA VMADDH
    STZ VMADDL

    LDA #$02
    STA MDMAEN

    RTS

read_auto_joypad1:
    LDA JOY1H
    STA P1_NES_BUTTONS
    TAY
    EOR P1_NES_BUTTONS_HELD
    AND P1_NES_BUTTONS
    STA P1_NES_BUTTONS_TRIGGER
    STY P1_NES_BUTTONS_HELD

    LDA JOY1L
    STA P1_SNES_BUTTONS
    TAY
    EOR P1_SNES_BUTTONS_HELD
    AND P1_SNES_BUTTONS
    STA P1_SNES_BUTTONS_TRIGGER
    STY P1_SNES_BUTTONS_HELD
    RTS

beagle_palette:
.incbin "./intro_tilemaps/beagleYay_112.mw3"

; .include "msu1_selection.asm"