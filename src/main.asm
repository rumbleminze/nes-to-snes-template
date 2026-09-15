.p816
.smart


.include "macros.inc"
.include "registers.inc"
.include "vars.inc"
.include "2a03_variables.inc"

.include "wram_routines.asm"
.include "hiromheader.asm"  

.segment "CODE"
.include "resetvector.asm"

.segment "EMPTY_SPACE"
; .include "msu_select_popups.asm"
.include "hires_tiles.asm"

.include "bank-snes.asm"
; these would need to be created from the original ROM using 
; the /utilities/parseNesFileToBanks.go file
; .include "bank0.asm"
; .include "bank1.asm"
; .include "bank2.asm"
; .include "bank3.asm"
; .include "bank4.asm"
; .include "bank5.asm"
; .include "bank6.asm"

; if the game has CHROM we put the tiles here (usually)
.include "chrom_banks.asm"

; these are tiles I use for intro/menu screens
.include "chrom-basic-intro-tiles.asm"

.include "msu.asm"
.include "dpcm_audio.asm"
.include "new_title.asm"