; bank 0 - this houses our init routine and setup stuff
.segment "PRGA0"
init_routine:
  PHK 
  PLB 
  BRA initialize_registers

initialize_registers:
  setAXY16
  setA8

  LDA #$8F
  STA INIDISP
  STA INIDISP_STATE
  STZ OBSEL
  STZ OAMADDL
  STZ OAMADDH
  STZ BGMODE  
  STZ MOSAIC  
  STZ BG1SC   
  STZ BG2SC   
  STZ BG3SC   
  STZ BG4SC   
  STZ BG12NBA 
  STZ BG34NBA 
  STZ BG1HOFS 
  STZ BG1HOFS
  STZ BG1VOFS
  STZ BG1VOFS
  STZ BG2HOFS
  STZ BG2HOFS
  STZ BG2VOFS
  STZ BG2VOFS
  STZ BG3HOFS
  STZ BG3HOFS
  STZ BG3VOFS
  STZ BG3VOFS
  STZ BG4HOFS
  STZ BG4HOFS
  STZ BG4VOFS
  STZ BG4VOFS

  LDA #$80
  STA VMAIN
  STZ VMADDL
  STZ VMADDH
  STZ M7SEL
  STZ M7A

  LDA #$01
  STA M7A
  STA MEMSEL
  STZ M7B
  STZ M7B
  STZ M7C
  STZ M7C
  STZ M7D
  STA M7D
  STZ M7X
  STZ M7X
  STZ M7Y
  STZ M7Y
  STZ CGADD
  STZ W12SEL
  STZ W34SEL
  STZ WOBJSEL
  STZ WH0
  STZ WH1     
  STZ WH2     
  STZ WH3     
  STZ WBGLOG  
  STZ WOBJLOG 
  STZ TM      
  STZ TS      
  STZ TMW     

  LDA #$30
  STA CGWSEL
  STZ CGADSUB

  ; STZ SETINI
  LDA #$00 
  ; LDA #$01 ; uncomment this to use auto-joypoll
  STA NMITIMEN
  STA NMITIMEN_STATE
  STZ VMAIN_STATE
  
  STZ SNES_OAM_TRANSLATE_NEEDED

  LDA #$FF
  STA WRIO   
  STZ WRMPYA 
  STZ WRMPYB 
  STZ WRDIVL 
  STZ WRDIVH 
  STZ WRDIVB 
  STZ HTIMEL 
  STZ HTIMEH 
  STZ VTIMEL 
  STZ VTIMEH 
  STZ MDMAEN 
  STZ HDMAEN 
  STZ MEMSEL 

  STZ STORED_OFFSETS_SET
  STZ UNPAUSE_BG1_VOFS_LB
  STZ UNPAUSE_BG1_VOFS_HB
  STZ UNPAUSE_BG1_HOFS_LB
  STZ UNPAUSE_BG1_HOFS_HB
  STZ EXTRA_VRAM_UPDATE
  STZ LEVEL_SELECT_INDEX
  
  setAXY8
  LDA #$00
  LDY #$0F
: STA ATTRIBUTE_DMA, Y
  STA COLUMN_1_DMA, Y
  DEY
  BNE :-

  LDY #$40
: DEY
  STA $0900, y
  BNE :-
  
  JSR clear_zp 
  JSR clear_buffers
  
  LDA #$20
  STA $00
  JSR clear_bg
  LDA #$24
  STA $00
  JSR clear_bg
  JSR clearvm
  LDA #$E0
  STA COLDATA
  LDA #$0F
  STA INIDISP_STATE

  JSR zero_oam  
  JSR dma_oam_table
  JSR zero_all_palette

  STA OBSEL
  LDA #$11
  STA BG12NBA
  LDA #$77
  STA BG34NBA
  LDA #$01
  STA BGMODE
  LDA #$21
  STA BG1SC
;   LDA #$32
;   STA BG2SC
;   LDA #$28
;   STA BG3SC
;   LDA #$7C
;   STA BG4SC
  LDA #$80
  STA OAMADDH
  LDA #$11
  STA TMW
  LDA #$02
  STA W12SEL
  STA WOBJSEL
  
  lda #%00010001
  STA TM
  LDA #$01
  STA MEMSEL
