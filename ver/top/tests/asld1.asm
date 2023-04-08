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
RESET:  LEAS RAMEND
        LEAU RANDOM

        LDA #$10        ; Will run these many iterations
LOOP:
        PSHS A

        LDD A,U         ; Value to shift
        PSHS D
        LDA 2,S         ; Number of times to shifti t
        ADDA #4
        LDD A,U
        ANDA #0
        ANDB #$F
        PSHS D
        BSR CHECK       ; shift and check
        LEAS 4,S        ; restore the stack

        PULS A          ; restore the count
        SUBA #2
        BNE LOOP

        LBRA END

CHECK:  ; MODIFIES D, Y
        LDD 4,S
        STD -2,S
        LDA 3,S
        ASLD -2,S

        LDD 4,S
        LDY 2,S
CK_L2:  ASLB            ; the comparison value is built step by step
        ROLA
        LEAY -1,Y
        BNE CK_L2
        CMPD -2,S
        BNE BAD
        RTS

        include finish.inc

RANDOM: DC.W $1CC7, $6255, $578B, $0135, $4628, $14BE, $7AE3, $6796
        DC.W $4AE4, $7263, $0126, $680E, $06AF, $79BD, $6F31, $1365
        DC.W $0288, $473F, $1D26, $6770, $0C62, $2DBF, $0270, $0A7B
        DC.W $23E1, $438A, $5739, $7900, $6F6B, $76B6, $5855, $6D1D
        DC.W $0BA4, $65AF, $72C4, $421E, $7645, $2FE8, $2D4C, $7AB3
        DC.W $1868, $7F43, $0A76, $7AF3, $19BE, $1EEA, $1B16, $43DE
        DC.W $463E, $3D25, $5144, $75A4, $0A67, $2C65, $368E, $3C5B
        DC.W $07FD, $0E43, $59EB, $0E2D, $2CF6, $5683, $5CEE, $33C0

; fill with zeros... up to interrupt table
        DC.B  [$FFFE-*]0
        FDB   RESET

