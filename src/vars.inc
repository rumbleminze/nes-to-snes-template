; useful build modifications to build with or without things present in the rom
.define DEBUG_MOD 1
.define ENABLE_MSU 0

; game specific constants

; These values are almost always used by NES game, but the values will be different
; for each game.  They will almost always be in the zero page, or close to it.
HOFS_LB             = $FD   ; BG H Scroll position [x] updated
VOFS_LB             = $FC   ; BG V Scroll position [x] updated

PPU_CONTROL_STATE   = $FF   ; Current state of the PPU Control register [x] updated
PPU_MASK_STATE      = $FE   ;needs updating  ; Current state of the PPU Mask register

ACTIVE_NES_BANK     = $1C  ; Current bank loaded into the 8000-BFFF bank (for UNROM and MMC1)
PREV_NES_BANK       = $27

CURRENT_SPRITE_BANK = $D5
CURRENT_BG_BANK     = $D6

; NES RAM MAP Values
; game specific stuff can be tracked here
.define SPRITE_LOOP_JUNK    $A0 ; this is used during sprite conversion

.define FULL_ATTRIBUTE_COPY_SRC_LB      $AD
.define FULL_ATTRIBUTE_COPY_SRC_HB      $AE
.define FULL_ATTRIBUTE_COPY_HB          $AF

.define P1_SNES_BUTTONS                     $0801
.define P2_SNES_BUTTONS                     $0802
.define P1_SNES_BUTTONS_TRIGGER             $0803
.define P2_SNES_BUTTONS_TRIGGER             $0804
.define P1_SNES_BUTTONS_HELD                $0805
.define P2_SNES_BUTTONS_HELD                $0806
.define P1_NES_BUTTONS                      $0807
.define P1_NES_BUTTONS_TRIGGER              $0808
.define P1_NES_BUTTONS_HELD                 $0809
.define RUMBLE_P1                           $080A
.define RUMBLE_WAVE_FORM_PLAYING            $080B
.define RUMBLE_WAVE_FORM_IDX                $080C
.define RUMBLE_WAVE_FORM_CTR                $080D

; SNES Register Value storage
; since SNES Registers don't line up with NES registers 1:1
; we have to store the state of SNES registers separately
.define NMITIMEN_STATE                      $0826
.define VMAIN_STATE                         $0825
.define INIDISP_STATE                       $0824
.define TM_STATE                            $0827
.define INIDISP_CACHE                       $0828
.define NMITIMEN_CACHE                      $0829
.define IN_INTRO_SEQ                        $082A

.define VRAM_IS_PALETTE                     $083B
.define PALETTE_STARTING_OFFSET             $083C
.define PALETTE_FILTER                      $083D
.define PALETTE_HAS_BEEN_SET_TO_GREYSCALE   $083E
.define PALETTE_NEEDS_UPDATING              $083F
.define PALETTE_UPDATE_START                $0840

; 0870 - 087F are used for options
.define OPTIONS_START_ADDR                  $0870

; which options are stored at which address
; these should be updated for whatever options are implemented
; this is an example for Castlevania
OPTIONS_PALETTE         = OPTIONS_START_ADDR
OPTIONS_DIFFICULTY      = OPTIONS_START_ADDR + 1
OPTIONS_LOOP            = OPTIONS_START_ADDR + 2
OPTIONS_SUB_WEAPON_SWAP = OPTIONS_START_ADDR + 3
OPTIONS_MSU_SELECTED    = OPTIONS_START_ADDR + 4
OPTIONS_MSU_PLAYLIST    = OPTIONS_START_ADDR + 5
OPTIONS_DISABLE_RUMBLE  = OPTIONS_START_ADDR + 6
OPTIONS_CONTROLS        = OPTIONS_START_ADDR + 7


