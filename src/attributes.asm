; values will be of the form
; VMADDL, VMADDH - upper left corner of attribute write
; 0x10 bytes of data in this order:
; 0 1 2 3
; 4 5 6 7
; 8 9 A B
; C D E F
ATTR_WORK_BYTE_0 = $D0
ATTR_WORK_BYTE_1 = ATTR_WORK_BYTE_0 + 1
ATTR_WORK_BYTE_2 = ATTR_WORK_BYTE_0 + 2
ATTR_WORK_BYTE_3 = ATTR_WORK_BYTE_0 + 3


; this needs to be 2 bytes on the ZP that ideally isn't used.
.define ZP_ADDR_USAGE $50
.a8
.i8

check_and_copy_attribute_buffer_l:
  jsr check_and_copy_attribute_buffer
  rtl

check_and_copy_attribute_buffer:

  LDA ATTRIBUTE_DMA
  BEQ :+
  JSR copy_prepped_attributes_to_vram
:
  RTS

copy_single_prepped_attribute:
  LDA ZP_ADDR_USAGE
  PHA
  LDA ZP_ADDR_USAGE + 1
  PHA

  LDA #$80
  STA VMAIN

  LDA ATTR_DMA_VMADDH
  STA VMADDH
  LDA ATTR_DMA_VMADDL
  STA VMADDL

  LDA ATTR_DMA_SRC_LB
  STA ZP_ADDR_USAGE
  LDA ATTR_DMA_SRC_HB
  STA ZP_ADDR_USAGE + 1

  LDX #$04
: LDY #$00
: LDA (ZP_ADDR_USAGE), y
  STA VMDATAH
  INY
  CPY #$04
  BNE :-

  LDA ZP_ADDR_USAGE
  CLC
  ADC #$20
  STA ZP_ADDR_USAGE

  LDA ATTR_DMA_VMADDL
  CLC
  ADC #$20
  STA ATTR_DMA_VMADDL
  BCC :+
  INC ATTR_DMA_VMADDH
  LDA ATTR_DMA_VMADDH
  CMP #$28
  BNE :+
      ; oob, we don't write this high, we're done.
      bra oob_exit
: LDA ATTR_DMA_VMADDH  
  STA VMADDH
  LDA ATTR_DMA_VMADDL
  STA VMADDL

  DEX  
  BNE :---
oob_exit:
  LDY #$0F
  LDA #$00
: STA ATTRIBUTE_DMA,Y
  DEY
  BPL :-

  jslb reset_vmain_to_stored_state, $a0

  PLA
  STA ZP_ADDR_USAGE + 1
  PLA
  STA ZP_ADDR_USAGE

  RTS

copy_prepped_attributes_to_vram:
  ; check for a single value
  LDA ATTR_DMA_SIZE_HB
  BNE :+
  LDA ATTR_DMA_SIZE_LB
  BNE :+
  RTS
: CMP #$10
  BNE :+
  JMP copy_single_prepped_attribute

: LDA #$80
  STA VMAIN
  STZ DMAP6
  LDA #$19
  STA BBAD6
  ; LDX #$00
  LDA #$7E
  STA A1B6
  LDA ATTR_DMA_SRC_HB ; ,X
  STA A1T6H
  LDA ATTR_DMA_SRC_LB ; ,X
  STA A1T6L
  LDA ATTR_DMA_SIZE_LB ;,X
  BEQ handle_full
  CMP #$80
  BMI handle_partials
  BRA handle_full
handle_partials:
  JSR copy_partial_prepped_attributes_to_vram
  BRA :+
handle_full: 
  STA DAS6L
  LDA ATTR_DMA_SIZE_HB
  STA DAS6H
  LDA ATTR_DMA_VMADDH
  STA VMADDH
  LDA ATTR_DMA_VMADDL
  STA VMADDL
  LDA #$40
  STA MDMAEN
