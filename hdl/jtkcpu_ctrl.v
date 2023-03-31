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
    input      [15:0] mdata,
    input      [ 7:0] psh_bit,
    input      [ 7:0] cc,

    input             halt,

    input             up_pc,
    input             up_pul_pc,

    // indexed addressing
    output     [2:0] idx_rsel,
    output     [1:0] idx_asel,
    output           idx_post,
    output           idx_pre,
    output           idxw,
    output           idx_ld,
    output           idx_8,
    output           idx_16,
    output           idx_acc,
    output           idx_dp,
    output           idx_en,
    output           data2addr,

    // System status
    input             irq_n,
    input             nmi_n,
    input             firq_n,
    input             alu_busy,
    input             mem_busy,

    // Direct microcode outputs
    output            addr_x,
    output            addr_y,
    output            pshdec,
    output            hi_lon,
    output            memhi,
    output            opd,
    output     [ 7:0] psh_sel,
    output            pul_en,
    output            up_lea,
    output            up_lines,
    output            up_lmul,
    output            us_sel,
    output            wrq,
    output            decb,
    output            decu,
    output            decx,
    output            incx,
    output            incy,
    output            ni,
    output            set_i,
    output            set_e,
    output            set_f,
    output            clr_e,
    output            up_cc,

    output     [ 3:0] intvec,

    // Derived logic
    output            up_a,
    output            up_b,
    output            up_d,
    output            up_x,
    output            up_y,
    output            up_u,
    output            up_s,

    output reg [15:0] pc


    // to do: add status signals from other modules as inputs

    // to do: add control signals to other modules as outputs

);

