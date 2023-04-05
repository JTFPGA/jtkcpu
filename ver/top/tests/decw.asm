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
        LDD #$1234
        STD ,X
        CMPD ,X
        BNE BAD

        DECW ,X
        CMPD ,X
        BEQ BAD

        SUBB #1
        CMPD ,X
        BNE BAD

        CLRD
        CLRW ,X
        LDD #$0000A
        STD ,Y
        CMPD ,Y
        BNE BAD
LOOP:
        DECW ,Y
        LDX ,Y
        BNE LOOP
        CMPX #$00
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