: DEC ATTRIBUTE_DMA + 1
  LDA ATTRIBUTE_DMA + 1
  BPL :-
  LDY #$0F
  LDA #$00
: STA ATTRIBUTE_DMA,Y
  DEY
  BPL :-
  LDA #$FF
  STA ATTRIBUTE_DMA + 1
  LDA VMAIN_STATE
  STA VMAIN
  RTS

copy_partial_prepped_attributes_to_vram:

; these are the same for all of them

  LDA #$7E
  STA A1B6

partial_row_loop:
  LDA ATTR_DMA_SIZE_LB
  LSR
  LSR
  STA DAS6L
  LDA #$00
  STA DAS6H
  LDA ATTR_DMA_SRC_LB
  CLC
  ADC ATTR_PARTIAL_CURR_OFFSET
  BCC :+
  ; rollover, bump up HB
  INC ATTR_DMA_SRC_HB
: STA A1T6L
  
  LDA ATTR_DMA_SRC_HB
  STA A1T6H  

  LDA ATTR_DMA_VMADDL
  CLC
  ADC ATTR_PARTIAL_CURR_OFFSET 
  BCC :+
  INC ATTR_DMA_VMADDH
: STA VMADDL

  LDA ATTR_DMA_VMADDH
  STA VMADDH
  
  LDA #$40
  STA MDMAEN

  LDA ATTR_PARTIAL_CURR_OFFSET
  ADC #$20
  STA ATTR_PARTIAL_CURR_OFFSET
  CMP #$80
  BMI partial_row_loop
  STZ ATTR_PARTIAL_CURR_OFFSET
  RTS

disable_attribute_buffer_copy:
  STZ ATTR_NES_VM_ADDR_HB
  STZ ATTR_NES_HAS_VALUES
  ; STZ ATTR_DMA_SIZE_LB
  RTS


attr_lookup_table_1_inf_9450:
.byte $00, $04, $08, $0C, $10, $14, $18, $1C, $80, $84, $88, $8C, $90, $94, $98, $9C

inf_95AE:
.byte $EA, $A1 
inf_95B0:
.byte $00, $D0, $06, $A9, $FF, $8D, $F0, $17, $6B, $4C, $20, $97, $00, $00, $01, $01
attr_lookup_table_2_inf_95C0:
.byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $00
.byte $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0, $00
.byte $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0, $00

convert_nes_attributes_and_immediately_dma_them:
  PHB
  PHK
  PLB
  PHY
  PHA

  LDA ATTR_NES_HAS_VALUES
  BEQ :++

  lda ATTR_NES_VM_ADDR_HB
  CMP #$20
  BCC not_attributes

  lda ATTR_NES_VM_ADDR_LB
  AND #$C0
  CMP #$C0
  BNE not_attributes

  LDA ATTR_NES_VM_COUNT
  CMP #$01
  BNE :+
    jsr buffer_single_attribute
    STZ ATTR_NES_HAS_VALUES
    bra :++
  :     
    JSR check_and_copy_nes_attributes_to_buffer
    JSR check_and_copy_attribute_buffer
  :

  PLA
  PLY
  PLB
  rtl

not_attributes:
  LDY #$60
  LDA #$00

: DEY
  BMI :+
  STA ATTR_NES_HAS_VALUES, Y
  BRA :-
:
  PLA
  PLY
  PLB
  rtl


convert_attributes_l:
  PHB
  ; PHP
  jsr check_and_copy_nes_attributes_to_buffer
  ; PLP
  PLB
  rtl

