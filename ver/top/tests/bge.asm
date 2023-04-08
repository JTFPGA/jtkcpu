; Load test
; 0000-0FFF RAM
; 1000      Simulation control
; 1001		read only, A[23:16]
; F000-FFFF ROM

; Simulation control bits
; 0 -> set to finish the sim
; 1 -> set to mark a bad result
; 5 -> set to trigger IRQ.  Clear manually
; 6 -> set to trigger FIRQ. Clear manually
; 7 -> set to trigger NMI.  Clear manually

RAMEND   EQU $1000
TESTCTRL EQU $1000

        ORG $F000
RESET:  LEAS RAMEND
        LEAU RANDOM

        LDA #$10        ; Will run these many iterations
LOOP:
        LDA #$7F
        CMPA #$7F
        BGE L1
        BRA BAD
L1:     BHI BAD
        BLT BAD
        BNE BAD
        LDA #$FF
        CMPA #$FF
        BGE L2
        BRA BAD
L2:     BHI BAD
        BLT BAD
        BNE BAD
        LDA #$30
        CMPA #$20
        BGE L3
        BRA BAD
L3:     BLE BAD
        BLT BAD
        BEQ BAD
        LDA #$F0
        CMPA #$E0
        BGE L4
        BRA BAD
L4:     BEQ BAD
        BLT BAD
        LDA #$F0        ; Signed comparison
        CMPA #1
        BLE L5
        BRA BAD
L5:     BGE BAD
        BGT BAD
        LDA #$10
        CMPA #$F0
        BGE L6
        BRA BAD
L6:     BEQ BAD
        BRN BAD
        LBRN BAD

        include finish.inc

RANDOM: DC.W $1CC7, $6255, $578B, $0135, $4628, $14BE, $7AE3, $6796
        DC.W $4AE4, $7263, $0126, $680E, $06AF, $79BD, $6F31, $1365
        DC.W $0288, $473F, $1D26, $6770, $0C62, $2DBF, $0270, $0A7B
        DC.W $23E1, $438A, $5739, $7900, $6F6B, $76B6, $5855, $6D1D
        DC.W $0BA4, $65AF, $72C4, $421E, $7645, $2FE8, $2D4C, $7AB3
        DC.W $1868, $7F43, $0A76, $7AF3, $19BE, $1EEA, $1B16, $43DE
        DC.W $463E, $3D25, $5144, $75A4, $0A67, $2C65, $368E, $3C5B
        DC.W $07FD, $0E43, $59EB, $0E2D, $2CF6, $5683, $5CEE, $33C0

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

