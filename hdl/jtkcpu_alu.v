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

module jtkcpu_alu(
    input      [ 7:0] op, 
    input      [15:0] opnd0, 
    input      [15:0] opnd1, 
    input      [ 7:0] cc_in,
    output reg [ 7:0] cc_out,
    output reg [15:0] rslt
);

localparam CC_C = 8'h01;
localparam CC_V = 8'h02;
localparam CC_Z = 8'h04;
localparam CC_N = 8'h08;
localparam CC_H = 8'h20;

always @* begin
    cc_out = cc_in;
    case (op)
        8'h86,8'h87,8'h88: begin  // NEG
            rslt[7:0]        = ~opnd0[7,0] + 1'b1;
            cc_out[CC_C] = (rslt[7:0] != 0);
            cc_out[CC_V] = (opnd0 == 8'h80);  // 127 ~ -128
        end
        8'hC4,8'hC5: begin // NEGD , NEGW
            rslt         = ~opnd0 + 1'b1;
            cc_out[CC_C] = (rslt  != 0);
            cc_out[CC_V] = (opnd0 == 16'h8000);
        end

        8'h89,8'h8A,8'h8B,8'hC6,8'hC7: begin  // INC, INCD, INCW
            if ( (8'h89) || (8'h8A)|| (8'h8B)) begin
                rslt[7:0]    =  opnd0[7,0] + 1'b1;
                cc_out[CC_V] =  (~opnd0[7] & rslt[7]);
            end else begin
                rslt         = opnd0 + 1'b1;
                cc_out[CC_V] = (~opnd0[15] & rslt[15]);
            end            
        end
        8'h8C,8'h8D,8'h8E,8'hC8,8'hC9: begin  // DEC, DECD, DECW
            if ( (8'h8C) || (8'h8D) || (8'h8E) ) begin
                rslt[7,0]    = opnd0[7,0] - 1'b1;
                cc_out[CC_V] = (opnd0[7] & ~rslt[7]);
            end else begin
                rslt         = opnd0 - 1'b1;
                cc_out[CC_V] = (opnd0[15] & ~rslt[15]);
            end
        end
    endcase
    
end

endmodule