; This is used for bankswapping CHR Rom banks quickly by putting various banks
; at places in VRAM and changing where the BG tiles are loaded from
bankswap_table:
; bank #$20, my basic intro tiles
.byte <(basic_intro_tiles), >(basic_intro_tiles), $B0
; banks of msu tiles for the video
.if ENABLE_MSU = 1
  .byte <(msu_intro_tiles_0), >(msu_intro_tiles_0), $B1
  .byte <(msu_intro_tiles_1), >(msu_intro_tiles_1), $B1
  .byte <(msu_intro_tiles_2), >(msu_intro_tiles_2), $B1
  .byte <(msu_intro_tiles_3), >(msu_intro_tiles_3), $B1
.endif

; .byte .lobyte(chrom_bank_0_tileset_0),  .hibyte(chrom_bank_0_tileset_0), $A8
; .byte .lobyte(chrom_bank_0_tileset_1),  .hibyte(chrom_bank_0_tileset_1), $A8
; .byte .lobyte(chrom_bank_0_tileset_2),  .hibyte(chrom_bank_0_tileset_2), $A8
; .byte .lobyte(chrom_bank_0_tileset_3),  .hibyte(chrom_bank_0_tileset_3), $A8

; .byte .lobyte(chrom_bank_1_tileset_4),  .hibyte(chrom_bank_1_tileset_4), $A9
; .byte .lobyte(chrom_bank_1_tileset_5),  .hibyte(chrom_bank_1_tileset_5), $A9
; .byte .lobyte(chrom_bank_1_tileset_6),  .hibyte(chrom_bank_1_tileset_6), $A9
; .byte .lobyte(chrom_bank_1_tileset_7),  .hibyte(chrom_bank_1_tileset_7), $A9

; .byte .lobyte(chrom_bank_2_tileset_8),  .hibyte(chrom_bank_2_tileset_8), $AA
; .byte .lobyte(chrom_bank_2_tileset_9),  .hibyte(chrom_bank_2_tileset_9), $AA
; .byte .lobyte(chrom_bank_2_tileset_10), .hibyte(chrom_bank_2_tileset_10), $AA
; .byte .lobyte(chrom_bank_2_tileset_11), .hibyte(chrom_bank_2_tileset_11), $AA

; .byte .lobyte(chrom_bank_3_tileset_12), .hibyte(chrom_bank_3_tileset_12), $AB
; .byte .lobyte(chrom_bank_3_tileset_13), .hibyte(chrom_bank_3_tileset_13), $AB
; .byte .lobyte(chrom_bank_3_tileset_14), .hibyte(chrom_bank_3_tileset_14), $AB
; .byte .lobyte(chrom_bank_3_tileset_15), .hibyte(chrom_bank_3_tileset_15), $AB

; .byte .lobyte(chrom_bank_4_tileset_16), .hibyte(chrom_bank_4_tileset_16), $AC
; .byte .lobyte(chrom_bank_4_tileset_17), .hibyte(chrom_bank_4_tileset_17), $AC
; .byte .lobyte(chrom_bank_4_tileset_18), .hibyte(chrom_bank_4_tileset_18), $AC
; .byte .lobyte(chrom_bank_4_tileset_19), .hibyte(chrom_bank_4_tileset_19), $AC

; .byte .lobyte(chrom_bank_5_tileset_20), .hibyte(chrom_bank_5_tileset_20), $AD
; .byte .lobyte(chrom_bank_5_tileset_21), .hibyte(chrom_bank_5_tileset_21), $AD
; .byte .lobyte(chrom_bank_5_tileset_22), .hibyte(chrom_bank_5_tileset_22), $AD
; .byte .lobyte(chrom_bank_5_tileset_23), .hibyte(chrom_bank_5_tileset_23), $AD

; .byte .lobyte(chrom_bank_6_tileset_24), .hibyte(chrom_bank_6_tileset_24), $AE
; .byte .lobyte(chrom_bank_6_tileset_25), .hibyte(chrom_bank_6_tileset_25), $AE
; .byte .lobyte(chrom_bank_6_tileset_26), .hibyte(chrom_bank_6_tileset_26), $AE
; .byte .lobyte(chrom_bank_6_tileset_27), .hibyte(chrom_bank_6_tileset_27), $AE

