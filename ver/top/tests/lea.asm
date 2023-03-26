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
RESET:  LDX  #0
        LEAX X,$1234
        LEAY X,$3421
        LEAU X,$2341
        LEAS X,$4123

END:    LDY #$BABE
        LDA #1
        LDY #TESTCTRL
        STA ,Y 
        BRA END

BAD:    LDY #DEAD
        LDA #3
        LDY #TESTCTRL
        STA ,Y
        BRA BAD

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

