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
        LDA #$20        ; Sets the IRQ pin
        STA TESTCTRL
        LDA #5

LOOP:   ; Spend some time here, the IRQ should be ignored because of default CC
        CMPB #5
        BEQ BAD
        DECA
        BNE LOOP

        ; Set some register values that the IRQ service routine will change
        LDX #$1234
        LDY #$5678
        LDU #$9ABC

        CLRA        ; enable interrupts
        PSHS A
        PULS CC
        NOP
        NOP
        NOP             ; the interrupt should happen around here
        NOP
        NOP
        NOP
        PSHS CC         ; check that the CC was restored correctly
        PULS A
        CMPA #$80
        BNE BAD
LOOP2:
        CMPX #$1234     ; these registers should be the same after the IRQ service
        BNE BAD
        CMPY #$5678
        BNE BAD
        CMPU #$9ABC
        BNE BAD

        LDB <0      ; the service changes this byte
        CMPB #5
        BNE LOOP2

        CMPS #RAMEND    ; S should be at the top
        BNE BAD

        include finish.inc

FIRQ:
        BRA BAD
IRQ:
        ANDCC #$7F       ; Clear the E bit
        CLRA
        STA TESTCTRL    ; Clear the IRQ
        LDX #$DEAD      ; alter these, to check that all registers are pulled back
        LDU #$DEAD
        LDY #$DEAD
        LDA #5
        STA <0          ; leave a mark that we were here
        RTI
NMI:

        DC.B  [$FFF6-*]0
        FDB   FIRQ,IRQ,$FFFF,NMI,RESET