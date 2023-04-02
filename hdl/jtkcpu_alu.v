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
    Date: 14-02-2023 */

module jtkcpu_alu(
    input             rst,
    input             clk,
    input             cen,

    input      [ 7:0] op,
    input      [15:0] opnd0,
    input      [15:0] opnd1, // data from memory
    input      [ 7:0] cc_in,
    output     [ 7:0] cc_out,

    output            busy,

    output reg [15:0] rslt,
    output reg [15:0] rslt_hi // used only in lmul
);

`include "jtkcpu.inc"

reg c_out, v_out, z_out, n_out, h_out, e_out, i_out, f_out;
reg alu16;
wire [3:0] msb   = alu16 ? 4'd15 : 4'd7;

// Divider
reg         div_start = 0, div_len = 0, div_sign = 0;
wire        div_v;
wire [ 7:0] div_quot, div_rem;

assign cc_out = { e_out, f_out, h_out, i_out, n_out, z_out, v_out, c_out };

always @(posedge clk) begin
    alu16 <= op==CMPD_IMM || op==CMPD_IDX || op==ASRD_IMM || op==ASRD_IDX || op==ASRW || op==ADDD_IMM || op==INCD || op==NEGD || op==ABSD ||
             op==CMPX_IMM || op==CMPX_IDX || op==ASLD_IMM || op==ASLD_IDX || op==ASLW || op==ADDD_IDX || op==INCW || op==NEGW || op== ABX ||
             op==CMPY_IMM || op==CMPY_IDX || op==ROLD_IMM || op==ROLD_IDX || op==ROLW || op==SUBD_IMM || op==DECD || op==TSTD || op== SEX ||
             op==CMPU_IMM || op==CMPU_IDX || op==RORD_IMM || op==RORD_IDX || op==LSRW || op==SUBD_IDX || op==DECW || op==TSTW ||
             op==CMPS_IMM || op==CMPS_IDX || op==LSRD_IMM || op==LSRD_IDX || op==RORW;
end

jtkcpu_div u_div(
    .rst  ( rst         ),
    .clk  ( clk         ),
    .cen  ( cen         ),
    .op0  ( opnd0       ),
    .op1  ( opnd1[7:0]  ),
    .len  ( div_len     ),
    .sign ( div_sign    ),
    .start( div_start   ),
    .quot ( div_quot    ),
    .rem  ( div_rem     ),
    .busy ( busy        ),
    .v    ( div_v       )
);

always @* begin
    c_out   = cc_in[CC_C];
    v_out   = cc_in[CC_V];
    z_out   = cc_in[CC_Z];
    n_out   = cc_in[CC_N];
    h_out   = cc_in[CC_H];
    e_out   = cc_in[CC_E];
    i_out   = cc_in[CC_I];
    f_out   = cc_in[CC_F];
    rslt_hi = 0;

    case (op)
        STA,  STB,  STD,
        STX,  STY,  STU,  STS,
        LEAX, LEAY, LEAU, LEAS: begin
            rslt  = opnd0;
            v_out = 0;      // TO DO: do STA/B modify any flag?
        end
        LDA_IMM,LDB_IMM,LDA_IDX,LDB_IDX,TSTA,TSTB,TST,LDD_IMM,LDD_IDX,LDX_IMM,
        LDX_IDX,LDY_IMM,LDY_IDX,LDU_IMM,LDU_IDX,LDS_IMM,LDS_IDX,TSTD,TSTW: begin  // LD, ST, TST, TSTD, TSTW
            rslt  = opnd1;
            v_out = 0;
        end
        ADDA_IMM,ADDB_IMM,ADDA_IDX,ADDB_IDX: begin  // ADD
            {c_out, rslt[7:0]} = {1'b0, opnd0[7:0]} + {1'b0, opnd1[7:0]};
            v_out         = (opnd0[msb] & opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & ~opnd1[msb] & rslt[msb]);
            h_out = opnd0[4] ^ opnd1[4] ^ rslt[4];
        end
        ADDD_IMM,ADDD_IDX: begin  // ADD
            {c_out, rslt} = {1'b0, opnd0} + {1'b0, opnd1};
            v_out         = (opnd0[msb] & opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & ~opnd1[msb] & rslt[msb]);
        end
        ADCA_IMM,ADCB_IMM,ADCA_IDX,ADCB_IDX: begin  // ADC
            {c_out, rslt[7:0]} =  {1'b0, opnd0[7:0]} + {1'b0, opnd1[7:0]} + {8'd0,cc_in[CC_C]};
            v_out         = (opnd0[msb] & opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & ~opnd1[msb] & rslt[msb]);
            h_out         = opnd0[4] ^ opnd1[4] ^ rslt[4];
        end
        SUBA_IMM,SUBB_IMM,SUBA_IDX,SUBB_IDX: begin  // SUB
            {c_out, rslt[7:0]} = {1'b0, opnd0[7:0]} - {1'b0, opnd1[7:0]};
            v_out         = (opnd0[msb] & ~opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & opnd1[msb] & rslt[msb]);
        end
        SUBD_IMM, SUBD_IDX,
        CMPA_IMM, CMPB_IMM,
        CMPA_IDX, CMPB_IDX,
        CMPD_IMM, CMPD_IDX,
        CMPX_IMM, CMPX_IDX,
        CMPY_IMM, CMPY_IDX,
        CMPU_IMM, CMPU_IDX,
        CMPS_IMM, CMPS_IDX:  begin  // SUB/CMP
            {c_out, rslt} = {1'b0, opnd0} - {1'b0, opnd1};
            v_out         = (opnd0[msb] & ~opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & opnd1[msb] & rslt[msb]);
        end
        SBCA_IMM,SBCB_IMM,SBCA_IDX,SBCB_IDX: begin   // SBC
            {c_out, rslt[7:0]} = {1'b0, opnd0[7:0]} - {1'b0, opnd1[7:0]} - {8'd0,cc_in[CC_C]};
            v_out         = (opnd0[msb] & ~opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & opnd1[msb] & rslt[msb]);
        end
        ANDA_IMM,ANDB_IMM,ANDA_IDX,ANDB_IDX,BITA_IMM,BITB_IMM,BITA_IDX,BITB_IDX: begin  // AND, BIT
            rslt  = opnd0 & opnd1;
            v_out = 0;
        end
        EORA_IMM,EORB_IMM,EORA_IDX,EORB_IDX: begin    // EOR
            rslt  = opnd0 ^ opnd1;
            v_out = 0;
        end
        ORA_IMM,ORB_IMM,ORA_IDX,ORB_IDX: begin  // OR
            rslt  = opnd0 | opnd1;
            v_out = 0;
        end
        ANDCC: begin
            { e_out, f_out, h_out, i_out, n_out, z_out, v_out, c_out } = cc_in & opnd1[7:0];
            rslt=0;
        end
        ORCC: begin
            { e_out, f_out, h_out, i_out, n_out, z_out, v_out, c_out } = cc_in | opnd1[7:0];
            rslt=0;
        end
        CLRA,CLRB,CLR,CLRD,CLRW: begin  // CLR, CLRD, CLRW
            rslt  = 0;
            c_out = 0;
            v_out = 0;
        end
        COMA,COMB,COM: begin  // COM
            rslt  = ~opnd0;
            c_out = 1;
            v_out = 0;
        end
        NEGA,NEGB,NEG: begin  // NEG, NEGA , NEGB
            { c_out, rslt[7:0] } = ~{ opnd0[7], opnd0[7:0] } + 9'b1;
            v_out = opnd0[msb]==rslt[msb];
        end
        NEGD,NEGW: begin
            { c_out, rslt } = ~{ opnd0[15], opnd0 } + 17'b1;
            v_out = opnd0[msb]==rslt[msb];
        end
        INCA,INCB,INC,INCD,INCW: begin  // INC, INCD, INCW
            rslt  = opnd0 + 1'b1;
            v_out = (~opnd0[msb] & rslt[msb]); // overflow calculated for signed integers
        end
        DECA,DECB,DEC,DECD,DECW: begin  // DEC, DECD, DECW
            rslt  = opnd0 - 1'b1;
            v_out = (opnd0[msb] & ~rslt[msb]); // overflow calculated for signed integers
        end
        LSRA,LSRB,LSR: begin  // LSR, LSRW, LSRD
            {rslt[7:0], c_out} = {1'b0, opnd0[7:0]};
            // rslt  = opnd0 >> 1;
            // c_out = opnd0[msb];
        end
        LSRW,LSRD_IMM,LSRD_IDX: begin  // LSR, LSRW, LSRD
            {rslt[15:0], c_out} = {1'b0, opnd0[15:0]};
        end
        RORA,RORB,ROR: begin  // ROR, RORW, RORD
            {rslt[7:0], c_out} = {cc_in[CC_C], opnd0[7:0]};
        end
        RORW,RORD_IMM,RORD_IDX: begin  // ROR, RORW, RORD
            {rslt[15:0], c_out} = {cc_in[CC_C], opnd0[15:0]};
        end
        ASRA,ASRB,ASR,ASRW,ASRD_IMM,ASRD_IDX: begin  // ASR, ASRW, ASRD
            rslt      = opnd0>>1;
            rslt[msb] = opnd0[msb];
            c_out     = opnd0[0];
        end
        ASLA,ASLB,ASL,ASLW,ASLD_IMM,ASLD_IDX: begin  // LSL, ASL, ASLW, ASLD
            // {c_out, rslt} = {opnd0, 1'b0};
            rslt  = opnd0 << 1;
            c_out = opnd0[msb];
            // v_out = opnd0[msb] ^ opnd0[msb-1];
            v_out = opnd0[msb] ^ rslt[msb];
        end
        ROLA,ROLB,ROL,ROLW,ROLD_IMM,ROLD_IDX: begin  // ROL, ROLW, ROLD
            {c_out, rslt} = {opnd0, cc_in[CC_C]};
            v_out         =  opnd0[msb] ^ rslt[msb];
        end
        ABX: rslt = {8'h0, opnd0[7:0]} + {8'h0, opnd1[7:0]};  // ABX
        DAA: begin  // DAA
            if ( c_out || opnd0[7:4] > 4'h9 || (opnd0[7:4] > 4'h8 && opnd0[3:0] > 4'h9 ))
                rslt[7:4] = 4'h6;
            else
                rslt[7:4] = 4'h0;
            if ( h_out || opnd0[3:0] > 4'h9 )
                rslt[3:0] = 4'h6;
            else
                rslt[3:0] = 4'h0;
            {rslt[8], rslt[7:0]} = {1'b0, opnd0[7:0]} + rslt[7:0];
            c_out = c_out | rslt[8];
        end
        SEX: begin  // SEX
            rslt  = {{8{opnd0[7]}}, opnd0[7:0]};
            v_out = 0;
        end
        MUL: begin
            rslt  = opnd0[15:8]*opnd0[7:0];
            c_out = rslt[7];
        end
        LMUL: begin
            { rslt_hi, rslt }  = opnd0*opnd1;
            c_out = rslt_hi[15];
        end
        //
        ABSA, ABSB, ABSD: begin  // ABS
            if (opnd0[msb] )
                rslt = alu16 ? -opnd0 : {opnd0[15:8],-opnd0[7:0]};
            else
                rslt = opnd0;
            c_out = 0;
            v_out = 0;
        end
        default:
            rslt = opnd0;
    endcase

    if ( op!=LEAU && op!=LEAS && op!=ABX && op!=ABSA && op!=ABSB && op!=ABSD && op!=ANDCC && op!=ORCC )
        z_out = alu16 ? rslt==0 : rslt[7:0]==0;
    if ( op!=LEAX && op!=LEAY && op!=LEAU && op!=LEAS && op!=ABX && op!=MUL && op!=LMUL && op!=ANDCC && op!=ORCC)
        n_out = rslt[msb];
end

endmodule