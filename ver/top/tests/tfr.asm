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
LINESRD  EQU $1001

        ORG $F000
RESET:
        LDS #RAMEND

        TFR S,U
        PSHS U
        PULS D
        CMPD #RAMEND
        BNE BAD

        LDX #$1234
        LDU #$5678
        EXG X,U
        CMPX #$5678
        BNE BAD

        EXG U,Y
        EXG X,Y
        CMPX #$1234
        BNE BAD

        LDD #$CAFE
        EXG A,B
        CMPD #$FECA
        BNE BAD

        CLRA
        TFR A,B
        CMPD #0
        BNE BAD

        include finish.inc

FIRQ:
        BRA BAD
IRQ:
        BRA BAD
NMI:
        BRA BAD

        DC.B  [$FFF6-*]0
        FDB   FIRQ,IRQ,$FFFF,NMI,RESET