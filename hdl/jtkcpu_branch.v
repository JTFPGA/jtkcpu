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

module jtkcpu_branch(
	input      [7:0] op, 
	input      [7:0] cc_in,
    output reg       branch, 
);

localparam CC_C = 8'h01;
localparam CC_V = 8'h02;
localparam CC_Z = 8'h04;
localparam CC_N = 8'h08;

always @* begin
    case( op )
        8'h60,8'h68,8'hAA,8'hAB: // BRA , LBRA , BSR , LBSR
            branch = 1;
        8'h70,8'h78: // BRN , LBRN
            branch = 0;
        8'h61,8'h69: // BHI , LBHI
            branch = !( cc_in[CC_Z] | cc_in[CC_C] )
        8'h71,8'h79: // BLS , LBLS
            branch = ( cc_in[CC_Z] | cc_in[CC_C] )
        8'h62,8'h6A: // BCC , LBCC
            branch = !cc_in[CC_C]
        8'h72,8'h7A: // BCS , LBCS
            branch = cc_in[CC_C]
        8'h63,8'h6B: // BNE , LBNE
            branch = !cc_in[CC_Z]
        8'h73,8'h7B: // BEQ , LBEQ
            branch = cc_in[CC_Z]
        8'h64,8'h6C: // BVC , LBVC
            branch = !cc_in[CC_V];
        8'h74,8'h7C: // BVS , LBVS
            branch = cc_in[CC_V]
        8'h65,8'h6D: // BPL , LBPL
            branch = !cc_in[CC_N]
        8'h75,8'h7D: // BMI , LBMI
            branch = cc_in[CC_N]
        8'h66,8'h6E: // BGE , LBGE
            branch = !( cc_in[CC_N] ^ cc_in[CC_V] )
        8'h76,8'h7E: // BLT , LBLT
            branch = ( cc_in[CC_N] ^ cc_in[CC_V] )
        8'h67,8'h6F: // BGT , LBGT
            branch = !( cc_in[CC_N] ^ cc_in[CC_V] ) & !( cc_in[CC_Z] ) 
        8'h77,8'h7F: // BLE , LBLE
            branch = ( cc_in[CC_N] ^ cc_in[CC_V] ) | ( cc_in[CC_Z] )
        default: branch = 0;
    endcase
end

endmodule
