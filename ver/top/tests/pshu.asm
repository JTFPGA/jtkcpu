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
DATAW    EQU $0100

        ORG $F000
RESET:  LDU #RAMEND
        CLRB
        LDA #$23
        PSHU A                  ; PUSH A

        LDB ,U
        CMPB #$23
        BNE BAD

        CLRA
        PSHU B                  ; PUSH B
        LDA ,U
        CMPA #$23
        BNE BAD

        LDD #$1234              ; PUSH D
        PSHU D
        CLRD
        CMPD #0
        BNE BAD
        LDD ,U
        CMPD #$1234
        BNE BAD

        LDX #$CAFE              ; PUSH X,Y,S
        LDY #$BEEF
        LDS #$DACA
        PSHU X,Y,S
        CMPX ,U
        BNE BAD
        CMPY 2,U
        BNE BAD
        CMPU 4,U
        BNE BAD

        ORCC #$FF
        PSHU CC
        LDA ,U
        CMPA #$FF
        BNE BAD

        include finish.inc

DATAR:  FDB   END,$1234, $5678, $9ABC, $DEF0

        DC.B  [$FFFE-*]0
        FDB   RESET