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
    input               rst,
    input               clk,
    input               cen,

    input               halt,
    input               nmi,
    input               irq,
    input               firq,
    input               dtack, 

    // memory bus
    input        [ 7:0] din,
    output       [ 7:0] dout,
    output       [23:0] addr,
    output              we,    // write enable
    output              as     // 

    // to do: add the rest of pins, check AJAX schematics
    // pins must connect to modules below and all must be driven
);

wire [15:0] opnd0, opnd1, rslt; 
wire [15:0] data, idx_reg, mux, acc;
wire [15:0] idx_addr, psh_addr;
wire [15:0] x, y, u, s, pc, nx_u, nx_s; 
wire [ 7:0] a, b, cc, dp;
wire [ 7:0] alu_op, postbyte;
wire [ 7:0] psh_bit, psh_sel, psh_mux;
wire [ 2:0] idx_sel;
wire [ 2:0] vector;
wire        busy;
wire        idx_en,psh_en;
wire        c_out, n_out, z_out, v_out, h_out;
wire        up_a, up_b, up_cc, up_dp, up_x, up_y, up_u, up_s, up_pc; 
wire        indirect, branch; 
wire        hi_lon, pul_en, dec_us, us_sel;

jtkcpu_ctrl u_ctrl(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),

    .op         ( alu_op     ), 
    .psh_bit    ( psh_bit    ),
    .hi_lon     ( hi_lon     ),
    .pul_en     ( pul_en     ),
    .dec_us     ( dec_us     ),
    .psh_sel    ( psh_sel    ),
    .us_sel     ( us_sel     ),
    .postbyte   ( postbyte   )

    // to do: fill in the rest
);

jtkcpu_memctrl u_memctrl(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),

    .addr       ( addr       ),
    .din        ( din        ),
    .idx_addr   ( idx_addr   ),
    .psh_addr   ( psh_addr   ),
    .pc         ( pc         ),
    .dp         ( dp         ),
    .data       ( data       ),
    .busy       ( busy       ),
    .halt       ( halt       ),
    .idx_en     ( idx_en     ),
    .psh_en     ( psh_en     ),
    .vector     ( vector     )

    // to do: fill in the rest
);

jtkcpu_alu u_alu(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),

    .op         ( alu_op     ), 
    .opnd0      ( opnd0      ), 
    .opnd1      ( opnd1      ), 
    .cc_in      ( cc         ),
    .c_out      ( c_out      ),
    .v_out      ( v_out      ),
    .z_out      ( z_out      ),
    .n_out      ( n_out      ),
    .h_out      ( h_out      ),
    .busy       ( busy       ),
    .rslt       ( rslt       )
);

jtkcpu_regs u_regs(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),

    .op_sel     ( alu_op     ), 
    .psh_sel    ( psh_sel    ),
    .psh_hilon  ( hi_lon     ),
    .psh_ussel  ( us_sel     ),
    .pul_en     ( pul_en     ),
    .psh_mux    ( psh_mux    ),
    .psh_bit    ( psh_bit    ),
    .psh_addr   ( psh_addr   ), // to do: rename connection to psh_addr
    .dec_us     ( dec_us     ),
    .cc         ( cc         ),
    .pc         ( pc         ),
    .alu        ( rslt       ),
    .up_a       ( up_a       ),
    .up_b       ( up_b       ),
    .up_dp      ( up_dp      ),
    .up_x       ( up_x       ),
    .up_y       ( up_y       ),
    .up_u       ( up_u       ),
    .up_s       ( up_s       ),
    .mux        ( mux        ),
    .idx_reg    ( idx_reg    ),
    .acc        ( acc        ),
    .up_pul_cc  ( up_cc      ),
    .up_pul_pc  ( up_pc      ),
    .nx_u       ( nx_u       ),
    .nx_s       ( nx_s       )
);

jtkcpu_idx u_idx(
    .rst        ( rst        ), 
    .clk        ( clk        ), 
    .cen        ( cen        ),

    .postbyte   ( postbyte   ), 
    .idx_reg    ( idx_reg    ), 
    .a          ( a          ), 
    .b          ( b          ), 
    .data       ( data       ), 
    .idx_sel    ( idx_sel    ), 
    .idx_addr   ( idx_addr   ), // to do: rename output connection to idx_addr
    .indirect   ( indirect   )
);

endmodule