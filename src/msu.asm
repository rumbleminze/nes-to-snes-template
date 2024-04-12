.segment "PRGB2"

; Audio Tracks for CnD
; 0x00 - Zone 0
; 0x01 - Zone B
; 0x02 - Zone D
; 0x03 - Zone G
; 0x04 - Zone J
; 0x05 - Zone A
; 0x06 - Zone F
; 0x07 - title
; 0x08 - Ending
; 0x09 - overworld
; 0x0A - Boss
; 0x0B - Game Over
; 0x0C - Bonus Stage
; 0x0D - Invincible
; 0x15 - Life Lost
; 0x23 - zone clear

; Read Flags
.DEFINE MSU_STATUS      $2000
.DEFINE MSU_READ        $2001
.DEFINE MSU_ID          $2002   ; 2002 - 2007

; Write flags
.DEFINE MSU_SEEK        $2000
.DEFINE MSU_TRACK       $2004   ; 2004 - 2005
.DEFINE MSU_VOLUME      $2006
.DEFINE MSU_CONTROL     $2007

.DEFINE CURRENT_NSF     $09FF
.DEFINE REMAPPED_NSF    $09FE
.DEFINE LOOP_VALUE      $09FD
.DEFINE MSU_ENABLE      $09FC
.DEFINE MSU_TRIGGER     $09FB

.DEFINE NSF_STOP        #$F2
.DEFINE NSF_PAUSE       #$F3
.DEFINE NSF_RESUME      #$F4

; Checks for MSU track for audio try in Accumulator
msu_check:
  PHB
  PHY
  PHX

  PHA  
  LDA #$B2
  PHA
  PLB
  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  

  ; check if we have a track for this value
  PLA
  CMP NSF_STOP
  BEQ stop_msu
  CMP NSF_PAUSE
  BEQ pause_msu
  CMP NSF_RESUME
  BEQ resume_msu

  TAY
  PHA
  LDA msu_track_lookup, Y
  CMP #$FF
  BEQ fall_through  

  ; non-FF value means we have an MSU track
  BRA msu_available

stop_msu:
; is msu playing?  if not, just exit
    PHA
    LDA MSU_ENABLE
    BEQ fall_through
    STZ MSU_CONTROL
    BRA fall_through

pause_msu:
    PHA
    LDA MSU_ENABLE
    BEQ fall_through
    STZ MSU_CONTROL
    BRA fall_through

resume_msu:
    PHA
    LDA MSU_ENABLE
    BEQ fall_through
    LDA REMAPPED_NSF
    TAY
    LDA msu_track_loops, Y
    STA MSU_CONTROL
    BRA fall_through

  ; fall through to default
fall_through:
  PLA
  PLX
  PLY
  PLB
  STX $00 ; native code
  LDX $DA ; native code
  STA $01
  LDA $DC,X

  RTL

  ; if msu is present, process msu routine
msu_available:
  TAY
  PLA
  PHY                   ; push the MSU-1 track 
  PHA                   ; repush the NSF track

  LDA #$00		        ; clear disable/enable nsf music flag
  STA MSU_ENABLE		; clear disable/enable nsf music flag

  PLA
  STA CURRENT_NSF		; store current nsf track-id for later retrieval

  LDA #$01
  STA MSU_TRIGGER
  LDA #$FF		       
  STA MSU_ENABLE		; set mute NSF flag (writing FF in RAM location)

  PLA                   ; pull the current MSU-1 Track
  STA REMAPPED_NSF		; store current re-mapped nsf track-id for later retrieval

  stz MSU_VOLUME		; drop volume to zero; reduce STAtic/noise during track changes in sd2snes
  STA MSU_TRACK		    ; store current valid NSF track-ID
  stz MSU_TRACK + 1	    ; must zero out high byte or current msu-1 track will not play !!!

  msu_status:		; check msu ready status (required for sd2snes hardware compatibility)
    bit MSU_STATUS
    bvs msu_status

  LDA MSU_STATUS ; load track STAtus
  AND #$08		; isolate PCM track present byte
        		; is PCM track present after attempting to play using STA $2004?
  BEQ play_msu
  LDA CURRENT_NSF
  PHA
  BRA fall_through ; track not available, fall back to NSF

play_msu:
  LDA CURRENT_NSF
  TAY
  LDA msu_track_loops, Y
  STA MSU_CONTROL		; write current loop value
  LDA msu_track_volume, Y
  STA MSU_VOLUME		; write max volume value
  ; STA MSU_ENABLE		; set mute NSF flag (writing FF in RAM location)
end_routine:
   LDA CURRENT_NSF		; restore original nsf track-id
  
    
  PLX
  PLY
  PLB

  STX $00 ; native code
  LDX $DA ; native code
  LDA #$f2
  STA $01
  LDA $DC,X
  
  RTL

; this 0x100 byte lookup table maps the NSF track to the MSU-1 track
msu_track_lookup:
; 0 - d are tracks, 15 is life lost, and 23 is zone clear, the rest are invalid
.byte $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $0F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $10, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; this 0x100 byte lookup table maps the NSF track to the if it loops ($03) or no ($00)
msu_track_loops:
; 0 - c all loop
.byte $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; this 0x100 byte lookup table maps the NSF track to the MSU-1 volume ($FF is max, $4F is half)
msu_track_volume:
; 0 - c all loop
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F