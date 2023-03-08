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

    // to do: add all status signals from
    // other blocks

    // control outputs
    output          pul_go,
    output          psh_go,
    // to do: add all control signals to other
    // blocks that will be generated here
);

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
localparam [5:0] SINGLE_ALU = 1,
                 MULTI_ALU  = 2,
                 SBRANCH    = 3,
                 LBRANCH    = 4,
                 LOOPX      = 5,
                 LOOPB      = 6,
                 BMOVE      = 7,
                 MOVE       = 8,
                 BSETA      = 9,
                 BSETD      = 10,
                 RIT        = 11,
                 RTS        = 12,
                 JMP        = 13,
                 JSR        = 14
                 PSH        = 15,
                 PUL        = 16,
                 NOP        = 17, 
                 SETLINES   = 18, // missing
                 STORE      = 19; // to do: add more as needed

reg [UCODE_DW-1:0] mem[0:2**(UCODE_AW-1)];
reg [UCODE_AW-1:0] addr; // current ucode position read
reg [OPCAT_AW-1:0] opcat;
reg                idx_src; // instruction requires idx decoding first to grab the source operand

wire ni, buserror; // next instruction

// Conversion of opcodes to op category
always @* begin
    // to do: fill the rest
    case( op )
        ADDA_IMM,ADDB_IMM,ADDA_IDX,ADDB_IDX,ADDD_IMM,ADDD_IDX,ADCA_IMM,ADCB_IMM,ADCA_IDX,ADCB_IDX,LDX_IMM,LDX_IDX,
        SUBA_IMM,SUBB_IMM,SUBA_IDX,SUBB_IDX,SUBD_IMM,SUBD_IDX,SBCA_IMM,SBCB_IMM,SBCA_IDX,SBCB_IDX,LDY_IMM,LDY_IDX,
        CMPA_IMM,CMPB_IMM,CMPA_IDX,CMPB_IDX,CMPD_IMM,CMPD_IDX,CMPX_IMM,CMPX_IDX,CMPY_IMM,CMPY_IDX,LDU_IMM,LDU_IDX,
        CMPU_IMM,CMPU_IDX,CMPS_IMM,CMPS_IDX,ANDA_IMM,ANDB_IMM,ANDA_IDX,ANDB_IDX,BITA_IMM,BITB_IMM,LDS_IMM,LDS_IDX,
        BITA_IDX,BITB_IMM,EORA_IMM,EORB_IMM,EORA_IDX,EORB_IDX,ORA_IMM,ORB_IMM,ORA_IDX,ORB_IDX,ABX,LDD_IMM,LDD_IDX,
        LDA_IMM,LDB_IMM,LDA_IDX,LDB_IDX,STA,STB,TSTA,TSTB,TST,STD,STX,STY,STU,STS,TSTD,TSTW,ANDCC,ABSA,ABSB,ABSD,
        CLR,CLRA,CLRB,CLRD,CLRW,COMA,COMB,COM,NEGA,NEGB,NEG,NEGD,NEGW,INCA,INCB,INC,INCD,INCW,ORCC,
        LEAX,LEAY,LEAU,LEAS,DEC,DECA,DECB,DECD,DECW : opcat = SINGLE_ALU; 
        LSRA,LSRB,LSR,LSRW,LSRD_IMM,LSRD_IDX,ROLA,ROLB,ROL,ROLW,ROLD_IMM,ROLD_IDX,DIV_X_B,SEX,MUL,
        ASRA,ASRB,ASR,ASRW,ASRD_IMM,ASRD_IDX,ASLA,ASLB,ASL,ASLW,ASLD_IMM,ASLD_IDX,LMUL,DAA: opcat = MULTI_ALU;
        BSR,BRA,BRN,BHI,BLS,BCC,BCS,BNE,BEQ,BVC,BVS,BPL,BMI,BGE,BLT,BGT,BLE: opcat = SBRANCH;
        LBSR,LBRA,LBRN,LBHI,LBLS,LBCC,LBCS,LBNE,LBEQ,LBVC,LBVS,LBPL,LBMI,LBGE,LBLT,LBGT,LBLE: opcat = LBRANCH;
        DECX_JNZ:     opcat = LOOPX;
        DECB_JNZ:     opcat = LOOPB;
        MOVE_Y_X_U:   opcat = MOVE;
        BMOVE_Y_X_U:  opcat = BMOVE;
        BSETA_X_U:    opcat = BSETA;
        BSETD_X_U:    opcat = BSETD;
        RTI:          opcat = RIT;
        RTS:          opcat = RTS;
        JMP:          opcat = JMP;
        JSR:          opcat = JSR;
        PUSHU, PUSHS: opcat = PSH;
        PULLU, PULLS: opcat = PUL;
        opcat = STORE;
        default: opcat = BUSERROR; // stop condition
    endcase
end

always @* begin
    case( op )
        ADDA_IDX,ADDB_IDX,ADDD_IDX,ADCA_IDX,ADCB_IDX,SUBA_IDX,SUBB_IDX,SUBD_IDX,LDD_IDX,
        SBCA_IDX,SBCB_IDX,CMPA_IDX,CMPB_IDX,CMPD_IDX,CMPX_IDX,CMPY_IDX,CMPU_IDX,LDX_IDX, 
        CMPS_IDX,ANDA_IDX,ANDB_IDX,BITA_IDX,BITB_IDX,EORA_IDX,EORB_IDX,LSRD_IDX,LDY_IDX, 
        RORD_IDX,ASRD_IDX,ASLD_IDX,ROLD_IDX, ORA_IDX, ORB_IDX, LDA_IDX, LDB_IDX,LDU_IDX, 
        LSRW,LSR,RORW,ROR,ASRW,ASR,ASLW,ASL,ROLW,ROL,LEAX,STX,LEAY,STY,LEAU,STU,LDS_IDX,
        CLRW,CLR,NEGW,NEG,INCW,INC,DECW,DEC,TSTW,TST,LEAS,STS,STA,STB,STD,COM,JMP,JSR,
        SETLINES_IDX: idx_src = 1;  
        default: idx_src = 0;
    endcase
end

// get ucode data from a hex file
// initial begin
//     $readmemh( mem, "jtkcpu_ucode.hex");
// end

// to do: add all output signals to come
// from the current memory row being read
assign { /* add other control signals */ psh_go, pul_go, buserror, ni } = mem[addr];

always @(posedge clk) begin
    if( rst ) begin
        addr <= 0;  // Reset starts ucode at 0
    end else if(cen && !buserror) begin
        // To do: add the rest of control flow to addr progress
        addr <= addr + 1; // when we keep processing an opcode routine
        if( ni ) addr <= {1'd0,opcat,4'd0}; // when a new opcode is read
    end
end

endmodule