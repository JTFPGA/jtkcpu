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
RESET:
		LEAS DATAS
        LEAU DATAU
		LDX ,S++
		CMPX #$BEBE
		BNE BAD
		LDY ,U++
		CMPY #$CAFE
		BNE BAD

		LDX  ,S++
        CMPX #$ABCD
        BNE  BAD

        LDX #$1234

        LDX  ,S++
        CMPX #$FEED
        BNE  BAD

        LDX #$4321

        LDX  ,--S
        CMPX #$FEED
        BNE  BAD

		LDY #$5555

		LDY  ,--U
        CMPY #$CAFE
        BNE  BAD

        LDY  ,U++
        CMPY #$CAFE
        BNE  BAD

        LDY  ,U++
        CMPY #$ABBA
        BNE  BAD

        LDY #$F003

        LDY  ,U++
        CMPY #$A1B2
        BNE  BAD

        include finish.inc

DATAS:  FDB   $BEBE, $ABCD, $FEED
DATAU:  FDB   $CAFE, $ABBA, $A1B2

        DC.B  [$FFFE-*]0
        FDB   RESET