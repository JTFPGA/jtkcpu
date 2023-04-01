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

module jtkcpu_regs(
    input               rst,
    input               clk,
    input               cen,

    input        [15:0] pc,
    input        [15:0] mdata,     // postbyte used to select specific registers
    input        [ 7:0] op,        // op code used to select specific registers

    // Stack
    input        [ 7:0] psh_sel,
    input               psh_hihalf,
    input               psh_ussel,
    input               pul_en,
    input               psh_dec,

    // Index addressing
    input        [ 2:0] idx_rsel,   // register to modify
    input        [ 1:0] idx_asel,   // accumulator used
    output       [15:0] idx_reg,
    output       [15:0] idx_racc,
    input        [15:0] idx_addr,
    input               idx_post,
    input               idx_pre,
    input               idxw,
    output reg   [ 7:0] dp,

    // Register update
    input        [31:0] alu,
    input               up_a,
    input               up_b,
    input               up_d,
    input               up_x,
    input               up_y,
    input               up_u,
    input               up_s,
    input               up_lmul,
    input               up_lea,
    // input               up_alu_a,
    // input               up_alu_b,

    // Flags from ALU
    input               up_cc,
    input        [ 7:0] alu_cc,
    // Flags from control
    input               set_e,
    input               set_i,
    input               set_f,
    input               clr_e,
    //input               clr_i,
    //input               clr_f,

    // Direct increment/decrement
    input               inc_x,
    input               inc_y,
    input               dec_x,
    input               dec_b,
    input               dec_u,

    output   reg [15:0] mux,
    output   reg [15:0] d_mux,
    output   reg [15:0] mux_reg0,
    output   reg [15:0] mux_reg1,
    output   reg [15:0] nx_u,
    output   reg [15:0] nx_s,
    output       [15:0] psh_addr,
    output   reg [15:0] x,
    output   reg [15:0] y,
    output   reg [ 7:0] cc,
    output   reg [ 7:0] psh_mux,
    output   reg [ 7:0] psh_bit,
    output   reg        up_pul_pc
);

