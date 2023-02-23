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
    input      [ 7:0] postbyte,

    output reg [15:0] addr, 
    output reg        rslt, 
);

reg [15:0] s_nxt;
reg [15:0] u_nxt;

always @* begin

    //addr = (op[0]) ? u : s;
    if ( ( op==8'h0C ) || ( op==8'h0D )) begin  // PUSH
        if ( postbyte[7] & ~(postbyte[15] )) begin  // PC_LO
            addr = (op[0]) ? u-1 : s-1;
            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1; 
            rslt = pc[7:0];

        end else if ( postbyte[7] & (postbyte[15] ))  begin  // PC_HI

            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = pc[15:8];

        end else if ( postbyte[6] & ~(postbyte[15] )) begin  // U/S LO
        
            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = (op[0]) ? s[7:0] : u[7:0];

        end else if ( postbyte[6] & (postbyte[15] ))  begin  // U/S HI
            
            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = (op[0]) ? s[15:0] : u[15:0];

        end else if ( postbyte[5] & ~(postbyte[15] )) begin  // Y LO
            
            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = y[7:0];

        end else if ( postbyte[5] & (postbyte[15] ))  begin  // Y HI
            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = y[15:8];

        end else if ( postbyte[4] & ~(postbyte[15] )) begin  // X LO 

            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = x[7:0];

        end else if ( postbyte[4] & (postbyte[15] ))  begin  // X HI
            
            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = x[15:8];

        end else if ( postbyte[3] ) begin  // DP
            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = dp;

        end else if ( postbyte[2] ) begin  // B

            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = b;

        end else if ( postbyte[1] ) begin  // A

            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = a;

        end else if ( postbyte[0] ) begin  // CC
            if ( op==8'h0D)
                u_nxt = u-1;
            else
                s_nxt = s-1;
            rslt = cc;
        end

    end

    else if ( ( op == 8'h0E ) || ( op == 8'h0F )) begin  // PULL
        
        if ( postbyte[0] ) begin  // CC

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = cc

        end else if ( postbyte[1] ) begin  // A

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = a

        end else if ( postbyte[2] ) begin  // B

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = b

        end else if ( postbyte[3] ) begin  // DP

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = dp

        end else if ( postbyte[4] & (postbyte[15] ))  begin  // X HI

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = x[15:8]

        end else if ( postbyte[4] & ~(postbyte[15] )) begin  // X LO 

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = x[7:0]

        end else if ( postbyte[5] & (postbyte[15] ))  begin  // Y HI

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = y[15:8]

        end else if ( postbyte[5] & ~(postbyte[15] )) begin  // Y LO

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = y[7:0]

        end else if ( postbyte[6] & (postbyte[15] ))  begin  // U/S HI

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = (op[0]) ? s[15:8] : u[15:8]; 

        end else if ( postbyte[6] & ~(postbyte[15] )) begin  // U/S LO

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = (op[0]) ? s[7:0] : u[7:0];

        end else if ( postbyte[7] & (postbyte[15] ))  begin  // PC_HI

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = pc[15:8]

        end else if ( postbyte[7] & ~(postbyte[15] )) begin  // PC_LO

            if ( op==8'h0F)
                u_nxt = u+1;
            else
                s_nxt = s+1;
            rslt = pc[7:0]

        end

    end

end  

endmodule

