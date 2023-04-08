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

// Memory controller

module jtkcpu_memctrl(
    input             rst,
    input             clk,
    input             cen2,      // This should 2x faster than the rest of the CPU
    input             cen,  // cen2 of the control unit

    // inputs to address mux
    input      [15:0] pc,
    input             up_move,
    input      [15:0] idx_addr,
    input             idx_adv,
    input      [15:0] regs_x,
    input      [15:0] regs_y,

    // Stack
    input      [15:0] psh_addr,
    input             psh_dec,
    input             stack_busy,
    input      [ 7:0] psh_mux,
    // memory interface
    input      [ 7:0] din,
    output reg [ 7:0] dout,
    output reg [15:0] addr,
    output reg [ 7:0] lines,
    output reg        we,

    // Data fetched can be 8 or 16 bits
    output reg [ 7:0] op,
    output reg [15:0] data,
    output reg        busy,  // data not ready
    output reg        up_pc, // PC updated after processing an interrupt
    output reg        is_op, // the data[7:0] output is an OP code

    // select addressing mode
    input             memhi,
    input             halt,   // hold the current address
    input             up_lines,
    input             idx_en,
    input             addrx,
    input             addry,
    input             fetch,
    input             opd,    // the next byte (word) is an operand
    input      [ 3:0] intvec, // interrupt number. Set after the register pushing step

    // Write requests
    input      [15:0] alu_dout,
    input             wrq
);

// To do: fill in the vectors for each interrupt type
localparam FIRQ = 16'hFFF6,
           IRQ  = 16'hFFF8,
           NMI  = 16'hFFFC,
           RST  = 16'hFFFE;

reg  is_int, hold;
wire mem_en;

assign mem_en = fetch | opd | stack_busy | addrx | addry | idx_en;

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        addr   <= 0;
        data   <= 0;
        busy   <= 0;
        up_pc  <= 0;
        is_op  <= 0;
        is_int <= 0;
        lines  <= 0;
    end else if( cen2 && !halt ) begin
        // signals active for a single clock cycle:
        up_pc  <= 0;
        we     <= 0;
        dout   <= psh_dec ? psh_mux :
                    memhi ? alu_dout[15:8] :
                  up_move ? data[7:0] : alu_dout[7:0];
        hold   <= psh_dec;
        if( up_lines ) lines <= data[7:0];
        if( busy ) begin
            data[15:8] <= din; // get the MSB half and
            addr <= addr + 1'd1;  // pick up the next byte
            busy <= 0;
            // Data writes
            dout <= alu_dout[7:0];
            if( we ) we <= 1; // keep it high for one more cycle
        end else if( !up_pc ) begin
            is_int <= 0;
            // Select the active address
            if( is_int ) begin // Keep the address constant while waiting
                // is_op <= 1;    // for the PC to get the interrupt intvec
                up_pc <= 1;
            end else if( mem_en ) begin
                addr <= pc;
                is_op <= 1;
                if( opd        ) begin is_op <= 0; end
                if( psh_dec    ) begin
                    is_op <= 0;
                    addr <= psh_addr - 16'd1;
                end else if( stack_busy ) begin
                    is_op <= 0;
                    addr <= psh_addr;
                end
                if( addrx      ) begin is_op <= 0; addr <= regs_x;   end
                if( addry      ) begin is_op <= 0; addr <= regs_y;   end
                if( idx_en     ) begin
                    is_op <= 0;
                    addr  <= idx_addr + { 15'd0, idx_adv };
                end
                if( (wrq || psh_dec) && cen ) we <= 1;
            end
            // interrupt vectors
            if( intvec!=0 && !is_int) begin
                busy   <= 1;
                is_op  <= 0;
                is_int <= 1;
                case( intvec )
                    4'b0001: addr <= IRQ;
                    4'b0010: addr <= FIRQ;
                    4'b0100: addr <= NMI;
                    4'b1000: addr <= RST;
                    default:; // Leave code 0 free
                endcase
            end
            // Capture data
            if( is_op ) begin
                op <= din;
                // $display("OP=%02X",op);
            end
            if( !hold && !wrq ) begin
                if(memhi) begin
                    data[15:8] <= din;
                end else begin
                    data[ 7:0] <= din; // get the lower half/regular 1-byte access
                end
            end
        end
    end
end

endmodule