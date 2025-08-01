.segment "HEADER"
;      012345678901234567890
.byte "GAMENAME GOES HERE V1" ; ROM name, must be 21 chars
       
                
.segment "ROMSPEC"
.byte $31   ; Map Mode: 3.58MHz HiROM
.byte $01   ; Cartridge Type: ROM+SRAM only
.byte $0C   ; ROM Size
.byte $00   ; RAM size
.byte $01   ; Destination Code: USA
.byte $01   ; Fixed value
.byte $00   ; Mask ROM Version
.word $0000 ; Complement Check
.word $0000 ; Check Sum

.segment "VECTOR"
; native mode vectors
.word 0, 0
.addr _rti  ; COP
.addr _rti  ; BRK
.addr _rti  ; ABORT
.addr nmi   ; NMI
.addr start ; RST
.addr _rti  ; IRQ

; emulation mode vectors - largely unused, since we run in native mode
.word 0, 0
.addr 0
.addr 0
.addr 0
.addr 0
.addr start ; RST
.addr 0