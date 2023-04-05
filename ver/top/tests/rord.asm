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

        LDD #$8000
        RORD #4
        CMPD #$0800
        BNE BAD

        LDD #$8000
        RORD #8
        CMPD #$0080
        BNE BAD

        LDD #$8000
        RORD #16
        CMPD #$0000
        BNE BAD

        include finish.inc

CHECBK: DC.W $0000
        DC.W $0001,$0002,$0004,$0008,$0010,$0020,$0040,$0080
        DC.W $0100,$0200,$0400,$0800,$1000,$2000,$4000,$8000
CHECKE:

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET