.segment "PRGB3"
; Waits for SPC to finish booting. Call before first
; using SPC or after bootrom has been re-run.
; Preserved: X, Y
spc_wait_boot:
    lda #$AA
@wait:  
   cmp $2140
    bne @wait

    ; Clear in case it already has $CC in it
    ; (this actually occurred in testing)
    sta $2140

    lda #$BB
@wait2: 
    cmp $2141
    bne @wait2
rts

; Starts upload to SPC addr Y and sets Y to
; 0 for use as index with spc_upload_byte.
; Preserved: X
spc_begin_upload:
    sty $2142

    ; Send command
    lda $2140
    clc
    adc #$22
    bne skip       ; special case fully verified
    inc
skip:  
    sta $2141
    sta $2140

    ; Wait for acknowledgement
waitUploadStartAck:  
    cmp $2140
    bne waitUploadStartAck

    ; Initialize index
    .byte $A0, $00, $00 ; ldy #$0000
rts

; Uploads byte A to SPC and increments Y. The low byte
; of Y must not changed between calls.
; Preserved: X
spc_upload_byte:
    sta $2141

    ; Signal that it's ready
    tya
    sta $2140
    iny

    ; Wait for acknowledgement
waitUploadByteAck:
    cmp $2140
    bne waitUploadByteAck
rts

spc_init_driver:
    pha
    phx
    phy
    phb
    php
    
    setAXY16
    ldy #.loword(spc_driver)

    phk
    plb
    jsr send_apu_data

    plp
    plb
    ply
    plx
    pla
    rtl

;;; SPC Upload Code Borrowed from Super Metroid ;;;
;;; $8059: Send APU data ;;;
send_apu_data:
;; Parameters:
;;     Y: Address of data
;;     DB: Bank of data

; Data format:
;     ssss dddd [xx xx...] (data block 0)
;     ssss dddd [xx xx...] (data block 1)
;     ...
;     0000 aaaa
; Where:
;     s = data block size in bytes
;     d = destination address
;     x = data
;     a = entry address. Ignored by SPC engine after first APU transfer

; The xx data can cross bank boundaries, but the data block entries otherwise can't (i.e. s, d, a and 0000) unless they're word-aligned

; Wait until APU sets APU IO 0..1 = AAh BBh
; Kick = CCh
; For each data block:
;    APU IO 2..3 = destination address
;    APU IO 1 = 1 (arbitrary non-zero value)
;    APU IO 0 = kick
;    Wait until APU echoes kick back through APU IO 0
;    Index = 0
;    For each data byte
;       APU IO 1 = data byte
;       APU IO 0 = index
;       Wait until APU echoes index back through APU IO 0
;       Increment index
;    Increment index (and again if resulting in 0)
;    Kick = index
; Send entry address through APU IO 2..3
; APU IO 1 = 0
; APU IO 0 = kick
; (Optionally wait until APU echoes kick back through APU IO 0)

        PHP
        REP #$30
        LDA #$3000             ;\
        STA $000641               ;|
                                  ;|
apuWait:
        LDA #$BBAA                ;|
        CMP $002140               ;|
        BEQ apuReady                   ;} Wait until [APU IO 0..1] = AAh BBh
        LDA $000641               ;|
        DEC A                     ;|
        STA $000641               ;|
        BNE apuWait                   ;/
crash:
        BRA crash                   ; If exceeded 3000h attempts: crash

apuReady:
        SEP #$20
        LDA #$CC                  ; Kick = CCh
        BRA processDataBlock     ; Go to BRANCH_PROCESS_DATA_BLOCK

; BRANCH_UPLOAD_DATA_BLOCK
uploadDataBlock:
        LDA $0000,y               ;\
        JSR incY                 ;} Data = [[Y++]]
        XBA                       ;/
        LDA #$00                  ; Index = 0
        BRA uploadData           ; Go to BRANCH_UPLOAD_DATA

