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
.include "2a03_emulator_first_8000.asm"
.include "2a03_emulator_second_8000.asm"

.include "bank-snes.asm"
; these would need to be uncommented
; .include "bank0.asm"
; .include "bank1.asm"
; .include "bank2.asm"
; .include "bank3.asm"
; .include "bank4.asm"
; .include "bank5.asm"
; .include "bank6.asm"

; .include "chrom-tiles-0.asm"
; .include "chrom-tiles-1.asm"
; .include "chrom-tiles-2.asm"
; .include "chrom-tiles-3.asm"
; .include "chrom-tiles-4.asm"
; .include "chrom-tiles-5.asm"
; .include "chrom-tiles-6.asm"
; .include "chrom-tiles-7.asm"
; .include "chrom-basic-intro-tiles.asm"


.if ENABLE_MSU = 1
    .include "msu.asm"
.endif
    .include "chrom-tiles-msu-intro.asm"
.if ENABLE_MSU = 1
    .include "msu_video_player.asm"
.endif
