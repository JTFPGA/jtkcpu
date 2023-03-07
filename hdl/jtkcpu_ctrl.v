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

module jtkcpu_ctrl(
    input             rst,
    input             clk,
    input             cen,

    input      [ 7:0] op,
    input      [ 7:0] postbyte,

    input      [ 7:0] psh_bit,

    input             halt
    input             vector,


    // to do: connect interrupt
    // from jtkcpu top level

    // to do: add status signals from other modules as inputs

    // to do: add control signals to other modules as outputs

);

// to do: signals that are resolved within the
// module should be here as wires. Watchout for buses
wire branch;
wire pul_go, psh_go, idle;


jtkcpu_ucode u_ucode(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),

    .op         ( alu_op     ), 
    .branch     ( branch     ),
    .pul_go     ( pul_go     ),
    .psh_go     ( psh_go     ),

    // To do: finish connections
);

// some of the instruction logic is
// decoded in hardware, not in ucode:

// to do: add logic to handle interrupts

jtkcpu_branch u_branch(
    .op         ( alu_op     ), 
    .cc         ( cc         ), 
    .branch     ( branch     ) 
);

jtkcpu_pshpul u_pshpul(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),

    .op         ( alu_op     ), 
    .pul_go     ( pul_go     ),
    .psh_go     ( psh_go     ),
    .psh_bit    ( psh_bit    ),
    .hi_lon     ( hi_lon     ),
    .pul_en     ( pul_en     ),
    .dec_us     ( dec_us     ),
    .psh_sel    ( psh_sel    ),
    .idle       ( idle       ),
    .us_sel     ( us_sel     ),
    .postbyte   ( postbyte   )
);

endmodule