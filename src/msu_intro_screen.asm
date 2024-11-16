intro_screen_text:
.byte $D2, $51, $29, $28, $2b, $2d, $40                                             ; Port
.byte $1b, $32, $ff                                                                 ; by 
.byte $F2, $51, $2b, $2e, $26, $1b, $25, $1e, $26, $22, $27, $33, $1e, $FF        ; Rumbleminze, 
.byte $12, $52, $12, $10, $12, $14, $ff                                           ; 2024


.byte $E1, $42, $28, $2b, $22, $20, $22, $27, $1a, $25, $40, $27, $1e, $2c, $FF ;ORIGINAL NES
.byte $01, $43, $2c, $28, $2e, $27, $1d, $2d, $2b, $1a, $1c, $24, $40, $2f, $22, $1a, $FF ; SOUNDTRACK VIA
.byte $21, $43, $12, $1a, $10, $13, $40                                           ; 2A03
.byte $2c, $28, $2e, $27, $1d, $ff                                                ; SOUND 
.byte $41, $43, $1e, $26, $2e, $25, $1a, $2d, $28, $2b, $ff                       ; EMULATOR
.byte $61, $43, $1b, $32, $40                                                     ; BY
.byte $26, $1e, $26, $1b, $25, $1e, $2b, $2c, $ff                                 ; MEMBLERS

.byte $16, $43, $26, $2c, $2e, $11, $ff; MSU1
.byte $34, $43, $1e, $27, $21, $1a, $27, $1c, $1e, $1d, $ff ; ENHANCED 
.byte $55, $43, $26, $2e, $2c, $22, $1c, $FF ; MUSIC

.byte $78, $53, $2b, $1e, $2f, $10, $ff                                           ; Version (REV0)
.byte $ff, $ff

do_intro:
    PHB
    LDA #$B2
    PHA
    PLB
    JSR setup_intro_bg1
    JSR load_intro_tilesets
    JSR write_intro_palette
    JSR write_intro_tiles
    JSR fade_right_side

    LDA #$0F
    STA INIDISP
    LDX #$FF


:
    jsr check_for_input
    LDA JOYTRIGGER1
    BEQ :-
    AND #$03
    BEQ :+
        jsr switch_fade
    :    

    LDA JOYTRIGGER1
    AND #$10
    CMP #$10
    BNE :--

    LDA INIDISP_STATE
    ORA #$8F
    STA INIDISP_STATE
    STA INIDISP

    .if ENABLE_MSU_MOVIE = 1
        JML $C7FF00
    .endif
    jsr reset_bg_values
    PLB
  RTL
setup_intro_bg1:
  LDA #$03
  STA BGMODE
    LDA #$70
    STA BG1SC
    LDA #$50
    STA BG2SC

    LDA #$00
    STA BG12NBA

    LDA #$50
    STA VMADDH
    STZ VMADDL

    setAXY16
    LDA #$0747
    LDX #$0400
:   STA VMDATAL
    DEX
    BNE :-
    LDA #$0000
    LDX #$0000

    setAXY8

    LDA #$FF
    STA BG1VOFS
    LDA #$01
    STA BG1VOFS
    STZ BG1HOFS
    STZ BG1HOFS

    rts

reset_bg_values:
  LDA #$01
  STA BGMODE
    LDA #$21
    STA BG1SC
    LDA #$11
    STA BG12NBA
    rts

write_intro_text:
    LDY #$00

next_line:
    ; get starting address
    LDA intro_screen_text, Y
    CMP #$FF
    BEQ exit_intro_write

    PHA
    INY    
    LDA intro_screen_text, Y
    STA VMADDH
    PLA
    STA VMADDL
    INY

next_tile:
    LDA intro_screen_text, Y
    INY
    CMP #$FF
    BEQ next_line
    
    CLC
    ADC #$60
    STA VMDATAL
    LDA #$23
    STA VMDATAH
    
    BRA next_tile

exit_intro_write:
    RTS

fade_right_side:

    LDA #$80
    STA WH2

    LDA #$FF
    STA WH3

    LDA #$80
    STA WOBJSEL


    LDA #$10
    STA $02
    STA CGWSEL

    LDA #$7f
    STA CGADSUB

    LDA #$E0
    STA COLDATA

    LDA #$01
    STA TMW

    RTS

switch_fade:
    LDA $02
    EOR #$30
    STA $02
    STA CGWSEL
    
    LDA MSU_SELECTED
    EOR #$01
    STA MSU_SELECTED
    RTS

write_intro_tiles:
:   LDA RDNMI
    BPL :-
    STZ HDMAEN
    STZ MDMAEN
    LDA #$80
    STA VMAIN
    setAXY16
    LDA #$7000
    STA VMADDL

    LDY #$0000
:   LDA title_bg_tilemap_8bpp, Y
    STA VMDATAL
    INY
    INY
    CPY #$800
    BNE :-

    setAXY8
    rts

write_intro_palette:
    jsr write_8bpp_pallete
    rts

write_nes_box_pallete:

    STZ CGADD    

    LDY #$00
:   LDA nes_box_palette, y
    STA CGDATA
    INY
    BNE :-

    RTS

write_8bpp_pallete:
  STZ DMAP0
  LDA #$22
  STA BBAD0
  STZ CGADD
  LDA #^(title_bg_palette_8bpp)
  STA A1B0
  LDA #>(title_bg_palette_8bpp)
  STA A1T0H
  STZ A1T0L
  LDA #$02
  STA DAS0H
  STZ DAS0L
  LDA #$01
  STA MDMAEN
  rts


load_intro_tilesets:
    lda #$00
    sta NMITIMEN
    LDA VMAIN_STATE
    LDA #$80
    STA VMAIN
    LDA #$8F
    STA INIDISP
    STA INIDISP_STATE

    LDA #$01
    STA DMAP0
    LDA #$18
    STA BBAD0
    LDA #$C6
    STA A1B0
    STZ A1T0H
    STZ A1T0L
    STZ VMADDH
    STZ VMADDL
    LDA #$E0
    STA DAS0H
    STZ DAS0L
    LDA #$01
    STA MDMAEN
  rts
    

 check_for_input:
PHA
readjoy:
    lda #$01
    STA JOYSER0
    STA buttons
    LSR A
    sta JOYSER0
loop:
    lda JOYSER0
    lsr a
    rol buttons
    bcc loop

    lda buttons
    ldy JOYPAD1
    sta JOYPAD1
    tya
    eor JOYPAD1
    and JOYPAD1
    sta JOYTRIGGER1
    beq :+

    tya
    and JOYPAD1
    sta JOYHELD1
:
    PLA
    rts
.include "msu_intro_tilemap.asm"
; .include "movie-palette.asm"
.include "msu-intro-palette.asm"