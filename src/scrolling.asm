
infidelitys_scroll_handling:

  ; LDA $F1
  ; AND #$01
  LDA curr_ppu_ctrl_value
  PHA 
  AND #$80
  BNE :+
  LDA #$01  ; assumes auto-poll joypad is tru
  BRA :++
: LDA #$81  ; assumes auto-poll joypad is tru
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
  ; set up 47 lines of hud
  LDA $18
  CMP #$0E
  BEQ falling

  LDA #47
  STA SCROLL_HDMA_START
  STZ SCROLL_HDMA_START + 1
  STZ SCROLL_HDMA_START + 2
  STZ SCROLL_HDMA_START + 3
  STZ SCROLL_HDMA_START + 4

  LDA #1
  STA SCROLL_HDMA_START + 5
  LDA curr_hoff_low  
  STA SCROLL_HDMA_START + 6
  LDA curr_ppu_ctrl_value
  AND #$01
  STA SCROLL_HDMA_START + 7
  LDX curr_voff_low
  LDA $A0A180,X
  STA SCROLL_HDMA_START + 8
  LDX curr_ppu_ctrl_value
  LDA $A0A610,X
  STA SCROLL_HDMA_START + 9
  STZ SCROLL_HDMA_START + 10

  rtl

falling:
  LDX curr_voff_low
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

  LDA curr_hoff_low
  STA SCROLL_HDMA_START + 1
  STA SCROLL_HDMA_START + 6
  STA SCROLL_HDMA_START + 11
  
  ; lda $F1
  ; AND #$01
  ; lda #$00
  LDA curr_ppu_ctrl_value
  AND #$01
  STA SCROLL_HDMA_START + 2
  STA SCROLL_HDMA_START + 7
  STA SCROLL_HDMA_START + 12

  ; v-hi byte
  LDX curr_ppu_ctrl_value
  LDA $A0A610,X
  STA SCROLL_HDMA_START + 4
  STA SCROLL_HDMA_START + 9
  STA SCROLL_HDMA_START + 14

 end_hdma:
  ; end hdma byte
  LDA #$00
  STA SCROLL_HDMA_START+15


  RTL

adjust_previous_hdma_for_attributes:
    ; Y - 2 is the line count, change that to #08
    LDA #$08
    STA SCROLL_HDMA_START - 2, Y

    ; pull the other values from Y - 5 (previous set)
    LDA SCROLL_HDMA_START - 6, Y
    STA SCROLL_HDMA_START - 1, Y

    LDA SCROLL_HDMA_START - 5, Y
    STA SCROLL_HDMA_START, Y

    LDA SCROLL_HDMA_START - 4, Y
    STA SCROLL_HDMA_START + 1, Y

    LDA SCROLL_HDMA_START - 3, Y
    STA SCROLL_HDMA_START + 2, Y

    INY
    INY
    INY
    LDA #01
    STA SCROLL_HDMA_START, Y
    
    INY 
    LDA #$00
    STA SCROLL_HDMA_START, Y  
    
    INY
    LDA #$01
    STA SCROLL_HDMA_START, Y

    LDA VOFS_LB ;  #$00
    CLC
    ADC #$08
    RTS

nohud:

  LDX curr_voff_low
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

  LDA curr_hoff_low
  STA SCROLL_HDMA_START + 1
  STA SCROLL_HDMA_START + 6
  STA SCROLL_HDMA_START + 11

  LDA HOFS_HB
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
  LDA #$00
  STA BG1VOFS
  LDA #$00
  STA BG1VOFS
  STZ BG1HOFS
  STZ BG1HOFS
  STZ SCROLL_HDMA_START
  STZ SCROLL_HDMA_START + 1
  STZ SCROLL_HDMA_START + 2
: RTL

setup_pause_overlay_hdma:
PHB
PHK
PLB

LDA #$7F
STA PAUSE_HDMA_START
STZ PAUSE_HDMA_START + 1
STZ PAUSE_HDMA_START + 2

LDA #$49
STA PAUSE_HDMA_START + 3
STZ PAUSE_HDMA_START + 4
STZ PAUSE_HDMA_START + 5

LDA #$08
STA PAUSE_HDMA_START + 6
LDY OPTIONS_MSU_PLAYLIST
LDA msu_option_offsets, Y
STA PAUSE_HDMA_START + 7
STZ PAUSE_HDMA_START + 8

LDA #$08
STA PAUSE_HDMA_START + 9
LDY OPTIONS_PALETTE
LDA palette_option_offsets, Y
STA PAUSE_HDMA_START + 10
STZ PAUSE_HDMA_START + 11

LDA #$08
STA PAUSE_HDMA_START + 12
STZ PAUSE_HDMA_START + 13
STZ PAUSE_HDMA_START + 14
STZ PAUSE_HDMA_START + 15


PLB
RTL

paused_hdma:
.byte $7F, $11, $49, $11, $01, $13, $00

not_paused_hdma_TM_11:
.byte $01, $11, $00 

not_paused_hdma_TM_00:
.byte $01, $00, $00


setup_tm_hdma:
  LDA $22 ; pause check, castlevania, for instance sets $22 to a non-0 value
  LDA #$00 ; skip this by default
  BEQ :+
    ; paused
    LDA #$7F
    STA TM_HDMA_START
    STA TMW_HDMA_START

    LDA #$11
    STA TM_HDMA_START + 1
    STZ TMW_HDMA_START + 1

    LDA #$41
    STA TM_HDMA_START + 2 
    STA TMW_HDMA_START + 2

    LDA #$11
    STA TM_HDMA_START + 3   
    STZ TMW_HDMA_START + 3

    LDA #$01
    STA TM_HDMA_START + 4 
    sta TMW_HDMA_START + 4

    LDA #$13
    STA TM_HDMA_START + 5
    LDA #%00010011
    STA TMW_HDMA_START + 5

    STZ TM_HDMA_START + 6
    STZ TMW_HDMA_START + 6
    rtl

  :

  STZ TM_HDMA_START
  LDA #$01
  STA TMW_HDMA_START
  STZ TMW_HDMA_START + 1
  STZ TMW_HDMA_START + 2

  rtl
  

msu_option_offsets:
.byte $37, $3F, $47, $4F, $57, $5F, $67

palette_option_offsets:
.byte $66, $6E, $76, $7E, $86, $8E, $96, $9E, $A6, $AE, $B6, $BE, $C6, $CE, $D6, $DE
