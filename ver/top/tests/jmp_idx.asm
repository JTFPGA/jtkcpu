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
DATAW    EQU $0100

        ORG $F000
RESET:  NOP
        ; store the jump destination minus an offset
        LDD #NEAR
        LDY #$100
        STD 2,Y
        LDA #2

        JMP [A,Y]
        BRA BAD
        DC.B    [$23]0
        BRA BAD
NEAR:
        BRA END

        include finish.inc

DATAR:  FDB   $1234, $5678, $9ABC, $DEF0

        DC.B  [$FFFE-*]0
        FDB   RESET