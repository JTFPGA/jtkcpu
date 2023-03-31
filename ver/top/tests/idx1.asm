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
RESET:  LEAX DATAR
        LEAY DATAW
        LEAY 16,Y
        LDB #16
LOOP:                   ; Copy data in reversed order
        LDA ,X+
        STA ,-Y
        DECB
        BNE LOOP

        LDB #16         ; check that the copy was correct
CHECK:  LDA  ,-X
        CMPA ,Y+
        BNE BAD
        DECB
        BNE CHECK


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

DATAR:  FDB   0,1,2,3,4,5,6,7,8,9,$A,$B,$C,$D,$E,$F

DATAW:  DC.B  [$FFFE-*]0
        FDB   RESET