.define OBJ_CHR_BANK_SWITCH                 $0890
.define BG_CHR_BANK_SWITCH                  $0891
.define CHR_BANK_0_CURR                     $0892
.define CHR_BANK_1_CURR                     $0893
.define DATA_CHR_BANK_CURR                  $0894
.define TARGET_BANK_OFFSET                  $0895
.define OBJ_CHR_HB                          $0896
.define CHR_BANK_BANK_TO_LOAD               $0897
.define CHR_BANK_TARGET_BANK                $0898
.define CHR_BANK_NEXT_OBJ_BANK              $0899
.define CHR_BANK_READ_LB                    $089A
.define CHR_BANK_READ_HB                    $089B
.define CHR_BANK_READ_DB                    $089C
.define CURRENT_LVL_OBJ_LOAD                $089D
.define CHR_BANK_SEGMENT_LOAD               $089E

.define curr_ppu_ctrl_value                 $089F
.define curr_hoff_low                       $08A0
.define HOFS_HB                             $08A1
.define curr_voff_low                       $08A2
.define VOFS_HB                             $08A3
.define lines_left_to_handle                $08A4
.define current_voff_offset                 $08A5
.define PALETTE_ENTRY_CNT                   $08A6
.define PALETTE_OFFSET                      $08A7


.define REUSABLE_CALC_BYTE                  $08A8
.define LEVEL_SELECT_INDEX                  $08A9
.define CHEATS_ENABLED                      $08AA
.define APU_INITIALIZED                     $08AB
.define NEED_TO_CLEAR_8x16_SPRITES          $08AC
.define BANK_SWITCH_CTRL_REGS               $08AD
.define W12SEL_STATE                        $08AE
.define SCANLINE_FOR_IRQ                    $08AF
.define LAST_SFX                            $08B0

; HDMA for scrolling normally handled by IRQ
.define IRQ_SCROLL_HDMA_START               $08E0
.define SCROLL_HDMA_LINE_TO_START_OFFSET    $08E1
.define SCROLL_HDMA_LINES_HANDLED           $08E2
.define SCROLL_HDMA_NEXT_TO_HANDLE          $08E3  ; 0 = handle Attr next, 1 = handle irq next

.define CHR_BANK_LOADED_TABLE               $08F0

; HDMA for Scrolling, needs ~0x20 bytes
.define SCROLL_HDMA_START                   $0900 ; - 091F
.define SCROLL_HDMA_SAVED                   $0920 ; - 093F

.define FULL_ATTRIBUTE_QUARTER_COUNTER      $0940
.define FAQ_OFFSET                          $0941
.define ATTR_NES_SIZE                       $0942
.define ATTR_NES_CURR_CALC_OFFSET           $0943
.define ATTR_PARTIAL_CURR_OFFSET            $0944

; 940 -947 - which enemy is on which sprite table
; these aren't used on CV2, but are left here for compatibility with other engines
.define CURRENT_ENEMY_TILE_OFFSET           $094B ; either $80 or $00, controls the HB of the tile
.define CURRENT_SPRITE_TABLE_OFFSET         $094C ; either $00 or $01, $00 if we're the first table, $01 if we're the 2nd
.define ENEMY_TO_LOAD                       $094D
.define CURRENT_ENEMY_SLOT                  $094E
.define ACTIVE_SPRITE_SECOND_BANK_SLOT      $094F

.define TILE_CHUNK_COUNT                    $0950
.define TILE_DEST_LB_SETS                   $0951
.define TILE_DEST_HB                        $0952
.define TILE_SRC_LB_BANK                    $0953
.define TILE_SRC_HB                         $0954
.define TILE_WORK_SIZE_LB                   $0955
.define TILE_WORK_SIZE_HB                   $0956

.define BANK_SWITCH_LB                      $0960
.define BANK_SWITCH_HB                      $0961
.define BANK_SWITCH_DB                      $0962

.define BANK_SWITCH_X                       $0963
.define BANK_SWITCH_Y                       $0964
.define BANK_SWITCH_A                       $0965

.define STACK_RETURN_LB                     $0966
.define STACK_RETURN_HB                     $0967
.define STACK_RETURN_DB                     $0968

