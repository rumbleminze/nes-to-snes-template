translate_8_by_16_sprites:
  jsl disable_nmi_no_store
  jsr totals_sprite_conversion
  jsl enable_nmi
  RTL


  LDX #$03
  LDY #$00
traslation_start:
  LDA $0200,X
  STA SNES_OAM_START + 0,Y
  STA SNES_OAM_START + 4,Y
  DEX
  DEX
  DEX
  INY
  LDA $0200,X
  STA SNES_OAM_START + 0,Y
  CLC
  ADC #$08
  BNE :+
  LDA #$F8
: STA SNES_OAM_START + 4,Y
  INX
  INY
  LDA $0200,X
  PHA
  AND #$01
  BEQ :+
  STA $0AFE
  PLA
  DEC
  BRA :++
: PLA
: STA SNES_OAM_START,Y
  INC
  STA SNES_OAM_START + 4,Y
  INX
  INY
  LDA $0200,X
  AND #$80
  BPL :+
  DEY
  LDA SNES_OAM_START + 4,Y
  STA SNES_OAM_START + 0,Y
  DEC
  STA SNES_OAM_START + 4,Y
  INY
: LDA $0200,X
  PHA
  ; AND #$0F
  AND #$03
	ASL A
	STA SPRITE_LOOP_JUNK
	PLA
	AND #$F0
	EOR #%00110000
	ORA SPRITE_LOOP_JUNK
  STA $0AFF
  ; CLC
  ; ADC $0200,X
  ; STA $0AFF
  ; PLA
  ; AND #$C0
  ; CLC
  ; ADC #$30
  ; ORA $0AFF
  ; STA $0AFF

  LDA $0200,X
  AND #$20
  BEQ :+
  LDA $0AFF
  SEC
  SBC #$30
  BRA :++
: LDA $0AFF
: STA SNES_OAM_START + 0,Y
  STA SNES_OAM_START + 4,Y
  PHA
  LDA $0AFE
  BEQ :+
  PLA
  CLC
  ADC $0AFE
  STA SNES_OAM_START + 0,Y
  STA SNES_OAM_START + 4,Y
  STZ $0AFE
  BRA :++
: STZ $0AFE
  PLA
: INX
  INX
  INX
  INX
  INX
  TYA
  CLC
  ADC #$05
  TAY
  BEQ second_half_of_sprites
  JMP traslation_start
  nop
second_half_of_sprites: 
  LDA $0200,X
  STA SNES_OAM_SECOND_BLOCK + 0,Y
  STA SNES_OAM_SECOND_BLOCK + 4,Y
  DEX
  DEX
  DEX
  INY
  LDA $0200,X
  STA SNES_OAM_SECOND_BLOCK + 0,Y
  CLC
  ADC #$08
  BNE :+
  LDA #$F8
: STA SNES_OAM_SECOND_BLOCK + 4,Y
  INX
  INY
  LDA $0200,X
  PHA
  AND #$01
  BEQ :+
  STA $0AFE
  PLA
  DEC
  BRA :++
: PLA
: STA SNES_OAM_SECOND_BLOCK + 0,Y
  INC
  STA SNES_OAM_SECOND_BLOCK + 4,Y
  INX
  INY
  LDA $0200,X
  AND #$80
  BPL :+
  DEY
  LDA SNES_OAM_SECOND_BLOCK + 4,Y
  STA SNES_OAM_SECOND_BLOCK + 0,Y
  DEC
  STA SNES_OAM_SECOND_BLOCK + 4,Y
  INY
: LDA $0200,X
  PHA
  ; AND #$0F
  AND #$03
	ASL A
	STA SPRITE_LOOP_JUNK
	PLA
	AND #$F0
	EOR #%00110000
	ORA SPRITE_LOOP_JUNK
  STA $0AFF
;;;;;;;;;
  ; CLC
  ; ADC $0200,X
  ; STA $0AFF
  ; PLA
  ; AND #$C0
  ; CLC
  ; ADC #$30
  ; ORA $0AFF
  ; STA $0AFF
  LDA $0200,X
  AND #$20
  BEQ :+
  LDA $0AFF
  SEC
  SBC #$30
  BRA :++
: LDA $0AFF
: STA SNES_OAM_SECOND_BLOCK + 0,Y
  STA SNES_OAM_SECOND_BLOCK + 4,Y
  PHA
  LDA $0AFE
  BEQ :+
  PLA
  CLC
  ADC $0AFE
  STA SNES_OAM_SECOND_BLOCK + 0,Y
  STA SNES_OAM_SECOND_BLOCK + 4,Y
  STZ $0AFE
  BRA :++
: STZ $0AFE
  PLA
: INX
  INX
  INX
  INX
  INX
  TYA
  CLC
  ADC #$05
  TAY
  BEQ :+
  JMP second_half_of_sprites