; LOOP_NEXT_DATA
loopNextData:
        XBA                       ;\
        LDA $0000,y               ;|
        JSR incY                 ;} Data = [[Y++]]
        XBA
:                                 ;/
        CMP $002140               ;\
        BNE :-                     ;} Wait until APU IO 0 echoes
        INC A                     ; Increment index

; BRANCH_UPLOAD_DAT             
uploadData:
        REP #$20
        STA $002140               ; APU IO 0..1 = [index] [data]
        SEP #$20
        DEX                       ; Decrement X (block size)
        BNE loopNextData                   ; If [X] != 0: go to LOOP_NEXT_DATA
:
        CMP $002140               ;\
        BNE :-                     ;} Wait until APU IO 0 echoes

ensureKick:
        ADC #$03                  ; Kick = [index] + 4
        BEQ ensureKick                     ; Ensure kick != 0

; BRANCH_PROCESS_DATA_BLOCK
processDataBlock:
        PHA
        REP #$20
        LDA $0000,y               ;\
        JSR incY2                ;} X = [[Y]] (block size)
        TAX                       ;} Y += 2
        LDA $0000,y               ;\
        JSR incY2                 ;} APU IO 2..3 = [[Y]] (destination address)
        STA $002142               ;} Y += 2
        SEP #$20
        CPX #$0001                ;\
        LDA #$00                  ;|
        ROL A                     ;} If block size = 0: APU IO 1 = 0 (EOF), else APU IO 1 = 1 (arbitrary non-zero value)
        STA $002141               ;/
        ADC #$7F               ; Set overflow if block size != 0, else clear overflow
        PLA                    ;\
        STA $002140               ;} APU IO 0 = kick
        PHX
        LDX #$1000                ;\

:                                  ;|
        DEX                       ;} Wait until APU IO 0 echoes
        BEQ ret                  ;} If exceeded 1000h attempts: return
        CMP $002140               ;|
        BNE :-                     ;/
        
        PLX
        BVS uploadDataBlock      ; If block size != 0: go to BRANCH_UPLOAD_DATA_BLOCK
        SEP #$20
        STZ $2141               
        STZ $2142               
        STZ $2143               
        PLP
        RTS
ret:
        SEP #$20
        STZ $2141
        STZ $2142
        STZ $2143
        PLX
        PLP
        RTS

;;; $8100: Increment Y twice, bank overflow check ;;;
incY2:
; Only increments Y once if overflows bank first time (which is a bug scenario)
        INY
        BEQ next


;;; $8103: Increment Y, bank overflow check ;;;
incY:
        INY
        BEQ next                 
        RTS
next:
        INC $02                   ; Increment $02
        PEI ($01)                 ;\
        PLB                    ;} DB = [$02]
        PLB                    ;/
        LDY #$8000             ; Y = 8000h
        RTS

; spc_init_dpcm:
;     PHA
;     PHX
;     PHY
;     PHB
;     PHP

;     sep #$20

;     ldy #$4000
;     jsr spc_begin_upload

; ; Starts upload to SPC addr Y and sets Y to
; ; 0 for use as index with spc_upload_byte.
; ; Preserved: X
; spc_begin_upload:
;     sty $2142

;     ; Send command
;     lda $2140
;     clc
;     adc #$22
;     bne skip       ; special case fully verified
;     inc
; skip:  
;     sta $2141
;     sta $2140

;     ; Wait for acknowledgement
; waitUploadStartAck:  
;     cmp $2140
;     bne waitUploadStartAck

;     ; Initialize index
;     ldy #$0000
; rts


dmc_lookup_start_pos = $4060
spc_init_dpcm:
    pha
    phx
    phy
    phb
    php

    setAXY16
    setA8
