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
RESET:
        LDX #$800
        LDA #$12
        STA ,X

        TST ,X
        LBEQ BAD
        CMPA ,X
        LBNE BAD

        CLRB
        STB ,X
        TST ,X
        LBNE BAD
        CMPB ,X
        LBNE BAD
        LBRA END

        DC.B [$110]0
        include finish.inc

        DC.B  [$FFFE-*]0
        FDB   RESET