: jsl enable_nmi
  RTL

OAMNES_Y    = $200
OAMNES_IDX  = $201
OAMNES_ATTR = $202
OAMNES_X    = $203


OAMSNES_X    = $1000
OAMSNES_Y    = $1001
OAMSNES_IDX  = $1002
OAMSNES_ATTR = $1003

totals_sprite_conversion:
    PHP
    PHB
    PHK
    PLB
    setXY16
    LDA #$00
    XBA
    LDX #$0000
    LDY #$0000
LoopSprite:
    ; Y coordinate
    LDA OAMNES_Y, X
    CMP #$F0
    BCS Clear

    ; SEC 
    ; SBC #!VSpriteOffset

    BIT OAMNES_ATTR, X
    BMI VFlip
    STA OAMSNES_Y, Y
    CLC 
    ADC #$08
    STA OAMSNES_Y+$4, Y
    BRA XCoord

VFlip:
    STA OAMSNES_Y+$4, Y
    CLC 
    ADC #$08
    STA OAMSNES_Y, Y
    
XCoord:
    ; X coordinate
    LDA OAMNES_X, X
    STA OAMSNES_X, Y
    STA OAMSNES_X+$4, Y

    LDA OAMNES_IDX, X
    AND #$FE
    STA OAMSNES_IDX, Y
    INC
    STA OAMSNES_IDX+$4, Y

    LDA OAMNES_ATTR, X
    PHX
    TAX
    LDA AttributeTable, X
    ORA OBJ_CHR_HB
    PLX
    STA OAMSNES_ATTR, Y

    LDA OAMNES_IDX, X
    AND #$01
    ORA OAMSNES_ATTR, Y
    STA OAMSNES_ATTR, Y
    STA OAMSNES_ATTR+$4, Y

    bra Next

;     LDA OAMNES_ATTR, X
;     AND #$04
;     BEQ noExtended

;     LDA OAMSNES_ATTR, Y
;     ORA #$09
;     STA OAMSNES_ATTR, Y
;     STA OAMSNES_ATTR + $4, Y
    
;     LDA OAMNES_IDX, X
;     AND #$03
;     BNE odd
;     ; For an extended sprite with index 0, 4, 8 etc, set the index of
;     ; the other sprite to Index+2
;     LDA OAMNES_IDX+$4, Y
;     INC
;     STA OAMNES_IDX+$4, Y
;     BRA noExtended

; odd:
;     LDA OAMNES_IDX, Y 
;     DEC 
;     STA OAMNES_IDX, Y

; noExtended:
;     BRA Next

Clear:
    LDA  #$F0
    STA OAMSNES_Y, Y
    STA OAMSNES_Y+$4, Y
Next:
    INY
    INY
    INY
    INY
    INY
    INY
    INY
    INY
    INX
    INX
    INX
    INX
    CPX #$0100
    BEQ :+
    JMP LoopSprite
:
    setAXY8
    PLB
    PLP
    RTS

translate_8by8only_nes_sprites_to_oam:
    ; check if we need to do this
    LDA SNES_OAM_TRANSLATE_NEEDED
    BNE :+
    RTL
    ; PHA
    ; PHX
    ; PHY
    ; PHB
:   
  LDA SPRITE_LOOP_JUNK
  PHA
  setXY16
	LDY #$0000

sprite_loop:	

	; byte 0, Tile Y position
	LDA $200,Y
	STA SNES_OAM_START + 1, y
  CMP #$F0
  beq next_sprite

	; byte 1, Tile index
	LDA $201, Y
	STA SNES_OAM_START + 2, y
	; beq empty_sprite

	; byte 3, Tile X Position
	LDA $203, Y
	STA SNES_OAM_START, y 

	; properties
	LDA $202, Y
	PHA
	AND #$03
	ASL A
	STA SPRITE_LOOP_JUNK
	PLA
	AND #$F0
	EOR #%00110000
	ORA SPRITE_LOOP_JUNK
  STA SPRITE_LOOP_JUNK

  LDA $201, Y
  BPL :+
  ; 2nd half tile, adjust it based on active bank
  AND #$7F
  ORA CURRENT_ENEMY_TILE_OFFSET
  STA SNES_OAM_START + 2, y

  LDA SPRITE_LOOP_JUNK
  ORA CURRENT_SPRITE_TABLE_OFFSET
  STA SPRITE_LOOP_JUNK
:	
  LDA SPRITE_LOOP_JUNK
  STA SNES_OAM_START + 3, y
	; bra next_sprite

	; empty_sprite:
	; sta SNES_OAM_START, y
	; lda #$f8 
	; sta SNES_OAM_START + 1, y
	; lda #$38
	; sta SNES_OAM_START + 3, y

	next_sprite:
	INY
	INY
	INY
	INY
	CPY #$100
	BNE sprite_loop

  setAXY8
  PLA
  STA SPRITE_LOOP_JUNK
  STZ SNES_OAM_TRANSLATE_NEEDED
	rtl

