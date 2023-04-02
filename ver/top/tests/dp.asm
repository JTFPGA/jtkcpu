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

RAMEND   EQU $1000
TESTCTRL EQU $1000

        ; assume DP:$00
        ORG $F000
RESET:
        LDS #RAMEND

        LDA #$10
        STA <0
        STA <1
        STA <2
        LDU #0
        CMPA ,U
        BNE BAD
        CMPA 1,U
        BNE BAD
        CMPA 2,U
        BNE BAD

        LDA #1
        PSHS A
        PULS DP
        STA <0
        STA <1
        STA <2
        CMPA $100,U
        BNE BAD
        CMPA $101,U
        BNE BAD
        CMPA $102,U
        BNE BAD

        PSHS DP
        PULS B
        CMPB #1
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

        DC.B  [$FFFE-*]0
        FDB   RESET