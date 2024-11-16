
write_palette_data:
  PHX
  PHY
  PHA

  setAXY8
  LDA #$A0
  
  PHA
  PLB
  LDY #$00
  STZ CURR_PALETTE_ADDR
  STZ CGADD

  ; lookup our 2 byte color from palette_lookup, color * 2
  ; Our palettes are written by writing to CGDATA
  ; PALETTE_UPDATE_START contains the first byte of palette data to update.
palette_entry:

  LDA PALETTE_UPDATE_START, Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA

  LDA PALETTE_UPDATE_START + 1, Y
  ASL A
  TAX 
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA

  LDA PALETTE_UPDATE_START + 2, Y
  ASL A
  TAX 
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA

  LDA PALETTE_UPDATE_START + 3, Y
  ASL A
  TAX 
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA

  LDA CURR_PALETTE_ADDR
  CLC
  ADC #$10
  STA CGADD
  STA CURR_PALETTE_ADDR

  INY
  INY
  INY
  INY
  ; CPY #$10
  ; BNE palette_entry

  TYA
  AND #$0F
  CMP #$00
  BNE skip_writing_four_empties

  ; after 16 entries we write an empty set of palettes
  CLC
  LDA CURR_PALETTE_ADDR
  ADC #$40
  STA CGADD
  STA CURR_PALETTE_ADDR 

skip_writing_four_empties:
  CPY #$20
  BEQ :+
  jmp palette_entry
:
  LDA ACTIVE_NES_BANK
  INC A
  ORA #$A0
  PHA
  PLB
  PLA
  PLY  
  PLX
  ; done after $20
  RTL
  
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

snes_sprite_palatte:
; .byte $D6, $10, $FF, $7F, $D6, $10, $00, $00, $91, $29, $CE, $39, $5B, $29, $35, $3A
; .byte $77, $46, $B5, $56, $B9, $4E, $FB, $56, $3D, $5F, $7B, $6F, $FC, $7F, $FF, $7F
.byte $1F, $00, $FF, $7F, $53, $08, $00, $00, $91, $29, $CE, $39, $5B, $29, $35, $3A
.byte $77, $46, $B5, $56, $B9, $4E, $FB, $56, $3D, $5F, $7B, $6F, $D7, $18, $FF, $7F
write_default_palettes:
  LDA #$80
  sta CGADD
  LDY #$00
: LDA snes_sprite_palatte, y
  STA CGDATA
  INY
  CMP #$20
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