dma_oam_table_long:
  JSR dma_oam_table
  RTL

dma_oam_table:
  STZ OAMADDL
  STZ OAMADDH
  LDA #<OAMDATA
  STA BBAD2
  LDA #$A0
  STA A1B2

  STZ DMAP2
  LDA #>SNES_OAM_START
  STA A1T2H
  LDA #<SNES_OAM_START
  STA A1T2L
  LDA #$02
  STA DAS2H
  LDA #$20
  STA DAS2L
  LDA #$04
  STA MDMAEN

  INC SNES_OAM_TRANSLATE_NEEDED
  RTS

zero_oam:

  setXY16
  ldx #$0000

: stz SNES_OAM_START, x
  lda #$f0
  STA SNES_OAM_START + 1, x
  STZ SNES_OAM_START + 2, x
  STZ SNES_OAM_START + 3, x
  INX
  INX
  INX
  INX
  CPX #$200
  bne :-
: stz SNES_OAM_START, X
  inx
  CPX #$220
  bne :-
  setAXY8
  RTS


move_sprites_offscreen:
  LDA #$f0
  STA $0200
  STA $0204
  STA $0208
  STA $020C
  STA $0210
  STA $0214
  STA $0218
  STA $021C
  STA $0220
  STA $0224
  STA $0228
  STA $022C
  STA $0230
  STA $0234
  STA $0238
  STA $023C
  STA $0240
  STA $0244
  STA $0248
  STA $024C
  STA $0250
  STA $0254
  STA $0258
  STA $025C
  STA $0260
  STA $0264
  STA $0268
  STA $026C
  STA $0270
  STA $0274
  STA $0278
  STA $027C
  STA $0280
  STA $0284
  STA $0288
  STA $028C
  STA $0290
  STA $0294
  STA $0298
  STA $029C
  STA $02A0
  STA $02A4
  STA $02A8
  STA $02AC
  STA $02B0
  STA $02B4
  STA $02B8
  STA $02BC
  STA $02C0
  STA $02C4
  STA $02C8
  STA $02CC
  STA $02D0
  STA $02D4
  STA $02D8
  STA $02DC
  STA $02E0
  STA $02E4
  STA $02E8
  STA $02EC
  STA $02F0
  STA $02F4
  STA $02F8
  STA $02FC

  rtl

  AttributeTable:
.byte $20, $22, $24, $26, $20, $22, $24, $26, $20, $22, $24, $26, $20, $22, $24, $26, $20, $22, $24, $26, $20, $22, $24, $26, $20, $22, $24, $26, $20, $22, $24, $26, $00, $02, $04, $06 
.byte $00, $02, $04, $06, $00, $02, $04, $06, $00, $02, $04, $06, $00, $02, $04, $06, $00, $02, $04, $06, $00, $02, $04, $06, $00, $02, $04, $06, $60, $62, $64, $66, $60, $62, $64, $66 
.byte $60, $62, $64, $66, $60, $62, $64, $66, $60, $62, $64, $66, $60, $62, $64, $66, $60, $62, $64, $66, $60, $62, $64, $66, $40, $42, $44, $46, $40, $42, $44, $46, $40, $42, $44, $46 
.byte $40, $42, $44, $46, $40, $42, $44, $46, $40, $42, $44, $46, $40, $42, $44, $46, $40, $42, $44, $46, $A0, $A2, $A4, $A6, $A0, $A2, $A4, $A6, $A0, $A2, $A4, $A6, $A0, $A2, $A4, $A6 
.byte $A0, $A2, $A4, $A6, $A0, $A2, $A4, $A6, $A0, $A2, $A4, $A6, $A0, $A2, $A4, $A6, $80, $82, $84, $86, $80, $82, $84, $86, $80, $82, $84, $86, $80, $82, $84, $86, $80, $82, $84, $86 
.byte $80, $82, $84, $86, $80, $82, $84, $86, $80, $82, $84, $86, $E0, $E2, $E4, $E6, $E0, $E2, $E4, $E6, $E0, $E2, $E4, $E6, $E0, $E2, $E4, $E6, $E0, $E2, $E4, $E6, $E0, $E2, $E4, $E6, $E0, $E2, $E4
.byte $E6, $E0, $E2, $E4, $E6, $C0, $C2, $C4, $C6, $C0, $C2, $C4, $C6, $C0, $C2, $C4, $C6, $C0, $C2, $C4, $C6, $C0, $C2, $C4, $C6, $C0, $C2, $C4, $C6, $C0, $C2, $C4, $C6, $C0, $C2, $C4    