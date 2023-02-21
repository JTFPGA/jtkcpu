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

module jtkcpu_regs(
    input               rst,
    input               clk,
    input        [ 7:0] op_sel,     // op code used to select specific registers
    input        [ 7:0] cc,
    input        [15:0] pc,

    // Register update
    input        [ 7:0] alu8,
    input        [15:0] alu16,
    input               up_a,
    input               up_b,
    input               up_dp,
    input               up_x,
    input               up_y,
    input               up_u,
    input               up_s,

    output   reg [15:0] mux,
    output   reg [15:0] idx_reg,
    output       [15:0] acc
);

reg  [ 7:0] a, b, dp;
reg  [15:0] x, y, u, s, 

assign acc = { b, a };

// exg/tfr mux
always @* begin
    case( op_sel[7:4] )
        4'b0000: mux = {a, b};
        4'b0001: mux = x;
        4'b0010: mux = y;
        4'b0011: mux = u;
        4'b0100: mux = s;
        4'b0101: mux = pc;
        4'b1000: mux = {8'hFF,  a};
        4'b1001: mux = {8'hFF,  b};
        4'b1010: mux = {8'hFF, cc};
        4'b1011: mux = {8'hFF, dp};
        default: mux = 0
    endcase 

end

// indexed idx_reg
always @* begin
    case ( op_sel[6:5] ) 
        1'b00  : idx_reg = x;
        1'b01  : idx_reg = y; 
        1'b10  : idx_reg = u;
        1'b11  : idx_reg = s;
        default: idx_reg = pc; 
    endcase  
end

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        a  <= 0;
        b  <= 0;
        dp <= 0;
        x  <= 0;
        y  <= 0;
        u  <= 0;
        s  <= 0;
    end else begin
        if( up_a  ) a  <= sel16 ? alu16[7:0] : alu8;
        if( up_b  ) b  <= alu8;
        if( up_dp ) dp <= alu8;
        if( up_x  ) x  <= alu16;
        if( up_y  ) y  <= alu16;
        if( up_u  ) u  <= alu16;
        if( up_s  ) s  <= alu16;
    end
end

endmodule
