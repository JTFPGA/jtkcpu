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
RESET:  LEAU DATAR
        LDD  ,U++
        CMPD #$CAFE
        BNE  BAD

        LDD  ,U++
        CMPD #$BEEF
        BNE  BAD

        LDD  ,U++
        CMPD #$DED0
        BNE  BAD

        LDD  #$5555

        LDD  ,--U
        CMPD #$DED0
        BNE  BAD

        LDD  ,--U
        CMPD #$BEEF
        BNE  BAD

        LDD  ,--U
        CMPD #$CAFE
        BNE  BAD

        CMPU #DATAR
        BNE  BAD

        include finish.inc

DATAR:  FDB   $CAFE, $BEEF, $DED0

        DC.B  [$FFFE-*]0
        FDB   RESET