; Use #$04 to enable overscan if we can.
  LDA #$04
  LDA #$00
  STA SETINI


  lda #%0000000
  sta OBSEL

  STZ ATTR_NES_HAS_VALUES
  STZ ATTR_NES_VM_ADDR_HB
  STZ ATTR_NES_VM_ADDR_LB
  STZ ATTR_NES_VM_ATTR_START
  STZ ATTR2_NES_HAS_VALUES
  STZ ATTR2_NES_VM_ADDR_HB
  STZ ATTR2_NES_VM_ADDR_LB
  STZ ATTR2_NES_VM_ATTR_START
  STZ ATTRIBUTE2_DMA
  STZ ATTRIBUTE_DMA
  STZ COL_ATTR_HAS_VALUES
  STZ COLUMN_1_DMA
  LDA #$00
  ; LDA #$01 ; uncomment this to use auto-poll joypad
  STA NMITIMEN_STATE
  JSL upload_sound_emulator_to_spc
  jsr write_sound_wram_routines
  JSR do_intro
  
intro_done:
  STZ TM      
  STZ TS      
  STZ TMW   
    LDA #$30
  STA CGWSEL
  STZ CGADSUB
  
  JSR setup_hide_left_8_pixel_window
  JSL disable_hide_left_8_pixel_window
  JSR clearvm_to_12
  JSR write_default_palettes
  ; JSR write_stack_adjustment_routine_to_ram
  ; JSR write_sound_hijack_routine_to_ram
  
  LDA #$02
  STA $4D

  LDA #$A1
  PHA
  PLB 
  JML $A1C000


  snes_nmi:
    LDA RDNMI 
    jslb update_values_for_ppu_mask, $a0
    jslb infidelitys_scroll_handling, $a0
    jslb setup_hdma, $a0

    LDA #$7E
    STA A1B3
    LDA #$09
    STA A1T3H
    STZ A1T3L
    
    LDA #<(BG1HOFS)
    STA BBAD3
    LDA #$03
    STA DMAP3

    LDA #%00001000
    STA HDMAEN

    JSR dma_oam_table
    RTL

clear_bg_jsl:
  jsr clear_bg
  rtl
clear_bg:

  LDA #$80
  STA VMAIN

  ; fixed A value, increment B
  
  LDA #$09
  sta DMAP0
  
  LDA $00
  STA VMADDH
  STZ VMADDL

  LDA #$18
  STA BBAD0

  LDA #$A0
  STA A1B0

  LDA #>dma_values
  STA A1T0H
  LDA #<dma_values
  STA A1T0L

  LDA #$08
  STA DAS0H  
  STZ DAS0L

  LDA #$01
  STA MDMAEN

  LDA VMAIN_STATE
  STA VMAIN
  RTS

clearvm_jsl:
  jsr clearvm
  rtl
clearvm:
  LDA #$80
  STA VMAIN

  ; fixed A value, increment B
  setAXY16

  LDA #$0009
  sta DMAP0

  LDA #$0000
  STZ VMADDL

  LDA #$18
  STA BBAD0

  LDA #$A0
  STA A1B0

  setAXY8
  LDA #>dma_values
  STA A1T0H
  LDA #<dma_values
  STA A1T0L
  setAXY16

  STZ DAS0L

  LDA #$0001
  STA MDMAEN

  setAXY8
  LDA VMAIN_STATE
  STA VMAIN
  RTS

clearvm_to_12_long:
  JSR clearvm_to_12
  RTL

clearvm_to_12:

: LDA RDNMI
  BPL :-

  LDA #$01
  STA NMITIMEN
  jslb force_blank_no_store, $a0 
  setAXY16
  ldx #$2000
  stx VMADDL 
	
	lda #$0000
	
	LDY #$0000
	:
		sta VMDATAL
		iny
		CPY #(32*64)
		BNE :-
  
  setAXY8
  jslb reset_inidisp, $a0 

  RTS

clear_zp:
  LDA #$00
  LDY #$00

: STA $00, Y
  INY
  BNE :-
  RTS

clear_buffers:
  LDA #$00
  LDY #$00
  LDX #$FF