.define RESET_VECTOR_BS_LB                  $096A
.define RESET_VECTOR_BS_HB                  $096B
.define RESET_VECTOR_BS_DB                  $096C

.define VRAM_UPDATE_ADDR_LB                 $0970
.define VRAM_UPDATE_ADDR_HB                 $0971
.define VRAM_UPDATE_DATA                    $0972
.define EXTRA_VRAM_UPDATE                   $0980
.define STACK_TEMP_STORAGE                  $0981

.define ATTR_NES_HAS_VALUES                 $09A0
.define ATTR_NES_VM_ADDR_HB                 $09A1
.define ATTR_NES_VM_ADDR_LB                 $09A2
.define ATTR_NES_VM_COUNT                   $09A3
.define ATTR_NES_VM_ATTR_START              $09a4

; used if we need HDMA during pause, or for TM or TMW
.define PAUSE_HDMA_START                    $0A40
.define TM_HDMA_START                       $0A50
.define TMW_HDMA_START                      $0A60


.define SNES_OAM_START                      $1000 ; - $10FF
SNES_OAM_SECOND_BLOCK = SNES_OAM_START + $100     ; - $11FF


; MSU Variables 1220 - 129F
; 1220 - 123f - 0x20 track availability (does .pcm file exist on game start)
; 1240 - 125f - 0x20 track enabled (do we want to use it)
; 1260 - 126f - various msu variabes
; 127f - 129f - currently unused
.define TRACKS_AVAILABLE                    $1220     ; Is MSU track present
.define TRACKS_ENABLED                      $1240       ; Is MSU track enabled

; timers aren't used in this game, so we can reuse these
.DEFINE MSU_MUTE_TIMER                      $1262
.DEFINE MSU_TEMP_MUTED                      $1263
.DEFINE MSU_TIMER_INDX                      $1264
.DEFINE MSU_TIMER_ON                        $1265
.DEFINE MSU_TIMER_LB                        $1266
.DEFINE MSU_TIMER_HB                        $1267

; if timers are used we probably need to move these
.DEFINE MSU_SONG_PLAYING                    $1262
.DEFINE SPRITE_TRANSLATION_UNREADY          $1263
.DEFINE MSU_FADE_DELAY                      $1264
.DEFINE MSU_CURR_FADE_VOLUME                $1265
.DEFINE MSU_FADE_TO_TRACK                   $1266
.DEFINE MSU_FADE_IN_PROGRESS                $1267

.DEFINE MSU_CURR_CTRL                       $1268
.DEFINE MSU_CURR_VOLUME                     $1269
.DEFINE MSU_SELECTED                        $126A
.DEFINE MSU_TRIGGER                         $126B
.DEFINE MSU_PLAYING                         $126C
.DEFINE MSU_AVAILABLE                       $126D
.DEFINE MSU_TRACK_IDX                       $126E
.DEFINE CURRENT_NSF                         $126F

.DEFINE SNES_OAM_TRANSLATE_NEEDED           $12E0

.DEFINE ATTRIBUTE_DMA                       $12F0
.DEFINE ATTR_DMA_SRC_HB                     $12F2
.DEFINE ATTR_DMA_SRC_LB                     $12F4
.DEFINE ATTR_DMA_SIZE_LB                    $12F6
.DEFINE ATTR_DMA_SIZE_HB                    $12F8
.DEFINE ATTR_DMA_VMADDH                     $12FA
.DEFINE ATTR_DMA_VMADDL                     $12FC
.DEFINE ATTRIBUTE_CACHE                     $1300 ; - $14FF

.define NUM_WRITES                          $1700 ; how many 1-byte writes are pending writing
.define NEXT_WRITE_INDEX                    $1701
.define SINGLE_ATTRIBUTE_WRITES             $1700 ; note doesn't actually conflice because attribute writes will actually start at $1710

.define CURR_PALETTE_ADDR                   $17E0
.define ATT1                                $17E2
.define ATT2                                $17E3
.define ATT3                                $17E4
.define ATT4                                $17E5



OPTIONS_PALETTE_SAVE = $60A3