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
DATAW    EQU $0100

        ORG $F000
RESET:  LEAX DATAR
        LDY ,X
        LDU 2,X
        LDS 4,X

        LDX #DATAW
        STX ,X
        STY 2,X
        STU 4,X
        STS 6,X

        CMPX ,X
        BNE BAD
        CMPY 2,X
        BNE BAD
        CMPU 4,X
        BNE BAD
        CMPS 6,X
        BNE BAD

END:    LDU #$BABE
        LDA #1
        LDS #TESTCTRL
        STA ,S                  ; Finish test, result ok
        BRA END

BAD:    LDU #$DEAD
        LDA #3
        LDS #TESTCTRL
        STA ,S                  ; Finish test, result bad
        BRA BAD

DATAR:  FDB   $1234, $5678, $9ABC, $DEF0

        DC.B  [$FFFE-*]0
        FDB   RESET