augment_input:

    ; origingal code
    LDX $FB
    INX
    STX JOYSER0
    DEX
    STX JOYSER0
    LDX #$08
:   LDA JOYSER0
    LSR
    ROL $F5
    LSR
    ROL $00
    LDA JOYSER1
    LSR
    ROL $F6
    LSR
    ROL $01
    DEX
    BNE :-

    ; example from Double Dragon
    ; we also ready the next bit, which is the SNES "A" button
    ; and if it's on, treat it as if they've hit both Y and B
    ; lda JOYSER0
    ; AND #$01
    ; BEQ :+
    ; LDA $00
    ; ORA #$C0
    ; STA $00

    ; X
    ; lda JOYSER0
    ; lda JOYSER0
    ; AND #$01
    ; BEQ :+
    

    ; this checks for the komani code by looking at where the game stores input.
; :   jsr check_for_code_input_from_ram_values

    RTL