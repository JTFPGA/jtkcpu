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
RESET:  LDA #$5B
        LDB #$1D
        STB ,Y
        EORA ,Y
        CMPA #$46
        BNE BAD

        LDB #$23
        LDA #$67
        STA ,X
        EORB ,X
        CMPB #$44
        BNE BAD

        LDB #$CA
        STB ,X
        LDA #$FE
        EORA ,X
        CMPA #$34
        BNE BAD

        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

