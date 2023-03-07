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

// Op codes = 8 bits, many op-codes will be parsed in the
// same way. Let's assume we only need 64 ucode routines
// 64 = 2^6, Using 2^10 memory rows -> 2^4=16 rows per
// routine
// To do: group op codes in categories that can be parsed
// using the same ucode. 32 categories used for op codes
// another 32 categories reserved for common routines

localparam UCODE_AW = 10, // 1024 ucode lines
           OPCAT_AW = 5,  // op code categories
           UCODE_DW = 24; // Number of control signals

// to do: define localparam with op categories
localparam [5:0] SINGLE_ALU = 1,
                 MULTI_ALU  = 2,
                 SBRANCH    = 3,
                 LBRANCH    = 4,
                 LOOPX      = 5,
                 LOOPB      = 6,
                 BMOVE      = 7,
                 MOVE       = 8,
                 BSETA      = 9,
                 BSETD      = 10,
                 RIT        = 11,
                 PSH        = 12,
                 PUL        = 13
                 SETLINES   = 14
                 STORE      = 15; // to do: add more as needed

reg [UCODE_DW-1:0] mem[0:2**(UCODE_AW-1)];
reg [UCODE_AW-1:0] addr; // current ucode position read
reg [OPCAT_AW-1:0] opcat;
reg                idx_src; // instruction requires idx decoding first to grab the source operand

wire ni, buserror; // next instruction

// Conversion of opcodes to op category
always @* begin
    // to do: fill the rest
    case( op )
        ADDA_IMM, ADDB_IMM, ADDA_IDX, ADDB_IDX: opcat = SINGLE_ALU; // to do: add other ALU operations that resolve in a single cycle
        LSRW, RORW, DIV: opcat = MULTI_ALU; // to do: fill the rest
        default: opcat = BUSERROR; // stop condition
    endcase
end

always @* begin
    case( op )
        ADDA_IDX, ADDB_IDX: idx_src = 1; // to do: add the rest
        default: idx_src = 0;
    endcase
end

// get ucode data from a hex file
// initial begin
//     $readmemh( mem, "jtkcpu_ucode.hex");
// end

// to do: add all output signals to come
// from the current memory row being read
assign { /* add other control signals */ psh_go, pul_go, buserror, ni } = mem[addr];

always @(posedge clk) begin
    if( rst ) begin
        addr <= 0;  // Reset starts ucode at 0
    end else if(cen && !buserror) begin
        // To do: add the rest of control flow to addr progress
        addr <= addr + 1; // when we keep processing an opcode routine
        if( ni ) addr <= {1'd0,opcat,4'd0}; // when a new opcode is read
    end
end

endmodule