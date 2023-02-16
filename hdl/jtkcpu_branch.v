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
    output reg [7:0] branch, 
);

always @* begin
    branch = 0;                                                     // Default
    case (op)
        8'h60,8'h68,8'hAA,8'hAB:                                    // BRA , LBRA , BSR , LBSR
            branch = 1;
        8'h70,8'h78:                                                // BRN , LBRN
            branch = 0;
        8'h61,8'h69:                                                // BHI , LBHI
            if ( ( cc_in[CC_Z_BIT] | cc_in[CC_C_BIT] ) == 0)
                branch = 1;
        8'h71,8'h79:                                                // BLS , LBLS
            if ( cc_in[CC_Z_BIT] | cc_in[CC_C_BIT] )
                branch = 1;
        8'h62,8'h6A:                                                // BCC , LBCC
            if ( cc_in[CC_C_BIT] == 0 )
                branch = 1;
        8'h72,8'h7A:                                                // BCS , LBCS
            if ( cc_in[CC_C_BIT] == 1 )
                branch = 1;
        8'h63,8'h6B:                                                // BNE , LBNE
            if ( cc_in[CC_Z_BIT] == 0 )
                branch = 1;
        8'h73,8'h7B:                                                // BEQ , LBEQ
            if ( cc_in[CC_Z_BIT] == 1 )
                branch = 1;
        8'h64,8'h6C:                                                // BVC , LBVC
            if ( cc_in[CC_V_BIT] == 0)
                branch = 1;
        8'h74,8'h7C:                                                // BVS , LBVS
            if ( cc_in[CC_V_BIT] == 1)
                branch = 1;
        8'h65,8'h6D:                                                // BPL , LBPL
            if ( cc_in[CC_N_BIT] == 0 )
                branch = 1;
        8'h75,8'h7D:                                                // BMI , LBMI
            if (cc_in[CC_N_BIT] == 1)
                branch = 1;
        8'h66,8'h6E:                                                // BGE , LBGE
            if ((cc_in[CC_N_BIT] ^ cc_in[CC_V_BIT]) == 0)
                branch = 1;
        8'h76,8'h7E:                                                // BLT , LBLT
            if ((cc_in[CC_N_BIT] ^ cc_in[CC_V_BIT]) == 1)
                branch = 1;
        8'h67,8'h6F:                                                // BGT , LBGT
            if ( ((cc_in[CC_N_BIT] ^ cc_in[CC_V_BIT]) == 0) & (cc_in[CC_Z_BIT] == 0) )
                branch = 1;
        8'h77,8'h7F:                                                // BLE , LBLE
            if ( ((cc_in[CC_N_BIT] ^ cc_in[CC_V_BIT]) == 1) | (cc_in[CC_Z_BIT] == 1) )
                branch = 1;
    endcase
end

endmodule