;     sep #$20    ; 8-bit A

    jsr spc_wait_boot

    ;  $4000-$400f:  dmc address bytes (see ../nes-spc/spc.asm:267)
    ldy #$4000  ;  Start an upload at $4000 aram
    jsr spc_begin_upload

    lda #$1e
    jsr spc_upload_byte
    lda #$1d
    jsr spc_upload_byte
;     lda #$20
;     jsr spc_upload_byte
;     lda #$4c
;     jsr spc_upload_byte
;     lda #$80
;     jsr spc_upload_byte

    ;  $4010-$401f:  frequency cutoff values (see ../nes-spc/spc.asm:268)
    ldy #$4010  ;  Start an upload at $4010 aram
    jsr spc_begin_upload

    lda #$0f
    jsr spc_upload_byte
    lda #$0f
    jsr spc_upload_byte
;     lda #$0f
;     jsr spc_upload_byte
;     lda #$0f
;     jsr spc_upload_byte
;     lda #$0d
;     jsr spc_upload_byte

    ;  $4020-$405f: SRCN lookup entries (see ../nes-spc/spc.asm:271)
    ldy #$4020  ;  Start an upload at $4020 aram
    jsr spc_begin_upload

;     upload entry for knee
    rep #$30    ; 16-bit load
    lda #dmc_lookup_start_pos
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte

    rep #$30    ; 16-bit load
    lda #dmc_lookup_start_pos
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte

;     upload entry for contra file
    rep #$30    ; 16-bit load
    lda #(dmc_lookup_start_pos + flying_knee_end - flying_knee)
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte

    rep #$30    ; 16-bit load
    lda #(dmc_lookup_start_pos + flying_knee_end - flying_knee)
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte        

    ldy #$4060  ;  Start an upload at $4060 aram
    jsr spc_begin_upload
    ldx #$0000

nextbyte:
    lda flying_knee,x
    jsr spc_upload_byte
    inx
    cpx #(flying_knee_end-flying_knee)
    bne nextbyte

    ldx #$0000

nextbyte2:
    lda contra_brr,x
    jsr spc_upload_byte
    inx
    cpx #(contra_brr_end-contra_brr)
    bne nextbyte2


    jsr reset_to_ipc_rom

    plp 
    plb
    ply
    plx
    pla
rtl

;  Execute spc starting at location in Destination (the IPC rom at $ffc0)
reset_to_ipc_rom:
  Destination = $ffc0 ; Program's address in SPC700 RAM
  lda #Destination & $00ff
  sta $2142
  lda #Destination>>8
  sta $2143

  stz $2141          ; Zero = start the program that was sent over

  lda $2140          ; Must be at least 2 higher than the previous APUIO0 value.
  inc
  inc
  sta $2140          ; Tell the SPC700 to start running the new program.

wait:                 ; Wait for the SPC700 to acknowledge this.
  cmp $2140
  bne wait

rts

brr:
flying_knee:
; .incbin "../sfx/brrs/e1-flyingknee.brr"
flying_knee_end:

