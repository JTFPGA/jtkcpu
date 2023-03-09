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
    input           irq,

    // to do: add all status signals from
    // other blocks

    // control outputs
    output reg      inter,
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
        CMPA_IMM, LDA_IMM, ANDA_IMM, ADDA_IMM, SUBA_IMM, CLRA, INCA, NEGA, ANDCC,
        CMPB_IMM, LDB_IMM, ANDB_IMM, ADDB_IMM, SUBB_IMM, CLRB, INCB, NEGB,  ORCC,
        CMPD_IMM, LDD_IMM, BITA_IMM, ADDD_IMM, SUBD_IMM, CLRD, INCD, NEGD,  COMB,
        CMPX_IMM, LDX_IMM, BITB_IMM, ADCA_IMM, SBCA_IMM, CLRW, INCW, NEGW,  COMA,
        CMPY_IMM, LDY_IMM, EORA_IMM, ADCB_IMM, SBCB_IMM,  CLR,  INC,  NEG,   COM,
        CMPU_IMM, LDU_IMM, EORB_IMM,  ORA_IMM,  ORB_IMM,                   
        CMPS_IMM, LDS_IMM,                                

        CMPA_IDX, LDA_IDX, ANDA_IDX, ADDA_IDX, SUBA_IDX, TSTA, DECA, LEAX, ABSA,
        CMPB_IDX, LDB_IDX, ANDB_IDX, ADDB_IDX, SUBB_IDX, TSTB, DECB, LEAY, ABSB,
        CMPD_IDX, LDD_IDX, BITA_IDX, ADDD_IDX, SUBD_IDX, TSTD, DECD, LEAU, ABSD,
        CMPX_IDX, LDX_IDX, BITB_IDX, ADCA_IDX, SBCA_IDX, TSTW, DECW, LEAS,  ABX,
        CMPY_IDX, LDY_IDX, EORA_IDX, ADCB_IDX, SBCB_IDX,  TST,  DEC,
        CMPU_IDX, LDU_IDX, EORB_IDX,  ORA_IDX,  ORB_IDX,                  
        CMPS_IDX, LDS_IDX:                                    opcat = SINGLE_ALU; 


        LSRD_IMM, LSRD_IDX, LSRA, LSRB, LSRW, LSR, DIV_X_B,
        RORD_IMM, RORD_IDX, RORA, RORB, RORW, ROR,    LMUL,
        ASRD_IMM, ASRD_IDX, ASRA, ASRB, ASRW, ASR,     MUL,
        ASLD_IMM, ASLD_IDX, ASLA, ASLB, ASLW, ASL,     SEX,
        ROLD_IMM, ROLD_IDX, ROLA, ROLB, ROLW, ROL,     DAA:   opcat = MULTI_ALU;


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
        RTI:          opcat = RIT;
        RTS:          opcat = RTS;
        JMP:          opcat = JMP;
        JSR:          opcat = JSR;
        PUSHU, PUSHS: opcat = PSH;
        PULLU, PULLS: opcat = PUL;
        NOP:          opcat = NOP;
        
        STA, STB, STD, STX, STY, STU, STS: opcat = STORE;
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

// to do: add all output signals to come
// from the current memory row being read
assign { /* add other control signals */ psh_go, pul_go, buserror, ni } = mem[addr];

always @(posedge clk) begin
    if( rst ) begin
        addr <= 0;  // Reset starts ucode at 0
    end else if(cen && !buserror) begin
        // To do: add the rest of control flow to addr progress
        
        if (irq) begin // interrupción activada
                addr <= vector;
                inter <= 1;
        end else begin // interrupción no activada
                inter <= 0;
        end

        addr <= addr + 1; // when we keep processing an opcode routine
        if( ni ) addr <= {1'd0,opcat,4'd0}; // when a new opcode is read
    end
end

endmodule