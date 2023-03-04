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
    Date: 3-03-2023 */

module jtkcpu_ucode(
    input           rst,
    input           clk,
    input           cen,

    input     [7:0] op, // data fetched from memory
    // status inputs
    input           branch,
    input           alu_busy,
    // to do: add all status signals from
    // other blocks

    // control outputs
    output          pul_go,
    output          psh_go,
    // to do: add all control signals to other
    // blocks that will be generated here
);

localparam UCODE_AW = 10, // 1024 ucode lines
           UCODE_DW = 24; // Number of control signals

reg [UCODE_DW-1:0] mem[0:2**(UCODE_AW-1)];
reg [UCODE_AW-1:0] addr; // current ucode position read

// get ucode data from a hex file
// initial begin
//     $readmemh( mem, "jtkcpu_ucode.hex");
// end

// to do: add all output signals to come
// from the current memory row being read
assign { psh_go, pul_go } <= mem[addr];

always @(posedge clk) begin
    if( rst ) begin
        addr <= 0;  // Reset starts ucode at 0
    end else if(cen) begin
        // To do: add control flow to addr progress
        addr <= addr + 1;
    end
end

endmodule