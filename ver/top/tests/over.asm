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

        ORG $F000
RESET:
        LDA #$7F
        INCA
        BVC BAD

        LDA #$FF
        INCA
        BVC BAD

        LDB #0
        DECB
        BVC BAD

        LDB #$80
        DECB
        BVC BAD

        LDA #$7F
        ADDA #1
        BVC BAD
        SUBA #1
        BVC BAD

        LDA #$80
        SUBA #1
        BVC BAD
        ADDA #1
        BVC BAD

        CLRA
        LDA #$7F
        COMA
        CMPA #$80
        BNE BAD

        CLRD
        LDB #$80
        NEGB
        CMPB #$80
        BNE BAD
        NEGA
        CMPA #$00
        BNE BAD


        include finish.inc

        DC.B  [$FFFE-*]0
        FDB   RESET