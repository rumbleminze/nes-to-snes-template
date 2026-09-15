; this is an example fancy MSU1 selection screen.
; it's likely not going to be used for anything
; but it's here if I decide to do more fancy selections

CURRENT_SOUNDTRACK = $00
HOFFS_VALUE = $01
CONFIRM = $0F
SAVED_SOUNDTRACK = $60A2 ; random SRAM that isn't used by save games

.define NUM_SOUNDTRACKS 9
show_msu1_selection:
    ; first things first, check if MSU1 is available
    jslb check_if_msu_is_available, $b2

    LDA MSU_AVAILABLE
    BNE :+
        ; no msu1
        RTL
:

    ; MSU1 selection uses mode 3
    ; with two horizontal tilemaps on bg 2
        PHB
        PHK
        PLB
        
        LDA SAVED_SOUNDTRACK
        CMP #NUM_SOUNDTRACKS
        BCC :+
            LDA #$00
        :
        STA CURRENT_SOUNDTRACK
        ; wait for NMI
        
        jsr wait_for_nmi

        LDA #128
        STA MSU_TRACK
        STZ MSU_TRACK + 1

       ; wait for NMI
        
        jsr wait_for_nmi
        LDA MSU_AVAILABLE
        BEQ :+
            LDA #$03
                STA MSU_CONTROL
                LDA #$AF
                STA MSU_VOLUME
        :

        jsr wait_for_nmi
        ; start our music
        LDA #$03
        STA MSU_CONTROL
        LDA #$AF
        STA MSU_VOLUME

        LDA #$8F
        STA INIDISP
        jsr wipe_all_tiles

        LDA #%01000010
        STA OBSEL
        jsr load_popup_sprites

        LDA #$f9
        STA BG1SC

        LDA #$03
        STA BGMODE

        ; STZ CURRENT_SOUNDTRACK

        ; set up BG 2 if we use it here
        jsr setup_bg2

        LDA #$50
        STA BG12NBA

   
    LDA #$F0
    STA BG1VOFS
    STZ BG1VOFS
        ; all done
        LDA #$E0
        STA BG1HOFS
        STA HOFFS_VALUE
        LDA #$01
        STA BG1HOFS
        jsr load_soundtrack_cover

        
LDA #$0F
STA INIDISP

wait_for_input:
        ; wait for input
        jsr wait_for_nmi

        ; need to kill some time here for auto-joypad
        LDX #$05
        LDY #$00
    :   DEY
        BNE :-
        DEX 
        BNE :-
        
        jsr read_auto_joypad1
        ; <-- or --> increment / decrement soundtrack, go to load
        
        LDA P1_NES_BUTTONS_TRIGGER
        AND #$03
        BEQ :+
            jsr change_soundtrack_selection
            ; load the current soundtrack image
        :

        LDA P1_NES_BUTTONS_TRIGGER
        AND #$10
        BEQ :+
        ; start again confirm
            LDA CONFIRM
            BNE exit_msu1_selection
            
            ; show confirm
            LDA #$01
            STA CONFIRM
            LDA #$13           
            STA TM   
            BRA wait_for_input     
        :
        LDA P1_NES_BUTTONS_TRIGGER
        AND #$40
        BEQ wait_for_input

        LDA CONFIRM
        BEQ wait_for_input

        ; b - hide text box if open
        LDA #$03
        STA TM
        STZ CONFIRM

        BRA wait_for_input
exit_msu1_selection:        
        STZ $1200 ; sets sprites back to 8x8
        LDA CURRENT_SOUNDTRACK                  
        STA SAVED_SOUNDTRACK  
        CMP #(NUM_SOUNDTRACKS-1)
        BEQ no_msu1_chosen
            STA OPTIONS_MSU_PLAYLIST      
            bra reset_ppu_registers
no_msu1_chosen:
        STZ MSU_AVAILABLE
        STZ MSU_SELECTED
         

reset_ppu_registers:
    LDA #$8F
    STA INIDISP
    LDA #$40
    STA BG12NBA
    LDA #$21
    STA BG1SC
    LDA #$01
    STA BGMODE
    LDA #$00
    STA OBSEL

        PLB

    rtl

change_soundtrack_selection:
    LDA CONFIRM
    BNE abort_change_soundtrack

    LDA P1_NES_BUTTONS
    AND #$03
    CMP #$01
    BNE decrement_soundtrack
        INC CURRENT_SOUNDTRACK
        LDA CURRENT_SOUNDTRACK
        CMP #NUM_SOUNDTRACKS
        BNE finished_soundtrack_selection
        STZ CURRENT_SOUNDTRACK
        BRA finished_soundtrack_selection
decrement_soundtrack:
        DEC CURRENT_SOUNDTRACK
        LDA CURRENT_SOUNDTRACK
        BPL finished_soundtrack_selection
        LDA #(NUM_SOUNDTRACKS - 1)
        STA CURRENT_SOUNDTRACK


