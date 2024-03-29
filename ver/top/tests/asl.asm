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
RESET:  LDA #$1

        ASLA
        BCS BAD
        BVS BAD
        BEQ BAD

        ASLA
        BCS BAD
        BVS BAD
        BEQ BAD

        ASLA
        BCS BAD
        BVS BAD
        BEQ BAD

        ASLA
        BCS BAD
        BVS BAD
        BEQ BAD

        ASLA
        BCS BAD
        BVS BAD
        BEQ BAD
        CMPA #$20
        BNE BAD

        ASLA
        BCS BAD
        BVS BAD
        BEQ BAD

        ASLA
        BCS BAD
        BVC BAD
        BEQ BAD

        ASLA
        BCC BAD
        BVC BAD
        BNE BAD

        LDB #$0F
        ASLB
        ASLB
        ASLB
        CMPB #$78
        BNE BAD

        LDA #$8F
        ASLA
        BVC BAD

        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