; .byte .lobyte(chrom_bank_7_tileset_28), .hibyte(chrom_bank_7_tileset_28), $AF
; .byte .lobyte(chrom_bank_7_tileset_29), .hibyte(chrom_bank_7_tileset_29), $AF
; .byte .lobyte(chrom_bank_7_tileset_30), .hibyte(chrom_bank_7_tileset_30), $AF
; .byte .lobyte(chrom_bank_7_tileset_31), .hibyte(chrom_bank_7_tileset_31), $AF

; rewrite of E6CA - need to keep db set to wherever we came from
; track how many PPU bytes we've writen to the cache


; use $10/$11 to point to VM cache write
VM_CACHE_PTR = $10

write_vm_cache:
  ; assume VM addres is already set
  LDX #$00
  LDY #$08

:
  LDA VM_CACHE, Y
  STA VMDATAH
  LDA VM_CACHE, X
  STA VMDATAL

  INX
  INY

  CPY #$10
  BNE :-

  STZ VMDATAL
  STZ VMDATAL
  STZ VMDATAL
  STZ VMDATAL
  STZ VMDATAL
  STZ VMDATAL
  STZ VMDATAL
  STZ VMDATAL

  STZ VM_CACHE_PTR
  RTS

write_to_vm_cache:
  PHX
  PHY
  PHA

  LDY #$00
  STA (VM_CACHE_PTR), Y
  INC VM_CACHE_PTR

  LDA VM_CACHE_PTR
  CMP #$10
  BNE :+
    jsr write_vm_cache
  :

  PLA
  PLY
  PLX
  RTS

load_tileset_x:
  LDA VM_CACHE_PTR
  PHA
  LDA VM_CACHE_PTR + 1
  PHA

  LDA #<VM_CACHE
  STA VM_CACHE_PTR
  LDA #>VM_CACHE
  STA VM_CACHE_PTR + 1

  LDA $E6EE,X
  STA $00
  LDA $E6EF,X
  STA $01

  ; JMP $F09E
  JSR $E8C3
  STA $21
  STA $FC
  STA $FD
  LDA RDNMI

  ; get the starting VM Address
  LDY #$01
  LDA ($00),Y
  STA VMADDH ; PpuAddr_2006
  DEY
  LDA ($00),Y
  STA VMADDL ; PpuAddr_2006

  LDX #$00
  LDA #$02  
  JSR $EF37

nes_F0BE:
  LDY #$00
  LDA ($00),Y

  ; check for done
  CMP #$FF
  BEQ return_load_tileset_x

  CMP #$7F
  BEQ nes_F0FC
  
  ; not special control values (FF = done, 7F = ???)
  TAY
  BPL nes_F0EA

  AND #$7F
  STA $02
  LDY #$01

nes_F0D3:
  LDA ($00),Y
  jsr write_to_vm_cache ; STA PpuData_2007
  CPY $02
  BEQ nes_F0DF
  INY
  BNE nes_F0D3

nes_F0DF:
  LDA #$01
  CLC
  ADC $02

nes_F0E4:
  JSR $EF37
  JMP nes_F0BE

; positive values of rle
nes_F0EA:
  LDY #$01
  STA $02
  LDA ($00),Y
  LDY $02
: jsr write_to_vm_cache ; STA PpuData_2007
  DEY
  BNE :-
  LDA #$02
  BNE nes_F0E4

nes_F0FC:
  LDA #$01
  JSR $EF37
  JMP $F0A7
  JMP $E893

return_load_tileset_x:
  PLA
  STA VM_CACHE_PTR + 1
  PLA
  STA VM_CACHE_PTR
  
  RTL


