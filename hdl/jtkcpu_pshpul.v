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

module jtkcpu_pshpul(
	input      [ 7:0] op,
    input      [ 7:0] u, 
    input      [ 7:0] s,
    input      [15:0] postbyte,

    output reg [15:0] addr, 
    output reg        rslt, 
);

always @* begin

    //addr = (op[0]) ? u : s;
    if ( ( op == 8'h0C ) || ( op == 8'h0D )) begin
        if ( postbyte[7] & ~(postbyte[15] )) begin  // PC_LO
            addr = (postbyte[14]) ? u-1 : s-1;
            if (postbyte[14])  

        end else if ( postbyte[7] & (postbyte[15] ))  begin  // PC_HI

        end else if ( postbyte[6] & ~(postbyte[15] )) begin  // U/S LO
        
        end else if ( postbyte[6] & (postbyte[15] ))  begin  // U/S HI
            
        end else if ( postbyte[5] & ~(postbyte[15] )) begin  // Y LO

        end else if ( postbyte[5] & (postbyte[15] ))  begin  // Y HI

        end else if ( postbyte[4] & ~(postbyte[15] )) begin  // X LO 

        end else if ( postbyte[4] & (postbyte[15] ))  begin  // X HI
        
        end else if ( postbyte[3] ) begin  // DP
        
        end else if ( postbyte[2] ) begin  // B

        end else if ( postbyte[1] ) begin  // A

        end else if ( postbyte[0] ) begin  // CC

        end

    end

    else if ( ( op == 8'h0E ) || ( op == 8'h0F )) begin
        
        if ( postbyte[0] ) begin  // CC

        end else if ( postbyte[1] ) begin  // A

        end else if ( postbyte[2] ) begin  // B

        end else if ( postbyte[3] ) begin  // DP

        end else if ( postbyte[4] & (postbyte[15] ))  begin  // X HI

        end else if ( postbyte[4] & ~(postbyte[15] )) begin  // X LO 

        end else if ( postbyte[5] & (postbyte[15] ))  begin  // Y HI

        end else if ( postbyte[5] & ~(postbyte[15] )) begin  // Y LO

        end else if ( postbyte[6] & (postbyte[15] ))  begin  // U/S HI

        end else if ( postbyte[6] & ~(postbyte[15] )) begin  // U/S LO

        end else if ( postbyte[7] & (postbyte[15] ))  begin  // PC_HI

        end else if ( postbyte[7] & ~(postbyte[15] )) begin  // PC_LO

        end

    end

end  

endmodule

