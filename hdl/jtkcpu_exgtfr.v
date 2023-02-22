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

module jtkcpu_exgtfr(
	input        [ 7:0] op, 
    input        [ 7:0] opnd0,
    input        [15:0] mux,
    output   reg [15:0] rslt
    output   reg [15:0] x,
    output   reg [15:0] y,
    output   reg [15:0] u,
    output   reg [15:0] s,
    output   reg [15:0] pc,
    output   reg [ 7:0] dp,
    output   reg [ 7:0] cc,
    output   reg [ 7:0]  a,
    output   reg [ 7:0]  b,
);


always @* begin

    if ( op == 8'h3F ) begin
        case ( opnd0[3:0] )
            4'b0000: {a, b} = mux;
            4'b0001:      x = mux;
            4'b0010:      y = mux;
            4'b0011:      u = mux;
            4'b0100:      s = mux;
            4'b0101:     pc = mux;
            4'b1000:     dp = mux[7:0];
            4'b1001:     cc = mux[7:0];
            4'b1010:      a = mux[7:0];
            4'b1011:      b = mux[7:0];
            default:      0
        endcase           
    end 

    /*else if ( op == 8'h3E ) begin
        case ( opnd0[7:4] )
            4'b0000: {a, b} = ;
            4'b0001:      x = ;
            4'b0010:      y = ;
            4'b0011:      u = ;
            4'b0100:      s = ;
            4'b0101:     pc = ;
            4'b1000:     dp = ;
            4'b1001:     cc = ;
            4'b1010:      a = ;
            4'b1011:      b = ;
            default:      0
        endcase
        case ( opnd0[3:0] )
            4'b0000: {a, b} = ;
            4'b0001:      x = ;
            4'b0010:      y = ;
            4'b0011:      u = ;
            4'b0100:      s = ;
            4'b0101:     pc = ;
            4'b1000:     dp = ;
            4'b1001:     cc = ;
            4'b1010:      a = ;
            4'b1011:      b = ;
            default:      0
        endcase
    end*/

end
endmodule