: LDA #$00
  STA $0800, Y
  STA $0900, Y
  STA $0A00, Y
  STA $0B00, Y
  STA $0C00, Y
  STA $0D00, Y
  STA $0E00, Y
  STA $0F00, Y
  
  STA $1000, Y
  STA $1100, Y
  STA $1200, Y
  STA $1300, Y
  STA $1400, Y
  STA $1500, Y
  STA $1600, Y
  STA $1700, Y
  
  STA $1800, Y
  STA $1900, Y
  STA $1A00, Y
  STA $1B00, Y
  STA $1C00, Y
  STA $1D00, Y
  STA $1E00, Y
  STA $1F00, Y

  LDA #$FF
  STA $6500, y
  STA $6600, y
  DEY
  BNE :-
  RTS

msu_movie_rti:
  REP #$30
  PLY
  PLX
  PLA
  SEP #$30
  PLP
  RTI



dma_values:
  .byte $00, $12

.if ENABLE_MSU = 1
  .include "msu_intro_screen.asm"
.endif

.if ENABLE_MSU = 0
  .include "intro_screen.asm"
.endif
  .include "konamicode.asm"
  .include "palette_updates.asm"
  .include "palette_lookup.asm"
  .include "sprites.asm"
  .include "tiles.asm"
  .include "hardware-status-switches.asm"
  .include "scrolling.asm"
  .include "attributes.asm"
  .include "hdma_scroll_lookups.asm"
  .include "2a03_conversion.asm"
  .include "windows.asm"


write_sound_wram_routines:
LDY #$00
:
LDA wram_routines, Y
STA $1D00, Y
LDA wram_routines + $100, Y
STA $1E00, Y
LDA wram_routines + $200, Y
STA $1F00, Y
INY
BNE :-
RTS

wram_routines:
.byte $A5, $E0, $C9, $00, $F0, $22, $C9, $04, $F0, $38, $C9, $08, $F0, $4E, $B1, $E2
.byte $20, $8C, $1E, $C8, $B1, $E2, $20, $90, $1E, $C8, $B1, $E2, $20, $94, $1E, $C8
.byte $B1, $E2, $20, $9C, $1E, $C8, $80, $4E, $B1, $E2, $20, $79, $1D, $C8, $B1, $E2
.byte $20, $89, $1D, $C8, $B1, $E2, $20, $B3, $1D, $C8, $B1, $E2, $20, $BF, $1D, $C8
.byte $80, $34, $B1, $E2, $20, $06, $1E, $C8, $B1, $E2, $20, $12, $1E, $C8, $B1, $E2
.byte $20, $33, $1E, $C8, $B1, $E2, $20, $3B, $1E, $C8, $80, $1A, $B1, $E2, $20, $66
.byte $1E, $C8, $B1, $E2, $20, $6A, $1E, $C8, $B1, $E2, $20, $6E, $1E, $C8, $B1, $E2
.byte $20, $76, $1E, $C8, $80, $00, $A9, $00, $60, $8D, $00, $0A, $60, $99, $00, $0A
.byte $60, $8C, $00, $0A, $60, $8E, $00, $0A, $60, $EB, $A9, $40, $0C, $16, $0A, $EB
.byte $8D, $01, $0A, $60, $EB, $A9, $40, $0C, $16, $0A, $EB, $8C, $01, $0A, $60, $C0
.byte $00, $D0, $04, $20, $89, $1D, $60, $C0, $04, $D0, $04, $20, $12, $1E, $60, $99
.byte $01, $0A, $60, $8D, $02, $0A, $60, $8E, $02, $0A, $60, $99, $02, $0A, $60, $DA
.byte $8D, $03, $0A, $AA, $BD, $00, $1F, $8D, $20, $0A, $EB, $A9, $01, $0C, $15, $0A
.byte $0C, $16, $0A, $FA, $EB, $60, $48, $8E, $03, $0A, $BD, $00, $1F, $8D, $20, $0A
.byte $A9, $01, $0C, $15, $0A, $0C, $16, $0A, $68, $60, $C0, $00, $D0, $04, $20, $BF
.byte $1D, $60, $C0, $04, $D0, $04, $20, $3B, $1E, $60, $C0, $08, $D0, $04, $20, $76

.byte $1E, $60, $20, $9C, $1E, $60, $8D, $04, $0A, $60, $8E, $04, $0A, $60, $8C, $04
.byte $0A, $60, $EB, $A9, $80, $0C, $16, $0A, $EB, $8D, $05, $0A, $60, $EB, $A9, $80
.byte $0C, $16, $0A, $EB, $8E, $05, $0A, $60, $EB, $A9, $80, $0C, $16, $0A, $EB, $8C
.byte $05, $0A, $60, $8D, $06, $0A, $60, $8E, $06, $0A, $60, $DA, $8D, $07, $0A, $AA
.byte $BD, $00, $1F, $8D, $22, $0A, $EB, $A9, $02, $0C, $15, $0A, $0C, $16, $0A, $FA
.byte $EB, $60, $48, $8E, $07, $0A, $BD, $00, $1F, $8D, $22, $0A, $A9, $02, $0C, $15
.byte $0A, $0C, $16, $0A, $68, $60, $8D, $08, $0A, $60, $8D, $09, $0A, $60, $8D, $0A
.byte $0A, $60, $8E, $0A, $0A, $60, $DA, $8D, $0B, $0A, $AA, $A9, $04, $0C, $16, $0A
.byte $0C, $15, $0A, $BD, $00, $1F, $8D, $24, $0A, $8A, $FA, $60, $8D, $0C, $0A, $60
.byte $8D, $0D, $0A, $60, $8D, $0E, $0A, $60, $8E, $0E, $0A, $60, $DA, $8D, $0F, $0A
.byte $AA, $A9, $08, $0C, $16, $0A, $0C, $15, $0A, $BD, $00, $1F, $8D, $26, $0A, $8A
.byte $FA, $60, $8D, $28, $0A, $EB, $AD, $28, $0A, $49, $FF, $29, $1F, $1C, $15, $0A
.byte $1C, $16, $0A, $4E, $28, $0A, $B0, $06, $9C, $03, $0A, $9C, $20, $0A, $4E, $28
.byte $0A, $B0, $06, $9C, $07, $0A, $9C, $22, $0A, $4E, $28, $0A, $B0, $06, $9C, $0B
.byte $0A, $9C, $24, $0A, $4E, $28, $0A, $B0, $06, $9C, $0F, $0A, $9C, $26, $0A, $4E
.byte $28, $0A, $90, $0A, $A9, $10, $0C, $15, $0A, $D0, $03, $0C, $16, $0A, $EB, $60

.byte $06, $06, $06, $06, $06, $06, $06, $06, $80, $80, $80, $80, $80, $80, $80, $80
.byte $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $02, $02, $02, $02, $02, $02, $02, $02
.byte $15, $15, $15, $15, $15, $15, $15, $15, $03, $03, $03, $03, $03, $03, $03, $03
.byte $29, $29, $29, $29, $29, $29, $29, $29, $04, $04, $04, $04, $04, $04, $04, $04
.byte $51, $51, $51, $51, $51, $51, $51, $51, $05, $05, $05, $05, $05, $05, $05, $05
.byte $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $06, $06, $06, $06, $06, $06, $06, $06
.byte $08, $08, $08, $08, $08, $08, $08, $08, $07, $07, $07, $07, $07, $07, $07, $07
.byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $08, $08, $08, $08, $08, $08, $08, $08
.byte $07, $07, $07, $07, $07, $07, $07, $07, $09, $09, $09, $09, $09, $09, $09, $09
.byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A
.byte $19, $19, $19, $19, $19, $19, $19, $19, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
.byte $31, $31, $31, $31, $31, $31, $31, $31, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
.byte $61, $61, $61, $61, $61, $61, $61, $61, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
.byte $25, $25, $25, $25, $25, $25, $25, $25, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
.byte $09, $09, $09, $09, $09, $09, $09, $09, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
.byte $11, $11, $11, $11, $11, $11, $11, $11, $10, $10, $10, $10, $10, $10, $10, $10



.segment "PRGA0C"
fixeda0:
.include "bank7.asm"
fixeda0_end: