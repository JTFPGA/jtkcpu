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
RESET:
        LDA #$87
        ROLA            ;(1)0E
        BVC BAD
        BCC BAD
        ROLA            ;(0)1D
        BVS BAD
        BCS BAD

        ROLA            ;(0)3A
        ROLA            ;(0)74
        CMPA #$74
        BNE BAD
        ORCC #1
        ROLA            ;(0)E9
        BCS BAD
        CMPA #$E9
        BNE BAD
        ROLA
        BCC BAD

        ANDCC #$FE
        LDB #$15
        ROLB
        CMPB #$2A
        BNE BAD

        CLRA
        LDA #$80
        ROLA
        ROLA
        CMPA #$01
        BNE BAD

        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