finished_soundtrack_selection:
   jsr load_current_soundtrack_image
abort_change_soundtrack:
   RTS


read_auto_joypad1:
    LDA JOY1H
    STA P1_NES_BUTTONS
    TAY
    EOR P1_NES_BUTTONS_HELD
    AND P1_NES_BUTTONS
    STA P1_NES_BUTTONS_TRIGGER
    STY P1_NES_BUTTONS_HELD

    LDA JOY1L
    STA P1_SNES_BUTTONS
    TAY
    EOR P1_SNES_BUTTONS_HELD
    AND P1_SNES_BUTTONS
    STA P1_SNES_BUTTONS_TRIGGER
    STY P1_SNES_BUTTONS_HELD
    RTS

soundtrack_table:
; .ADDR cv2_msu_palette, cv2_msu_tiles, cv2_msu_tilemap, CV2_MSU1_BANK
; .ADDR cv2fds_palette, cv2fds_tiles, cv2fds_tilemap, CV2_FDS_BANK
; .ADDR nesfdsmix_palette, nesfdsmix_tiles, nesfdsmix_tilemap, NESFDSMIX_BANK
; .ADDR vrc6_palette, vrc6_tiles, vrc6_tilemap, VRC6_BANK
; .ADDR cvrebirth_palette, cvrebirth_tiles, cvrebirth_tilemap, CVREBIRTH_BANK
; .ADDR orchestral_palette, orchestral_tiles, orchestral_tilemap, ORCHESTRAL_BANK
; .ADDR progrock_palette, progrock_tiles, progrock_tilemap, PROGROCK_BANK
; .ADDR msxscc_palette, msxscc_tiles, msxscc_tilemap, MSX_SCC_BANK
; .ADDR cv2_2a03_palette, cv2_2a03_tiles, cv2_2a03_tilemap, CV2_2A03_BANK

popup_tiles:
; .ADDR msu_2a03_popup
; .ADDR msu_fds_popup
; .ADDR nesfdsmix_popup
; .ADDR vrc6_popup
; .ADDR msu_cvrebirth_popup
; .ADDR orchestral_popup
; .ADDR msu_progrock_popup
; .ADDR msxscc_popup
; .ADDR memblers_popup

load_current_soundtrack_image:
    ; slowly scroll BG1 to left
:   DEC HOFFS_VALUE
    DEC HOFFS_VALUE
    DEC HOFFS_VALUE
    DEC HOFFS_VALUE
    LDA HOFFS_VALUE
    STA BG1HOFS
    LDA #$01
    STA BG1HOFS
    LDA HOFFS_VALUE
    BEQ done_scrolling_off_screen

    
    jsr wait_for_nmi
    BRA :-

done_scrolling_off_screen:

    ; f blank
    ; LDA #$80
    ; STA INIDISP

    ; load tiles, palette, tilemap for image
    JSR load_soundtrack_cover

    ; LDA #$0f
    ; STA INIDISP


    ; slowly scroll BG1 on
:   INC HOFFS_VALUE
    INC HOFFS_VALUE
    INC HOFFS_VALUE
    INC HOFFS_VALUE
    LDA HOFFS_VALUE
    
    STA BG1HOFS
    PHA
    LDA #$01
    STA BG1HOFS
    PLA
    CMP #$E0
    BEQ done_scrolling_on_screen
    jsr wait_for_nmi
    BRA :-

done_scrolling_on_screen:


    rts 

load_soundtrack_cover:


    jsr wait_for_nmi

; write_palette:
    LDA CURRENT_SOUNDTRACK
    ASL
    ASL
    ASL
    TAY

    LDX #$00
:   LDA soundtrack_table, Y
    STA $10, X
    INY
    INX
    CPX #$08
    BNE :-
    

    setXY16
    LDA #$10
    STA CGADD
    LDY #$20 ; the first palette is empty, skip it

:   LDA ($10), Y
    STA CGDATA
    INY
    CPY #$110
    BNE :-
        
    jsr wait_for_nmi
    
:   LDA ($10), Y
    STA CGDATA
    INY
    CPY #$1e0
    BNE :-


    setAXY8

    jsr wait_for_nmi
    
; write_tiles, 1000 at a time
    LDA #$80
    STA VMAIN

    LDA #$01
    STA DMAP1

    LDA #$18
    STA BBAD1

    LDA $12
    STA A1T1L

    LDA $13
    STA A1T1H

    LDA $16
    STA A1B1

    LDA #$10
    STA DAS1H
    STZ DAS1L

    LDA #$00
    STA VMADDH
    STZ VMADDL

    LDA #$02
    STA MDMAEN

 
    LDX #$08
    
:
    jsr wait_for_nmi
    LDA #$10
    STA DAS1H
    STZ DAS1L
    LDA #$02
    STA MDMAEN
    DEX
    BNE :-

    jsr wait_for_nmi
