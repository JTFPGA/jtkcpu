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
    input            rst,
    input            clk,
    input            cen /* synthesis direct_enable */,

    input     [ 7:0] cc,
    input     [ 7:0] op,     // data fetched from memory
    input     [15:0] mdata,
    output           intsrv,

    // indexed addressing
    output reg [2:0] idx_rsel,
    output reg [1:0] idx_asel,
    output reg       idx_post,
    output           idx_pre,
    output reg       idxw,
    output reg       idx_ld,
    output           idx_8,
    output           idx_16,
    output reg       idx_acc,
    output           idx_dp,
    output           idx_en,
    output           data2addr,
    // status inputs
    input           alu_busy,
    input           mem_busy,
    input           stack_busy,
    input           branch,
    input           irq_n,
    input           nmi_n,
    input           firq_n,
    input           uz,
    // control outputs from ucode
    output          addrx,
    output          addry,
    output          branch_bnz,
    output          buserror,
    output          clr_e,
    output          decb,
    output          decu,
    output          decx,
    output          div_en,
    output          idx_adv,
    output          incx,
    output          int_en,
    output          memhi,
    output          ni,
    output          niuz,
    output          opd,
    output          pc_jmp,
    output          psh_all,
    output          psh_cc,
    output          psh_go,
    output          psh_pc,
    output          pul_go,
    output          rti_cc,
    output          rti_other,
    output          set_e,
    output          set_f,
    output          set_i,
    output          set_opn0_b,
    output          set_opn0_mem,
    output          set_pc_branch16,
    output          set_pc_branch8,
    output          shd_en,
    output          uc_loop,
    output          up_ab,
    output          up_abx,
    output          up_cc,
    output          up_exg,
    output          up_ld16,
    output          up_ld8,
    output          up_lda,
    output          up_ldb,
    output          up_lea,
    output          up_lines,
    output          up_lmul,
    output          up_move,
    output          up_tfr,
    output          up_div,
    output          we,

    // other outputs
    output    [3:0] intvec
);

`include "jtkcpu.inc"

// Op codes = 8 bits, many op-codes will be parsed in the
// same way. Let's assume we only need 64 ucode routines
// 64 = 2^6, Using 2^10 memory rows -> 2^4=16 rows per
// routine
// To do: group op codes in categories that can be parsed
// using the same ucode. 32 categories used for op codes
// another 32 categories reserved for common routines

// localparam UCODE_AW = 10; // 1024 ucode lines

`include "jtkcpu_ucode.inc"

localparam [UCODE_AW-OPCAT_AW-1:0] OPLEN=0;

reg [UCODE_DW-1:0] mem[0:2**(UCODE_AW-1)], ucode;
reg [UCODE_AW-1:0] addr; // current ucode position read
reg [OPCAT_AW-1:0] opcat, post_idx, nx_cat, idx_cat;
reg          [3:0] cur_int;
reg                idx_postl, nil, niuzl, idx_ind_rq;
reg                nmin_l, do_nmi;
wire               idx_ret, idx_ind, idx_jmp,
                   set_idx_post, set_idx_acc, set_idxw;
wire               cc_i, cc_f;

assign cc_i = cc[CC_I];
assign cc_f = cc[CC_F];

always @* begin
    case( {mdata[7],mdata[2:0]} )
        4'b0_111: idx_cat = IDX_EXT;
        4'b0_000: idx_cat = IDX_RINC;
        4'b0_001: idx_cat = IDX_RINC2;
        4'b0_010: idx_cat = IDX_RDEC;
        4'b0_011: idx_cat = IDX_RDEC2;
        4'b0_100: idx_cat = IDX_OFFSET8;
        4'b0_101: idx_cat = IDX_OFFSET16;
        4'b0_110: idx_cat = IDX_R;
        4'b1_100: idx_cat = IDX_DP;
        4'b1_000,
        4'b1_001,
        4'b1_111: idx_cat = IDX_ACC;
        default:  idx_cat = BUSERROR;
    endcase
end

