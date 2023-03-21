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
    output              we    // write enable
    //output              as      
);

wire [15:0] opnd0, opnd1;
wire [31:0] rslt;
wire [15:0] data, idx_reg, mux, d_mux, acc;
wire [15:0] idx_addr, psh_addr;
wire [15:0] regs_x, regs_y, u, s, pc, nx_u, nx_s; 
wire [ 7:0] a, b, cc, cc_out;
wire [ 7:0] op, postbyte;
wire [ 7:0] psh_bit, psh_sel, psh_mux;
wire [ 3:0] intvec;
wire [ 2:0] idx_sel;
wire        alu_busy, mem_busy, idx_busy;
wire        idx_en, hi_lon;
wire        is_op; 
wire        up_a, up_b, up_d, up_cc, up_x, up_y, up_u, up_s, up_pc; 
wire        indirect, branch, mem16, memhi; 
wire        pul_en, pshdec, us_sel, idx_ld, idx_ret;
wire        wrq, opd, addr_x, addr_y, up_lines, up_lea, up_lmul, 
            inc_x, inc_y, dec_b, dec_u, dec_x, 
            clr_e, set_e, set_f, set_i,
            set_regs_alu, up_alu_a, up_alu_b, up_pul_pc,
            idx_inc;

jtkcpu_ctrl u_ctrl(
    .rst          ( rst          ),
    .clk          ( clk          ),
    .cen          ( cen          ),

    .op           ( op           ), 
    .postdata     ( data     ),
    .psh_bit      ( psh_bit      ),
    .cc           ( cc           ),
    .data         ( data         ),
    .halt         ( halt         ),
    .up_pc        ( up_pc        ), 
    
    // System status
    .alu_busy     ( alu_busy     ),
    .mem_busy     ( mem_busy     ),
    .idx_busy     ( idx_busy     ),
    .irq          ( irq          ),
    .firq         ( firq         ),
    .nmi          ( nmi          ),

    .addr_x       ( addr_x       ),
    .addr_y       ( addr_y       ),
    .pshdec       ( pshdec       ),
    .hi_lon       ( hi_lon       ),
    .mem16        ( mem16        ),
    .memhi        ( memhi        ),
    .opd          ( opd          ),
    .psh_sel      ( psh_sel      ),
    .pul_en       ( pul_en       ),
    .up_lea       ( up_lea       ),
    .up_lines     ( up_lines     ),
    .up_lmul      ( up_lmul      ),
    .us_sel       ( us_sel       ),
    .wrq          ( wrq          ),
    .incx         ( inc_x        ),
    .incy         ( inc_y        ),
    .decx         ( dec_x        ),
    .decb         ( dec_b        ),
    .decu         ( dec_u        ),
    .set_e        ( set_e        ),
    .set_i        ( set_i        ),
    .set_f        ( set_f        ),
    .clr_e        ( clr_e        ),
    .idx_ld       ( idx_ld       ),
    .idx_ret      ( idx_ret      ),
    .idx_en       ( idx_en       ),
    .set_regs_alu ( set_regs_alu ),

    .up_a         ( up_a         ),
    .up_b         ( up_b         ),
    // .up_d         ( up_d         ),
    .up_x         ( up_x         ),
    .up_y         ( up_y         ),
    .pc           ( pc           ),
    .up_u         ( up_u         ),
    .up_s         ( up_s         ),
    .up_pul_pc    ( up_pul_pc    )


);

