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
    input               rst,
    input               clk,

    input        [ 7:0] op,
    input        [ 7:0] postbyte,

    input               psh_go,
    input        [ 7:0] psh_bit,
    output   reg        hi_lon,

    output   reg [15:0] addr,
    output   reg [ 7:0] psh_sel,
    output              idle,
    output   reg        us_sel
);

reg  [7:0]  psh_sel;


assign idle = psh_sel==0;

always @(posedge clk or posedge rst) begin 
    if(rst) begin
        psh_sel <= 0;
        hi_lon  <= 0;
        us_sel  <= 0;
    end else begin
        if( idle ) begin
            if( psh_go ) begin
                psh_sel <= postbyte;
                us_sel  <= op[0];
                hi_lon  <= 1;
            end
        end else begin
            if( psh_bit[7:4]!=0 && hi_lon ) begin
                hi_lon <= 0;
            end else begin
                hi_lon <= 1;
                psh_sel <= psh_sel & ~psh_bit;
            end
        end
    end
end



endmodule


