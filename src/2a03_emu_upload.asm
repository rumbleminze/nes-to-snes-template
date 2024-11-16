.segment "SOUND_EMU"

.DEFINE NesAPUEmulatorBinSize $2c02

upload_sound_emulator_to_spc:
  PHP
  setA8

  
  LDA #$8F
  STA INIDISP     ; Turn screen off
  LDA #$01
  STA NMITIMEN    ; disable interrupts

  setXY16
  PHB
  LDA #SPC700CodeBank ; #$8C
  PHA
  PLB

  LDX #$BBAA
  WaitSPCEq:
    cpx APUIO0
    bne WaitSPCEq    ; wait for SPC to be ready

		ldy #$0000

		ldx #NesAPUEmulatorBinSize
		stx TEMP_DATA
    ldx #$1000       ; start address for writing
    stx APUIO2

    lda #$01
    sta APUIO1        ; block

		; send the load starter byte: $CC
    lda #$CC
    sta APUIO0
  WaitSPC700Start:
    lda APUIO0
    cmp #$CC
    bne WaitSPC700Start  
  SendAll:
		lda sound_emulator_first_2FBB, Y ; Get the SPC700 binary code from the rom
		sta APUIO1               ; send byte
		tya
		sta APUIO0
  WaitSPCReply:
    cmp APUIO0
    bne WaitSPCReply        ; wait for SPC to reply with # sent
		iny
		cpy TEMP_DATA             ; test if transfer is finished
		bne SendAll
        ; send terminator block
		stz APUIO1
		ldx #$1000
		stx APUIO2
		; send the transfered byte count
		iny
		iny
		tya
		sta APUIO0
  Spc700FwEnd:
		lda #$01
		sta APUInit
		plb ; Restore the bank
    plp
  STZ $00
  STZ $01
  STZ $02
    RTL