; converts attributes stored at 9A0 - A07 to attribute cache
check_and_copy_nes_attributes_to_buffer:

  LDA ATTR_WORK_BYTE_0
  PHA
  LDA ATTR_WORK_BYTE_1
  PHA
  LDA ATTR_WORK_BYTE_2
  PHA
  LDA ATTR_WORK_BYTE_3 
  PHA


  LDA ATTR_NES_HAS_VALUES
  BEQ :++
    LDA ATTRIBUTE_DMA
    beq :+
      LDA #$80
      STA INIDISP      
      jsr copy_prepped_attributes_to_vram
      LDA INIDISP_CACHE
      STA INIDISP
      
    :
    LDA ATTR_NES_VM_COUNT
    TAX
    LDA #$00
    STA ATTR_NES_VM_ATTR_START, X
    jsr convert_attributes_inf
  :

  pla
  sta ATTR_WORK_BYTE_3
  pla
  sta ATTR_WORK_BYTE_2
  pla
  sta ATTR_WORK_BYTE_1
  pla 
  sta ATTR_WORK_BYTE_0

do_nothing:
  STZ ATTR_NES_HAS_VALUES 
  RTS
  
  
convert_attributes_inf:
  PHK
  PLB

  LDX #$00
  JSR disable_attribute_hdma

  LDA #<(ATTR_NES_VM_ADDR_HB) ; #$A1
  STA ATTR_WORK_BYTE_0
  LDA #>(ATTR_NES_VM_ADDR_HB) ; #$09
  STA ATTR_WORK_BYTE_1

  STZ ATTR_DMA_SRC_LB
  STZ ATTR_DMA_SRC_LB + 1
  LDA #>(ATTRIBUTE_CACHE) ; #$18

  STA ATTR_DMA_SRC_HB
  LDA #$1A
  STA ATTR_DMA_SRC_HB + 1

  LDY #$00  

inf_9497:
  LDA (ATTR_WORK_BYTE_0),Y ; $00.w is $09A1 to start
  ; early rtl  
  BEQ do_nothing

  AND #$03
  CMP #$03
  BEQ :+
  JMP inf_9700
: INY
  LDA (ATTR_WORK_BYTE_0),Y
  AND #$F0
  CMP #$C0
  BEQ :+
  CMP #$D0
  BEQ :+
  CMP #$E0
  BEQ :+
  CMP #$F0
  BEQ :+
  JMP inf_9700 + 1
: JSR inc_attribute_hdma_store_to_x

  LDA (ATTR_WORK_BYTE_0),Y
  PHY
  AND #$0F
  TAY
  LDA attr_lookup_table_1_inf_9450,Y
  PLY
  ; AND #$0F
  ; ASL A
  ; ASL a
  ; ASL a
  ; ASL A
  STA ATTR_DMA_VMADDL
  LDA (ATTR_WORK_BYTE_0),Y
  AND #$30
  LSR
  LSR
  LSR
  LSR
  ORA #$20
  XBA
  DEY
  LDA (ATTR_WORK_BYTE_0),Y
  CMP #$24
  BMI :+
  LDA #$00
  XBA
  INC
  INC
  INC
  INC
  STA ATTR_DMA_VMADDH,X
  BRA :++
: LDA #$00
  XBA
  STA ATTR_DMA_VMADDH,X
: INY
  INY
  LDA (ATTR_WORK_BYTE_0),Y
  AND #$0F
  ASL
  ASL
  ASL
  ASL
  ; PHX
  ; TAX
  ; LDA attr_lookup_table_2_inf_95C0 + 15,X
  ; PLX  
  STA ATTR_DMA_SIZE_LB,X
  LDA (ATTR_WORK_BYTE_0),Y
  AND #$F0  
  CMP #$0F
  BPL :+
  LDA #$00
  BRA :++
: AND #$F0
  LSR
  LSR
  LSR
  LSR
  ; PHX
  ; TAX
  ; LDA inf_95AE,X
  ; PLX
: STA ATTR_DMA_SIZE_HB,X
  ; LDA #$80
  ; STA ATTR_DMA_SIZE_LB
  ; STZ ATTR_DMA_SIZE_HB
  LDA (ATTR_WORK_BYTE_0),Y
  STA ATTRIBUTE_DMA + 14
  STA ATTRIBUTE_DMA + 15
  LDA ATTRIBUTE_DMA + 2,X
  sta ATTR_WORK_BYTE_3
  LDA ATTRIBUTE_DMA + 4,X
  sta ATTR_WORK_BYTE_2
  INY
  INY
  TYX
  LDA #$A0
  sta ATTR_WORK_BYTE_0
  TYA
  CLC
  ADC ATTR_WORK_BYTE_0
  sta ATTR_WORK_BYTE_0
  BRA :+
inf_952D:  
  INC ATTR_WORK_BYTE_0
: JSR inf_9680
  NOP
  LDA (ATTR_WORK_BYTE_0,X)
  PHA
  AND #$03
  TAX
  LDA attr_lookup_table_1_inf_9450,X
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$20
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$02
  PLA
  PHA
  AND #$0C
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$22
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$40
  PLA
  PHA
  AND #$30
  LSR
  LSR
  LSR
  LSR
  TAX
  LDA attr_lookup_table_1_inf_9450,X
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$60
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$42
  PLA
  AND #$C0
  LSR
  LSR
  LSR
  LSR
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$62
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDA ATTR_WORK_BYTE_2
  CLC
  ADC #$04
  sta ATTR_WORK_BYTE_2
  CMP #$20
  BEQ :+
  CMP #$A0
  BNE :++
: CLC
  ADC #$60
  sta ATTR_WORK_BYTE_2
  BNE :+
  INC ATTR_WORK_BYTE_3
: DEC ATTRIBUTE_DMA + 14
  LDA ATTRIBUTE_DMA + 14
  BEQ :+
  JMP inf_952D
: JSR inf_9690
  NOP
  LDA (ATTR_WORK_BYTE_0,X)
  BNE inf_95b9

  STZ ATTR_NES_HAS_VALUES
  LDA #$FF
  STA ATTRIBUTE_DMA
  RTS

inf_95b9:
  ; i can't find this getting called, and 9720 looks non-sensical to me
  JMP inf_9720

inc_attribute_hdma_store_to_x:
  INC ATTRIBUTE_DMA + 1
  LDX ATTRIBUTE_DMA + 1
  RTS


disable_attribute_hdma:
  LDA #$FF
  STA ATTRIBUTE_DMA + 1
  RTS

inf_9680:
  LDA ATTR_WORK_BYTE_0
  BNE :+
  INC ATTR_WORK_BYTE_1
: LDX #$00
  LDY #$00
  RTS


inf_9690:
  LDA #$FF
  STA ATTRIBUTE_DMA
  INC ATTR_WORK_BYTE_0
  LDX #$00
  RTS

inf_9700:
  INY
  INY
  LDA ATTR_WORK_BYTE_2
  PHA
  STY ATTR_WORK_BYTE_2
  LDA (ATTR_WORK_BYTE_0),Y
  AND #$3F
  CLC
  ADC ATTR_WORK_BYTE_2
  INC
  TAY
  PLA
  sta ATTR_WORK_BYTE_2
  JMP inf_9497

inf_9720:
  LDA ATTR_WORK_BYTE_2
  PHA
  STZ ATTR_WORK_BYTE_2
: LDA ATTR_WORK_BYTE_0
  CMP #$A1
  BEQ :+
  DEC ATTR_WORK_BYTE_0
  INC ATTR_WORK_BYTE_2
  BRA :-
: LDY ATTR_WORK_BYTE_2
  PLA
  sta ATTR_WORK_BYTE_2
  JMP inf_9497

; X should contain VMADDH
; Y should contain VMADDL
; A should contain VMDATAL
add_extra_vram_update:
  STY VRAM_UPDATE_ADDR_LB
  STX VRAM_UPDATE_ADDR_HB
  STA VRAM_UPDATE_DATA

  LDA EXTRA_VRAM_UPDATE
  ASL A
  ADC EXTRA_VRAM_UPDATE
  INC A
  TAY

  LDA VRAM_UPDATE_ADDR_LB
  STA EXTRA_VRAM_UPDATE, Y

  LDA VRAM_UPDATE_ADDR_HB
  STA EXTRA_VRAM_UPDATE + 1, Y

  LDA VRAM_UPDATE_DATA
  STA EXTRA_VRAM_UPDATE + 2, Y

  INC EXTRA_VRAM_UPDATE
  RTL

write_one_off_vrams:
  
  LDX EXTRA_VRAM_UPDATE
  BEQ :++
  LDY #$00
: LDA EXTRA_VRAM_UPDATE+1, Y
  STA VMADDL  
  INY

  LDA EXTRA_VRAM_UPDATE+1, Y
  STA VMADDH
  INY

  LDA EXTRA_VRAM_UPDATE+1, Y
  STA VMDATAL
  INY

  DEX
  BNE :-  

: STZ EXTRA_VRAM_UPDATE
  RTS


zero_all_attributes:
  LDA #$80
  STA VMAIN
  LDA #$08
  STA DMAP6
  LDA #$19
  STA BBAD6

  LDA #$A0
  STA A1B6

  LDA #>zero_all_attributes_values
  STA A1T6H

  LDA #<zero_all_attributes_values
  STA A1T6L

  STZ DAS6L
  LDA #$04
  STA DAS6H
  
  LDA #$20
  STA VMADDH
  STZ VMADDL

  LDA #$40
  STA MDMAEN

  LDA #$24
  STA VMADDH
  STZ VMADDL
  LDA #$04
  STA DAS6H
  
  LDA #$40
  STA MDMAEN

  LDA VMAIN_STATE
  STA VMAIN
  rtl

  zero_all_attributes_values:
  .byte $00, $00


; VRAMLB -
; VRAMHB -
; ATTR_VALUE -
; uses 4 work ram values ATT1-ATT4
; optimized for updating a single attribute value
write_single_attribute:

LDA #$80
STA VMAIN
lda ATTR_NES_VM_ADDR_LB
SEC
SBC #$C0
ASL
TAY

LDA starting_address_lookup+1, Y
PHA
LDA ATTR_NES_VM_ADDR_HB
CMP #$23
BEQ :+
  PLA
  CLC
  ADC #$04
  PHA
:
PLA

STA VMADDH
LDA starting_address_lookup, Y
STA VMADDL
PHA ; store starting lb for later

lda ATTR_NES_VM_ATTR_START
PHA
AND #$03
ASL
ASL
STA ATT1

PLA
PHA
AND #$0C
STA ATT2

PLA
PHA
AND #$30
LSR
LSR
STA ATT3

PLA
AND #$C0
LSR
LSR
LSR
LSR
STA ATT4

LDA ATT1
STA VMDATAH
STA VMDATAH

LDA ATT2
STA VMDATAH
STA VMDATAH

PLA
CLC
ADC #$20
PHA
STA VMADDL

LDA ATT1
STA VMDATAH
STA VMDATAH

LDA ATT2
STA VMDATAH
STA VMDATAH

PLA
CLC
ADC #$20
PHA
STA VMADDL

LDA ATT3
STA VMDATAH
STA VMDATAH

LDA ATT4
STA VMDATAH
STA VMDATAH

PLA
CLC
ADC #$20
STA VMADDL

LDA ATT3
STA VMDATAH
STA VMDATAH

LDA ATT4
STA VMDATAH
STA VMDATAH

LDA VMAIN_STATE
STA VMAIN

rtl



