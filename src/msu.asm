.segment "PRGB2"

; Audio Tracks for <game>
; NES value - track

; Number of tracks.  We have to check if all the tracks are available for the game
; so that if a track isn't present we can fall back to NES audio 
.DEFINE NUM_TRACKS        $0A

; Read Flags
.DEFINE MSU_STATUS      $2000
.DEFINE MSU_READ        $2001
.DEFINE MSU_ID          $2002   ; 2002 - 2007

; Write flags
.DEFINE MSU_SEEK        $2000
.DEFINE MSU_TRACK       $2004   ; 2004 - 2005
.DEFINE MSU_VOLUME      $2006
.DEFINE MSU_CONTROL     $2007

; game specific flags, needs to be updated
.DEFINE NSF_STOP        #$00
.DEFINE NSF_PAUSE       #$FF ; 
.DEFINE NSF_RESUME      #$FF ; 
.DEFINE NSF_MUTE        #$00 ; this can be different per game.  It's the value that the game sends to mute audio.

.DEFINE FADE_RATE #$01 ; We sometimes want to kick off an MSU1 fade, this controls the rate the volume goes down

fade_if_needed:
  LDA MSU_FADE_IN_PROGRESS
  BEQ :++

    DEC MSU_FADE_DELAY
    BPL :+
      LDA FADE_RATE
      STA MSU_FADE_DELAY
      
      DEC MSU_CURR_VOLUME
    :
      LDA MSU_CURR_VOLUME
      STA MSU_VOLUME

    ; exit if we're not at 0
    BNE :+
    STZ MSU_FADE_IN_PROGRESS
    ; if we are at 0, then start the next track
    LDA MSU_FADE_TO_TRACK
    BEQ :+
    jslb play_track_hijack, $b2
    STZ MSU_FADE_TO_TRACK
  :
  RTS

queue_fade_to_next_track:
  PHA
  LDA MSU_SELECTED
  bne :+
    PLA
    rtl
  :
  PLA
  STA MSU_FADE_TO_TRACK
  LDA #$01
  STA MSU_FADE_IN_PROGRESS
  LDA #$00
  rtl


play_track_hijack:

    PHA
    jslb msu_check, $b2
    CMP NSF_MUTE
    BEQ mute_nintendo_audio
    ; non-0 value returned from MSU-check, we're not playing MSU
    ; either it's not a music track or we don't have it.
    ; return the original value
    PLA
    rtl

mute_nintendo_audio:   
;   00 returned from msu_check, mute nsf and return the mute value
    PLA ; eat the original value
    LDA NSF_MUTE
    rtl


wait_a_frame:
  LDA RDNMI
: LDA RDNMI
  BPL :-
  rts


check_for_all_tracks_present:
  PHB
  LDA #$B2
  PHA
  PLB
  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BEQ :+
  PLB
  RTL ; no MSU exit early

: STZ MSU_VOLUME
  LDY #NUM_TRACKS
  INY
: 
  jsr wait_a_frame
  STZ MSU_CONTROL

  DEY
  BMI :+
  
  LDA #$00
  STA TRACKS_AVAILABLE, Y
  STA TRACKS_ENABLED, Y

  TYA
  STA MSU_TRACK
  STZ MSU_TRACK + 1 

  msu_status_check:
    LDA MSU_STATUS
    AND #$40
    BNE msu_status_check

  LDA MSU_STATUS ; load track STAtus
  AND #$08		; isolate PCM track present byte
        		; is PCM track present after attempting to play using STA $2004?
  
  BNE :-
  LDA #$01
  STA TRACKS_AVAILABLE, Y  
  STA TRACKS_ENABLED, Y
  BRA :-
: 
  LDA #$01
  STA MSU_SELECTED
  PLB
  RTL

; Checks for MSU track for audio track in Accumulator
msu_check:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through


  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  
  ; check if we have a track for this value

  PLA
  PHA
      CMP NSF_PAUSE
      BEQ pause_msu

      CMP NSF_RESUME
      BEQ resume_msu
  TAY
  LDA msu_track_lookup, Y
  CMP #$FF
  BEQ fall_through
  
  TAY


  PLA
  CMP CURRENT_NSF
  BEQ already_playing
  STA CURRENT_NSF		; store current nsf track-id for later retrieval
  PHA

  TYA

  ; non-FF value means we have an MSU track
  BRA msu_available

