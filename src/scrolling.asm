
infidelitys_scroll_handling:

  LDA $F1
  AND #$01
  ORA PPU_CONTROL_STATE

  PHA 
  AND #$80
  BNE :+
  LDA #$00
  BRA :++
: LDA #$80
: STA NMITIMEN
  PLA        
  PHA 
  AND #$04
  ; A now has the BG table address
  BNE :+
  LDA #$00
  BRA :++
: LDA #$01   
: STA VMAIN 
  PLA 
  AND #$03
  BEQ :+
  CMP #$01
  BEQ :++
  CMP #$02
  BEQ :+++
  CMP #$03
  BEQ :++++
: STZ HOFS_HB
  STZ VOFS_HB
  BRA :++++   ; RTL
: LDA #$01
  STA HOFS_HB
  STZ VOFS_HB
  BRA :+++    ; RTL
: STZ HOFS_HB
  LDA #$01
  ; STA VOFS_HB
  BRA :++     ; RTL
: LDA #$01
  STA HOFS_HB
  ; STA VOFS_HB

: RTL 


setup_hdma:

  ; line count
  ;   HOFS_LB, HOFS_HB, VOFS_LB, VOFS_LB
  ; x3
  ; 00

  LDX VOFS_LB
  LDA $A0A080,X
  STA SCROLL_HDMA_START + 0
  LDA $A0A180,X
  STA SCROLL_HDMA_START + 3
  LDA $A0A280,X
  STA SCROLL_HDMA_START + 5
  LDA $A0A380,X
  STA SCROLL_HDMA_START + 8
  
  LDA $A0A480,X
  STA SCROLL_HDMA_START + 10
  LDA $A0A560,X
  STA SCROLL_HDMA_START + 13

  LDA HOFS_LB
  STA SCROLL_HDMA_START + 1
  STA SCROLL_HDMA_START + 6
  STA SCROLL_HDMA_START + 11
  
  lda $F1
  AND #$01
  STA SCROLL_HDMA_START + 2
  STA SCROLL_HDMA_START + 7
  STA SCROLL_HDMA_START + 12

  ; v-hi byte, always 0 for BM
  ; LDX VOFS_HB  
  ; LDA $A0A610,X
  STZ SCROLL_HDMA_START + 4
  STZ SCROLL_HDMA_START + 9
  STZ SCROLL_HDMA_START + 14

  STZ SCROLL_HDMA_START + 15

  RTL

default_scrolling_hdma_values:
.byte $6F, $00, $92, $00, $C9, $58, $00, $92, $00, $C9, $27, $00, $00, $00, $01, $00

set_scrolling_hdma_defaults:

  LDA $3D
  AND #$04
  BEQ :+
  LDA $3E
  AND #$01
  BEQ :+
  jmp simple_scrolling

: PHY
  PHB
  LDA #$A0
  PHA
  PLB
  LDY #$00
: LDA default_scrolling_hdma_values, Y
  CPY #$0f
  BEQ :+
  STA SCROLL_HDMA_START, Y
  INY
  BRA :-

: PLB
  PLY
  RTL

  ; used where we just want to set the scroll to 0,0 and not worry about 
; attributes, because they'll naturally be offscreen
simple_scrolling:
  LDA #$08
  STA BG1VOFS
  LDA #$01
  STA BG1VOFS
  STZ BG1HOFS
  STZ BG1HOFS
  STZ SCROLL_HDMA_START
  STZ SCROLL_HDMA_START + 1
  STZ SCROLL_HDMA_START + 2
  RTL