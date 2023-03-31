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
RESET:  LDA #$55
        LDB #$81
        ABSA
        CMPA #$AA
        BNE BAD
        ABSB
        CMPB #$7E
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

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

