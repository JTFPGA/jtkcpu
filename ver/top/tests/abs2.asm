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
RESET:  LDA #$55
        ABSA
        CMPA #$55
        BNE BAD

        NEGA
        BPL BAD
        ABSA
        BMI BAD
        CMPA #$55
        BNE BAD

        LDB #-$23
        ABSB
        BMI BAD
        CMPB #$23
        BNE BAD
        NEGB
        BPL BAD
        CMPB #-$23
        BNE BAD

        CLRA
        ABSA
        BNE BAD

        CLRB
        ABSB
        BNE BAD


        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