: RTL
check_for_chr_bankswap:

  LDA OBJ_CHR_BANK_SWITCH
  CMP #$FF
  BEQ :-
  CMP CHR_BANK_CURR_P1
  BEQ :-

  LDA OBJ_CHR_BANK_SWITCH
  STA CHR_BANK_CURR_P1
  ; LDA #$FF
  ; STA OBJ_CHR_BANK_SWITCH
  
  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA CHR_BANK_CURR_P1
  ASL A
  ADC CHR_BANK_CURR_P1
  TAY

  LDA #$80
  STA VMAIN

  LDA #$01
  STA DMAP0

  LDA #$18
  STA BBAD0

  ; source LB
  LDA bankswap_table, Y
  STA A1T0L

  ; source HB
  INY
  LDA bankswap_table, y
  STA A1T0H

  ; source DB
  INY
  LDA bankswap_table, y
  STA A1B0

  ; 0x2000 bytes
  LDA #$20
  STA DAS0H
  STZ DAS0L

  ; page 1 is at $0000
  LDA #$00
  STZ VMADDH
  STZ VMADDL

  LDA #$01
  STA MDMAEN

  PLB

  LDA VMAIN_STATE
  STA VMAIN

: RTL


; we'll put the data at $7000 always
swap_data_bg_chr:
  LDA BG_CHR_BANK_SWITCH
  CMP DATA_CHR_BANK_CURR
  BEQ :-
  STA DATA_CHR_BANK_CURR
  LDA #$60
  STA TARGET_BANK_OFFSET
  JMP bankswap_start


check_for_bg_chr_bankswap:
  LDA BG_CHR_BANK_SWITCH
  CMP #$FF
  BEQ :-

;   CMP #$1A
;   BPL swap_data_bg_chr

  CMP BG_CHR_BANK_CURR
  BEQ :-

bankswap_start:
  LDA NMITIMEN_STATE
  AND #$7F
  STA NMITIMEN
  
  LDA INIDISP_STATE
  ORA #$80
  STA INIDISP

  ; LDA RDNMI
: LDA RDNMI
  AND #$80
  BEQ :-

  ; LDA #$80
  ; STA INIDISP
  ; STZ TM
  
  LDA BG_CHR_BANK_SWITCH
  STA BG_CHR_BANK_CURR
  ; LDA #$FF
  ; STA OBJ_CHR_BANK_SWITCH

  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA BG_CHR_BANK_CURR
  ASL A
  ADC BG_CHR_BANK_CURR
  TAY

  LDA #$80
  STA VMAIN

  LDA #$01
  STA DMAP1

  LDA #$18
  STA BBAD1

  ; source LB
  LDA bankswap_table, Y
  STA A1T1L

  ; source HB
  INY
  LDA bankswap_table, y
  STA A1T1H

  ; source DB
  INY
  LDA bankswap_table, y
  STA A1B1

  ; 0x2000 bytes
  LDA #$20
  STA DAS1H
  STZ DAS1L

  ; page 2 is at $1000, data bank will add 6000 to that
  LDA #$10
  ADC TARGET_BANK_OFFSET
  STA VMADDH
  STZ VMADDL
  STZ TARGET_BANK_OFFSET

  LDA #$02
  STA MDMAEN
  PLB
  LDA VMAIN_STATE
  STA VMAIN

  LDA INIDISP_STATE
  STA INIDISP

  LDA NMITIMEN_STATE
  STA NMITIMEN

  ; LDA #$11
  ; STA TM
  ; LDA INIDISP_STATE
  ; STA INIDISP

  RTL

bankswitch_bg_chr_data:
  PHB
  LDA #$A0
  PHA
  PLB

  ; bgs are on 1000, 3000, 5000, 7000.
  LDY #$01
: LDA CHR_BANK_LOADED_TABLE, y
  CMP CHR_BANK_BANK_TO_LOAD
  BEQ switch_bg_to_y
  CPY #$07
  BEQ new_bg_bank
  INY
  INY
  BRA :-
  RTL

new_bg_bank:

  LDA CHR_BANK_BANK_TO_LOAD
  
  CMP #$19
  BPL new_data_bank
  PLB
  RTL

switch_bg_to_y:
  TYA
  ORA #$10
  STA BG12NBA

  PLB
  RTL
new_data_bank:

  STZ CHR_BANK_TARGET_BANK
  INC CHR_BANK_TARGET_BANK
  jslb load_chr_table_to_vm, $a0

  PLB
  RTL

bankswitch_obj_chr_data:
  ; this is a hack that happens to work most of the time.
  PHB
  LDA #$A0
  PHA
  PLB

  LDY #$00
: LDA CHR_BANK_LOADED_TABLE, y
  CMP CHR_BANK_BANK_TO_LOAD
  BEQ switch_to_y
  CPY #$06
  BEQ new_obj_bank
  INY
  INY
  BRA :-

