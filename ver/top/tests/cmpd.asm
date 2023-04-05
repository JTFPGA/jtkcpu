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
DATAW    EQU $0100

        ORG $F000
RESET:  LDU #RAMEND

        LDX #$ABBA
        LDY #$BEBE
        LDD #$ACDC
        PSHU D,X,Y

        CMPY 4,U
        BNE BAD
        CMPX 2,U
        BNE BAD
        CMPD ,U
        BNE BAD

        CLRD
        LDD #$CAFE
        PSHU D
        CMPD ,U
        BNE BAD

        include finish.inc

DATAR:  FDB   END,$1234, $5678, $9ABC, $DEF0

        DC.B  [$FFFE-*]0
        FDB   RESET