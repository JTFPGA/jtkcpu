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

module jtkcpu_alu16(
	input      [7:0] op, 
	input      [15:0] opnd0, 
	input      [15:0] opnd1, 
	input      [7:0] cc_in,
	output reg [7:0] cc_out,
	output reg [15:0] rslt
);

always @* begin
    cc_out = cc_in;
    case (op)
        
        8'h54,8'h55,8'hB0: begin      // ADD , ABX
            {cc_out[CC_C_BIT], rslt} =  {1'b0, opnd0} + opnd1;
            cc_out[CC_V_BIT]   =  (opnd0[15] & opnd1[15] & ~rslt[15]) | (~opnd0[15] & ~opnd1[15] & rslt[15]);
        end

        8'h56,8'h57: begin      // SUB
            {cc_out[CC_C_BIT], rslt} =  {1'b0, opnd0} - {1'b0, opnd1};
            cc_out[CC_V_BIT]   =  (opnd0[15] & ~opnd1[15] & ~rslt[15]) | (~opnd0[15] & opnd1[15] & rslt[15]);
        end

        8'h40,8'h41,8'h42,8'h43,8'h44,8'h45,8'h46,8'h47,8'h48,8'h49: begin       // LD
            rslt  =  opnd1;
            cc_out[CC_V_BIT]   =  1'b0;
        end

        8'h4A,8'h4B,8'h4C,8'h4D,8'h4E,8'h4F,8'h50,8'h51,8'h52,8'h53: begin      // CMP
            {cc_out[CC_C_BIT], rslt} =  {1'b0, opnd0} - {1'b0, opnd1};
            cc_out[CC_V_BIT]   =  (opnd0[15] & ~opnd1[15] & ~rslt[15]) | (~opnd0[15] & opnd1[15] & rslt[15]);
        end

        8'h08,8'h09,8'h0A,8'h0B: begin      // LEA
            rslt  =  opnd0;
        end


        default:
            rslt = 16'h0000;

    endcase


    cc_out[CC_Z_BIT]   =  (rslt[15:0] == 16'h0000);
    if ((op != 8'h08) || (op != 8'h09) || (op != 8'h0A) || (op != 8'h0B))
        cc_out[CC_N_BIT]   =  rslt[15];

end

endmodule