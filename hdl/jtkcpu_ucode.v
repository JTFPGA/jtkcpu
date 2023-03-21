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
    input           idx_busy,
    input           irq,
    input           nmi,
    input           firq,

    // control outputs from ucode
    output          adr_data, 
    output          adr_idx, 
    output          adrx,
    output          adry, 
    output          back1_unz, 
    output          back2_unz, 
    output          buserror, 
    output          clr_e, 
    output          decb, 
    output          decu, 
    output          decx, 
    output          idx_en, 
    output          idx_ld, 
    output          idx_ret, 
    output          idx_step, 
    output          incx, 
    output          incy, 
    output          jmp_idx, 
    output          mem16, 
    output          memhi, 
    output          ni, 
    output          opd, 
    output          psh_all, 
    output          psh_cc, 
    output          psh_go, 
    output          psh_pc, 
    output          pul_go, 
    output          pul_pc, 
    output          rti_cc, 
    output          rti_other, 
    output          set_e, 
    output          set_f, 
    output          set_i, 
    output          set_opn0_a, 
    output          set_opn0_b, 
    output          set_opn0_mem, 
    output          set_opn0_regs, 
    output          set_pc_bnz_branch, 
    output          set_pc_branch16, 
    output          set_pc_branch8, 
    output          set_pc_int, 
    output          set_pc_jmp, 
    output          set_pc_xnz_branch, 
    output          set_upregs_alu, 
    output          skip_noind, 
    output          up_data, 
    output          up_ld16, 
    output          up_ld8, 
    output          up_lea, 
    output          up_lines, 
    output          up_lmul, 
    output          we, 
    output          int_en,

    // other outputs
    output    [3:0] intvec
);

`include "jtkcpu.inc";

// Op codes = 8 bits, many op-codes will be parsed in the
// same way. Let's assume we only need 64 ucode routines
// 64 = 2^6, Using 2^10 memory rows -> 2^4=16 rows per
// routine
// To do: group op codes in categories that can be parsed
// using the same ucode. 32 categories used for op codes
// another 32 categories reserved for common routines

// localparam UCODE_AW = 10; // 1024 ucode lines

`include "jtkcpu_ucode.inc";

reg [UCODE_DW-1:0] mem[0:2**(UCODE_AW-1)], ucode;
reg [UCODE_AW-1:0] addr; // current ucode position read
reg [OPCAT_AW-1:0] opcat, after_idx, nx_after_idx;
reg                idx_src; // instruction requires idx decoding first to grab the source operand
reg          [3:0] cur_int;

wire wait_stack, waitalu;  

localparam [UCODE_AW-OPCAT_AW-1:0] OPLEN=0;

// Conversion of opcodes to op category
always @* begin
    nx_after_idx = after_idx;
    case( op ) 
        CMPA_IMM, ANDA_IMM, ADDA_IMM, SUBA_IMM, LDA_IMM, 
        CMPB_IMM, ANDB_IMM, ADDB_IMM, SUBB_IMM, LDB_IMM, 
        EORA_IMM, BITA_IMM, ADCA_IMM, SBCA_IMM, ORA_IMM, ANDCC,
        EORB_IMM, BITB_IMM, ADCB_IMM, SBCB_IMM, ORB_IMM,  ORCC,
        LSRA,     RORA,     ASRA,     ASLA,     ROLA,
        LSRB,     RORB,     ASRB,     ASLB,     ROLB:               opcat = SINGLE_ALU;
       
        CMPD_IMM, CMPY_IMM, LDD_IMM, LDY_IMM, ADDD_IMM, CMPS_IMM,  
        CMPX_IMM, CMPU_IMM, LDX_IMM, LDU_IMM, SUBD_IMM,  LDS_IMM:   opcat = SINGLE_ALU_16;
        
        CLRA, INCA, NEGA, COMB, TSTB, DECB, ABSA, SEX, ABX,
        CLRB, INCB, NEGB, COMA, TSTA, DECA, ABSB, DAA:              opcat = SINGLE_ALU_INH;
        CLRD, INCD, NEGD,       TSTD, DECD, ABSD:                   opcat = SINGLE_ALU_INH16;
         
        CLR,  INC,  NEG,  COM,  TST,  DEC,
        LSR,  ROR,  ASR,  ASL,  ROL:                                opcat = MEM_ALU_IDX;

        // Operand in indexed memory
        CMPA_IDX, ANDA_IDX, ADDA_IDX, SUBA_IDX, LDA_IDX,  
        EORA_IDX, BITA_IDX, ADCA_IDX, SBCA_IDX, ORA_IDX,        
        CMPB_IDX, ANDB_IDX, ADDB_IDX, SUBB_IDX, LDB_IDX,   
        EORB_IDX, BITB_IDX, ADCB_IDX, SBCB_IDX, ORB_IDX:            begin
            opcat        = PARSE_IDX;
            nx_after_idx = SINGLE_ALU_IDX;
        end
        
        CMPD_IDX, CMPU_IDX, LDU_IDX, LDD_IDX, LEAU, LEAX, ADDD_IDX,
        CMPX_IDX, CMPS_IDX, LDS_IDX, LDX_IDX, LEAS, LEAY, SUBD_IDX,
        CMPY_IDX,           LDY_IDX:                                begin
            opcat        = PARSE_IDX;
            nx_after_idx = SINGLE_ALU_IDX16;
        end

