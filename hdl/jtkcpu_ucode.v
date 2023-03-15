/*  This file is part of JTKCPU.
    JTKCPU program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTKCPU program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTKCPU.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 3-03-2023 */

module jtkcpu_ucode(
    input           rst,
    input           clk,
    input           cen,

    input     [7:0] op, // data fetched from memory
    // status inputs
    input           branch,
    input           alu_busy,
    input           mem_busy,
    input           irq,
    input           nmi,
    input           firq,

    // to do: add all status signals from
    // other blocks

    // control outputs
    output reg      int_en,
    output          we, 
    output          pul_go, 
    output          psh_go, 
    output          pshpc, 
    output          pshcc, 
    output          pshall, 
    output          set_pc_xnz_branch, 
    output          set_pc_bnz_branch, 
    output          set_pc_vector, 
    output          set_pc_puls, 
    output          set_pc_branch, 
    output          set_opn0_regs, 
    output          set_opn0_d, 
    output          set_opn0_a, 
    output          mem16, 
    output          incx, 
    output          ifirq_pulall, 
    output          iffirq_pulpc, 
    output          iffirq_pulcc, 
    output          set_i, 
    output          set_f, 
    output          extsgn, 
    output          set_e, 
    output          clr_e, 
    output          decx, 
    output          decu, 
    output          decb, 
    output          adry, 
    output          adrx, 
    output          adridx
    
    // to do: add all control signals to other
    // blocks that will be generated here
);

