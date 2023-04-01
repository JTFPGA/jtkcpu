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
RESET:  LDX #TABLE

        ; Counts the number of negative numbers in TABLE
        ; The table end is marked with a zero
        CLRB
LOOP    LDA ,X+
        BEQ LOOPEND
        BPL LOOP
        INCB
        BRA LOOP

LOOPEND:

        ; Check that the count is right
        CMPB #4
        BNE BAD

END:    LDX #$BABE
        LDA #1
        LDX #TESTCTRL
        STA ,X                  ; Finish test, result ok
        BRA END
BAD:    LDX #$DEAD
        LDA #3
        LDX #TESTCTRL
        STA ,X                  ; Finish test, result bad
        BRA BAD

TABLE  FCB 3,2,6,-1,24,100,-23,-54,-2,0

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET