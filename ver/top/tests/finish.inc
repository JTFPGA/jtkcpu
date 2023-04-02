END:    LDX #$BABE
        LDA #3
        LDX #TESTCTRL
        STA ,X                  ; Finish test, result ok
        BRA END
BAD:    LDX #$DEAD
        LDA #1
        LDX #TESTCTRL
        STA ,X                  ; Finish test, result bad
        BRA BAD