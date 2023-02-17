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

module jtkcpu(
);

wire [15:0] opnd0, opnd1, rslt16, data, idx_addr, idx_reg;
wire [ 7:0] alu_op, rslt8, postbyte;
wire [ 7:0] cc, nx_cc8, nx_cc16;
wire [ 2:0] idx_sel;
wire        indirect, branch, rst, clr;

jtkcpu_alu8(
    .op       ( alu_op     ), 
    .opnd0    ( opnd0[7:0] ), 
    .opnd1    ( opnd1[7:0] ), 
    .cc_in    ( cc         ),
    .cc_out   ( nx_cc8     ),
    .rslt     ( rslt8      )
);

jtkcpu_alu16(
    .op       ( alu_op     ), 
    .opnd0    ( opnd0      ), 
    .opnd1    ( opnd1      ), 
    .cc_in    ( cc         ),
    .cc_out   ( nx_cc16    ),
    .rslt     ( rslt16     )
);

jtkcpu_branch(
    .op       ( alu_op     ), 
    .cc_in    ( cc         ), 
    .branch   ( branch     ), 
);

jtkcpu_idx(
    .postbyte ( postbyte   ), 
    .idx_reg  ( idxReg     ), 
    .a        ( reg_a      ), 
    .b        ( reg_b      ), 
    .data     ( data       ), 
    .idx_sel  ( idx_sel    ), 
    .idx_addr ( idx_addr   ), 
    .indirect ( indirect   ),
    .rst      ( rst        ), 
    .clk      ( clk        ), 
);

endmodule