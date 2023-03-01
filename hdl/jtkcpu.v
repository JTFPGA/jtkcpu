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

wire [15:0] opnd0, opnd1, rslt; 
wire [15:0] data, addr, idx_reg, mux, acc;
wire [15:0] x, y, u, s, pc, nx_u, nx_s; 
wire [ 7:0] alu_op, postbyte;
wire [ 7:0] reg_a, reg_b;
wire [ 7:0] cc, c_out, n_out, z_out, v_out, h_out;
wire [ 7:0] psh_bit, psh_sel, psh_mux;
wire [ 2:0] idx_sel;
wire        up_a, up_b, up_cc, up_dp, up_x, up_y, up_u, up_s, up_pc; 
wire        rst, clr; 
wire        indirect, branch, rst, clk; 
wire        pul_go, psh_go, hi_lon, pul_en, dec_us, us_sel, idle;

jtkcpu_alu u_alu(
    .op         ( alu_op     ), 
    .opnd0      ( opnd0      ), 
    .opnd1      ( opnd1      ), 
    .cc_in      ( cc         ),
    .c_out      ( c_out      ),
    .v_out      ( v_out      ),
    .z_out      ( z_out      ),
    .n_out      ( n_out      ),
    .h_out      ( h_out      ),
    .rslt       ( rslt       )
);

jtkcpu_branch u_branch(
    .op         ( alu_op     ), 
    .cc         ( cc         ), 
    .branch     ( branch     ) 
);

// jtkcpu_exgtfr(
//     .op         (      ), 
//     .oprn0      (      ), 
//     .mux        (      ), 
// );

jtkcpu_pshpul u_pshpul(
    .rst        ( rst        ),
    .clk        ( clk        ),
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

jtkcpu_regs u_regs(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .op_sel     ( alu_op     ), 
    .psh_sel    ( psh_sel    ),
    .psh_hilon  ( hi_lon     ),
    .psh_ussel  ( us_sel     ),
    .pul_en     ( pul_en     ),
    .psh_mux    ( psh_mux    ),
    .psh_bit    ( psh_bit    ),
    .psh_addr   ( addr       ),
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
    .up_s       ( s          ),
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
    .postbyte   ( postbyte   ), 
    .idx_reg    ( idx_reg    ), 
    .a          ( reg_a      ), 
    .b          ( reg_b      ), 
    .data       ( data       ), 
    .idx_sel    ( idx_sel    ), 
    .idx_addr   ( addr       ), 
    .indirect   ( indirect   )
);

endmodule