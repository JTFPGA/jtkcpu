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

module jtkcpu_idxdecode(
	input      [7:0] postbyte, 
	output reg [7:0] regnum,
	output reg [7:0] mode,
    output reg       indirect
);

always @* begin
    indirect     = 0;
    mode         = 0;

    if (postbyte[7] == 0)                           // 5-bit-offset
    begin
        mode     =  5'b00000;
    end
    else
    begin
        mode     = postbyte[3:0];
        indirect = postbyte[4];
    end

    if ((mode != 4'b1100) && (mode != 4'b1101))
        regnum[2:0] = {1'b0,postbyte[6:5]};         // Register field (X,Y,U,S)
    else
        regnum[2:0] = PCR;                          // Register PC 
end

endmodule
