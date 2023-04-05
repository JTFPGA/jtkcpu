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
	LDU ,S++
	CMPU #$DED0
	BNE BAD
	LDU ,S++
	CMPU #$ACBC
	BNE BAD
	LDX  ,S++
        CMPX #$BEE
        BNE  BAD
        LDU  ,--S
        CMPU #$BEE
        BNE  BAD

        LEAU DATAU
        LDS ,U++
        CMPS #$CAFE
        BNE  BAD
        LDS ,U++
        CMPS #$FEED
        BNE  BAD
        LDY  ,U++
        CMPY #$AAAA
        BNE  BAD
        LDS  ,--U
        CMPS #$AAAA
        BNE  BAD

        include finish.inc

DATAS:  FDB   $DED0, $ACBC, $BEE
DATAU:  FDB   $CAFE, $FEED, $AAAA

        DC.B  [$FFFE-*]0
        FDB   RESET