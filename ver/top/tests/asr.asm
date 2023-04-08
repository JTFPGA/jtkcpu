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
RESET:  LDB #$0B
        ASRB
        ASRB
        ASRB
        CMPB #$01
        BNE BAD

        LDA #$34
        ASRA
        ASRA
        CMPA #$0D
        BNE BAD

        LDA #$80
        ASRA
        BCS BAD
        BPL BAD
        BVS BAD
        ASRA
        BCS BAD
        BPL BAD
        BVS BAD
        ASRA
        BCS BAD
        BPL BAD
        BVS BAD
        ASRA
        BCS BAD
        BPL BAD
        BVS BAD
        CMPA #$F8
        BNE BAD
        BVS BAD
        ASRA
        BCS BAD
        BPL BAD
        BVS BAD
        BVS BAD
        ASRA
        BCS BAD
        BPL BAD
        BVS BAD
        ASRA
        BCS BAD
        BPL BAD
        BVS BAD
        CMPA #$FF
        BNE BAD
        BVS BAD
        TFR A,B
        ASRB
        BCC BAD
        CMPB #$FF
        BVS BAD
        BNE BAD

        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

