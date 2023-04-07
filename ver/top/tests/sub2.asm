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
RESET:  LDA #$A3
        LDB #$04
        SUBB #$80
        SUBA #$25
        CMPB #$84
        BNE BAD
        CMPA #$7E
        BNE BAD

        include finish.inc

        DC.B  [$FFFE-*]0
        FDB   RESET

