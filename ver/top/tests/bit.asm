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

TESTCTRL EQU $1000

        ORG $F000
RESET:
        LDA #$55
        BITA #$AA
        BNE BAD
        CMPA #$55
        BNE BAD

        LDB #$AA
        BITB #$55
        BNE BAD
        CMPB #$AA
        BNE BAD

        STB ,X
        LDB #$FF
        BITB ,X
        BEQ BAD
        CMPB #$FF
        BNE BAD

        LDA #$F
        STA ,X
        LDA #$F0
        BITA ,X
        BNE BAD
        CMPA #$F0
        BNE BAD

        include finish.inc


DATAR:  FCB 1,2,3,4,5

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

