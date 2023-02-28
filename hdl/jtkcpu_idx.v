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
    
    input      [15:0] idx_reg, 
    input      [15:0] data,  // offset encoded in the data after the op
    input      [ 7:0] postbyte, 
    input      [ 7:0] a, 
    input      [ 7:0] b, 

    output reg [15:0] idx_addr, 
    output reg [ 2:0] idx_sel,
    output reg        indirect
);

reg [15:0] offset;

assign idx_sel = { postbyte[1], postbyte[6:5] };

always @* begin
    indirect     = postbyte[4];

    if ( !postbyte[7] ) begin // 5-bit-offset    
        case( postbyte[3:0] )
            4'b0000: offset =  1;
            4'b0001: offset =  2;
            4'b0010: offset = -1;
            4'b0011: offset = -2;
            4'b0100: offset =  0;
            4'b0101: offset =  { {8{b[7]}}, b };
            4'b0110: offset =  { {8{a[7]}}, a };
            4'b1000: offset =  { {8{data[7]}}, data[7:0] };
            4'b1001: offset =  data;
            4'b1011: offset =  {a, b};
            4'b1100: offset =  { {8{data[7]}}, data[7:0] };
            4'b1101: offset =  data;
            4'b1111: offset =  0;
            default: offset =  0;
        endcase
    end else begin
        offset = { {11{postbyte[4]}}, postbyte[4:0] }; // 5-bit sign extension
    end
end

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        idx_addr <= 0;
    end else begin
        idx_addr <= idx_reg + offset;
    end
end

endmodule
