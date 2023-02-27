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

wire [15:0] opnd0, opnd1, rslt, data, idx_addr, idx_reg;
wire [ 7:0] alu_op, postbyte;
wire [ 7:0] cc, c_out, n_out, z_out, v_out;
wire [ 2:0] idx_sel;
wire        indirect, branch, rst, clr;

jtkcpu_alu(
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

jtkcpu_branch(
    .op         ( alu_op     ), 
    .cc_in      ( cc         ), 
    .branch     ( branch     ), 
);

jtkcpu_exgtfr(
    .op         (      ), 
    .oprn0      (      ), 
    .mux        (      ), 
);

jtkcpu_pshpul(
    .rst        (      ),
    .clk        (      ),
    .op         (      ), 
    .cc_in      (      ), 
    .branch     (      ),
    .pul_go     (      ),
    .psh_go     (      ),
    .psh_bit    (      ),
    .hi_lon     (      ),
    .pul_en     (      ),
    .dec_us     (      ),
    .addr       (      ),
    .psh_sel    (      ),
    .pul_sel    (      ),
    .idle       (      ),
    .us_sel     (      ),
);

jtkcpu_regs(
    .rst        (    ),
    .clk        (    ),
    .op_sel     (    ),
    .postbyte   (    ), 
    .psh_sel    (    ),
    .psh_hilon  (    ),
    .psh_ussel  (    ),
    .pul_en     (    ),
    .cc         (    ),
    .pc         (    ),
    .alu        (    ),
    .up_a       (    ),
    .up_b       (    ),
    .up_dp      (    ),
    .up_x       (    ),
    .up_y       (    ),
    .up_u       (    ),
    .up_s       (    ),
    .dec_us     (    ),
    .mux        (    ),
    .psh_mux    (    ),
    .psh_bit    (    ),
    .idx_reg    (    ),
    .psh_addr   (    ),
    .acc        (    ),
    .up_pull_cc (    ),
    .up_pull_pc (    ),
);

jtkcpu_idx(
    .postbyte   ( postbyte   ), 
    .idx_reg    ( idxReg     ), 
    .a          ( reg_a      ), 
    .b          ( reg_b      ), 
    .data       ( data       ), 
    .idx_sel    ( idx_sel    ), 
    .idx_addr   ( idx_addr   ), 
    .indirect   ( indirect   ),
    .rst        ( rst        ), 
    .clk        ( clk        ), 
);

endmodule