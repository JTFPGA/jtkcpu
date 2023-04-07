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
RESET:  LDA #$55
        ABSA
        BVS BAD
        CMPA #$55
        BNE BAD

        LDB #-$23
        ABSB
        CMPB #$23
        BNE BAD

        LDB #$80
        ABSB
        BVC BAD
        CMPB #$80
        BNE BAD

        LDB #$FF
        ABSB
        BVS BAD
        CMPB #$1
        BNE BAD

        CLRA
        ABSA
        BNE BAD

        LDD #$8000
        ABSD
        BVC BAD
        CMPD #$8000
        BNE BAD

        LDD #$FFFF
        ABSD
        BVS BAD
        CMPB #$1
        BNE BAD

        LDD #$7FFF
        ABSD
        BVS BAD
        CMPD #$7FFF
        BNE BAD

        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

