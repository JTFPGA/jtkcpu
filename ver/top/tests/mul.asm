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
RESET:  LDX #1234
        LDA #$0A
        LDB #$1D
        MUL
        BCS BAD         ; Test C flag
        BEQ BAD         ; Test Z flag

        CMPB #$22
        BNE BAD
        CMPA #$01
        BNE BAD

        LDA #$0F
        LDB #$10
        MUL
        BCC BAD         ; Test C flag
        BEQ BAD         ; Test Z flag
        CMPD #$F0
        BNE BAD

        CLRA            ; Test Z flag
        MUL
        BNE BAD

        CLRA
        CLRB
        CMPD #$0000
        BNE BAD

        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