// Conversion of opcodes to op category
always @* begin
    nx_cat = post_idx;
    case( op )
        ANDA_IMM, ADDA_IMM, SUBA_IMM, LDA_IMM,
        ANDB_IMM, ADDB_IMM, SUBB_IMM, LDB_IMM,
        EORA_IMM, ADCA_IMM, SBCA_IMM, ORA_IMM,
        EORB_IMM, ADCB_IMM, SBCB_IMM, ORB_IMM:              opcat = SINGLE_ALU;
        ADDD_IMM, SUBD_IMM:                                 opcat = SINGLE_ALUD;
        LDD_IMM, LDY_IMM,
        LDX_IMM, LDU_IMM, LDS_IMM:                          opcat = SINGLE_ALU_16;
        CLRA, INCA, NEGA, COMA, TSTA, DECA, DAA,
        ABSA, LSRA, RORA, ASRA, ASLA, ROLA:                 opcat = SINGLE_A_INH;
        CLRB, INCB, NEGB, COMB, TSTB, DECB,
        ABSB, LSRB, RORB, ASRB, ASLB, ROLB:                 opcat = SINGLE_B_INH;
        SEX, CLRD, INCD, NEGD, TSTD, DECD, ABSD:            opcat = SINGLE_ALU_INH16;
        ABX :                                               opcat = SINGLE_ABX;
        CLR,  INC,  NEG,  COM,  TST,  DEC,
        LSR,  ROR,  ASR,  ASL,  ROL:                  begin opcat  = PARSE_IDX;
                                                            nx_cat = MEM_ALU_IDX;
                                                            end
        CMPA_IMM, CMPB_IMM, ANDCC, ORCC:                    opcat = CMP8;
        CMPD_IMM, CMPX_IMM, CMPY_IMM, CMPU_IMM,CMPS_IMM:    opcat = CMP16;
        // Operand in indexed memory
        CMPA_IDX, CMPB_IDX:                           begin opcat  = PARSE_IDX;
                                                            nx_cat = CMP8_IDX;
                                                            end
        CMPX_IDX, CMPY_IDX, CMPD_IDX,
        CMPU_IDX, CMPS_IDX:                           begin opcat  = PARSE_IDX;
                                                            nx_cat = CMP16_IDX;
                                                            end
        BITA_IMM, BITB_IMM:                                 opcat  = BIT_ALU;
        BITA_IDX, BITB_IDX:                           begin opcat  = PARSE_IDX;
                                                            nx_cat = BIT_ALU_IDX;
                                                            end
        ANDA_IDX, ADDA_IDX, SUBA_IDX, LDA_IDX,
        EORA_IDX, ADCA_IDX, SBCA_IDX, ORA_IDX,
        ANDB_IDX, ADDB_IDX, SUBB_IDX, LDB_IDX,  ORB_IDX,
        EORB_IDX, ADCB_IDX, SBCB_IDX:                 begin opcat  = PARSE_IDX;
                                                            nx_cat = SINGLE_ALU_IDX;
                                                            end
        LEAU, LEAX, LEAS, LEAY:                       begin opcat  = PARSE_IDX;
                                                            nx_cat = LEA;
                                                            end
        ADDD_IDX, SUBD_IDX:                           begin opcat  = PARSE_IDX;
                                                            nx_cat = SINGLE_ALUD_IDX;
                                                            end
        LDU_IDX, LDX_IDX, LDD_IDX,
        LDS_IDX, LDY_IDX:                             begin opcat  = PARSE_IDX;
                                                            nx_cat = SINGLE_ALU_IDX16;
                                                            end
        JMP:                                          begin opcat  = PARSE_IDX;
                                                            nx_cat = JUMP;
                                                            end
        JSR:                                          begin opcat  = PARSE_IDX;
                                                            nx_cat = JMSR;
                                                            end

        MUL:                                                opcat = MULTIPLY;
        LMUL:                                               opcat = LMULTIPLY;
        DIVXB:                                              opcat = DIVIDE;
        LSRD_IMM, RORD_IMM, ASRD_IMM,
        ASLD_IMM, ROLD_IMM:                                 opcat = SHIFTD;
        LSRD_IDX, RORD_IDX, ASRD_IDX,
        ASLD_IDX, ROLD_IDX:                           begin opcat  = PARSE_IDX;
                                                            nx_cat = SHIFTD_IDX;
                                                            end

        LSRW, RORW, ASRW, ASLW, ROLW, NEGW, CLRW,
        INCW, DECW, TSTW:                             begin opcat  = PARSE_IDX;
                                                            nx_cat = WMEM_ALU;
                                                            end
        BSR:                                                opcat = SBSR;
        LBSR:                                               opcat = BSRL;
        BRA, BRN, BHI, BLS, BCC, BCS, BNE,
        BEQ, BVC, BVS, BPL, BMI, BGE, BLT, BGT, BLE:        opcat = SBRANCH;
        LBRA, LBRN, LBHI, LBLS, LBCC, LBCS, LBNE, LBLE,
        LBEQ, LBVC, LBVS, LBPL, LBMI, LBGE, LBLT, LBGT:     opcat = LBRANCH;

        DECX_JNZ:       opcat = LOOPX;
        DECB_JNZ:       opcat = LOOPB;
        MOVE_Y_X_U:     opcat = MOVE;
        BMOVE_Y_X_U:    opcat = BMOVE;
        BSETA_X_U:      opcat = BSETA;
        BSETD_X_U:      opcat = BSETD;
        RTI:            opcat = RTIT;
        RTS:            opcat = RTSR;
        PUSHU, PUSHS:   opcat = PSH;
        PULLU, PULLS:   opcat = PUL;
        NOP:            opcat = NOPE;
        SETLINES_IMM:   opcat = SETLNS;
        SETLINES_IDX:   begin   opcat  = PARSE_IDX;
                                nx_cat = SETLNS_IDX;
                        end

        STA, STB:       begin   opcat  = PARSE_IDX;
                                nx_cat = STORE8;
                        end
        STD, STX, STY,
        STU, STS:       begin   opcat  = PARSE_IDX;
                                nx_cat = STORE16;
                        end
        EXG:                    opcat  = EXCHANGE;
        TFR:                    opcat  = TRANSFER;
        default:                opcat  = BUSERROR; // stop condition
    endcase
