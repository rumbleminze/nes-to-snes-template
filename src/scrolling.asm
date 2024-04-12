reset_to_stored_screen_offsets:
  LDA STORED_OFFSETS_SET
  BEQ :+
  LDA UNPAUSE_BG1_HOFS_LB
  STA HOFS_LB
  LDA UNPAUSE_BG1_HOFS_HB
  STA HOFS_HB
  LDA UNPAUSE_BG1_VOFS_LB
  STA VOFS_LB
  LDA UNPAUSE_BG1_VOFS_HB
  ; STA VOFS_HB

  STZ STORED_OFFSETS_SET
: RTL

no_scroll_screen_enable:
  LDA HOFS_LB
  STA UNPAUSE_BG1_HOFS_LB
  LDA HOFS_HB
  STA UNPAUSE_BG1_HOFS_HB
  LDA VOFS_LB
  STA UNPAUSE_BG1_VOFS_LB
  LDA VOFS_HB
  STA UNPAUSE_BG1_VOFS_HB

  STZ HOFS_LB 
  STZ HOFS_HB 
  STZ VOFS_LB
  STZ VOFS_HB
  INC STORED_OFFSETS_SET
   
  lda PPU_CONTROL_STATE
  AND #$FC                 
  STA PPU_CONTROL_STATE
  RTL 

update_screen_scroll:
  LDA BG_SCREEN_INDEX
  AND #$01
  BEQ :+
  LDA #$01
  STA HOFS_HB

: STA BG1HOFS
  LDA HOFS_LB
  STA BG1HOFS

  LDA BG_SCREEN_INDEX
  AND #$02
  BEQ :+
  LDA #$02
  STA VOFS_HB
: STA BG1VOFS
  LDA VOFS_LB
  STA BG1VOFS

  RTL

infidelitys_scroll_handling:
  LDA BG_SCREEN_INDEX
  AND #$01
  ORA PPU_CONTROL_STATE
  PHA 
  AND #$80
  BNE :+
  LDA #$01
  BRA :++
: LDA #$81
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
  LDX VOFS_LB
  LDA $A0A080,X
  STA $0900
  LDA $A0A170,X
  STA $0903
  LDA $A0A260,X
  STA $0905
  LDA $A0A350,X
  STA $0908
  LDA $A0A440,X
  STA $090A
  LDA $A0A520,X
  STA $090D

  LDA HOFS_LB
  STA $0901
  STA $0906
  STA $090B
  lda BG_SCREEN_INDEX
  and #$01
  ora PPU_CONTROL_STATE
  STA $0902
  STA $0907
  STA $090C
  lda BG_SCREEN_INDEX
  and #$01
  LDX PPU_CONTROL_STATE
  
  LDA $A0A610,X
  STA $0904
  STA $0909
  STA $090E
  ; STZ $090B
  STZ $090F

  RTL

scroll_rollover:
  LDA #$EF  
  STA $FD

  LDA $5C
  ORA #$80
  STA $5C

  ; we have to update PPU_STORE here because we use it almost immediately
  ; in the hdma routine
  JSR flip_bg1_bit

  RTL

title_screen_rollover:
  LDA #$00
  STA $14
  STA $15
  LDA $1A
  EOR #$01
  STA $1A
  LDA #$00
  STA $FD
  JSR flip_bg1_bit

  RTL

flip_bg1_bit:
  LDA BG_SCREEN_INDEX
  EOR #$02  
  STA BG_SCREEN_INDEX
  RTS


handle_horizontal_scroll_wrap:
  INC $1B

  LDA BG_SCREEN_INDEX
  EOR #$01
  STA BG_SCREEN_INDEX

  LDA $5C
  ORA #$80
  STA $5C

  RTL


; copy of 02:AC47
horizontal_attribute_scroll_handle:
  JSR nes_02_ada9_copy
  LDY #$00
  STZ COL_ATTR_VM_COUNT
  STZ COL_ATTR_LB_SET

: INC COL_ATTR_VM_COUNT
  TYA
  ASL A
  ASL A
  ASL A
  CLC
  ADC $00
  STA $03
  CLC
  ADC #$C0
  PHA
  LDA $1B
  EOR #$01
  AND #$01
  ASL A
  ASL A
  ORA #$23  
  PHA
  LDA COL_ATTR_LB_SET
  BNE :+
  PLA
  STA COL_ATTR_VM_HB
  PLA  
  STA COL_ATTR_VM_LB  
  INC COL_ATTR_LB_SET
  BRA :++
: PLA  
  PLA
: LDX $03
  LDA $03B0,X
  STA COL_ATTR_VM_START, Y
  INY
  CPY #$08
  BCC :---
  LDA #$00

  STA COL_ATTR_VM_START, Y
  INC COL_ATTR_HAS_VALUES
  ; would normall do this during screen but for now just do it in line
  JSR convert_column_of_tiles

  RTL

nes_02_ada9_copy:
  LDA #$00
  STA $00
  LDA $FE
  AND #$E0
  ASL A
  ROL $00
  ASL A
  ROL $00
  ASL A
  ROL $00
  RTS

credits_scroll_rollover:
  INC $1A
  LDA #$00
  STA $FD
  PHA
  JSR flip_bg1_bit
  PLA
  RTL