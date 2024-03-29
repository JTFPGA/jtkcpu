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
        LDB #$30
        LDA #$0C
        STB ,X
        DEC ,X
        CMPX #$2F
        BEQ BAD
        CLRB

LOOP:   DEC ,X
        LDB ,X
        DECA
        CMPA #$00
        BNE LOOP

        CMPB #$23
        BNE BAD

        include finish.inc

        DC.B  [$FFFE-*]0
        FDB   RESET