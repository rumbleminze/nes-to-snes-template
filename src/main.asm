.p816
.smart

.include "macros.inc"
.include "registers.inc"
.include "vars.inc"
.include "2a03_variables.inc"
.include "2a03_emu_upload.asm"
.include "hiromheader.asm"

.segment "CODE"
.include "resetvector.asm"

.segment "EMPTY_SPACE"
; there's two versions of the 2a03 emulator.  one lifted from Totals' quad randomizer
; (which is itself lifted from project Nested) and an older one.  sometimes
; the older one sounds better and sometimes the newer one does, try em both!
; .include "2a03_emulator_first_8000.asm"
.include "2a03_emulator_first_8000_total.asm"
.include "2a03_emulator_second_8000.asm"

.include "bank-snes.asm"
; these would need to be created from the original ROM using 
; the /utilities/parseNesFileToBanks.go file
.include "bank0.asm"
.include "bank1.asm"
.include "bank2.asm"
.include "bank3.asm"
.include "bank4.asm"
.include "bank5.asm"
.include "bank6.asm"

; These are optional if the game uses CH ROM
; .include "chrom-tiles-0.asm"
; .include "chrom-tiles-1.asm"
; .include "chrom-tiles-2.asm"
; .include "chrom-tiles-3.asm"
; .include "chrom-tiles-4.asm"
; .include "chrom-tiles-5.asm"
; .include "chrom-tiles-6.asm"
; .include "chrom-tiles-7.asm"
; these are tiles I use for intro/menu screens
.include "chrom-basic-intro-tiles.asm"


.if ENABLE_MSU = 1
    .include "msu.asm"
    .include "chrom-tiles-msu-intro.asm"
    .include "msu_video_player.asm"
.endif
