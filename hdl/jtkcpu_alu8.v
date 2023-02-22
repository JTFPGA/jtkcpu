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

module jtkcpu_alu8(
	input      [7:0] op, 
	input      [7:0] opnd0, 
	input      [7:0] opnd1, 
	input      [7:0] cc_in,
	output reg [7:0] cc_out,
	output reg [7:0] rslt
);

reg [7:0] tmp;

localparam CC_C = 8'h01;
localparam CC_V = 8'h02;
localparam CC_Z = 8'h04;
localparam CC_N = 8'h08;
localparam CC_H = 8'h20;

always @* begin
    cc_out = cc_in;
    case (op)
        8'h86,8'h87,8'h88: begin  // NEG
            rslt[7:0]        = ~opnd0 + 1'b1;
            cc_out[CC_C] = (rslt[7:0] != 0);
            cc_out[CC_V] = (opnd0 == 'h80);  // 127 ~ -128
        end
        8'h9C,8'h9D,8'h9E: begin  // LSL , ASL
            {cc_out[CC_C], rslt} = {opnd0, 1'b0};
            cc_out[CC_V]         = opnd0[7] ^ opnd0[6];
        end
        8'h93,8'h94,8'h95: begin  // LSR
            {rslt, cc_out[CC_C]} = {1'b0, opnd0};
        end
        8'h99,8'h9A,8'h9B: begin  // ASR
            {rslt, cc_out[CC_C]} = {opnd0[7], opnd0};
        end
        8'hA0,8'hA1,8'hA2: begin  // ROL
            {cc_out[CC_C], rslt} = {opnd0, cc_in[CC_C]};
            cc_out[CC_V]         =  opnd0[7] ^ opnd0[6];
        end
        8'h96,8'h97,8'h98: begin  // ROR
            {rslt, cc_out[CC_C]} = {cc_in[CC_C], opnd0};
        end
        8'h30,8'h31,8'h32,8'h33: begin  // OR
            rslt[7:0]        =  (opnd0 | opnd1);
            cc_out[CC_V] = 0;
        end
        8'h14,8'h15,8'h16,8'h17: begin  // ADD
            {cc_out[CC_C], rslt[7:0]} = {1'b0, opnd0} + {1'b0, opnd1};
            cc_out[CC_V]              =  (opnd0[7] & opnd1[7] & ~rslt[7]) | (~opnd0[7] & ~opnd1[7] & rslt[7]);
            cc_out[CC_H]              =  opnd0[4] ^ opnd1[4] ^ rslt[4];
        end
        8'h1C,8'h1D,8'h1E,8'h1F: begin  // SUB
            {cc_out[CC_C], rslt[7:0]} = {1'b0, opnd0} - {1'b0, opnd1};
            cc_out[CC_V]              = (opnd0[7] & ~opnd1[7] & ~rslt[7]) | (~opnd0[7] & opnd1[7] & rslt[7]);
        end
        8'h24,8'h25,8'h26,8'h27,8'h28,8'h29,8'h2a,8'h2b: begin  // AND, BIT
            rslt[7:0]        = (opnd0 & opnd1);
            cc_out[CC_V] = 1'b0;
        end
        8'h2C,8'h2D,8'h2E,8'h2F: begin    // EOR
            rslt[7:0]        = (opnd0 ^ opnd1);
            cc_out[CC_V] = 1'b0;
        end
        8'h34,8'h35,8'h36,8'h37: begin  // CMP
            {cc_out[CC_C], rslt[7:0]} = {1'b0, opnd0} - {1'b0, opnd1};
            cc_out[CC_V]              = (opnd0[7] & ~opnd1[7] & ~rslt[7]) | (~opnd0[7] & opnd1[7] & rslt[7]);
        end
        8'h83,8'h84,8'h85: begin  // COM
            rslt[7:0] =  ~opnd0;
            cc_out[CC_V] = 1'b0;
            cc_out[CC_C] = 1'b1;
        end
        8'h18,8'h19,8'h1A,8'h1B: begin  // ADC
            {cc_out[CC_C], rslt[7:0]} =  {1'b0, opnd0} + {1'b0, opnd1} + {8'd0,cc_in[CC_C]};
            cc_out[CC_V] = (opnd0[7] & opnd1[7] & ~rslt[7]) | (~opnd0[7] & ~opnd1[7] & rslt[7]);
            cc_out[CC_H] = opnd0[4] ^ opnd1[4] ^ rslt[4];
        end
        8'h10,8'h11,8'h12,8'h13,8'h3A,8'h3B,8'h90,8'h91,8'h92,8'hCC,8'hCD: begin  // LD , ST , TST , ABS
            rslt[7:0] =  opnd0;
            cc_out[CC_V] = 1'b0;
        end
        8'h89,8'h8A,8'h8B: begin  // INC
            rslt             =  opnd0 + 1'b1;
            cc_out[CC_V] =  (~opnd0[7] & rslt[7]);
        end
        8'h8C,8'h8D,8'h8E: begin  // DEC
            rslt             = opnd0 - 1'b1;
            cc_out[CC_V] = (opnd0[7] & ~rslt[7]);
        end
        8'h80,8'h81,8'h82: begin  // CLR
            rslt[7:0] =  8'h00;
            cc_out[CC_V]   =  1'b0;
            cc_out[CC_C]   =  1'b0;
        end
        8'h20,8'h21,8'h22,8'h23: begin   // SBC
            {cc_out[CC_C], rslt[7:0]} = {1'b0, opnd0} - {1'b0, opnd1} - {8'd0,cc_in[CC_C]};
            cc_out[CC_V]              = (opnd0[7] & ~opnd1[7] & ~rslt[7]) | (~opnd0[7] & opnd1[7] & rslt[7]);
        end
        8'h3C:  // ANDCC
            rslt = (opnd0 & opnd1);
        8'h3D:  // ORCC
            rslt = (opnd0 | opnd1);





        8'hB2: begin  // SEX
            {cc_out[CC_N], rslt[7:0]} = opnd0[7];
            cc_out[CC_V]              = 1'b0;
        end
        8'hB1: begin  // DAA
            if ( ((cc_out[CC_C]) || (opnd0[7:4] > 4'h9)) || ((opnd0[7:4] > 4'h8) && (opnd0[3:0] > 4'h9)) )
                tmp[7:4] = 4'h6;
            else
                tmp[7:4] = 4'h0;
            if ((cc_out[CC_H]) || (a[3:0] > 4'h9))
                tmp[3:0] = 4'h6;
            else
                tmp[3:0] = 4'h0;
            {tmp[8], rslt} = {1'b0, opnd0} + tmp[7:0];
            cc_out[CC_C]   = cc_out[CC_C] | tmp[8];
            cc_out[CC_N]   = rslt[7];
        end
        default:
            rslt = 8'h00;           
    endcase

    cc_out[CC_N] = rslt[7];
    cc_out[CC_Z] = (rslt == 8'h00);
end

endmodule
