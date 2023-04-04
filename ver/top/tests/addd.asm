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
RESET:  CLRB
        LDA  #$5
        ADDD #$A00
        LDB #$64
        CMPA #$0F
        BNE BAD

        ADDD #$111
        CMPD #$1075
        BNE BAD

        STD ,X
        ADDD ,X
        CMPD #$20EA
        BNE BAD

        include finish.inc

        DC.B  [$FFFE-*]0
        FDB   RESET