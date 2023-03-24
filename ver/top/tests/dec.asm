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
RESET:  LDX #$2000
        LDY #$2020
        LDB #$10

LOOP:   LDA ,X+
        STA ,Y+
        DECB
        BNE LOOP
        CMPB #$00
        BNE BAD

END:    LDY #$BABE
        LDB #1
        LDY #TESTCTRL
        STB ,Y 
        BRA END

BAD: 	LDY #$DEAD
        LDB #3
        LDY #TESTCTRL
        STB ,Y
 	BRA BAD

; fill with zeros... up to interrupt table
;FILL $FFFE-$

;dc.b [(*+255)&$FFFFFFFE-*]0

FDB RESET

