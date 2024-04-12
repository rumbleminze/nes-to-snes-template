  .segment "msu_video_player_0000"

  PHP
  SEP #$20
  PHA
  LDA $4210
  PLA
  PLP
  RTL

  PHP
  SEP #$20
  PHA
  LDA $4211
  LDA #$01
  .byte $8D, $11, $00
  PLA
  PLP
  RTL

  SEP #$20
  STZ $4200
  JSR $005A
  JSR $0056
  JSR $005A
  JSR $005A
  JSR $005A
  JSR $005A
  JSR $013B
  nop
  nop
  nop
  LDA #$01
  STA $420D
  JSR $0071
  JSR $0069
  JSR $0106
  JSR $03E4
  SEP #$20
  JSR $0436
  CLI
  JSR $005A
  JSR $0472
  JMP $FF40
  STZ $420C
  RTS

: LDA $4212
  AND #$80
  BNE :-
: LDA $4212
  AND #$80
  BEQ :-
  RTS
  SEP #$20
  REP #$10
  STZ $2130
  RTS
  SEP #$20
  REP #$10
  LDX #$0000
  STX $2116
  LDA #$09
;   STA $0010
  .byte $8D, $10, $00
  LDX #$0228
  LDA #$C7
;   STX $000B
  .byte $8E, $0B, $00
;   STA $000A
  .byte $8D, $0A, $00
  LDX #$0000
;   STX $000E
  .byte $8E, $0E, $00
  LDA #$18
;   STA $000D
  .byte $8D, $0D, $00
  JSR $03BC
  LDX #$3F80
  STX $2116
  LDA #$01
;   STA $0010
  .byte $8D, $10, $00
  LDX #$026E
  LDA #$C7
;   STX $000B
  .byte $8E, $0B, $00
;   STA $000A
  .byte $8D, $0A, $00
  LDX #$0100
;   STX $000E
  .byte $8E, $0E, $00
  LDA #$18
;   STA $000D
  .byte $8D, $0D, $00
  JSR $03BC
  LDX #$7F80
  STX $2116
  LDA #$01
;   STA $0010
  .byte $8D, $10, $00
  LDX #$036E
  LDA #$C7
;   STX $000B
  .byte $8E, $0B, $00
;   STA $000A
  .byte $8D, $0A, $00
  LDX #$0020
;   STX $000E
  .byte $8E, $0E, $00
  LDA #$18
;   STA $000D
  .byte $8D, $0D, $00
  JSR $03BC
  LDX #$0000
  STX $2102
  LDA #$08
;   STA $0010
  .byte $8D, $10, $00
  LDX #$0228
  LDA #$C7
;   STX $000B
  .byte $8E, $0B, $00
;   STA $000A
  .byte $8D, $0A, $00
  LDX #$0220
;   STX $000E
  .byte $8E, $0E, $00
  LDA #$04
;   STA $000D
  .byte $8D, $0D, $00
  JSR $03BC
  RTS
  SEP #$20
  REP #$10
  LDA #$13
  STA $2105
  LDA #$3C
  STA $2107
  LDA #$00
  STA $210B
  LDA #$01
  STA $212C
  LDA #$01
  STA $212D
  LDA #$20
  STA $2125
  LDA #$10
  STA $2126
  LDA #$EF
  STA $2127
  LDA #$40
  STA $2130
  STZ $2121
  RTS
  SEP #$20
  REP #$10
  STZ $4200
  LDA #$FF
  STA $4201
  STZ $4202
  STZ $4203
  STZ $4204
  STZ $4205
  STZ $4206
  STZ $4207
  STZ $4208
  STZ $4209
  STZ $420A
  STZ $420D
  LDA #$8F
  STA $2100
  STZ $2101
  STZ $2102
  STZ $2103
  STZ $2105
  STZ $2106
  STZ $2107
  STZ $2108
  STZ $2109
  STZ $210A
  STZ $210B
  STZ $210C
  STZ $210D
  STZ $210D
  STZ $210E
  STZ $210E
  STZ $210F
  STZ $210F
  STZ $2110
  STZ $2110
  STZ $2111
  STZ $2111
  STZ $2112
  STZ $2112
  STZ $2113
  STZ $2113
  STZ $2114
  STZ $2114
  LDA #$80
  STA $2115
  STZ $2116
  STZ $2117
  STZ $211A
  STZ $211B
  LDA #$01
  STA $211B
  STZ $211C
  STZ $211C
  STZ $211D
  STZ $211D
  STZ $211E
  STA $211E
  STZ $211F
  STZ $211F
  STZ $2120
  STZ $2120
  STZ $2121
  STZ $2123
  STZ $2124
  STZ $2125
  STZ $2126
  STZ $2127
  STZ $2128
  STZ $2129
  STZ $212A
  STZ $212B
  STZ $212C
  STZ $212D
  STZ $212E
  STZ $212F
  STZ $2130
  STZ $2131
  LDA #$E0
  STA $2132
  STZ $2133
  RTS

.byte $00, $00, $28, $8F, $8F, $7F, $0F, $0F, $11, $0F, $0F, $01, $8F, $8F, $00, $38
.byte $00, $00, $97, $01, $10, $00, $01, $87, $01, $10, $00, $00, $87, $01, $10, $00
.byte $01, $77, $01, $10, $00, $00, $77, $01, $10, $00, $01, $67, $01, $10, $00, $00
.byte $67, $01, $10, $00, $01, $57, $01, $10, $00, $00, $17, $01, $00, $28, $BC, $7F
.byte $BC, $01, $BC, $01, $FC, $00, $00, $00, $00, $00, $02, $00, $04, $00, $06, $00
.byte $08, $00, $0A, $00, $0C, $00, $0E, $00, $20, $00, $22, $00, $24, $00, $26, $00
.byte $28, $00, $2A, $00, $00, $00, $00, $00, $2C, $00, $2E, $00, $40, $00, $42, $00
.byte $44, $00, $46, $00, $48, $00, $4A, $00, $4C, $00, $4E, $00, $60, $00, $62, $00
.byte $64, $00, $66, $00, $00, $00, $00, $00, $68, $00, $6A, $00, $6C, $00, $6E, $00
.byte $80, $00, $82, $00, $84, $00, $86, $00, $88, $00, $8A, $00, $8C, $00, $8E, $00
.byte $A0, $00, $A2, $00, $00, $00, $00, $00, $A4, $00, $A6, $00, $A8, $00, $AA, $00
.byte $AC, $00, $AE, $00, $C0, $00, $C2, $00, $C4, $00, $C6, $00, $C8, $00, $CA, $00
.byte $CC, $00, $CE, $00, $00, $00, $00, $00, $E0, $00, $E2, $00, $E4, $00, $E6, $00
.byte $E8, $00, $EA, $00, $EC, $00, $EE, $00, $00, $01, $02, $01, $04, $01, $06, $01
.byte $08, $01, $0A, $01, $00, $00, $00, $00, $0C, $01, $0E, $01, $20, $01, $22, $01
.byte $24, $01, $26, $01, $28, $01, $2A, $01, $2C, $01, $2E, $01, $40, $01, $42, $01
.byte $44, $01, $46, $01, $00, $00, $00, $00, $48, $01, $4A, $01, $4C, $01, $4E, $01
.byte $60, $01, $62, $01, $64, $01, $66, $01, $68, $01, $6A, $01, $6C, $01, $6E, $01
.byte $80, $01, $82, $01, $00, $00, $00, $00, $84, $01, $86, $01, $88, $01, $8A, $01
.byte $8C, $01, $8E, $01, $A0, $01, $A2, $01, $A4, $01, $A6, $01, $A8, $01, $AA, $01
.byte $AC, $01, $AE, $01, $00, $00, $00, $00, $C0, $01, $C2, $01, $C4, $01, $C6, $01
.byte $C8, $01, $CA, $01, $CC, $01, $CE, $01, $E0, $01, $E2, $01, $E4, $01, $E6, $01
.byte $E8, $01, $EA, $01, $00, $00, $00, $01, $00, $01, $29, $E8, $6C, $C4, $F2, $E8
.byte $20, $C4, $F3, $78, $20, $F3, $D0, $F3, $E8, $2C, $C4, $F2, $E8, $00, $C4, $F3
.byte $78, $00, $F3, $D0, $F3, $E8, $3C, $C4, $F2, $E8, $00, $C4, $F3, $78, $00, $F3
.byte $D0, $F3, $2F, $FE

  REP #$10
  SEP #$20
  LDA $10
  nop
  STA $4300
  LDA $0D
  nop
  STA $4301
  LDA $0A
  nop
  LDX $0B
  nop
  STX $4302
  STA $4304
  LDX $0E
  nop
  STX $4305
  LDA #$01
  STA $420B
  RTS
  SEP #$20
  REP #$10
  LDA #$00
  STA $4310
  LDA #$07
  STA $4311
  LDA #$C7
  LDY #$0265
  STY $4312
  STA $4314
  LDA #$03
  STA $4320
  LDA #$0D
  STA $4321
  LDA #$C7
  LDY #$0237
  STY $4322
  STA $4324
  LDA #$01
  STA $4330
  LDA #$FF
  STA $4331
  LDA #$C7
  LDY #$022A
  STY $4332
  STA $4334
  JSR $005A
  LDX #$00B9
  STX $4209
  LDA #$0E
  STA $420C
  RTS


  SEP #$20
  REP #$10
  LDX #$0000
  STX $2000
  STX $2002
: BIT $2000
  BMI :-
  LDA #$90
  STA $2006
  STX $2004
: BIT $2000
  BVS :-
  LDX #$0000
  STX $2116
  LDA #$04
;   STA $0009
  .byte $8D, $09, $00
  STA $210B
  LDX #$2001
  STX $4302
  STZ $4304
  LDA #$01
;   STA $0008
  .byte $8D, $08, $00
  RTS

  SEP #$20
  REP #$10
  STZ $00
  nop
  LDA $2001
;   STA $0006
  .byte $8D, $06, $00
  LDA $2001
;   STA $0007
  .byte $8D, $07, $00
  LDA $2001
