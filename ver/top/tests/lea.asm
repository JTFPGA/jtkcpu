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
RESET:  LEAX RESET
        CMPX #RESET
        BNE BAD

        LEAX -2,X
        CMPX #(RESET-2)
        BNE BAD

        LEAY RAMEND
        LEAY $234,Y
        CMPY #(RAMEND+$234)
        BNE BAD

        LEAU RAMEND
        LDA #$10
        LEAU A,U
        CMPU #(RAMEND+$10)
        BNE BAD

        LEAS RAMEND
        LDB #$FF
        LEAS B,S
        CMPS #(RAMEND-1)
        BNE BAD

        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

