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
    input               cen,

    // input        [ 7:0] op,
    input        [ 7:0] op_sel,     // op code used to select specific registers
    input        [ 7:0] psh_sel,
    input               psh_hilon,
    input               psh_ussel,
    input               pul_en,
    input        [ 7:0] cc,
    input        [15:0] pc,

    // Register update
    input        [15:0] alu,
    input               up_a,
    input               up_b,
    input               up_dp,
    input               up_x,
    input               up_y,
    input               up_u,
    input               up_s,

    input               dec_us,

    output   reg [15:0] mux,
    output   reg [ 7:0] psh_mux,
    output   reg [ 7:0] psh_bit,
    output   reg [15:0] nx_u,    
    output   reg [15:0] nx_s,    
    output   reg [15:0] idx_reg,
    output       [15:0] psh_addr,
    output       [15:0] acc,
    output   reg        up_pul_cc,
    output   reg        up_pul_pc
);

reg         dec_u, dec_s, up_pul_x, up_pul_y, up_pul_other, up_pul_a, up_pul_b, up_pul_dp, inc_pul;
reg  [ 7:0] a, b, dp;
reg  [15:0] x, y, u, s; 
wire [15:0] psh_other;

assign acc = { b, a };
assign psh_addr  = psh_ussel ? u : s;
assign psh_other = psh_ussel ? s : u;

// exg/tfr mux
always @* begin

        case(op_sel[7:4] )
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
            default: mux = 0;
        endcase 

    // if ( op == 8'h3F ) begin

    //     case( op_sel[3:0] )
    //         4'b0000: {a, b} = mux; 
    //         4'b0001: x      = mux; 
    //         4'b0010: y      = mux; 
    //         4'b0011: u      = mux;
    //         4'b0100: s      = mux;
    //         4'b0101: pc     = mux;
    //         4'b1000: a      = mux[7:0]; 
    //         4'b1001: b      = mux[7:0]; 
    //         4'b1010: cc     = mux[7:0]; 
    //         4'b1011: dp     = mux[7:0]; 
    //         default: begin end
    //     endcase 
    // end
end


// U/S next value
always @* begin
    dec_u = 0;
    dec_s = 0;
    if ( dec_us && !psh_mux) begin
        if (psh_ussel) 
            dec_u = 1;
        else 
            dec_s = 1;
    end 
    nx_u = u;
    nx_s = s;
    if( up_u  ) nx_u = alu;
    if( up_s  ) nx_s = alu;
    if( dec_u ) nx_u = u - 16'd1;    
    if( dec_s ) nx_s = s - 16'd1;    
    if( up_pul_other &&  psh_hilon ) begin
        if( psh_ussel ) 
            nx_s[15:8] = alu[7:0]; 
        else 
            nx_u[15:8] = alu[7:0]; 
    end
    if( up_pul_other && !psh_hilon ) begin
        if( psh_ussel ) 
            nx_s[ 7:0] = alu[7:0]; 
        else 
            nx_u[ 7:0] = alu[7:0]; 
    end

end

// PUSH
always @* begin
    casez( psh_sel )
        8'b????_???1: begin psh_mux = cc; psh_bit = 8'h1; end
        8'b????_??10: begin psh_mux =  a; psh_bit = 8'h2; end
        8'b????_?100: begin psh_mux =  b; psh_bit = 8'h4; end
        8'b????_1000: begin psh_mux = dp; psh_bit = 8'h8; end
        8'b???1_0000: begin psh_mux = psh_hilon ? x[15:8] : x[7:0]; psh_bit = 8'h10; end
        8'b??10_0000: begin psh_mux = psh_hilon ? y[15:8] : y[7:0]; psh_bit = 8'h20; end
        8'b?100_0000: begin psh_mux = psh_hilon ? psh_other[15:8] : psh_other[7:0]; psh_bit = 8'h40; end
        default:      begin psh_mux = psh_hilon ? pc[15:8] : pc[7:0]; psh_bit = 8'h80; end
    endcase
end

// PULL
always @* begin
    up_pul_cc = 0; // output
    up_pul_a  = 0; // define all as regs
    up_pul_b  = 0; 
    up_pul_dp = 0; 
    up_pul_x  = 0; 
    up_pul_y  = 0; 
    up_pul_other = 0;
    up_pul_pc = 0; // output    
    casez( psh_sel )
        8'b????_???1: up_pul_cc    = pul_en; 
        8'b????_??10: up_pul_a     = pul_en; 
        8'b????_?100: up_pul_b     = pul_en; 
        8'b????_1000: up_pul_dp    = pul_en; 
        8'b???1_0000: up_pul_x     = pul_en; 
        8'b??10_0000: up_pul_y     = pul_en; 
        8'b?100_0000: up_pul_other = pul_en; 
        default:      up_pul_pc    = pul_en; 
    endcase    
    inc_pul = |{ up_pul_cc, up_pul_a, up_pul_b, up_pul_dp, up_pul_x, 
        up_pul_y, up_pul_other, up_pul_pc };
end 

// indexed idx_reg
always @* begin
    case ( op_sel[6:5] ) 
        2'b00  : idx_reg =  x;      
        2'b01  : idx_reg =  y; 
        2'b10  : idx_reg =  u;
        2'b11  : idx_reg =  s;
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
    end else if(cen) begin
        u <= nx_u;
        s <= nx_s;

        if( up_a  || up_pul_a  ) a  <= alu[7:0]; // pul must let fetched data through ALU
        if( up_b  || up_pul_b  ) b  <= alu[7:0];
        if( up_dp || up_pul_dp ) dp <= alu[7:0];
        if( up_x  ) x  <= alu;
        if( up_y  ) y  <= alu;
        // if( up_s  ) s  <= alu;
        // 16-bit registers from memory (PULL)
        if( up_pul_x &&  psh_hilon ) x[15:8] <= alu[15:8];
        if( up_pul_x && !psh_hilon ) x[ 7:0] <= alu[7:0];
        if( up_pul_y &&  psh_hilon ) y[15:8] <= alu[15:8];
        if( up_pul_y && !psh_hilon ) y[ 7:0] <= alu[7:0];

        if( inc_pul && psh_ussel )
            u <= u + 16'd1; 
        if( inc_pul && !psh_ussel )
            s <= s + 16'd1;
    end
end

endmodule