starting_address_lookup:
.word $2000
.word $2004
.word $2008
.word $200C
.word $2010
.word $2014
.word $2018
.word $201C
.word $2080
.word $2084
.word $2088
.word $208C
.word $2090
.word $2094
.word $2098
.word $209C
.word $2100
.word $2104
.word $2108
.word $210C
.word $2110
.word $2114
.word $2118
.word $211C
.word $2180
.word $2184
.word $2188
.word $218C
.word $2190
.word $2194
.word $2198
.word $219C
.word $2200
.word $2204
.word $2208
.word $220C
.word $2210
.word $2214
.word $2218
.word $221C
.word $2280
.word $2284
.word $2288
.word $228C
.word $2290
.word $2294
.word $2298
.word $229C
.word $2300
.word $2304
.word $2308
.word $230C
.word $2310
.word $2314
.word $2318
.word $231C
.word $2380
.word $2384
.word $2388
.word $238C
.word $2390
.word $2394
.word $2398
.word $239C

attribute_1_lookup:
.byte $00, $04, $08, $0C


buffer_single_attribute:

INC NUM_WRITES
LDY NEXT_WRITE_INDEX

lda ATTR_NES_VM_ADDR_LB
STA SINGLE_ATTRIBUTE_WRITES, Y
lda ATTR_NES_VM_ADDR_HB
STA SINGLE_ATTRIBUTE_WRITES+1, Y

lda ATTR_NES_VM_ATTR_START
PHA
AND #$03
ASL
ASL
STA SINGLE_ATTRIBUTE_WRITES + 2, Y

PLA
PHA
AND #$0C
STA SINGLE_ATTRIBUTE_WRITES + 3,Y

PLA
PHA
AND #$30
LSR
LSR
STA SINGLE_ATTRIBUTE_WRITES + 4, Y

PLA
AND #$C0
LSR
LSR
LSR
LSR
STA SINGLE_ATTRIBUTE_WRITES + 5, Y

TYA
CLC
ADC #$06
STA NEXT_WRITE_INDEX
BCC :+
  ; we wrapped around, we need to convert them nowsies
  jslb write_buffered_single_attributes, $a0
:
RTS

write_buffered_single_attributes:


LDA NUM_WRITES
BNE :+
  ; nothing to do
  RTL
:
PHB
PHK
PLB
LDA #$80
STA VMAIN
LDY #$0A ; first one is always at 10

next_single_write:
TYA
CLC
ADC #$06
TAY

LDA SINGLE_ATTRIBUTE_WRITES, Y ; LB
SEC
SBC #$C0
ASL

TAX
LDA starting_address_lookup+1, X
PHA


LDA SINGLE_ATTRIBUTE_WRITES + 1, Y ; HB
CMP #$23
BEQ :+
  PLA
  CLC
  ADC #$04
  PHA
:
PLA

STA VMADDH
LDA starting_address_lookup, X
STA VMADDL
PHA


LDA SINGLE_ATTRIBUTE_WRITES + 2, Y
STA VMDATAH
STA VMDATAH

LDA SINGLE_ATTRIBUTE_WRITES + 3, Y
STA VMDATAH
STA VMDATAH

PLA
CLC
ADC #$20
PHA
STA VMADDL

LDA SINGLE_ATTRIBUTE_WRITES + 2, Y
STA VMDATAH
STA VMDATAH

LDA SINGLE_ATTRIBUTE_WRITES + 3, Y
STA VMDATAH
STA VMDATAH

PLA
CLC
ADC #$20
PHA
STA VMADDL

LDA SINGLE_ATTRIBUTE_WRITES + 4, Y
STA VMDATAH
STA VMDATAH

LDA SINGLE_ATTRIBUTE_WRITES + 5, Y
STA VMDATAH
STA VMDATAH

PLA
CLC
ADC #$20
STA VMADDL

LDA SINGLE_ATTRIBUTE_WRITES + 4, Y
STA VMDATAH
STA VMDATAH

LDA SINGLE_ATTRIBUTE_WRITES + 5, Y
STA VMDATAH
STA VMDATAH

DEC NUM_WRITES
BEQ :+
  jmp next_single_write
:
LDA #$10
STA NEXT_WRITE_INDEX
STZ NUM_WRITES

LDA VMAIN_STATE
STA VMAIN

PLB
rtl
