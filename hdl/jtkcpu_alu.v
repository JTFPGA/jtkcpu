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
    input      [ 7:0] op, 
    input      [15:0] opnd0, 
    input      [15:0] opnd1, 
    input      [ 7:0] cc_in,
    output reg        c_out,
    output reg        v_out,
    output reg        z_out,
    output reg        n_out,
    output reg        h_out,
    output reg [15:0] rslt
);

`include "jtkcpu.inc"

wire       alu16 = op==8'h40 || op==8'h41 || op==8'h42 || op==8'h43 || op==8'h44 || op==8'h45 || op==8'h46 || op==8'h47 || op==8'h48 || op==8'h49 ||
                   op==8'h4A || op==8'h4B || op==8'h4C || op==8'h4D || op==8'h4E || op==8'h4F || op==8'h50 || op==8'h51 || op==8'h52 || op==8'h53 || 
                   op==8'h54 || op==8'h55 || op==8'h56 || op==8'h57 || op==8'h58 || op==8'h59 || op==8'h5A || op==8'h5B || op==8'h5C || op==8'hA3 || 
                   op==8'hA4 || op==8'hA5 || op==8'hA6 || op==8'hA7 || op==8'hB0 || op==8'hB2 || op==8'hB8 || op==8'hB9 || op==8'hBA || op==8'hBB ||
                   op==8'hBC || op==8'hBD || op==8'hBE || op==8'hBF || op==8'hC0 || op==8'hC1 || op==8'hC2 || op==8'hC3 || op==8'hC4 || op==8'hC5 ||
                   op==8'hC6 || op==8'hC7 || op==8'hC8 || op==8'hC9 || op==8'hCA || op==8'hCB || op==8'hCE;
wire [3:0] msb   = alu16 ? 4'd15 : 4'd7;

always @* begin
    c_out = cc_in[CC_C];
    v_out = cc_in[CC_V];
    z_out = cc_in[CC_Z];
    n_out = cc_in[CC_N];
    h_out = cc_in[CC_H];
    case (op)
        8'h08,8'h09,8'h0A,8'h0B: begin // LEA  // RAVISAR
            rslt  =  opnd0;
        end
        8'h10,8'h11,8'h12,8'h13,8'h3A,8'h3B,8'h90,8'h91,8'h92,8'h40,8'h41,8'h42,8'h43,
        8'h44,8'h45,8'h46,8'h47,8'h48,8'h49,8'h58,8'h59,8'h5A,8'h5B,8'h5C,8'hCA,8'hCB: begin  // LD, ST, TST, TSTD, TSTW
            rslt  =  opnd0;
            v_out = 1'b0;
        end
        8'h14,8'h15,8'h16,8'h17,8'h54,8'h55: begin  // ADD
            {c_out, rslt} = {1'b0, opnd0} + {1'b0, opnd1};
            v_out         = (opnd0[msb] & opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & ~opnd1[msb] & rslt[msb]);
            if ( op!=8'h54 || op!=8'h55 )
                h_out = opnd0[4] ^ opnd1[4] ^ rslt[4];
        end
        8'h18,8'h19,8'h1A,8'h1B: begin  // ADC
            {c_out, rslt} =  {1'b0, opnd0} + {1'b0, opnd1} + {8'd0,c_out};
            v_out         = (opnd0[msb] & opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & ~opnd1[msb] & rslt[msb]);
            h_out         = opnd0[4] ^ opnd1[4] ^ rslt[4];
        end
        8'h1C,8'h1D,8'h1E,8'h1F,8'h56,8'h57: begin  // SUB
            {c_out, rslt} = {1'b0, opnd0} - {1'b0, opnd1};
            v_out         = (opnd0[msb] & ~opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & opnd1[msb] & rslt[msb]);
        end
        8'h20,8'h21,8'h22,8'h23: begin   // SBC
            {c_out, rslt} = {1'b0, opnd0} - {1'b0, opnd1} - {8'd0,c_out};
            v_out         = (opnd0[msb] & ~opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & opnd1[msb] & rslt[msb]);
        end
        8'h24,8'h25,8'h26,8'h27,8'h28,8'h29,8'h2A,8'h2B,8'h3C: begin  // AND, BIT, ANDCC
            rslt = (opnd0 & opnd1);
            if ( op!=8'h3C )
                v_out = 0;
        end
        8'h2C,8'h2D,8'h2E,8'h2F: begin    // EOR
            rslt  = (opnd0 ^ opnd1);
            v_out = 0;
        end
        8'h30,8'h31,8'h32,8'h33,8'h3D: begin  // OR, ORCC
            rslt  = (opnd0 | opnd1);
            if ( op!=8'h3D )
                v_out = 0;
        end
        8'h34,8'h35,8'h36,8'h37,8'h4A,8'h4B,8'h4C,8'h4D,8'h4E,8'h4F,8'h50,8'h51,8'h52,8'h53: begin  // CMP
            {c_out, rslt} = {1'b0, opnd0} - {1'b0, opnd1};
            v_out         = (opnd0[msb] & ~opnd1[msb] & ~rslt[msb]) | (~opnd0[msb] & opnd1[msb] & rslt[msb]);
        end
        8'h80,8'h81,8'h82,8'hC2,8'hC3: begin  // CLR, CLRD, CLRW 
            rslt  = 0;
            c_out = 0;
            v_out = 0;
        end
        8'h83,8'h84,8'h85: begin  // COM
            rslt  = ~opnd0;
            c_out = 1'b1;
            v_out = 1'b0;
        end
        8'h86,8'h87,8'h88,8'hC4,8'hC5: begin  // NEG, NEGD , NEGW
            rslt  = ~opnd0 + 1'b1;
            c_out = alu16 ? rslt!=0 : rslt[7:0]!=0;
            v_out = opnd0[msb]==rslt[msb];
        end
        8'h89,8'h8A,8'h8B,8'hC6,8'hC7: begin  // INC, INCD, INCW
            rslt  = opnd0 + 1'b1;
            v_out = (~opnd0[msb] & rslt[msb]);
        end
        8'h8C,8'h8D,8'h8E,8'hC8,8'hC9: begin  // DEC, DECD, DECW
            rslt  = opnd0 - 1'b1;
            v_out = (opnd0[msb] & ~rslt[msb]);
        end
        8'h93,8'h94,8'h95,8'hA3,8'hB8,8'hB9: begin  // LSR, LSRW, LSRD
            // {rslt, c_out} = {1'b0, opnd0};
            rslt  = opnd0 >> 1;
            c_out = opnd0[msb];
        end
        8'h96,8'h97,8'h98,8'hA4,8'hBA,8'hBB: begin  // ROR, RORW, RORD 
            {rslt, c_out} = {c_out, opnd0};
        end
        8'h99,8'h9A,8'h9B,8'hA5,8'hBC,8'hBD: begin  // ASR, ASRW, ASRD 
            {rslt, c_out} = {opnd0[msb], opnd0};
        end
        8'h9C,8'h9D,8'h9E,8'hA6,8'hBE,8'hBF: begin  // LSL, ASL, ASLW, ASLD
            // {c_out, rslt} = {opnd0, 1'b0};
            rslt  = opnd0 << 1;
            c_out = opnd0[msb];
            // v_out = opnd0[msb] ^ opnd0[msb-1];
            v_out = opnd0[msb] ^ rslt[msb];
        end
        8'hA0,8'hA1,8'hA2,8'hA7,8'hC0,8'hC1: begin  // ROL, ROLW, ROLD
            {c_out, rslt} = {opnd0, c_out};
            v_out         =  opnd0[msb] ^ rslt[msb];
        end
        8'hB0: rslt = opnd0 + opnd1;  // ABX  
        8'hB1: begin  // DAA
            if ( ((c_out) || (opnd0[7:4] > 4'H9)) || ((opnd0[7:4] > 4'H8) && (opnd0[3:0] > 4'H9)) )
                rslt[7:4] = 4'H6;
            else
                rslt[7:4] = 4'H0;
            if ((h_out) || (opnd0[3:0] > 4'H9))
                rslt[3:0] = 4'H6;
            else
                rslt[3:0] = 4'H0;
            {rslt[8], rslt} = {1'b0, opnd0} + rslt[7:0];
            c_out = c_out | rslt[8];
        end
        8'hB2: begin  // SEX
            rslt  = {{8{opnd0[7]}}, opnd0[7:0]};
            v_out = 1'b0;
        end                
        8'hB3,8'hB4: begin  // MUL, LMUL 
            rslt  = opnd0 * opnd1;
            c_out = rslt[7];
        end
        // 
        8'hCC,8'hCD,8'hCE: begin  // ABS
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

    if ( op!=8'hB0 || op!=8'hB6 || op!=8'hB7 )
        z_out = (rslt == 0);
    if ( op!=8'h08 || op!=8'h09 || op!=8'h0A || op!=8'h0B || op!=8'hB0 || op!=8'hB3 || op!=8'hB4 || op!=8'hB6 || op!=8'hB7 )
        n_out = rslt[msb];
end

endmodule