// FIX MULTI_ALU_INH
        MUL, LMUL:                                                  opcat = MULTIPLY;
        DIV_X_B:                                                    opcat = MULTI_ALU_INH;
        LSRD_IMM, RORD_IMM, ASRD_IMM, ASLD_IMM, ROLD_IMM:           opcat = MULTI_ALU;
        LSRD_IDX, RORD_IDX, ASRD_IDX, ASLD_IDX, ROLD_IDX:           opcat = MULTI_ALU_IDX;

        LSRW, RORW, ASRW, ASLW, ROLW, NEGW, CLRW, INCW, DECW, TSTW:  opcat = WMEM_ALU;
        BSR, BRA, BRN, BHI, BLS, BCC, BCS, BNE, 
        BEQ, BVC, BVS, BPL, BMI, BGE, BLT, BGT, BLE:                 opcat = SBRANCH;
        LBSR, LBRA, LBRN, LBHI, LBLS, LBCC, LBCS, LBNE, 
        LBEQ, LBVC, LBVS, LBPL, LBMI, LBGE, LBLT, LBGT, LBLE:        opcat = LBRANCH;
        
        DECX_JNZ:       opcat = LOOPX;
        DECB_JNZ:       opcat = LOOPB;
        MOVE_Y_X_U:     opcat = MOVE;
        BMOVE_Y_X_U:    opcat = BMOVE;
        BSETA_X_U:      opcat = BSETA;
        BSETD_X_U:      opcat = BSETD;
        RTI:            opcat = RTIT;
        RTS:            opcat = RTSR;
        JMP:            opcat = JUMP;
        JSR:            opcat = JMSR;
        PUSHU, PUSHS:   opcat = PSH;
        PULLU, PULLS:   opcat = PUL;
        NOP:            opcat = NOPE;
        // SETLINES_IDX    opcat = SETLINES
        
        STA, STB:       opcat = STORE8;
        STD, STX, STY,
        STU, STS:       opcat = STORE16;
        default:        opcat = BUSERROR; // stop condition
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

assign intvec = cur_int & {4{int_en}};

always @(posedge clk) begin
    if( rst ) begin
        addr    <= 0;  // Reset starts ucode at 0
        cur_int <= 0;
    end else if( cen && !buserror ) begin
        after_idx <= nx_after_idx;

        if( !mem_busy && !(idx_en && idx_busy)) begin
            addr <= addr + 1; // keep processing an opcode routine
            if( skip_noind && !op[4] ) begin
                addr <= addr + 2;
            end
        end
        if( ni ) begin
            if( nmi ) begin // interrupt enabled irq
                cur_int <= 4'b0100;
                addr    <= { NMI, OPLEN };
            end else if( firq ) begin  // interrupt enabled nmi
                cur_int <= 4'b0010;
                addr    <= { FIRQ, OPLEN };
            end else if ( irq ) begin  // interrupt enabled firq
                cur_int <= 4'b0001;
                addr    <= { IRQ, OPLEN };
            end else begin   // interrupt disabled
                cur_int <= 0;
                addr    <= { opcat, OPLEN }; // when a new opcode is read
            end
        end
        // Indexed addressing parsing
        if( jmp_idx ) begin
            if( !op[7] ) begin
                addr <= { IDX_SUM, OPLEN };
            end else begin
                case( op[3:0] )
                    0:        addr <= { IDX_RINC, OPLEN };
                    1:        addr <= { IDX_RINC2, OPLEN };
                    2:        addr <= { IDX_RDEC, OPLEN };
                    3:        addr <= { IDX_RDEC2, OPLEN };
                    4,5,6,11: addr <= { IDX_SUM, OPLEN };
                    8,12:     addr <= { IDX_OFFSET8, OPLEN };
                    9,13:     addr <= { IDX_OFFSET16, OPLEN };
                    15:       addr <= { IDX_EXTIND, OPLEN };
                endcase
            end
        end
        if( idx_ret ) begin
            addr <= { after_idx, OPLEN };
        end
    end
end

endmodule