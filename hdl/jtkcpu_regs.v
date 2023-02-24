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
    input        [ 7:0] psh_sel,
    input               psh_hilon,
    input               psh_ussel,
    input               pul_en,
    input        [ 7:0] pul_sel,
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

    input               dec_u,

    output   reg [15:0] mux,
    output   reg [ 7:0] psh_mux,
    output   reg [ 7:0] psh_bit,
    output   reg [15:0] idx_reg,
    output       [15:0] psh_addr,
    output       [15:0] acc
);

reg  [ 7:0] a, b, dp;
reg  [15:0] x, y, u, s; 
wire [15:0] psh_other;

assign acc = { b, a };
assign psh_addr  = psh_ussel ? u : s;
assign psh_other = psh_ussel ? s : u;


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

// PUSH
always @* begin
    casez( psh_sel )
        8'b????_???1: begin psh_mux = cc; psh_bit = 8'h1; end
        8'b????_??10: begin psh_mux =  a; psh_bit = 8'h2; end
        8'b????_?100: begin psh_mux =  b; psh_bit = 8'h4; end
        8'b????_1000: begin psh_mux = dp; psh_bit = 8'h8; end
        8'b???1_0000: begin psh_mux =  psh_hilon ? x[15:8] : x[7:0]; psh_bit = 8'h10; end
        8'b??10_0000: begin psh_mux =  psh_hilon ? y[15:8] : y[7:0]; psh_bit = 8'h20; end
        8'b?100_0000: begin psh_mux =  psh_hilon ? psh_other[15:8] : psh_other[7:0]; psh_bit = 8'h40; end
        default:      begin psh_mux =  psh_hilon ? pc[15:8] : pc[7:0]; psh_bit = 8'h80; end
    endcase    
end

// PULL
always @* begin
    up_pull_cc = 0; // output
    up_pull_a  = 0; // define all as regs
    up_pull_b  = 0; 
    up_pull_dp = 0; 
    up_pull_x  = 0; 
    up_pull_y  = 0; 
    up_pull_other = 0;
    up_pull_pc = 0; // output    
    casez( pul_sel )
        8'b????_???1: up_pull_cc = pul_en; 
        8'b????_??10: up_pull_a  = pul_en; 
        8'b????_?100: up_pull_b  = pul_en; 
        8'b????_1000: up_pull_dp = pul_en; 
        8'b???1_0000: up_pull_x  = pul_en; 
        8'b??10_0000: up_pull_y  = pul_en; 
        8'b?100_0000: up_pull_other = pul_en; 
        default:      up_pull_pc = pul_en; 
    endcase    
    inc_pul = |{ up_pull_cc, up_pull_a, up_pull_b, up_pull_dp, up_pull_x, 
        up_pull_y, up_pull_other, up_pull_pc };
end


// indexed idx_reg
always @* begin
    case ( op_sel[6:5] ) 
        2'b00  : idx_reg = x;
        2'b01  : idx_reg = y; 
        2'b10  : idx_reg = u;
        2'b11  : idx_reg = s;
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
        if( up_a  || up_pull_a  ) a  <= : alu[7:0]; // pull must let fetched data through ALU
        if( up_b  || up_pull_b  ) b  <= : alu[7:0];
        if( up_dp || up_pull_dp ) dp <= : alu[7:0];
        if( up_x  ) x  <= : alu;
        if( up_y  ) y  <= : alu;
        if( up_u  ) u  <= : alu;
        if( up_s  ) s  <= : alu;
        // 16-bit registers from memory (PULL)
        if( up_pull_x &&  psh_hilon ) x[15:8] <= alu[7:0];
        if( up_pull_x && !psh_hilon ) x[ 7:0] <= alu[7:0];
        // y, u, s
        // Special operations
        // To do: manage dec_u/s for push operations
        if( dec_u ) u  <= u - 16'd1; // add +1 and inc_u/s...
        if( dec_s ) u  <= s - 16'd1;
        // use inc_pul and psh_ussel to increment u/s...
    end
end

endmodule