`include "jtkcpu.inc"

reg         psh_dec_u, psh_dec_s, inc_pul,
            up_pul_x, up_pul_y, up_pul_other,
            up_pul_a, up_pul_b, up_pul_dp, up_pul_cc;
reg  [ 7:0] a, b;
reg  [15:0] u, s;
wire [15:0] psh_other;
wire        idx_upx, idx_upy, idx_upu, idx_ups;
wire [15:0] idx_step, d;
wire        idx_x, idx_y, idx_u, idx_s;

assign d   = { a, b };

assign psh_addr  = psh_ussel ? u : s;
assign psh_other = psh_ussel ? s : u;
// Indexed increments/decrements
assign idx_x    = idx_rsel==2,
       idx_y    = idx_rsel==3,
       idx_u    = idx_rsel==5,
       idx_s    = idx_rsel==6;
assign idx_reg  = idx_x ? x : idx_y ? y : idx_u ? u : idx_s ? s : pc;
assign idx_racc = idx_asel==0 ? { {8{a[7]}},a } : idx_asel==1 ? { {8{b[7]}},b } : { a, b };
assign idx_upx  = (idx_post || idx_pre) && idx_x,
       idx_upy  = (idx_post || idx_pre) && idx_y,
       idx_upu  = (idx_post || idx_pre) && idx_u,
       idx_ups  = (idx_post || idx_pre) && idx_s;
assign idx_step = idx_post ? (idxw ? 16'd2 : 16'd1) : (idxw ? -16'd2 : -16'd1);

// exg/tfr mux
always @* begin
    case( mdata[7:4] )
        4'b0000: mux = {8'hFF,  a};
        4'b0001: mux = {8'hFF,  b};
        4'b0010: mux = x;
        4'b0011: mux = y;
        4'b0100: mux = s;
        4'b0101: mux = u;
        default: mux = 0;
    endcase

    case( mdata[3:0] )
        4'b0000: d_mux = {8'hFF,  a};
        4'b0001: d_mux = {8'hFF,  b};
        4'b0010: d_mux = x;
        4'b0011: d_mux = y;
        4'b0100: d_mux = s;
        4'b0101: d_mux = u;
        default: d_mux = 0;
    endcase
end

always @* begin
    case ( op )
        ADDB_IMM, SUBB_IMM, ANDB_IMM, EORB_IMM, ORB_IMM, CLRB, NEGB, ASRB,
        ADDB_IDX, SUBB_IDX, ANDB_IDX, EORB_IDX, ORB_IDX, COMB, TSTB, ASLB, MUL,
        ADCB_IMM, SBCB_IMM, BITB_IMM, CMPB_IMM, DECB,    LSRB, ROLB,
        ADCB_IDX, SBCB_IDX, BITB_IDX, CMPB_IDX, INCB,          RORB, ABSB, STB: mux_reg0 = {a, b}; // "a" will be ignored

        CMPD_IDX, ADDD_IMM, SUBD_IMM, LSRD_IMM, RORD_IMM, ASRD_IMM, ASLD_IMM, ROLD_IMM,
        CMPD_IMM, ADDD_IDX, SUBD_IDX, LSRD_IDX, RORD_IDX, ASRD_IDX, ASLD_IDX, ROLD_IDX,
            CLRD,     NEGD,     ABSD,      STD: mux_reg0 = {a, b};

        CMPX_IMM, CMPX_IDX,  ABX, STX: mux_reg0 = x;
        CMPY_IMM, CMPY_IDX, LMUL, STY: mux_reg0 = y;
        CMPU_IMM, CMPU_IDX, STU:       mux_reg0 = u;
        CMPS_IMM, CMPS_IDX, STS:       mux_reg0 = s;
        LEAX, LEAY, LEAU, LEAS:        mux_reg0 = idx_addr;
        SEX: mux_reg0 = { a, b };
        ANDCC, ORCC: mux_reg0 = {a, cc};

        default : mux_reg0 = {a, a};
    endcase
end

always @* begin
    case ( op )
        ABX:     mux_reg1 = {8'h0,  b};
        LMUL:    mux_reg1 = x;
        default: mux_reg1 = {8'h0,  a};
    endcase
end

// U/S next value
always @* begin
    psh_dec_u = 0;
    psh_dec_s = 0;
    if ( psh_dec && psh_mux!=0 ) begin
        if (psh_ussel)
            psh_dec_u = 1;
        else
            psh_dec_s = 1;
    end
    nx_u = u;
    nx_s = s;
    if( up_s  ) nx_s = up_lea && op[1:0]==3 ? idx_addr : mdata;
    if( up_u  ) nx_u = up_lea && op[1:0]==2 ? idx_addr : mdata;
    if( psh_dec_u | dec_u ) nx_u = u - 16'd1;
    if( psh_dec_s         ) nx_s = s - 16'd1;
    if( up_pul_other &&  psh_hihalf ) begin
        if( psh_ussel )
            nx_s[15:8] = alu[7:0];
        else
            nx_u[15:8] = alu[7:0];
    end
    if( up_pul_other && !psh_hihalf ) begin
        if( psh_ussel )
            nx_s[ 7:0] = alu[7:0];
        else
            nx_u[ 7:0] = alu[7:0];
    end

    if( !psh_dec && inc_pul &&  psh_ussel ) nx_u = u + 16'd1;
    if( !psh_dec && inc_pul && !psh_ussel ) nx_s = s + 16'd1;
end

// PUSH
always @* begin
    casez( psh_sel )
        8'b????_???1: begin psh_mux = cc; psh_bit = 8'h1; end
        8'b????_??10: begin psh_mux =  a; psh_bit = 8'h2; end
        8'b????_?100: begin psh_mux =  b; psh_bit = 8'h4; end
        8'b????_1000: begin psh_mux = dp; psh_bit = 8'h8; end
        8'b???1_0000: begin psh_mux = psh_hihalf ? x[15:8] : x[7:0]; psh_bit = 8'h10; end
        8'b??10_0000: begin psh_mux = psh_hihalf ? y[15:8] : y[7:0]; psh_bit = 8'h20; end
        8'b?100_0000: begin psh_mux = psh_hihalf ? psh_other[15:8] : psh_other[7:0]; psh_bit = 8'h40; end
        default:      begin psh_mux = psh_hihalf ? pc[15:8] : pc[7:0]; psh_bit = 8'h80; end
    endcase
end

// PULL
always @* begin
    up_pul_cc    = 0; // output
    up_pul_a     = 0; // define all as regs
    up_pul_b     = 0;
    up_pul_dp    = 0;
    up_pul_x     = 0;
    up_pul_y     = 0;
    up_pul_other = 0;
    up_pul_pc    = 0; // output
    casez( psh_sel )
        8'b????_???1: up_pul_cc    = pul_en;
        8'b????_??10: up_pul_a     = pul_en;
        8'b????_?100: up_pul_b     = pul_en;
        8'b????_1000: up_pul_dp    = pul_en;
        8'b???1_0000: up_pul_x     = pul_en;
        8'b??10_0000: up_pul_y     = pul_en;
        8'b?100_0000: up_pul_other = pul_en;
        default:      up_pul_pc    = pul_en;
    endcase
    inc_pul = |{ up_pul_cc, up_pul_a, up_pul_b, up_pul_dp, up_pul_x,
        up_pul_y, up_pul_other, up_pul_pc };
end

always @(posedge clk, posedge rst) begin
    if( rst ) begin // CHECK reset values, especially CC
        a  <= 0;
        b  <= 0;
        dp <= 0;
        x  <= 0;
        y  <= 0;
        u  <= 0;
        s  <= 0;
        cc <= 0;
    end else if(cen) begin
        u <= nx_u;
        s <= nx_s;
        if( idx_upx ) x <= x + idx_step;
        if( idx_upy ) y <= y + idx_step;
        if( idx_upu ) u <= u + idx_step;
        if( idx_ups ) s <= s + idx_step;

        // if( up_alu_a ) a <= alu[7:0]; // pul must let fetched data through ALU
        // if( up_alu_b ) b <= alu[7:0];

        if( up_a ) a <= up_pul_a ? mdata[7:0] : alu[7:0];
        if( up_b ) b <= up_pul_b ? mdata[7:0] : alu[7:0];

        if( up_d ) begin
            a <= alu[15:8];
            b <= alu[ 7:0];
        end

        if( up_pul_dp ) dp <= alu[7:0];
        // Update from memory
        // if( up_a  || up_pul_a  ) a <= mdata[7:0]; // pul must let fetched data through ALU
        // if( up_b  || up_pul_b  ) b <= mdata[7:0];
        if( dec_b ) b <= b - 8'd1;
        if( up_x  ) x  <= up_lmul || up_lea && op[1:0]==0 ? alu[15:0] : mdata;
        if( up_y  ) y  <= up_lmul ? alu[31:16] : up_lea && op[1:0]==1 ? alu[15:0] : mdata;
        // 16-bit registers from memory (PULL)
        if( up_pul_x &&  psh_hihalf ) x[15:8] <= alu[15:8];
        if( up_pul_x && !psh_hihalf ) x[ 7:0] <= alu[7:0];
        if( up_pul_y &&  psh_hihalf ) y[15:8] <= alu[15:8];
        if( up_pul_y && !psh_hihalf ) y[ 7:0] <= alu[7:0];

        // inc/dec
        if( inc_x ) x <= x + 16'd1;
        if( inc_y ) y <= y + 16'd1;
        if( dec_x ) x <= x - 16'd1;

        if( up_cc     ) cc <= alu_cc;
        if( up_pul_cc ) cc <= mdata[7:0];
        if( set_e ) cc[CC_E] <= 1;
        if( set_i ) cc[CC_I] <= 1;
        if( set_f ) cc[CC_F] <= 1;
        if( clr_e ) cc[CC_E] <= 0;
        //if( clr_i ) cc[CC_I] <= 0;
        //if( clr_f ) cc[CC_F] <= 0;
    end
end

endmodule
