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
	input      [7:0] cc,
    output reg       branch 
);

`include "jtkcpu.inc"

always @* begin
    case( op )
        8'h60,8'h68,8'hAA,8'hAB: branch = 1;  // BRA , LBRA , BSR , LBSR
        8'h70,8'h78: branch = 0; // BRN , LBRN
        8'h61,8'h69: branch = !( cc[CC_Z] | cc[CC_C] ); // BHI , LBHI
        8'h71,8'h79: branch = ( cc[CC_Z] | cc[CC_C] );  // BLS , LBLS
        8'h62,8'h6A: branch = !cc[CC_C]; // BCC , LBCC
        8'h72,8'h7A: branch = cc[CC_C];  // BCS , LBCS
        8'h63,8'h6B: branch = !cc[CC_Z]; // BNE , LBNE
        8'h73,8'h7B: branch = cc[CC_Z];  // BEQ , LBEQ
        8'h64,8'h6C: branch = !cc[CC_V]; // BVC , LBVC
        8'h74,8'h7C: branch = cc[CC_V];  // BVS , LBVS
        8'h65,8'h6D: branch = !cc[CC_N]; // BPL , LBPL
        8'h75,8'h7D: branch = cc[CC_N];  // BMI , LBMI
        8'h66,8'h6E: branch = !( cc[CC_N] ^ cc[CC_V] ); // BGE , LBGE
        8'h76,8'h7E: branch = ( cc[CC_N] ^ cc[CC_V] );  // BLT , LBLT
        8'h67,8'h6F: branch = !( cc[CC_N] ^ cc[CC_V] ) & !( cc[CC_Z] ); // BGT , LBGT
        8'h77,8'h7F: branch = ( cc[CC_N] ^ cc[CC_V] ) | ( cc[CC_Z] );   // BLE , LBLE
        default:     branch = 0;
    endcase
end

endmodule
