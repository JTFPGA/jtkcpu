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
        LDS #RAMEND
        LDA #$40
        STA TESTCTRL
        LDA #5

LOOP:   ; Spend some time here, the FIRQ should be ignored because of default CC
        CMPB #5
        BEQ BAD
        DECA
        BNE LOOP

        LDA #$10        ; enable FIRQ, keep IRQ disabled
        PSHS A
        PULS CC
LOOP2:
        CMPB #5
        BNE LOOP2

        CMPS #RAMEND    ; S should be at the top
        BNE BAD

        include finish.inc

FIRQ:   CLRA
        STA TESTCTRL            ; Clear FIRQ request
        PSHS CC                 ; Check that bit F is set
        PULS A
        ANDA #$40
        BEQ BAD
        LDB #5
        RTI
        BRA BAD
IRQ:
NMI:

        DC.B  [$FFF6-*]0
        FDB   FIRQ,IRQ,$FFFF,NMI,RESET