`include "jtkcpu.inc"

// to do: signals that are resolved within the
// module should be here as wires. Watchout for buses
wire branch;
wire pul_go, psh_go, psh_all, psh_cc, psh_pc,
     int_en, psh_busy,
     up_ld16, up_ld8, up_lda, up_ldb, up_ab,
     rti_cc, rti_other,
     set_pc_jmp, set_pc_branch16, set_pc_branch8, pc_inc1,
     buserror,

     addr_data,
     addr_idx,
     back1_unz,
     back2_unz,
     idx_step,
     pul_pc,
     set_opn0_a,
     set_opn0_b,
     set_opn0_mem,
     set_opn0_regs,
     set_pc_bnz_branch,
     set_pc_xnz_branch,
     skip_noind,
     up_data;

// assign up_a = ( up_ld8 & ~(op[0]^is_inh) ) ;
// assign up_b = ( up_ld8 &  (op[0]^is_inh) ) ;

assign up_a = ( up_ld8 && ~op[0] ) || up_lda;
assign up_b = ( up_ld8 &&  op[0] ) || up_ldb;

assign up_d = (up_ld16 && op[3:1]==0) || up_ab;
assign up_x = (up_ld16 && op[3:1]==1) || (up_lea && op[1:0]==LEAX[1:0]) || up_lmul;
assign up_y = (up_ld16 && op[3:1]==2) || (up_lea && op[1:0]==LEAY[1:0]) || up_lmul;
assign up_u = (up_ld16 && op[3:1]==3) || (up_lea && op[1:0]==LEAU[1:0]);
assign up_s = (up_ld16 && op[3:1]==4) || (up_lea && op[1:0]==LEAS[1:0]);
assign pc_inc1 = idx_post && idx_rsel==7;

wire short_branch = set_pc_branch8  & branch;
wire long_branch  = set_pc_branch16 & branch | set_pc_jmp;

always @(posedge clk) begin
    if( rst ) begin
        pc <= 0;
    end else if(cen) begin
        pc <= ( ni | opd | pc_inc1 ) ? pc+16'd1 :
              short_branch ? { {8{mdata[7]}}, mdata[7:0]}+pc :
              long_branch  ? mdata+pc :
              up_pc        ? mdata    : pc;
        // if( up_pul_pc &&  hi_lon ) pc[15:8] <= alu[15:8];
        // if( up_pul_pc && !hi_lon ) pc[ 7:0] <= alu[7:0];

    end
end

jtkcpu_ucode u_ucode(
    .rst               ( rst               ),
    .clk               ( clk               ),
    .cen               ( cen               ),

    .op                ( op                ),
    .mdata             ( mdata             ),

    .branch            ( branch            ),
    .alu_busy          ( alu_busy          ),
    .mem_busy          ( mem_busy          ),
    .irq_n             ( irq_n             ),
    .nmi_n             ( nmi_n             ),
    .firq_n            ( firq_n            ),
    .intvec            ( intvec            ),

    .adr_data          ( addr_data         ),
    .adr_idx           ( addr_idx          ),
    .adrx              ( addr_x            ),
    .adry              ( addr_y            ),
    .back1_unz         ( back1_unz         ),
    .back2_unz         ( back2_unz         ),
    .buserror          ( buserror          ),
    .clr_e             ( clr_e             ),
    .decb              ( decb              ),
    .decu              ( decu              ),
    .decx              ( decx              ),

    // Indexed addressing
    .idx_rsel          ( idx_rsel          ),
    .idx_asel          ( idx_asel          ),
    .idx_post          ( idx_post          ),
    .idx_pre           ( idx_pre           ),
    .idxw              ( idxw              ),
    .idx_ld            ( idx_ld            ),
    .idx_8             ( idx_8             ),
    .idx_16            ( idx_16            ),
    .idx_acc           ( idx_acc           ),
    .idx_dp            ( idx_dp            ),
    .idx_en            ( idx_en            ),
    .data2addr         ( data2addr         ),

    .incx              ( incx              ),
    .incy              ( incy              ),
    .int_en            ( int_en            ),
    .memhi             ( memhi             ),
    .ni                ( ni                ),
    .opd               ( opd               ),
    .psh_all           ( psh_all           ),
    .psh_cc            ( psh_cc            ),
    .psh_go            ( psh_go            ),
    .psh_pc            ( psh_pc            ),
    .pul_go            ( pul_go            ),
    .pul_pc            ( pul_pc            ),
    .rti_cc            ( rti_cc            ),
    .rti_other         ( rti_other         ),
    .set_e             ( set_e             ),
    .set_f             ( set_f             ),
    .set_i             ( set_i             ),
    .set_opn0_a        ( set_opn0_a        ),
    .set_opn0_b        ( set_opn0_b        ),
    .set_opn0_mem      ( set_opn0_mem      ),
    .set_opn0_regs     ( set_opn0_regs     ),
    .set_pc_bnz_branch ( set_pc_bnz_branch ),
    .set_pc_branch16   ( set_pc_branch16   ),
    .set_pc_branch8    ( set_pc_branch8    ),
    .set_pc_jmp        ( set_pc_jmp        ),
    .set_pc_xnz_branch ( set_pc_xnz_branch ),
    .up_cc             ( up_cc             ),
    .skip_noind        ( skip_noind        ),
    .up_data           ( up_data           ),
    .up_ld16           ( up_ld16           ),
    .up_ld8            ( up_ld8            ),
    .up_lda            ( up_lda            ),
    .up_ldb            ( up_ldb            ),
    .up_ab             ( up_ab             ),
    .up_lea            ( up_lea            ),
    .up_lines          ( up_lines          ),
    .up_lmul           ( up_lmul           ),
    .we                ( wrq               )

);

jtkcpu_branch u_branch(
    .op         ( op         ),
    .cc         ( cc         ),
    .branch     ( branch     )
);

jtkcpu_pshpul u_pshpul(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .cen        ( cen        ),

    .op         ( op         ),
    .postdata   ( mdata      ),
    .cc         ( cc         ),
    .psh_all    ( psh_all    ),
    .rti_cc     ( rti_cc     ),
    .rti_other  ( rti_other  ),
    .pul_go     ( pul_go     ),
    .psh_go     ( psh_go     ),
    .psh_pc     ( psh_pc     ),
    .psh_bit    ( psh_bit    ),
    .hi_lon     ( hi_lon     ),
    .pul_en     ( pul_en     ),
    .pshdec     ( pshdec     ),
    .psh_sel    ( psh_sel    ),
    .busy       ( psh_busy   ),
    .us_sel     ( us_sel     )
);

endmodule