jtkcpu_memctrl u_memctrl(
    .rst          ( rst          ),
    .clk          ( clk          ),
    .cen          ( cen          ),
    .cen2         ( cen2         ),

    .pc           ( pc           ),
    // .dp           ( dp           ),
    .idx_addr     ( idx_addr     ),
    .psh_addr     ( psh_addr     ),
    .regs_x       ( regs_x       ),
    .regs_y       ( regs_y       ),
    .din          ( din          ),
    .dout         ( dout         ),
    // Effective address
    .addr         ( addr[15:0]   ),
    .lines        ( addr[23:16]  ),

    .we           ( we           ),
    .op           ( op           ),
    .data         ( data         ),
    .busy         ( mem_busy     ),
    .up_pc        ( up_pc        ),
    .is_op        ( is_op        ),
    .mem16        ( mem16        ),
    .memhi        ( memhi        ),
    .halt         ( halt         ),
    .up_lines     ( up_lines     ),
    .idx_en       ( idx_en       ),
    .psh_en       ( pshdec       ),
    .addrx        ( addr_x       ),
    .addry        ( addr_y       ),
    .opd          ( opd          ),
    .intvec       ( intvec       ),
    .alu_dout     ( rslt[15:0]   ),
    .wrq          ( wrq          )
);

jtkcpu_alu u_alu(
    .rst          ( rst          ),
    .clk          ( clk          ),
    .cen          ( cen          ),

    .op           ( op           ), 
    .opnd0        ( opnd0        ), 
    .opnd1        ( data         ),
    .cc_in        ( cc           ),
    .cc_out       ( cc_out       ),
    .busy         ( alu_busy     ),

    .rslt         ( rslt[15:0]   ),
    .rslt_hi      ( rslt[31:16]  )
);

jtkcpu_regs u_regs(
    .rst          ( rst          ),
    .clk          ( clk          ),
    .cen          ( cen          ),

    .pc           ( pc           ),
    .x            ( regs_x       ), 
    .y            ( regs_y       ),
    .cc           ( cc           ),
    .a            ( a            ), 
    .b            ( b            ),
    .mdata        ( data         ), 
    .op           ( op           ), 
    .psh_sel      ( psh_sel      ),
    .psh_hilon    ( hi_lon       ),
    .psh_ussel    ( us_sel       ),
    .pul_en       ( pul_en       ),
    .alu          ( rslt         ),
    .idx_addr     ( idx_addr     ),
    .idx_inc      ( idx_inc      ),
    .up_a         ( up_a         ),
    .up_b         ( up_b         ),
    // .up_d         ( up_d         ),
    .up_x         ( up_x         ),
    .up_y         ( up_y         ),
    .up_u         ( up_u         ),
    .up_s         ( up_s         ),
    .up_lmul      ( up_lmul      ),
    .up_lea       ( up_lea       ),
    .up_alu_a     ( up_alu_a     ),
    .up_alu_b     ( up_alu_b     ),
    .set_regs_alu ( set_regs_alu ),
    .alu_cc       ( cc_out       ),
    .set_e        ( set_e        ),
    .set_i        ( set_i        ),
    .set_f        ( set_f        ),
    .clr_e        ( clr_e        ),
    // .clr_i        ( clr_i        ),
    // .clr_f        ( clr_f        ),
    .inc_x        ( inc_x        ),
    .inc_y        ( inc_y        ),
    .dec_x        ( dec_x        ),
    .dec_b        ( dec_b        ),
    .dec_u        ( dec_u        ),
    .pshdec       ( pshdec       ),
    
    .mux          ( mux          ),
    .d_mux        ( d_mux        ),
    .mux_reg0     ( opnd0        ),
    .mux_reg1     ( opnd1        ),
    .nx_u         ( nx_u         ),
    .nx_s         ( nx_s         ),
    .idx_reg      ( idx_reg      ),
    .psh_addr     ( psh_addr     ), 
    .acc          ( acc          ),
    .psh_mux      ( psh_mux      ),
    .psh_bit      ( psh_bit      ),
    .up_pul_cc    ( up_cc        ),
    .up_pul_pc    ( up_pul_pc    )
);

jtkcpu_idx u_idx(
    .rst          ( rst          ), 
    .clk          ( clk          ), 
    .cen          ( cen          ),

    .idx_reg      ( idx_reg      ), 
    .mdata        ( data         ), 
    .a            ( a            ), 
    .b            ( b            ),
    .idx_ret      ( idx_ret      ), 
    .idx_ld       ( idx_ld       ), 
    .addr         ( idx_addr     ),
    .busy         ( idx_busy     ),
    .indirect     ( indirect     )
);

endmodule