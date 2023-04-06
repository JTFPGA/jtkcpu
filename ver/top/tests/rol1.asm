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
RESET:  LDB #$20
        STB ,Y
        ROL ,Y
        LDB ,Y
        CMPB #$40
        BNE BAD

        ANDCC #$FE
        LDA #$80
        STA ,X
        ROL ,X
        LDA ,X
        ROL ,X
        LDA ,X
        ROL ,X
        LDA ,X
        ROL ,X
        LDA ,X
        CMPA #$08
        BNE BAD



        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

