intro_screen_text:
.byte $D2, $41, $29, $28, $2b, $2d, $00                       ; Port
.byte $1b, $32, $ff                                                     ; by 
.byte $F2, $41, $2b, $2e, $26, $1b, $25, $1e, $26, $22, $27, $33, $1e, $FF        ; Rumbleminze, 
.byte $12, $42, $12, $10, $12, $14, $ff                                           ; 2024

.byte $b2, $42, $12, $1a, $10, $13, $00                                 ; 2A03
.byte $2c, $28, $2e, $27, $1d, $ff                                      ; SOUND 
.byte $d2, $42, $1e, $26, $2e, $25, $1a, $2d, $28, $2b, $ff                       ; EMULATOR
.byte $f2, $42, $1b, $32, $00                                                     ; BY
.byte $26, $1e, $26, $1b, $25, $1e, $2b, $2c, $ff                       ; MEMBLERS

.byte $78, $43, $2b, $1e, $2f, $10, $ff ; Version (REV0)
.byte $ff, $ff

do_intro:
    JSR setup_intro_bg1
    JSR load_intro_tilesets
    JSR write_intro_palette
    JSR write_intro_tiles
    JSR write_intro_text

    LDA #$0F
    STA INIDISP
    LDX #$FF


:
    jsr check_for_code_input
    ; jsr check_for_sprite_swap
    ; jsr check_for_msu
    LDA JOYTRIGGER1
    AND #$10
    CMP #$10
    BNE :-

    LDA INIDISP_STATE
    ORA #$8F
    STA INIDISP_STATE
    STA INIDISP

    .if ENABLE_MSU = 1
        JML $C7FF00
    .endif
    jsr reset_bg_values
  RTS
setup_intro_bg1:
    LDA #$40
    STA BG1SC
    LDA #$50
    STA BG2SC

    LDA #$00
    STA BG12NBA
    rts

reset_bg_values:
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
    
    STA VMDATAL
    ; tiles from bank 3
    ; pallete 7
    LDA #$1F
    STA VMDATAH
    
    BRA next_tile

exit_intro_write:
    RTS

write_intro_tiles:
    
    LDA #$80
    STA VMAIN
    setAXY16
    LDA #$4000
    STA VMADDL

    LDY #$0000
:   LDA msu_intro_tilemap, Y
    STA VMDATAL
    INY
    INY
    CPY #$0380 * 2
    BNE :-

    setAXY8
    rts

write_intro_palette:
    jsr write_nes_box_pallete
    rts

write_nes_box_pallete:

    STZ CGADD    

    LDY #$00
:   LDA nes_box_palette, y
    STA CGDATA
    INY
    BNE :-

    RTS


load_intro_tilesets:
    lda #$01
    sta NMITIMEN
    LDA VMAIN_STATE
    AND #$0F
    STA VMAIN
    LDA #$8F
    STA INIDISP
    STA INIDISP_STATE

  LDA #$21
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$00
  STA CHR_BANK_TARGET_BANK
  JSL load_chr_table_to_vm

  LDA #$22
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$01
  STA CHR_BANK_TARGET_BANK
  JSL load_chr_table_to_vm

  LDA #$23
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$02
  STA CHR_BANK_TARGET_BANK
  JSL load_chr_table_to_vm

  LDA #$20
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$03
  STA CHR_BANK_TARGET_BANK
  JSL load_chr_table_to_vm

  rts
    
.include "msu_intro_tilemap.asm"
.include "movie-palette.asm"
.include "nes-box-palette.asm"