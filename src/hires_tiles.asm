; holds tiles in unused rom space
; copied from D0 - DF banks.
; this is used in CV2 for MSU 1 selection, for the template we just use the Beagle Bank
; ORCHESTRAL_BANK = $D4
; NESFDSMIX_BANK  = $D5
; VRC6_BANK       = $D6
BEAGLE_BANK     = $D7
; BATTY_BANK      = $D8
; CVREBIRTH_BANK  = $D9
; CV2_2A03_BANK   = $DA
; CV2_FDS_BANK    = $DB
; PROGROCK_BANK   = $DC
; CV2_MSU1_BANK   = $DD
; MSX_SCC_BANK    = $DE
; MSU1_BG2_BANK   = $DF

; .segment "ORCHESTRAL_TILES"
; orchestral_tilemap: 
; .incbin "../resources/orchestral_map16.bin"
; orchestral_tiles:
; .incbin "../resources/orchestral.bin"

; .segment "NESFDSMIX_TILES"
; nesfdsmix_tilemap:
; .incbin "../resources/nesfdsmix_map16.bin"
; nesfdsmix_tiles:
; .incbin "../resources/nesfdsmix.bin"

; .segment "VRC6_TILES"
; vrc6_tilemap:
; .incbin "../resources/cv2vrc6_map16.bin"

; vrc6_tiles:
; .incbin "../resources/cv2vrc6.bin"

.segment "BEAGLE_TILES"
beagle_tilemap:
.incbin "./intro_tilemaps/beagleYay_112_map16.bin"


beagle_tiles:
.incbin "./intro_tilemaps/beagleYay_112.bin"
beagle_tiles_end:

; .segment "BATTY_TILES"
; batty_tilemap:
; .incbin "../resources/battycredit_map16.bin"


; batty_tiles:
; .incbin "../resources/battycredit.bin"
; batty_tiles_end:


; .segment "CVREBIRTH_TILES"
; cvrebirth_tilemap:
; .incbin "../resources/rebirth_map16.bin"

; cvrebirth_tiles:
; .incbin "../resources/rebirth.bin"
; cvrebirth_tiles_end:

; .segment "CV2_2A03_TILES"
; cv2_2a03_tilemap:
; .incbin "../resources/cv2-2a03_map16.bin"
; cv2_2a03_tiles:
; .incbin "../resources/cv2-2a03.bin"
; cv2_2a03_tiles_end:

; .segment "CV2_FDS_TILES"
; cv2fds_tilemap:
; .incbin "../resources/cv2fds_map16.bin"
; cv2fds_tiles:
; .incbin "../resources/cv2fds.bin"
; cv2fds_tiles_end:


; .segment "PROGROCK_TILES"
; progrock_tilemap:
; .incbin "../resources/progrock_map16.bin"
; progrock_tiles:
; .incbin "../resources/progrock.bin"
; progrock_tiles_end:


; .segment "CV2_MSU1_TILES"
; cv2_msu_tilemap:
; .incbin "../resources/cv2-msu_map16.bin"
; cv2_msu_tiles:
; .incbin "../resources/cv2-msu.bin"
; cv2_msu_tiles_end:

; .segment "MSXSCC_TILES"
; msxscc_tilemap:
; .incbin "../resources/msxscc_map16.bin"
; msxscc_tiles:
; .incbin "../resources/msxscc.bin"
; msxscc_tiles_end:

; .segment "MSU1_BG2_TILES"
; msu1_selection_bg_tilemap:
; .incbin "../resources/sc4-bg_map16.bin"
; msu1_selection_bg_tiles:
; .incbin "../resources/sc4-bg.bin"
; msu1_selection_bg_tiles_end: