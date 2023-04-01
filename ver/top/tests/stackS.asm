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
RESET:  LDS #RAMEND
	LDA #$FE
	PSHS A
	LDB #$3C
	PSHS B
	CLRA
	CLRB
	PULS A
	PULS B
        CMPA #$3C
        BNE BAD
	CMPB #$FE
	BNE BAD

END:    LDX #$BABE
	LDA #1
	LDX #TESTCTRL
	STA ,X
        BRA END

BAD: 	LDX #$DEAD
	LDA #3
	LDX #TESTCTRL
	STA ,X
 	BRA BAD

        DC.B  [$FFFE-*]0
        FDB   RESET