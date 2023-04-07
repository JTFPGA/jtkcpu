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
RESET:  LDA #$0F
        ADDA #$1F
        LDB #$64
        CMPA #$2E
        BNE BAD
        ADDB #$64
        CMPB #$C8
        BNE BAD

        CLRD
        LDA #$8F
        INCA
        CMPA #$90
        BNE BAD

        LDB #$7F
        INCB
        CMPB #$80
        BNE BAD

        CLRD
        LDB #$80
        DECB
        CMPB #$7F
        BNE BAD

        LDA #$81
        DECA
        CMPA #$80
        BNE BAD

        include finish.inc

        DC.B  [$FFFE-*]0
        FDB   RESET