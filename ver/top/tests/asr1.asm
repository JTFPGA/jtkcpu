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
RESET:  LDB #$40
        STB ,U

        ASR ,U
        BCS BAD
        BEQ BAD
        BMI BAD
        BVS BAD

        ASR ,U
        BCS BAD
        BEQ BAD
        BMI BAD
        BVS BAD

        ASR ,U
        BCS BAD
        BEQ BAD
        BMI BAD
        BVS BAD

        LDB ,U
        CMPB #$08
        BNE BAD

        ASR ,U
        BCS BAD
        BEQ BAD
        BMI BAD
        BVS BAD

        ASR ,U
        BCS BAD
        BEQ BAD
        BMI BAD
        BVS BAD

        ASR ,U
        BCS BAD
        BEQ BAD
        BMI BAD
        BVS BAD

        ASR ,U
        BCC BAD
        BNE BAD
        BMI BAD
        BVS BAD

        LDA #$FE
        STA ,X
        ASR ,X
        ASR ,X
        BCC BAD
        BPL BAD
        LDA ,X
        CMPA #$FF
        BNE BAD

        include finish.inc

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

