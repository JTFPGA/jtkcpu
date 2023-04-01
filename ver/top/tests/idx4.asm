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
RESET:  LDD #DATAR
        LEAS DATAW
        STD  ,S
        LEAS 100,S
        LDD  #-100
        LDD  [D,S]
        CMPD #$CAFE
        BNE  BAD

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

DATAR:  DB   $CA,$FE

        DC.B  [$FFFE-*]0
        FDB   RESET