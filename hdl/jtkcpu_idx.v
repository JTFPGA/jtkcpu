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

module jtkcpu_idx(
    input             rst,
    input             clk,
    input             cen,

    input      [15:0] idx_reg,
    input      [15:0] mdata,
    input      [ 7:0] a,
    input      [ 7:0] b,

    // Control
    input             idx_ret,
    input             idx_ld,

    output reg [15:0] addr,
    output reg        busy,
    output reg        indirect

);

reg  [15:0] offset;
reg         idx_enl;
wire [ 7:0] postbyte;

assign postbyte = mdata[7:0];

// assign idx_sel = { postbyte[1], postbyte[6:5] };

always @* begin
    indirect = postbyte[3];
    use_dp   = postbyte==8'hc4 || postbyte==8'hcc;

    case( { postbyte[7], postbyte[2:0] } )
        4'b0_000: offset =  1;
        4'b0_001: offset =  2;
        4'b0_010: offset = -1;
        4'b0_011: offset = -2;
        4'b0_100: offset =  0;
        4'b0_101: offset =  { {8{b[7]}}, b };
        4'b0_110: offset =  { {8{a[7]}}, a };
        4'b1_000: offset =  { {8{mdata[7]}}, mdata[7:0] };
        4'b1_001: offset =  mdata;
        4'b1_011: offset =  {a, b};
        4'b1_100: offset =  { {8{mdata[7]}}, mdata[7:0] };
        4'b1_101: offset =  mdata;
        4'b1_111: offset =  0;
        default: offset =  0;
    endcase
end

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        addr <= 0;
        busy <= 0;
    end else if (cen) begin
        if( idx_ret ) begin
            addr <= idx_ld ? mdata : idx_reg + offset;
        end
    end
end

endmodule