contra_brr:
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$98,$00,$00,$00,$00,$00,$1A
.byte $F5,$0F,$64,$EA,$C0,$9B,$F8,$EC,$80,$9B,$08,$7C,$2F,$D4,$C0,$2B
.byte $3F,$D4,$B1,$2B,$6C,$7C,$B7,$81,$38,$5D,$C6,$82,$28,$6C,$6C,$C6
.byte $82,$38,$DF,$EF,$C5,$08,$6C,$6B,$D5,$0E,$1F,$AC,$FE,$D4,$18,$68
.byte $DE,$DD,$3F,$A9,$CE,$CD,$DC,$E2,$6C,$09,$E4,$FE,$1E,$AB,$0E,$C5
.byte $E9,$6C,$E3,$1F,$F0,$FF,$0B,$BF,$C6,$DB,$6C,$5A,$E5,$FA,$B0,$DF
.byte $C0,$4B,$A1,$6C,$3B,$A1,$21,$EF,$0F,$0E,$AC,$33,$64,$F9,$A0,$FF
.byte $0F,$98,$88,$8D,$0F,$6C,$00,$0F,$1F,$2E,$9E,$34,$00,$10,$5C,$03
.byte $02,$13,$12,$23,$23,$32,$6D,$6C,$AE,$67,$01,$4E,$A7,$7F,$32,$23
.byte $78,$20,$4F,$E1,$22,$62,$EF,$20,$54,$5C,$35,$70,$D4,$33,$42,$43
.byte $43,$25,$74,$30,$45,$33,$33,$33,$33,$33,$33,$4C,$76,$65,$76,$65
.byte $76,$65,$76,$57,$4C,$56,$66,$57,$56,$66,$65,$66,$56,$6C,$12,$12
.byte $11,$3D,$E1,$0F,$37,$6F,$7C,$21,$DE,$10,$00,$14,$12,$FD,$F1,$64
.byte $EE,$DD,$DC,$CD,$BB,$41,$BB,$BB,$64,$AB,$A9,$C2,$4E,$9A,$A9,$99
.byte $99,$6C,$D0,$42,$DA,$D0,$DF,$43,$BB,$DF,$6C,$EE,$FD,$EE,$D4,$F9
.byte $ED,$12,$AC,$6C,$EE,$C4,$F8,$E2,$1E,$0B,$AF,$C3,$6C,$F9,$E1,$2E
.byte $9C,$FD,$EC,$11,$9C,$6C,$11,$09,$E2,$83,$E9,$4F,$FE,$83,$6C,$F9
.byte $40,$BC,$22,$AC,$31,$AD,$22,$6C,$BA,$FD,$13,$EB,$E4,$E0,$F0,$F0
.byte $6C,$CB,$EE,$23,$FF,$1D,$A4,$2F,$00,$68,$E0,$FE,$1C,$A5,$E9,$05
.byte $1F,$00,$64,$FA,$B1,$41,$BA,$F4,$33,$51,$C2,$68,$3F,$11,$01,$20
.byte $22,$1A,$F1,$27,$74,$42,$F3,$34,$4F,$23,$F4,$1F,$FE,$6C,$75,$11
.byte $4D,$B7,$18,$37,$32,$22,$74,$2E,$04,$11,$40,$25,$45,$11,$55,$74
.byte $2F,$0F,$35,$45,$54,$F0,$35,$56,$74,$12,$51,$F2,$56,$12,$51,$E3
.byte $40,$78,$51,$D7,$D2,$5B,$61,$C3,$35,$FD,$74,$36,$40,$F3,$40,$36
.byte $46,$56,$51,$74,$F3,$66,$41,$01,$F2,$65,$72,$16,$78,$ED,$64,$D3
.byte $6F,$2D,$36,$C3,$5B,$7C,$61,$E2,$E3,$3F,$01,$11,$D4,$3F,$74,$F4
.byte $40,$52,$16,$31,$F0,$53,$E0,$74,$51,$15,$01,$74,$03,$64,$40,$16
.byte $78,$E2,$F1,$52,$D1,$6E,$07,$E1,$12,$7C,$1E,$F1,$F4,$4F,$DE,$43
.byte $C3,$2B,$78,$21,$01,$52,$EE,$6C,$16,$0D,$E3,$74,$40,$05,$45,$2F
.byte $F2,$54,$F3,$3E,$74,$F2,$63,$F4,$2F,$50,$14,$FF,$E0,$7C,$4C,$23
.byte $B0,$00,$F5,$EE,$51,$DF,$64,$7F,$BC,$C4,$2A,$C3,$73,$CA,$23,$6D
.byte $96,$6C,$A7,$F8,$27,$E8,$27,$DC,$31,$32,$32,$5F,$31,$2D,$2D,$2D
.byte $2D,$2D,$2D,$2D,$2D,$2D,$3E
contra_brr_end:

spc_driver:
.incbin "./spc/spc.bin"
spc_driver_end: