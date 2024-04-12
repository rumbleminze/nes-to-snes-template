translate_8_by_16_sprites:
  jsl disable_nmi_no_store
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
  AND #$0F
  CLC
  ADC $0200,X
  STA $0AFF
  PLA
  AND #$C0
  CLC
  ADC #$30
  ORA $0AFF
  STA $0AFF
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
  AND #$0F
  CLC
  ADC $0200,X
  STA $0AFF
  PLA
  AND #$C0
  CLC
  ADC #$30
  ORA $0AFF
  STA $0AFF
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

translate_8by8only_nes_sprites_to_oam:
    ; check if we need to do this
    LDA SNES_OAM_TRANSLATE_NEEDED
    BNE :+
    RTL
    ; PHA
    ; PHX
    ; PHY
    ; PHB
:   setXY16
	LDY #$0000

sprite_loop:	

	; byte 0, Tile Y position
	LDA $200,Y
	STA SNES_OAM_START + 1, y
  CMP #$F8
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
	; LDA #%00010010

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
  STZ SNES_OAM_TRANSLATE_NEEDED
	rtl

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