stop_msu:
; is msu playing?  if not, just exit
    LDA MSU_PLAYING
    STZ CURRENT_NSF
    BEQ fall_through
    STZ MSU_CONTROL
    STZ MSU_CURR_CTRL    
    STZ MSU_PLAYING
    BRA fall_through

pause_msu:
    LDA MSU_PLAYING
    BEQ fall_through
    STZ MSU_CONTROL
    STZ MSU_CURR_CTRL
    BRA fall_through

resume_msu:
    LDA MSU_PLAYING
    BEQ fall_through
    LDA MSU_TRACK_IDX
    TAY
    LDA msu_track_loops, Y
    STA MSU_CONTROL
    STA MSU_CURR_CTRL

  ; fall through to default
fall_through:
  PLA
  PLX
  PLY
  PLB
  RTL

already_playing:
  PLX
  PLY
  PLB
  LDA NSF_MUTE ; set nsf music to mute since we are playing msu  
  rtl

pause_msu_only:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through


  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  BRA pause_msu


resume_msu_only:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through

  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  BRA resume_msu

stop_msu_only:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through

  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  BRA stop_msu

  ; if msu is present, process msu routine
msu_available:
  TAY
  PLA
  PHY                   ; push the MSU-1 track 
  PHA                   ; repush the NSF track

  LDA #$00		        ; clear disable/enable nsf music flag
  STA MSU_PLAYING		; clear disable/enable nsf music flag

  PLA
  STA CURRENT_NSF		; store current nsf track-id for later retrieval

  LDA #$01
  STA MSU_TRIGGER
  LDA #$02          ; use #$02 for convience so we can ORA with it for "song playing" in DD2 sound engine		       
  STA MSU_PLAYING		; set mute NSF flag (writing 02 in RAM location)

  pla

  STA MSU_TRACK_IDX		; store current re-mapped nsf track-id for later retrieval
  LDA OPTIONS_MSU_PLAYLIST
  ASL
  ASL
  ASL
  ASL
  ORA MSU_TRACK_IDX
  STA MSU_TRACK		    ; store current valid NSF track-ID
  stz MSU_TRACK + 1	    ; must zero out high byte or current msu-1 track will not play !!!

  ; jsl msu_nmi_check
  PLX
  PLY
  PLB
  LDA NSF_MUTE ; set nsf music to mute since we are playing msu  

  RTL

:
  LDA MSU_CURR_VOLUME
  STA MSU_VOLUME
  RTL

; ran at nmi to see if we should play MSU1
msu_nmi_check:

  ; some tracks need to transition based on a timer
  ; this routine will decrement the timer if needed
  ; no need to enable it unless you've set up timers for the tracks
  ; jsr decrement_timer_if_needed
  jsr fade_if_needed
  jsr check_msu_pause
  
  LDA MSU_TRIGGER
  BEQ :-
  LDA MSU_STATUS
  AND #$40
  BNE :-
  LDA MSU_STATUS

  PHB
  PHK
  PLB
  STZ MSU_TRIGGER

  LDA MSU_TRACK_IDX ; pull the current MSU-1 Track
  TAY
  LDA msu_track_loops, Y
  STA MSU_CONTROL		; write current loop value
  STA MSU_CURR_CTRL

  ; we're balancing all the tracks outside of the hack
  ; but if we wanted to do tracks individually we'd need to
  ; populate the msu_track_volume below
  ; LDA msu_track_volume, Y
  LDA #$5F

  STA MSU_VOLUME		; write max volume value
  STA MSU_CURR_VOLUME
  
  ; disable any fade that _might_ be happening
  STZ MSU_FADE_IN_PROGRESS
  STZ MSU_CURR_FADE_VOLUME
  STZ MSU_FADE_DELAY

  ; if tracks require timers to be set
  ; this needs to be uncommented and configured to "do the right thing"
  ; jsr set_timer_if_needed

  PLB
  RTL


check_if_msu_is_available:
  STZ MSU_AVAILABLE
  LDA MSU_ID
  CMP #$53
  BNE :+
    LDA #$01
    STA MSU_AVAILABLE
  : 
  rtl

  
