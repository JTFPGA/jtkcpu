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
RESET:
        LDS #RAMEND

        LDA  #8
        ADDA #7
        PSHS CC
        PULS B
        BITB #$20
        BNE BAD

        LDA  #9
        ADDA #9
        PSHS CC
        PULS B
        BITB #$20
        BEQ BAD

        LDA  #8
        ADDA #7
        DAA
        CMPA #$15
        BNE BAD

        LDA  #9
        ADDA #9
        DAA
        CMPA #$18
        BNE BAD

        LDA  #8
        ADDA #1
        DAA
        CMPA #$9
        BNE BAD

        include finish.inc

        DC.B  [$FFFE-*]0
        FDB   RESET