`include "jtkcpu.inc"

// Op codes = 8 bits, many op-codes will be parsed in the
// same way. Let's assume we only need 64 ucode routines
// 64 = 2^6, Using 2^10 memory rows -> 2^4=16 rows per
// routine
// To do: group op codes in categories that can be parsed
// using the same ucode. 32 categories used for op codes
// another 32 categories reserved for common routines

localparam UCODE_AW = 10, // 1024 ucode lines
           OPCAT_AW = 5,  // op code categories
           UCODE_DW = 24; // Number of control signals

// to do: define localparam with op categories
localparam [5:0] SINGLE_ALU       = 1,
                 SINGLE_ALU16     = 2,
                 SINGLE_ALU_IDX   = 3,
                 SINGLE_ALU_IDX16 = 4,
                 MULTI_ALU        = 5,
                 WMEM_ALU         = 6,
                 SBRANCH          = 7,
                 LBRANCH          = 8,
                 LOOPX            = 9,
                 LOOPB            = 10,
                 BMOVE            = 11,
                 MOVE             = 12,
                 BSETA            = 13,
                 BSETD            = 14,
                 RTIT             = 15,
                 RTSR             = 16,
                 JUMP             = 17,
                 JMSR             = 18,
                 PSH              = 19,
                 PUL              = 20,
                 NOPE             = 21, 
                 SETLINES         = 22, // missing
                 STORE8           = 23,
                 STORE16          = 24,
                 FIRQ             = 25,
                 IRQ              = 26,
                 NMI              = 27;

reg [UCODE_DW-1:0] mem[0:2**(UCODE_AW-1)];
reg [UCODE_AW-1:0] addr; // current ucode position read
reg [OPCAT_AW-1:0] opcat;
reg                idx_src; // instruction requires idx decoding first to grab the source operand

wire ni, buserror; // next instruction
wire waituz, wait16;  


// Conversion of opcodes to op category
always @* begin
    case( op ) 

        CMPA_IMM, ANDA_IMM, ADDA_IMM, SUBA_IMM, LDA_IMM, CLRA, INCA, NEGA, ANDCC, COMB,
        CMPB_IMM, ANDB_IMM, ADDB_IMM, SUBB_IMM, LDB_IMM, CLRB, INCB, NEGB,  ORCC, COMA,
        EORA_IMM, BITA_IMM, ADCA_IMM, SBCA_IMM, ORA_IMM,  CLR,  INC,  NEG,   COM,
        EORB_IMM, BITB_IMM, ADCB_IMM, SBCB_IMM, ORB_IMM:             opcat = SINGLE_ALU;
             
        CMPD_IMM, CMPY_IMM, LDD_IMM, LDY_IMM, ADDD_IMM, CLRD, INCD, NEGD,  
        CMPX_IMM, CMPU_IMM, LDX_IMM, LDU_IMM, SUBD_IMM,                      
                  CMPS_IMM, LDS_IMM:                                 opcat = SINGLE_ALU16; 

        CMPA_IDX, ANDA_IDX, ADDA_IDX, SUBA_IDX, LDA_IDX, ABSA, ABSB,
        CMPB_IDX, ANDB_IDX, ADDB_IDX, SUBB_IDX, LDB_IDX, TSTA, DECA,  
        EORA_IDX, BITA_IDX, ADCA_IDX, SBCA_IDX, ORA_IDX, TSTB, DECB,       
        EORB_IDX, BITB_IDX, ADCB_IDX, SBCB_IDX, ORB_IDX,  TST,  DEC: opcat = SINGLE_ALU_IDX;              
        
        CMPD_IDX, CMPU_IDX, LDU_IDX, LDD_IDX, LEAU, LEAX, ADDD_IDX, DECD, TSTD, ABSD,
        CMPX_IDX, CMPS_IDX, LDS_IDX, LDX_IDX, LEAS, LEAY, SUBD_IDX,  ABX,
        CMPY_IDX,           LDY_IDX:                                 opcat = SINGLE_ALU_IDX16; 

        LSRD_IMM, LSRD_IDX, LSRA, LSRB, LSR, DIV_X_B,
        RORD_IMM, RORD_IDX, RORA, RORB, ROR,    LMUL,
        ASRD_IMM, ASRD_IDX, ASRA, ASRB, ASR,     MUL,
        ASLD_IMM, ASLD_IDX, ASLA, ASLB, ASL,     SEX,
        ROLD_IMM, ROLD_IDX, ROLA, ROLB, ROL,     DAA:                opcat = MULTI_ALU;

        LSRW, RORW, ASRW, ASLW, ROLW, NEGW, CLRW, INCW, DECW, TSTW:  opcat = WMEM_ALU;

        BSR, BRA, BRN, BHI, BLS, BCC, BCS, BNE, 
        BEQ, BVC, BVS, BPL, BMI, BGE, BLT, BGT, BLE:          opcat = SBRANCH;

        LBSR, LBRA, LBRN, LBHI, LBLS, LBCC, LBCS, LBNE, 
        LBEQ, LBVC, LBVS, LBPL, LBMI, LBGE, LBLT, LBGT, LBLE: opcat = LBRANCH;
        
        DECX_JNZ:     opcat = LOOPX;
        DECB_JNZ:     opcat = LOOPB;
        MOVE_Y_X_U:   opcat = MOVE;
        BMOVE_Y_X_U:  opcat = BMOVE;
        BSETA_X_U:    opcat = BSETA;
        BSETD_X_U:    opcat = BSETD;
        RTI:          opcat = RTIT;
        RTS:          opcat = RTSR;
        JMP:          opcat = JUMP;
        JSR:          opcat = JMSR;
        PUSHU, PUSHS: opcat = PSH;
        PULLU, PULLS: opcat = PUL;
        NOP:          opcat = NOPE;
        
        STA, STB:                opcat = STORE8;
        STD, STX, STY, STU, STS: opcat = STORE16;
        default: opcat = BUSERROR; // stop condition
    endcase
end

always @* begin
    case( op )

        CMPA_IDX, LDA_IDX, ANDA_IDX, ADDA_IDX, SUBA_IDX, LSRD_IDX, LSRW, LSR, CLRW, CLR, LEAX, STX, STA,
        CMPB_IDX, LDB_IDX, ANDB_IDX, ADDB_IDX, SUBB_IDX, RORD_IDX, RORW, ROR, NEGW, NEG, LEAY, STY, STB,
        CMPD_IDX, LDD_IDX, BITA_IDX, ADDD_IDX, SUBD_IDX, ASRD_IDX, ASRW, ASR, INCW, INC, LEAU, STU, JMP,
        CMPX_IDX, LDX_IDX, BITB_IDX, ADCA_IDX, SBCA_IDX, ASLD_IDX, ASLW, ASL, DECW, DEC, LEAS, STS, JSR,
        CMPY_IDX, LDY_IDX, EORA_IDX, ADCB_IDX, SBCB_IDX, ROLD_IDX, ROLW, ROL, TSTW, TST,       STD, COM,
        CMPU_IDX, LDU_IDX, EORB_IDX,  ORA_IDX,  ORB_IDX,
        CMPS_IDX, LDS_IDX, SETLINES_IDX:                    idx_src = 1;       

        default: idx_src = 0;
    endcase
end

// get ucode data from a hex file
// initial begin
//     $readmemh( mem, "jtkcpu_ucode.hex");
// end

always @(posedge clk) begin
    if( rst ) begin
        addr <= 0;  // Reset starts ucode at 0
        int_en <= 0;  
    end else if( cen && !buserror ) begin
        // To do: add the rest of control flow to addr progress
        
        if( irq ) begin // interrupt enabled irq
            addr <= { 1'd0, IRQ, 4'd0 };
            int_en <= 1;
        end else if( nmi ) begin  // interrupt enabled nmi
                addr <= { 1'd0, NMI, 4'd0 };
        end else if ( firq ) begin  // interrupt enabled firq
             addr <= { 1'd0, FIRQ, 4'd0 };
             int_en = 1;
        end else    // interrupt disabled
            int_en = 0;

        if( !mem_busy ) addr <= addr + 1; // when we keep processing an opcode routine
        if( ni ) addr <= { 1'd0, opcat, 4'd0 }; // when a new opcode is read
    end
end

endmodule