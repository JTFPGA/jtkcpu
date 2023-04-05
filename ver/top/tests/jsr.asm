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

        ORG  $F000
RESET:
        LDS  #$1000
        CLRA
        LEAX PROC
        JSR  ,X
RTSA:
        BNE   BAD

        CLRA
        LEAY ONE2
        JSR  2,Y
        CMPA #1
        BNE BAD


        include finish.inc

PROC:
        LDD ,S
        CMPD #RTSA
        BNE BAD
        BEQ END
ONE2    BRA BAD
ONE:
        LDA   #1
        RTS

        DC.B  [$FFFE-*]0
        FDB   RESET