end

// get ucode data from a hex file
// initial begin
//     $readmemh( mem, "jtkcpu_ucode.hex");
// end

assign intvec = cur_int & {4{int_en}};
assign intsrv = do_nmi || (!firq_n && !cc_f) || (!irq_n && !cc_i);

`ifdef SIMULATION
integer error_cnt=-1;
always @(posedge clk) if( cen )  begin
    if( buserror && error_cnt<0 ) error_cnt <= 40;
    if( error_cnt > 0 ) error_cnt <= error_cnt - 1;
    if( error_cnt==0 ) begin
        $display("\nJTKCPU Error: simulation finished because of bus error");
        $finish;
        // $finish;
    end
end
`endif

always @(posedge clk) begin
    if( rst ) begin
        addr       <= { RESET, OPLEN };  // Reset starts ucode at 0
        cur_int    <= 4'b1000;
        idx_rsel   <= 0;
        idx_asel   <= 0;
        idx_ind_rq <= 0;
        idx_postl  <= 0;
        nil        <= 0;
        post_idx   <= 0;
        idx_post   <= 0;
        idx_ld     <= 0;
        idx_acc    <= 0;
        idxw       <= 0;
        nmin_l     <= 0;
        do_nmi     <= 0;
        niuzl      <= 0;
    end else if( cen && !buserror ) begin
        nil       <= ni | niuzl;
        niuzl     <= niuz & uz;
        post_idx  <= nx_cat;
        idx_post  <= 0;
        idx_ld    <= 0;
        nmin_l    <= nmi_n;

        if( !nmi_n && nmin_l ) do_nmi <= 1; // NMI is edge triggered
        if( !mem_busy && !alu_busy && !stack_busy && !niuz && !niuzl ) begin
            addr <= addr + 1'd1; // keep processing an opcode routine
        end
        if( ni ) begin
            if( do_nmi ) begin // pending NMI
                do_nmi  <= 0;
                cur_int <= 4'b0100;
                addr    <= { NMI, OPLEN };
                nil <= 0;
            end else if( !firq_n && !cc_f ) begin  // FIRQ triggered by level
                cur_int <= 4'b0010;
                addr    <= { FIRQ, OPLEN };
                nil <= 0;
            end else if ( !irq_n && !cc_i ) begin  // IRQ triggered by level
                cur_int <= 4'b0001;
                addr    <= { IRQ, OPLEN };
                nil <= 0;
            end
        end
        if( nil ) begin
            cur_int <= 0;
            addr    <= { opcat, OPLEN }; // when a new opcode is read
        end
        if( uc_loop ) addr <= { opcat, OPLEN };
        // Indexed addressing parsing
        if( set_idx_post ) idx_postl <= 1;
        if( set_idxw     ) idxw <= 1;
        idx_acc <= set_idx_acc;
        if( idx_jmp ) begin
            addr       <= {idx_cat, OPLEN};
            idx_rsel   <= mdata[6:4];
            idx_asel   <= mdata[1:0];
            idx_ind_rq <= mdata[3];
            idxw       <= 0;
        end
        if( idx_ind ) begin
            idx_ld    <= !data2addr && !idx_dp && !idx_8 && !idx_16;
            addr      <= idx_ind_rq ? {IDX_IND, OPLEN} : {nx_cat, OPLEN};
            idx_post  <= idx_postl;
            idx_postl <= 0;
        end
        if( idx_ret ) begin
            idx_ind_rq <= 0;
            idxw       <= 0;
            addr       <= {nx_cat, OPLEN};
        end
    end
end

endmodule