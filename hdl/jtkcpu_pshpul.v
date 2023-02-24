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
    output   reg        pul_en,

    output   reg [15:0] addr,
    output   reg [ 7:0] psh_sel,
    output   reg [ 7:0] pul_sel,
    output              idle,
    output   reg        us_sel
);

reg  [7:0]  psh_sel;

assign idle = psh_sel==0;
//assign idle = op[1] ? psh_sel==0 : pul_sel==0;

always @(posedge clk or posedge rst) begin 
    if(rst) begin
        psh_sel <= 0;
        hi_lon  <= 0;
        us_sel  <= 0;
        pul_en  <= 0;
    end else begin
        if( idle ) begin
            pul_en <= 0;
            if( psh_go || pul_go ) begin
                psh_sel <= postbyte;
                us_sel  <= op[0];
                hi_lon  <= 1;
                pul_en  <= 1;
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


/*/always @(posedge clk or posedge rst) begin 
    if(rst) begin
        us_sel  <= 0;
        pul_sel <= 0;
        hi_lon  <= 0;
    end else begin
        if ( op==8'h0E || op==8'h0F ) begin
            casez( postbyte )
                8'b????_???1: begin pul_sel = up_cc; us_sel = op[0]; end
                8'b????_??10: begin pul_sel =  up_a; us_sel = op[0]; end
                8'b????_?100: begin pul_sel =  up_b; us_sel = op[0]; end
                8'b????_1000: begin pul_sel = up_dp; us_sel = op[0]; end
                8'b???1_0000: begin pul_sel =  up_x; us_sel = op[0]; end
                8'b??10_0000: begin pul_sel =  up_y; us_sel = op[0]; end
                8'b?100_0000: begin pul_sel = us_sel=op[0] ? up_s : up_u; end
                default:      begin pul_sel = up_pc; us_sel = op[0]; end
            endcase    
        end else begin
            if( psh_bit[7:4]!=0 && hi_lon ) begin
                pul_sel <= postbyte;
                hi_lon <= 1;
            end else begin
                hi_lon <= 0;
                pul_sel <= pul_sel & ~psh_bit;
            end
        end
    end
end


/*always @(posedge clk or posedge rst) begin 
    if(rst) begin
        psh_sel <= 0;
        pul_sel <= 0;
        hi_lon  <= 0;
        us_sel  <= 0;
    end else begin
        if( idle ) begin
            us_sel  <= op[0];
            if( psh_go ) begin
                psh_sel <= postbyte;
                hi_lon  <= 1;
            end else begin
                pul_sel <= postbyte;
                hi_lon <= 0;
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
*/

endmodule


