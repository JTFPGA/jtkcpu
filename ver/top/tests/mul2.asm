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

        LDD #$1234
        MUL

        PSHS D
        PULS X
        CMPX #$3A8
        BNE BAD

        LDB #$34
        DIV X,B
        CMPX #$12
        BNE BAD
        TSTB
        BNE BAD

        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