; write_tilemap:
    
    LDA #$80
    STA VMAIN

    LDA #$01
    STA DMAP1

    LDA #$18
    STA BBAD1

    LDA $14
    STA A1T1L

    LDA $15
    STA A1T1H

    LDA $16
    STA A1B1

    LDA #$06
    STA DAS1H
    LDA #$00
    STA DAS1L

    LDA #$78
    STA VMADDH
    STZ VMADDL

    LDA #$02
    STA MDMAEN

    jsr wait_for_nmi
    ; load sprite tiles
    LDA #$80
    STA VMAIN

    LDA #$01
    STA DMAP1

    LDA #$18
    STA BBAD1

    LDA CURRENT_SOUNDTRACK
    ASL
    TAY

    LDA popup_tiles, Y
    STA A1T1L
    INY

    LDA popup_tiles, Y
    STA A1T1H

    LDA #$D0
    STA A1B1

    LDA #$10
    STA DAS1H
    LDA #$00
    STA DAS1L

    LDA #$40
    STA VMADDH
    STZ VMADDL

    LDA #$02
    STA MDMAEN

    ; load sprite palettes

    LDA #$03
    STA TM

    RTS

wipe_all_tiles:
; tile 3BF is the safest tile to be all empty
  STZ VMAIN
  setAXY16
  ldx #$7800
  stx VMADDL 
	
	lda #$03BF
	
	LDY #$0000
	:
		sta VMDATAL
		iny
		CPY #$800
		BNE :-
  
  setAXY8
  rts

load_popup_sprites:
    LDA #$40
    STA $1000
    LDA #$98
    STA $1001
    LDA #$00
    STA $1002

    LDA #$3E
    STA $1003
    STA $1007

    LDA #$08
    STA $1006
    LDA #$98
    STA $1005
    LDA #$80
    STA $1004

    ; set the first two sprites to be 64x64
    LDA #$0A
    STA $1200

    STZ OAMADDL
    STZ OAMADDH
    LDA #<OAMDATA
    STA BBAD2
    LDA #$A0
    STA A1B2

    STZ DMAP2
    LDA #>SNES_OAM_START
    STA A1T2H
    LDA #<SNES_OAM_START
    STA A1T2L
    LDA #$02
    STA DAS2H
    LDA #$20
    STA DAS2L
    LDA #$04
    STA MDMAEN

; load sprite palette

    LDA #$f0
    STA CGADD

    setXY16
    LDY #$00

:   LDA sprite_palette, Y
    STA CGDATA
    INY
    CPY #$20
    BNE :-

    setAXY8

    LDA #$03
    STA TM
    rts


sprite_palette:
.byte $00, $00, $B5, $5A, $08, $31, $4A, $2D, $73, $52, $94, $56, $B5, $5A, $CF, $41
.byte $09, $25, $79, $5E, $18, $52, $3B, $6B, $96, $41, $33, $31, $BB, $5A, $12, $25

bg2_palette:
; .incbin "../resources/sc4-bg.mw3"
.byte $00, $00, $B5, $5A, $08, $31, $4A, $2D, $73, $52, $94, $56, $B5, $5A, $CF, $41
.byte $09, $25, $79, $5E, $18, $52, $3B, $6B, $96, $41, $33, $31, $BB, $5A, $12, $25


setup_bg2:

    ; set BG2 to start at 4800.  we'll use 4800 - 4BFF for the tilemap
    ; 
    ; 18 << 10 = 4800           last two bits are for 1x1 bg
    ; 010010                    00
    LDA #%01001000
    STA BG2SC

    LDA #$00
    STA CGADD

    setXY16
    LDY #$00

:   LDA bg2_palette, Y
    STA CGDATA
    INY
    CPY #$20
    BNE :-

    setAXY8

; write_tiles:
    LDA #$80
    STA VMAIN

    LDA #$01
    STA DMAP1

    LDA #$18
    STA BBAD1

    LDA #<msu1_selection_bg_tiles
    STA A1T1L

    LDA #>msu1_selection_bg_tiles
    STA A1T1H

    LDA #MSU1_BG2_BANK
    STA A1B1

    LDA #$50
    STA DAS1H
    STZ DAS1L

    LDA #$50
    STA VMADDH
    STZ VMADDL

    LDA #$02
    STA MDMAEN

; write_tilemap:
    
    LDA #$80
    STA VMAIN

    LDA #$01
    STA DMAP1

    LDA #$18
    STA BBAD1

    LDA #<msu1_selection_bg_tilemap
    STA A1T1L

    LDA #>msu1_selection_bg_tilemap
    STA A1T1H

    LDA #MSU1_BG2_BANK
    STA A1B1

    LDA #$08
    STA DAS1H
    LDA #$00
    STA DAS1L

    LDA #$48
    STA VMADDH
    STZ VMADDL

    LDA #$02
    STA MDMAEN

    RTS

wait_for_nmi:
    
    LDA RDNMI
:   LDA RDNMI
    BPL :-
    RTS