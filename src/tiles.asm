; This is used for bankswapping CHR Rom banks quickly by putting various banks
; at places in VRAM and changing where the BG tiles are loaded from
bankswap_table:
.byte .lobyte(chrom_bank_0_tileset_0),  .hibyte(chrom_bank_0_tileset_0), $A8
.byte .lobyte(chrom_bank_0_tileset_1),  .hibyte(chrom_bank_0_tileset_1), $A8
.byte .lobyte(chrom_bank_0_tileset_2),  .hibyte(chrom_bank_0_tileset_2), $A8
.byte .lobyte(chrom_bank_0_tileset_3),  .hibyte(chrom_bank_0_tileset_3), $A8

.byte .lobyte(chrom_bank_1_tileset_4),  .hibyte(chrom_bank_1_tileset_4), $A9
.byte .lobyte(chrom_bank_1_tileset_5),  .hibyte(chrom_bank_1_tileset_5), $A9
.byte .lobyte(chrom_bank_1_tileset_6),  .hibyte(chrom_bank_1_tileset_6), $A9
.byte .lobyte(chrom_bank_1_tileset_7),  .hibyte(chrom_bank_1_tileset_7), $A9

.byte .lobyte(chrom_bank_2_tileset_8),  .hibyte(chrom_bank_2_tileset_8), $AA
.byte .lobyte(chrom_bank_2_tileset_9),  .hibyte(chrom_bank_2_tileset_9), $AA
.byte .lobyte(chrom_bank_2_tileset_10), .hibyte(chrom_bank_2_tileset_10), $AA
.byte .lobyte(chrom_bank_2_tileset_11), .hibyte(chrom_bank_2_tileset_11), $AA
.byte .lobyte(chrom_bank_3_tileset_12), .hibyte(chrom_bank_3_tileset_12), $AB
.byte .lobyte(chrom_bank_3_tileset_13), .hibyte(chrom_bank_3_tileset_13), $AB
.byte .lobyte(chrom_bank_3_tileset_14), .hibyte(chrom_bank_3_tileset_14), $AB
.byte .lobyte(chrom_bank_3_tileset_15), .hibyte(chrom_bank_3_tileset_15), $AB
.byte .lobyte(chrom_bank_4_tileset_16), .hibyte(chrom_bank_4_tileset_16), $AC
.byte .lobyte(chrom_bank_4_tileset_17), .hibyte(chrom_bank_4_tileset_17), $AC
.byte .lobyte(chrom_bank_4_tileset_18), .hibyte(chrom_bank_4_tileset_18), $AC
.byte .lobyte(chrom_bank_4_tileset_19), .hibyte(chrom_bank_4_tileset_19), $AC
.byte .lobyte(chrom_bank_5_tileset_20), .hibyte(chrom_bank_5_tileset_20), $AD
.byte .lobyte(chrom_bank_5_tileset_21), .hibyte(chrom_bank_5_tileset_21), $AD
.byte .lobyte(chrom_bank_5_tileset_22), .hibyte(chrom_bank_5_tileset_22), $AD
.byte .lobyte(chrom_bank_5_tileset_23), .hibyte(chrom_bank_5_tileset_23), $AD
.byte .lobyte(chrom_bank_6_tileset_24), .hibyte(chrom_bank_6_tileset_24), $AE
.byte .lobyte(chrom_bank_6_tileset_25), .hibyte(chrom_bank_6_tileset_25), $AE
.byte .lobyte(chrom_bank_6_tileset_26), .hibyte(chrom_bank_6_tileset_26), $AE
.byte .lobyte(chrom_bank_6_tileset_27), .hibyte(chrom_bank_6_tileset_27), $AE
.byte .lobyte(chrom_bank_7_tileset_28), .hibyte(chrom_bank_7_tileset_28), $AF
.byte .lobyte(chrom_bank_7_tileset_29), .hibyte(chrom_bank_7_tileset_29), $AF
.byte .lobyte(chrom_bank_7_tileset_30), .hibyte(chrom_bank_7_tileset_30), $AF
.byte .lobyte(chrom_bank_7_tileset_31), .hibyte(chrom_bank_7_tileset_31), $AF

; bank #$20, my basic intro tiles
.byte <(basic_intro_tiles), >(basic_intro_tiles), $B0
; banks of msu tiles for the video
.if ENABLE_MSU = 1
  .byte <(msu_intro_tiles_0), >(msu_intro_tiles_0), $B1
  .byte <(msu_intro_tiles_1), >(msu_intro_tiles_1), $B1
  .byte <(msu_intro_tiles_2), >(msu_intro_tiles_2), $B1
  .byte <(msu_intro_tiles_3), >(msu_intro_tiles_3), $B1
.endif

 : RTL

