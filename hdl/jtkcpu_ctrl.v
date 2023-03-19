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
    input      [ 7:0] cc,

    input             halt,

    // System status
    output            alu_busy,
    output            mem_busy,
    output            psh_busy,
    output            irq,
    output            nmi,
    output            firq,

    // Direct microcode outputs
    output            addr_x,
    output            addr_y,
    output            dec_us,
    output            hi_lon,
    output            intvec,
    output            mem16,
    output            psh_sel,
    output            pul_en,
    output            uplea,
    output            up_lmul,
    output            us_sel,
    output            wrq,

    // Derived logic
    output            up_x,
    output            up_y,

    output reg [15:0] pc

    // to do: add status signals from other modules as inputs

    // to do: add control signals to other modules as outputs

);

`include "jtkcpu.inc"

// to do: signals that are resolved within the
// module should be here as wires. Watchout for buses
wire branch;
wire pul_go, psh_go, int_en, ni,
     upld16;
reg  mem16l;

assign up_a = upld8 && ~op[0];
assign up_b = upld8 &&  op[0];

assign up_d = (upld16 && op[3:1]==0);
assign up_x = (upld16 && op[3:1]==1) || (uplea && op[1:0]==LEAX[1:0]) || up_lmul;
assign up_y = (upld16 && op[3:1]==2) || (uplea && op[1:0]==LEAY[1:0]) || up_lmul;
assign up_u = (upld16 && op[3:1]==3) || (uplea && op[1:0]==LEAU[1:0]);
assign up_s = (upld16 && op[3:1]==4) || (uplea && op[1:0]==LEAS[1:0]);

jtkcpu_ucode u_ucode(
    .rst            ( rst           ),
    .clk            ( clk           ),
    .cen            ( cen           ),

    .op             ( op            ), 
    .branch         ( branch        ),
    .alu_busy       ( alu_busy      ),
    .mem_busy       ( mem_busy      ),
    .irq            ( irq           ),
    .nmi            ( nmi           ),
    .firq           ( firq          ),
    .int_en         ( int_en        ),
    .pul_go         ( pul_go        ),
    .psh_go         ( psh_go        ),
    .mem16          ( mem16         ),
    .ni             ( ni            ),
    .we             ( wrq           ),
    .rti_cc         ( rti_cc        ),
    .rti_other      ( rti_other     ),
    .adrx           ( addr_x        ),
    .adry           ( addr_y        ),
    .set_pc_branch  ( pc_branch     )


    // To do: finish connections
);

wire short_branch = set_pc_branch8  & pc_branch;
wire long_branch  = set_pc_branch16 & pc_branch | set_pc_jmp;

always @(posedge clk) begin
    if( rst ) begin
        pc <= 0;
    end else if(cen) begin
        mem16l <= mem16;
        pc <= ( ni | opd ) ? pc+16'd1 :
              short_branch ? { {8{data[7]}}, data[7:0]}+pc :
              long_branch  ? data+pc :
              set_pc_int   ? up_pc : pc;
    end
end

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
    .postdata   ( postbyte   ),
    .cc         ( cc         ),
    .int_en     ( int_en     ),
    .rti_cc     ( rti_cc     ),
    .rti_other  ( rti_other  ),
    .pul_go     ( pul_go     ),
    .psh_go     ( psh_go     ),
    .psh_bit    ( psh_bit    ),
    .hi_lon     ( hi_lon     ),
    .pul_en     ( pul_en     ),
    .dec_us     ( dec_us     ),
    .psh_sel    ( psh_sel    ),
    .busy       ( psh_busy   ),
    .us_sel     ( us_sel     )
);

endmodule