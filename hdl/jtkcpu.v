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
    input               cen2,

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
    output              as      
);

wire [15:0] opnd0;
wire [31:0] rslt;
wire [15:0] data, idx_reg, mux, d_mux, acc;
wire [15:0] idx_addr, psh_addr;
wire [15:0] regs_x, regs_y, u, s, pc, nx_u, nx_s; 
wire [ 7:0] a, b, cc, dp;
wire [ 7:0] alu_op, postbyte;
wire [ 7:0] psh_bit, psh_sel, psh_mux;
wire [ 3:0] intvec;
wire [ 2:0] idx_sel;
wire        alu_busy, mem_busy, idx_busy;
wire        idx_en,psh_en, hi_lon;
wire        c_out, n_out, z_out, v_out, h_out;
wire        up_a, up_b, up_cc, up_dp, up_x, up_y, up_u, up_s, up_pc; 
wire        indirect, branch; 
wire        pul_en, pshdec, us_sel;
wire        wrq, addr_x, addr_y, uplines;

jtkcpu_ctrl u_ctrl(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),

    // System status
    .alu_busy   ( alu_busy   ),
    .mem_busy   ( mem_busy   ),
    .idx_busy   ( idx_busy   ),

    .op         ( alu_op     ), 
    .postbyte   ( postbyte   ),
    .psh_bit    ( psh_bit    ),
    .cc         ( cc         ),
    .halt       ( halt       ),
    .irq        ( irq        ),
    .firq       ( firq       ),
    .nmi        ( nmi        ),
    .pul_en     ( pul_en     ),
    .pshdec     ( pshdec     ),
    .psh_sel    ( psh_sel    ),
    .us_sel     ( us_sel     ),
    .mem16      ( mem16      ),
    .addr_x     ( addr_x     ),
    .addr_y     ( addr_y     ),
    .wrq        ( wrq        )

    // to do: fill in the rest
);

jtkcpu_memctrl u_memctrl(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),
    .cen        ( cen2       ),

    .pc         ( pc         ),
    .dp         ( dp         ),
    .idx_addr   ( idx_addr   ),
    .psh_addr   ( psh_addr   ),
    .regs_x     ( regs_x     ),
    .regs_y     ( regs_y     ),
    .din        ( din        ),
    .dout       ( dout       ),
    // Effective address
    .addr       ( addr[15:0] ),
    .lines      ( addr[23:16]),
    .uplines    ( uplines    ),

    .we         ( we         ),
    .op         ( alu_op     ),
    .data       ( data       ),
    .busy       ( mem_busy   ),
    .up_pc      ( up_pc      ),
    .is_op      ( is_op      ),
    .mem16      ( mem16      ),
    .halt       ( halt       ),
    .idx_en     ( idx_en     ),
    .psh_en     ( psh_en     ),
    .addrx      ( addrx      ),
    .addry      ( addry      ),
    .opd        ( opd        ),
    .intvec     ( intvec     ),
    .alu_dout   ( alu_dout   ),
    .wrq        ( wrq        )
);

jtkcpu_alu u_alu(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),

    .op         ( alu_op     ), 
    .opnd0      ( opnd0      ), 
    .opnd1      ( data       ),
    .cc_in      ( cc         ),
    .busy       ( alu_busy   ),
    .c_out      ( c_out      ),
    .v_out      ( v_out      ),
    .z_out      ( z_out      ),
    .n_out      ( n_out      ),
    .h_out      ( h_out      ),
    .rslt       ( rslt[15:0] ),
    .rslt_hi    ( rslt[31:16])
);

jtkcpu_regs u_regs(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),

    .pc         ( pc         ),
    .cc         ( cc         ),
    .op         ( alu_op     ), 
    .op_sel     ( postbyte   ), 
    .psh_sel    ( psh_sel    ),
    .psh_hilon  ( hi_lon     ),
    .psh_ussel  ( us_sel     ),
    .pul_en     ( pul_en     ),
    .alu        ( rslt       ),
    .up_a       ( up_a       ),
    .up_b       ( up_b       ),
    .up_dp      ( up_dp      ),
    .up_x       ( up_x       ),
    .up_y       ( up_y       ),
    .up_u       ( up_u       ),
    .up_s       ( up_s       ),
    .pshdec     ( pshdec     ),
    .mux        ( mux        ),
    .d_mux      ( d_mux      ),
    .mux_reg0   ( opnd0      ),
    .mux_reg1   ( opnd1      ),
    .nx_u       ( nx_u       ),
    .nx_s       ( nx_s       ),
    .idx_reg    ( idx_reg    ),
    .psh_addr   ( psh_addr   ), 
    .acc        ( acc        ),
    .psh_mux    ( psh_mux    ),
    .psh_bit    ( psh_bit    ),
    .up_pul_cc  ( up_cc      ),
    .up_pul_pc  ( up_pc      )
);

jtkcpu_idx u_idx(
    .rst        ( rst        ), 
    .clk        ( clk        ), 
    .cen        ( cen        ),

    .idx_reg    ( idx_reg    ), 
    .data       ( data       ), 
    .postbyte   ( postbyte   ), 
    .a          ( a          ), 
    .b          ( b          ), 
    .addr       ( idx_addr   ),
    .idx_sel    ( idx_sel    ), 
    .indirect   ( indirect   ),
    .busy       ( idx_busy   )
);

endmodule