set_timer_if_needed:  
  PHB
  PHK
  PLB
  LDA $00
  PHA
  LDA $01
  PHA

  LDA MSU_TRACK_IDX
  ASL a
  TAY

  LDA track_timers, Y
  STA $00
  INY 
  LDA track_timers, y
  STA $01
  
  LDY #$00
  LDA ($00),Y
  INY
  ORA ($00),Y
  BEQ :+
    LDA ($00),Y
    STA MSU_TIMER_HB
    DEY
    LDA ($00),Y
    STA MSU_TIMER_LB
    STZ MSU_TIMER_INDX
    INC MSU_TIMER_ON
    
  :

  PLA
  STA $01
  PLA
  STA $00
  PLB
  rts

decrement_timer_if_needed:
  LDA MSU_TIMER_ON
  BEQ :+

  setAXY16
  DEC MSU_TIMER_LB
  setAXY8

  BNE :+

  PHB
  PHK
  PLB

  LDA $00
  PHA
  LDA $01
  PHA

  STZ MSU_TIMER_ON
  ; set whatever logic we need to trigger when a timer expired

 ; check for follow up timer
  INC MSU_TIMER_INDX
  ; LDA #$01
  ; STA $E0
  ; 

  LDA MSU_TRACK_IDX
  ASL
  TAY
  LDA track_timers, Y
  STA $00
  INY 
  LDA track_timers, y
  STA $01

  LDA MSU_TIMER_INDX
  ASL
  INC A
  TAY
  LDA ($00),Y
  beq :+

    STA MSU_TIMER_HB
    DEY
    LDA ($00),Y
    STA MSU_TIMER_LB
    INC MSU_TIMER_ON
  :
  
  PLA
  STA $01
  PLA
  STA $00
  PLB
  rts

; example extra pause routine
pause_msu_for_stopwatch:
  PHA
  LDA MSU_SELECTED
  BEQ :+
  
  LDA #$01
  STA MSU_TEMP_MUTED
  LDA #$A0
  STA MSU_MUTE_TIMER
: PLA
  rtl

check_msu_pause:
  LDA MSU_TEMP_MUTED
  BEQ :+
    jslb pause_msu_only, $b2
    DEC MSU_MUTE_TIMER
    BNE :+
    STZ MSU_TEMP_MUTED
    jslb resume_msu_only, $b2
  :
  RTS


; this 0x100 byte lookup table maps the NSF track to the MSU-1 track
; MSU Index - NES value - track
; 
; here's an example from CV 2
; 00 - 00 - unused, going to use 00 for menu
; x1 - 55 - Message of Darkness (In game start menu/file load) FDS
; x2 - 39 - The Silence of Daylight (Town, Day)
; x3 - 3D - Bloody Tears (Woods, Day)
; x4 - 41 - Monster Dance (Woods &  Town, Night)
; x5 - 45 - Dwelling of Doom (Mansion)
; x6 - 49 - Within These Castle Walls (Ruins of Castlevania)
; x7 - 4D - Last Boss (Battle with Dracula)
; x8 - 59 - A Requiem (Ending)
; x9 - 51 - Game Over
; xA - F0 - Used for intro cinematic - no NSF equivalent
; 80 - MSU select screen
; 81 - Batty's title
; 82 - Rumble's title if I add one

; other soundtracks are 0x[12345]_
msu_track_lookup:
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $02, $FF, $FF, $FF, $03, $FF, $FF
.byte $FF, $04, $FF, $FF, $FF, $05, $FF, $FF, $FF, $06, $FF, $FF, $FF, $07, $FF, $FF
.byte $FF, $09, $FF, $FF, $FF, $01, $FF, $FF, $FF, $08, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $0A, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; this 0x100 byte lookup table maps the NSF track to the if it loops ($03) or no ($01)
msu_track_loops:
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00
.byte $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $01, $00, $00, $00, $00, $00

; this 0x100 byte lookup table maps the NSF track to the MSU-1 volume ($FF is max, $4F is half)
msu_track_volume:
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


; some example timer options
msu_track_e0_delay_options:
.word $0100, $068B, $0f4a

track_timers:
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 

.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 

.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 

.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 


no_timer:
.word $0000               ; 
death_jingle:
.word $0061, $0000        ; death jingld
game_over_timer:
.word $0100, $0000
