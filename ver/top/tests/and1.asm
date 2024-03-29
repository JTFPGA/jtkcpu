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
RESET:  LDX #DATAR
        LDB #05

LOOP:   LDA  ,X
        COMA
        ANDA ,X
        BNE BAD
        DECB
        BNE LOOP

        include finish.inc


DATAR:  FCB 1,2,3,4,5

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

