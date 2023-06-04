; Store and test flags
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
RESET:  LDA #1
        LDX #$200
        STA ,X
        BEQ BAD

        CLRA
        LDB #1
        BEQ BAD
        STA ,X
        BNE BAD

        ; Test 16 bit too
        STD ,X
        BEQ BAD
        CLRB
        ANDCC #$FB
        BEQ BAD
        STD ,X
        BNE BAD

        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

