; example rumble integration from Castlevania
send_rumble_l:
  jsr send_rumble
  RTL

send_rumble:
  LDA OPTIONS_DISABLE_RUMBLE
  BEQ :+
    ; rumble is off
    RTS
:
  PHX

  LDX #$01
  STX JOYSER0
  NOP
  NOP
  DEX
  STX JOYSER0
  NOP
  NOP

  LDY #$0F
: LDA JOYSER0
  DEY
  BPL :-

  LDX #$40

  STZ WRIO
  BIT JOYSER0
  STX WRIO
  BIT JOYSER0
  BIT JOYSER0
  BIT JOYSER0
  STZ WRIO
  BIT JOYSER0
  BIT JOYSER0
  STX WRIO
  BIT JOYSER0
  STZ WRIO
  BIT JOYSER0

  LDA RUMBLE_P1
  LSR
  STA WRIO
  BIT JOYSER0
  ROL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0

  LDA #$FF
  STA WRIO
  PLX
  rts


rumble_lookup_table:
.word $0000
.addr rumble_hit
.addr rumble_whip_right
.addr rumble_whip_left
.addr orb_pickup
.addr orb_stake
.addr jump_landing
.addr intro_castle
.addr lower_water
.addr tornado
.addr tornado_pickup
.addr ending_gravestone

play_rumble_wave_l:
  jsr play_rumble_wave
  rtl

play_rumble_wave:
    LDA RUMBLE_WAVE_FORM_PLAYING
    BEQ exit_rumble_wave

      PHB
      PHK
      PLB

      ASL
      TAY
      LDA $00
      PHA
      LDA $01
      PHA

      LDA rumble_lookup_table, Y
      STA $00
      LDA rumble_lookup_table + 1, Y
      STA $01

      LDY RUMBLE_WAVE_FORM_IDX  
      LDA ($00), Y
      STA RUMBLE_P1
      INY
      ORA ($00),Y
      BNE :+
            ; we're done with this rumble wave
            STZ RUMBLE_WAVE_FORM_PLAYING
            STZ RUMBLE_WAVE_FORM_IDX
            STZ RUMBLE_WAVE_FORM_CTR
            BRA :++
      :

      INC RUMBLE_WAVE_FORM_CTR
      LDA ($00), Y
      CMP RUMBLE_WAVE_FORM_CTR
      BNE :+
        STZ RUMBLE_WAVE_FORM_CTR
        ; next value in rumble wave
        INC RUMBLE_WAVE_FORM_IDX
        INC RUMBLE_WAVE_FORM_IDX
      :

      PLA
      STA $01
      PLA
      STA $00

      PLB
exit_rumble_wave:
    rts



  rumble_waves:
  rumble_hit:
  .byte $22, $10, $00, $00

  rumble_whip_right:
  .byte $20, $06, $11, $03, $01, $03, $02, $04, $00, $00

  rumble_whip_left:
  .byte $02, $06, $11, $03, $10, $03, $20, $04, $00, $00

  orb_pickup:
  .byte $66, $10, $AA, $40, $66, $10, $11, $20, $00, $00

  orb_stake:
  .byte $33, $10, $66, $40, $11, $10, $00, $00

  jump_landing:
  .byte $11, $02, $00, $00

  intro_castle:
  .byte $00, $FF, $00, $FF, $00, $3D, $44, $FF, $00, $00

  lower_water: ; ~122 frames
  .byte $11, 20, $33, 40, $55, 20, $11, 20, $00, $00

  tornado: ; 28 267 frames
  .byte $11, $FF, $11, $0B, $00, $00

  tornado_pickup: ; 2d 293 frames
  .byte $22, $FF, $22, $25, $00, $00

  ending_gravestone: ; 330 frames
  .byte $22, 110, $33, 110, $44, 110, $00, $00

check_for_rumble:
    PHA
    PHY
    PHB
    PHK
    PLB
    TAY
    LDA rumble_wave_lookup_table, Y
    BEQ :+
     STA RUMBLE_WAVE_FORM_PLAYING
    :
    PLB
    PLY
    PLA
    RTL

rumble_controller_l:
    jsr play_rumble_wave
    jsr send_rumble
    rtl

rumble_wave_lookup_table:
;       0    1    2   3    4    5    6    7    8    9    A    B    C    D    E    F
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 00-0F
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 10-1F
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 20-2F
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 30-3F
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 40-4F
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 50-5F
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 60-6F
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 70-7F

.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 80-8F
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 90-9F
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; A0-AF
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; B0-BF
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; C0-CF
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; D0-DF
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; E0-EF
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; F0-FF