;   STA $0004
  .byte $8D, $04, $00
;   STA $0001
  .byte $8D, $01, $00
  LDA $2001
;   STA $0002
  .byte $8D, $02, $00
  LDA $2001
;   STA $0003
  .byte $8D, $03, $00
  LDA #$01
;   STA $0005
  .byte $8D, $05, $00
  LDX $06
  nop
  DEX
  LDA #$21
  STA $4200
: LDA $11
  nop
  BEQ :-
  STZ $11
  nop
  LDA $00
  nop
  CMP #$02
  BPL :+
  LDA #$18
  STA $4301
  LDA #$09
  STA $4300
  LDY #$3F80
  STY $4305
  LDA #$01
  STA $420B
: INC $00
  nop
  LDA $00
  nop
  CMP $04
  nop
  BNE :--
  LDA $08
  nop
  BEQ :+
  LDA #$01
  STA $2007
  STZ $08
  nop
: LDA $05
  nop
  CMP $03
  nop
  BNE :+
  STZ $05
  nop
  LDA $02
  nop
  BRA :++
: LDA $01
  nop
  INC $05
  nop
: 
;  STA $0004
  .byte $8D, $04, $00
  STZ $00
  nop
  DEX
  BEQ :++
  JMP $0544
  LDA #$22
  STA $4301
  LDA #$08
  STA $4300
  LDY #$0200
  STY $4305
  LDA #$01
  STA $420B
  LDA $09
  nop
  BNE :+
  LDA #$04
  STA $210B
;   STA $0009
  .byte $8D, $09, $00
  LDY #$0000
  STY $2116
  JMP $04A8
: STZ $210B
  STZ $09
  nop
  LDY #$4000
  STY $2116
  JMP $04A8
: STZ $2007
  RTS

  PHX
  SEP #$30
  LDX #$01
  STX $4016
  DEX
  STX $4016
  LDX #$08
: LDA $4016
  LSR
  ROL $19
  LSR
  ROL $1D
  LDA $4017
  LSR
  ROL $1A
  LSR
  ROL $1E
  DEX
  BNE :-
  LDA $1D
  ORA $19
  STA $19
  LDA $1E
  ORA $1A
  STA $1A
  LDX #$01
: LDA $19,X
  TAY
  EOR $1B,X
  AND $19,X
  STA $19,X
  STY $1B,X
  DEX
  BPL :-
  LDX #$03
: LDA $19,X
  AND #$0C
  CMP #$0C
  BEQ :+
  LDA $19,X
  AND #$03
  CMP #$03
  BNE :++
: LDA $19,X
  AND #$F0
  STA $14,X
: DEX
  BPL :---
  LDA $19
  AND #$10
  BNE :+
  REP #$10
  PLX
  STZ $2121
  JMP $0506
: REP #$10
  PLX
  LDX #$0000
  STZ $2007
  RTS

  .segment "msu_video_player_fed0"
  ; fedo - when we're done with video
  .I8
  jsl disable_nmi_and_store
  LDY #$2F
.byte $A9, $00 
: 
  .byte $99, $30, $09 
  DEY
  BPL :-
  jmlb intro_done, $A0
  .SMART

.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00


; ff00
  SEI
  CLC
  XCE
  JML $C70019
  PHA
  SEP #$20
  LDA $4210
  LDA #$0E
 .byte $8D, $0C, $42, $68
  RTI

  PHA
  SEP #$20
  LDA #$01
;   STA $0011
  .byte $8D, $11, $00
  LDA $4211
  PLA
  RTI
  ; this might just be garbage
: WAI
  LDA $ABCDEF
  BRA :-

.byte $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

  LDA #$01
  STA $7F0002
  LDA #$80
  STA $4200
  STZ $320B
  STZ $420C
  LDA #$80
  STA $2100
  LDA #$FF
  STA $0400
  LDA #$21
  STA $2107
  LDA #$01
  STA $210B
  LDA #$01
  STA $2105
  STZ $2126
  LDA #$FF
  STA $2127
  SEP #$30
  LDY #$3F
  LDA #$00
: 
;   STA $0000,Y
  .byte $99, $00, $00
  DEY
  BPL :-
  LDA #$00
  STA $2133
  LDA #$01
  STA $7F0004
  LDA #$80
  STA $2103
  STZ $2000
  STZ $2001
  STZ $2002
  STZ $2003
  STZ $2004
  STZ $2005
  STZ $2006
  STZ $2007
  JMP $FED0

.byte $00, $00, $00, $00, $00, $00, $00, $4D, $52, $4D, $53, $55, $31, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $4D, $53, $55, $31, $20, $56, $49, $44, $45
.byte $4F, $20, $50, $4C, $41, $59, $45, $52, $20, $20, $20, $20, $31, $02, $06, $03
.byte $00, $33, $00, $FE, $2F, $01, $D0, $00, $00, $00, $00, $21, $FF, $21, $FF, $21
.byte $FF, $07, $FF, $00, $00, $14, $FF, $00, $00, $00, $00, $21, $FF, $00, $00, $21
.byte $FF, $21, $FF, $00, $FF, $21, $FF

