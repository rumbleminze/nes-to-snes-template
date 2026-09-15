; Palette related routines.  
; allow for changing the palette during game via L and R
adjust_palette_option:
  LDA P1_SNES_BUTTONS_TRIGGER
  CMP #$10
  BNE :+
    ; L, decrement
    DEC OPTIONS_PALETTE
    LDA OPTIONS_PALETTE
    BPL :++
    LDA #13
    BRA :++    
  :
  ; R, increment
  INC OPTIONS_PALETTE
  LDA OPTIONS_PALETTE
  CMP #14
  BNE :+
    LDA #$00
  :
  STA OPTIONS_PALETTE
  STA OPTIONS_PALETTE_SAVE
  RTS

check_for_palette_change:
  LDA P1_SNES_BUTTONS_TRIGGER
  AND #$30
  BEQ :+

    STZ NMITIMEN

    jsr wait_for_vblank
    jsr adjust_palette_option

    LDA #$80
    STA VMAIN
    jslb write_palette_data, $a0
    LDA VMAIN_STATE
    STA VMAIN
    LDA RDNMI
    LDA NMITIMEN_CACHE
    STA NMITIMEN
: 

rtl

check_for_palette_updates:
  PHA
  LDA PALETTE_NEEDS_UPDATING
  BNE :+
  PLA
  rtl
: pla
  stz PALETTE_NEEDS_UPDATING

write_palette_data:
  PHX
  PHY
  PHA

  setAXY8
  PHK
  PLB

  LDA $00
  PHA
  LDA $01
  PHA

  LDA OPTIONS_PALETTE
  ASL
  TAY
  LDA palette_adddresses, Y
  STA $00
  LDA palette_adddresses + 1, Y
  STA $01

  STZ CGADD
  STZ CURR_PALETTE_ADDR
  STZ PALETTE_STARTING_OFFSET
  LDX #$00
  
  ; lookup our 2 byte color from palette_lookup, color * 2
  ; Our palettes are written by writing to CGDATA
  ; PALETTE_UPDATE_START contains the first byte of palette data to update.
palette_entry:

  LDA PALETTE_UPDATE_START, X
  CMP #$FF
  BEQ done_updating_palettes
  CPX #$20
  BEQ done_updating_palettes
  
  AND PALETTE_FILTER
  ASL A
  TAY
  LDA ($00), Y

  STA CGDATA
  INY
  LDA ($00), Y
  STA CGDATA

  INX
  INC PALETTE_STARTING_OFFSET
  LDA PALETTE_STARTING_OFFSET
  CMP #$10
  BNE :+
    ; starting on the 2nd row, skip 16 entries
    CLC
    LDA CURR_PALETTE_ADDR
    ADC #$50
    STA CGADD
    STA CURR_PALETTE_ADDR 
    BRA palette_entry
:
  AND #$03
  BNE :+
  ; after every 4 entries we need to move the CGADD down by 10
    LDA CURR_PALETTE_ADDR
    CLC
    ADC #$10
    STA CGADD
    STA CURR_PALETTE_ADDR
  :
  bra palette_entry
  
done_updating_palettes:
  LDA ACTIVE_NES_BANK
  INC A
  ORA #$A0
  PHA
  PLB
  
  PLA
  STA $01
  PLA 
  STA $00

  PLA
  PLY  
  PLX
  ; done after $20
  RTL
  
zero_all_palette_long:
  jsr zero_all_palette
  rtl

zero_all_palette:
  LDY #$00
  LDX #$02

  STZ CGADD

: STZ CGDATA
  DEY
  BNE :-
  DEX
  BNE :-

  RTS

snes_default_bg_palette:
.byte $00, $00, $FF, $7F, $7D, $12, $D6, $10, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

snes_sprite_palatte:
.byte $00, $00, $FF, $7F, $7D, $12, $D6, $10, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

write_default_palettes_jsl:
  jsr write_default_palettes
  rtl

write_default_palettes:
  STZ CGADD
  ; sta CGADD
  LDY #$00
: LDA snes_sprite_palatte, y
  STA CGDATA
  INY
  CMP #$40
  BNE :-


  LDA #$80
  sta CGADD
  LDY #$00
: LDA snes_sprite_palatte, y
  STA CGDATA
  INY
  CMP #$40
  BNE :-
  rts

; assumes CGADD is already set
; nes color is in A
store_nes_color_in_palette:
  PHX
  ASL A
  TAX
  LDA $A086E0, X ; palette_lookup, X
  STA CGDATA
  LDA $A086E1, X ; palette_lookup + 1, X
  STA CGDATA

  PLX
  RTL



write_option_palette:
    PHK
    PLB
    LDA RDNMI
:   LDA RDNMI
    BPL :-

    LDA OPTIONS_PALETTE
    ASL
    TAY
    LDA palette_adddresses, Y
    STA $00
    INY
    LDA palette_adddresses, Y
    STA $01
    
    LDY #$00

    LDA #$41
    STA CGADD
    LDX #$80
    LDY #$00

:   LDA ($00), Y
    STA CGDATA
    INY
    DEX
    BNE :-

    RTL

write_option_palette_from_indexes:
    PHK
    PLB
    LDA RDNMI
:   LDA RDNMI
    BPL :-

    STZ CGADD
    LDY #$00
    LDX #$00

    LDA OPTIONS_PALETTE
    ASL
    TAY
    LDA palette_adddresses, Y
    STA $00
    INY
    LDA palette_adddresses, Y
    STA $01
    
    LDY #$00
    
option_palette_loop:
    LDA default_options_bg_palette_indexes, X
    ASL A
    TAY

    LDA ($00), Y
    STA CGDATA
    INY

    LDA ($00), Y
    STA CGDATA    
    INY

    ; every 4 we need to write a bunch of empty palette entries
    INX
    TXA
    AND #$03
    BNE :+

    CLC
    LDA CURR_PALETTE_ADDR
    ADC #$10
    STA CGADD
    STA CURR_PALETTE_ADDR

:
    TXA
    AND #$0F
    CMP #$00
    BNE :+
    ; after 16 entries we write an empty set of palettes
    CLC
    LDA CURR_PALETTE_ADDR
    ADC #$40
    STA CGADD
    STA CURR_PALETTE_ADDR 

:
    CPX #$20
    BNE option_palette_loop
    rtl    

    
default_options_bg_palette_indexes:
.byte $0F, $07, $00, $01, $0F, $02, $01, $1C, $0F, $0A, $18, $28, $0F, $17, $19, $10

default_options_sprite_palette_indexes:
.byte $0F, $30, $15, $0F, $0F, $30, $00, $0F, $0F, $3B, $1B, $0F, $0F, $06, $16, $38

default_options_palette:
.byte $00, $00, $FF, $7F, $74, $64, $42, $50, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $F7, $02, $33, $01, $6A, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $29, $6F, $07, $02, $A0, $44, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $BF, $65, $8C, $31, $76, $3C, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

options_sprite_palette:
.byte $00, $00, $FF, $7F, $1F, $3A, $6A, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $78, $7F, $42, $50, $76, $3C, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $08, $7D, $D8, $7D, $78, $7F, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $0D, $00, $D6, $10, $9C, $4B, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

