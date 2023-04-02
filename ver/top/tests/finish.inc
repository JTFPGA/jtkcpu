END:    LDX #$BABE
        CMPX #$BABE
        BNE BAD                 ; This catches a PC error where the PC has a 1-byte offset
        LDA #3
        LDX #TESTCTRL
        STA ,X                  ; Finish test, result ok
        BRA END
BAD:    LDX #$DEAD
        LDA #1
        LDX #TESTCTRL
        STA ,X                  ; Finish test, result bad
        BRA BAD