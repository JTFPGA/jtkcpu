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
    indirect   =  0;
    mode       =  0;

    if (postbyte[7] == 0)           // 5-bit
    begin
        mode   =  IDX_MODE_5BIT_OFFSET;
    end
    else
    begin
        mode   =  postbyte[3:0];
        indirect   =  postbyte[4];
    end
    /*if ((mode != IDX_MODE_8BIT_OFFSET_PC) && (mode != IDX_MODE_16BIT_OFFSET_PC))
        regnum[2:0]    =  {1'b0,postbyte[6:5]};
    else
        regnum[2:0]    =  IDX_REG_PC;*/
    if ((mode[6:5] != 2'b00) && (mode[6:5] != 2'b01) && (mode[6:5] != 2'b10) && (mode[6:5] != 2'b11))
        regnum[2:0]    =  IDX_REG_PC;
    else
        regnum[2:0]    =  {1'b0,postbyte[6:5]};

end
endfunction

endmodule