check_for_chr_bankswap:

  LDA OBJ_CHR_BANK_SWITCH
  CMP #$FF
  BEQ :-
  CMP CHR_BANK_0_CURR
  BEQ :-

  LDA OBJ_CHR_BANK_SWITCH
  STA CHR_BANK_0_CURR
  ; LDA #$FF
  ; STA OBJ_CHR_BANK_SWITCH
  
  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA CHR_BANK_0_CURR
  ASL A
  ADC CHR_BANK_0_CURR
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

  CMP CHR_BANK_1_CURR
  BEQ :-


  rtl

load_secondary_map_banks:
  jslb load_15_to_6, $a0
  jslb load_17_to_7, $a0
  rtl

load_11_to_3:
  LDA #$11
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$03
  STA TARGET_BANK_OFFSET
  jmp bankswap_start

backswap_to_11:
  LDA #$43
  STA BG12NBA
  rtl


load_15_to_6:
  LDA #$15
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$06
  STA TARGET_BANK_OFFSET
  jmp bankswap_start

load_17_to_7:
  LDA #$17
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$07
  STA TARGET_BANK_OFFSET
  jmp bankswap_start

load_bank_18:
  LDA #$18
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$05
  STA TARGET_BANK_OFFSET
  jmp bankswap_start

load_bank_1c:
  LDA #$1C
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$04
  STA TARGET_BANK_OFFSET
  bra bankswap_start
load_bank_1c_low_sprites:
  LDA #$1C
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$06
  STA TARGET_BANK_OFFSET
  bra bankswap_start
load_bank_1d_high_sprites:
  LDA #$1D
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$07
  STA TARGET_BANK_OFFSET
  bra bankswap_start
bankswap_to_1c:
  LDA #$44
  STA BG12NBA
  rtl
bankswap_to_18:
  LDA #$45
  STA BG12NBA
: rtl
; bank 0 is not always the BG =(
; this swaps out more than sprites mid-load
; we we'll save several banks in VRAM of tiles
; bank #$18 is literally the only weird one
; we're going to store it in $4000
bankswap_chr_bank_0:
  CMP #$18
  BEQ bankswap_to_18
  CMP #$1C
  BEQ bankswap_to_1c
  CMP #$11
  BEQ backswap_to_11
  CMP #$14
  BNE :+
    PHA
    jslb load_secondary_map_banks, $a0
    PLA
  :
  XBA  
  LDA #$40
  STA BG12NBA
  XBA
  CMP CHR_BANK_0_CURR
  BEQ :--
  STA CHR_BANK_0_CURR
  STA CHR_BANK_BANK_TO_LOAD
  STZ TARGET_BANK_OFFSET
  STA BG_CHR_BANK_SWITCH
  LDA #$40
  STA BG12NBA
  bra bankswap_start

; bank 1 is always the Sprites
bankswap_chr_bank_1:
  CMP CHR_BANK_1_CURR
  BEQ :--
  STA CHR_BANK_1_CURR
  STA CHR_BANK_BANK_TO_LOAD

  LDA IN_INTRO_SEQ
  BEQ :+
    LDA #$07
    BRA :++
  : LDA #$01
  :

  ; STZ TARGET_BANK_OFFSET
  ; INC TARGET_BANK_OFFSET
  STA TARGET_BANK_OFFSET
  STA BG_CHR_BANK_SWITCH
  bra bankswap_start

bankswap_start:
  
  LDA NMITIMEN_CACHE
  AND #$7F
  STA NMITIMEN
  
  LDA INIDISP_CACHE
  ORA #$80
  STA INIDISP

  LDA RDNMI
: LDA RDNMI
  AND #$80
  BEQ :-

  ; LDA #$80
  ; STA INIDISP
  ; STZ TM
  
  ; LDA #$FF
  ; STA OBJ_CHR_BANK_SWITCH

  PHB
  PHK
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

  ; page 2 is at $1000, data bank will add 6000 to that
  LDA TARGET_BANK_OFFSET
  ASL
  ASL
  ASL
  ASL
  STA VMADDH
  STZ VMADDL
  STZ TARGET_BANK_OFFSET

  LDA #$02
  STA MDMAEN
  PLB
  LDA VMAIN_STATE
  STA VMAIN

  LDA INIDISP_CACHE
  STA INIDISP

  ; if fblank is on, don't wait for NMI
  AND #$80
  BNE :++
 
  LDA RDNMI
: LDA RDNMI
  BPL :-
  :
  LDA NMITIMEN_CACHE
  STA NMITIMEN

  RTL

bankswitch_bg_chr_data:
  PHB
  PHK
  PLB

  ; bgs are on 0000, 3000, 4000, 5000, 6000, 7000.
  LDY #$00
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
  LDA INIDISP_CACHE
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
  LDA INIDISP_CACHE
  STA INIDISP
  PLA
  TAY
  bra switch_to_y

switch_to_y:
  ; our target bank is loaded at #$y000
  ; so just update our obj definition to use that for sprites
  TYA
  LSR ; for updating obsel, we have to halve y.  
  BRK
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