new_obj_bank:
  ; todo load the bank into 0000, 4000, or 6000
  LDA INIDISP_STATE
  ORA #$80
  STA INIDISP

  LDA CHR_BANK_BANK_TO_LOAD
  TAY
  LDA target_obj_banks, Y
  STA CHR_BANK_TARGET_BANK
  PHA
  jslb load_chr_table_to_vm, $a0

; sometimes there's additional logic.  for Super Dodgeball
; banks 0a - 19 always loaded with 17
;
; this is between 0A and 19, so we load 17 too
;   LDA #$17
;   STA CHR_BANK_BANK_TO_LOAD
;   LDA #$04
;   STA CHR_BANK_TARGET_BANK
;   jsl load_chr_table_to_vm

; : 
  LDA INIDISP_STATE
  STA INIDISP
  PLA
  TAY
  bra switch_to_y

switch_to_y:
  ; our target bank is loaded at #$y000
  ; so just update our obj definition to use that for sprites
  TYA
  LSR ; for updating obsel, we have to halve y.  
  STA OBSEL
  PLB
  RTL


load_chr_table_to_vm:
  LDA CHR_BANK_TARGET_BANK
  TAY
  LDA CHR_BANK_BANK_TO_LOAD
  STA CHR_BANK_LOADED_TABLE, Y
  
  JSR dma_chr_to_vm

  RTL

dma_chr_to_vm:
  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA CHR_BANK_BANK_TO_LOAD
  ASL A
  ADC CHR_BANK_BANK_TO_LOAD
  TAY

  LDA #$80
  STA VMAIN

  LDA #$01
  STA DMAP1

  LDA #$18
  STA BBAD1

  ; source LB
  LDA bankswap_table, Y
  STA A1T1L

  ; source HB
  INY
  LDA bankswap_table, y
  STA A1T1H

  ; source DB
  INY
  LDA bankswap_table, y
  STA A1B1

  ; 0x2000 bytes
  LDA #$20
  STA DAS1H
  STZ DAS1L

  ; 
  LDA CHR_BANK_TARGET_BANK
  ASL
  ASL
  ASL
  ASL
  STA VMADDH
  STZ VMADDL

  LDA #$02
  STA MDMAEN
  PLB
  LDA VMAIN_STATE
  STA VMAIN

  RTS

; todo update
; which bank we should swap the sprite into, 00 - 0A aren't sprites so we set it to 0
; we only use 00, 10, and 11 for sprite locations, which are 00, 04, and 06
; if they're all the same it'll not save any time when swapping banks.
target_obj_banks:
.byte $00 ; 00 - Sprites
.byte $00 ; 01 - Sprites
.byte $00 ; 02 - Sprites
.byte $00 ; 03 - Sprites
.byte $00 ; 04 - Sprites
.byte $00 ; 05 - Sprites
.byte $00 ; 06 - Sprites
.byte $00 ; 07 - Sprites
.byte $00 ; 08 - Sprites
.byte $00 ; 09 - Sprites
.byte $00 ; 0A - Sprites
.byte $00 ; 0B - Sprites
.byte $04 ; 0C - Sprites
.byte $06 ; 0D - Sprites / Letters
.byte $06 ; 0E - Sprites / Letters
.byte $06 ; 0F - Sprites / Letters
.byte $00 ; 10 - BG Tiles
.byte $00 ; 11 - BG Tiles
.byte $00 ; 12 - BG Tiles
.byte $00 ; 13 - BG Tiles
.byte $00 ; 14 - BG Tiles
.byte $00 ; 15 - BG Tiles
.byte $00 ; 16 - BG Tiles
.byte $00 ; 17 - BG Tiles
.byte $00 ; 18 - BG Tiles
.byte $00 ; 19 - BG Tiles
.byte $00 ; 1A - BG Tiles
.byte $00 ; 1B - BG Tiles
.byte $00 ; 1C - BG Tiles
.byte $00 ; 1D - BG Tiles
.byte $00 ; 1E - BG Tiles
.byte $00 ; 1F - BG Tiles
.byte $00 ; 20 - intro bg tiles
.byte $00 ; 21 - fancy intro tiles
.byte $00 ; 22 - more fancy intro tiles


