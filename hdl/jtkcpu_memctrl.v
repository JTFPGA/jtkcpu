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
    input             cen,      // This should 2x faster than the rest of the CPU
    input             ctl_cen,  // cen of the control unit

    // inputs to address mux
    input      [15:0] pc,
    input      [ 7:0] dp,
    input      [15:0] idx_addr,
    input      [15:0] psh_addr,

    // memory interface
    input      [ 7:0] din,
    output reg [ 7:0] dout,
    output reg [15:0] addr,
    output reg        we,
    
    // Data fetched can be 8 or 16 bits
    output reg [15:0] data,
    output reg        busy,  // data not ready
    output reg        up_pc, // PC updated after processing an interrupt
    output reg        is_op, // the data[7:0] output is an OP code

    // select addressing mode
    input             mem16,
    input             halt,   // hold the current address
    input             idx_en,
    input             psh_en,
    input      [ 2:0] intvec, // interrupt number. Set after the register pushing step

    // Write requests
    input      [15:0] alu_dout,
    input             wrq
);

// To do: fill in the vectors for each interrupt type
localparam FIRQ = 16'hFFF6,
           IRQ  = 16'hFFF8,
           // SWI  = 16'hFFFA, // was this in a table too? The M6809 has, but Konami don't have this instructions
           NMI  = 16'hFFFC,
           RST  = 16'hFFFE;

reg is_int;

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        addr  <= 0;
        data  <= 0;
        busy  <= 0;
        up_pc <= 0;
        is_op <= 0;
        we    <= 0;
    end else if( cen && !halt ) begin
        // signals active for a single clock cycle:
        up_pc <= 0;
        we    <= 0;
        if( busy ) begin
            data[15:8] <= din; // get the MSB half and
            addr <= addr + 1;  // pick up the next byte
            busy <= 0;
            // Data writes
            dout <= alu_dout[7:0];
            if( we ) we <= 1; // keep it high for one more cycle
        end else if( !up_pc ) begin
            // Select the active address
            if( is_int ) begin // Keep the address constant while waiting
                is_op <= 1;    // for the PC to get the interrupt intvec
                up_pc <= 1;
            end else begin
                addr <= pc;
                is_op <= 1;
                if( idx_en ) begin is_op <= 0; addr <= idx_addr; end
                if( psh_en ) begin is_op <= 0; addr <= psh_addr; end
                if( mem16 && !busy ) begin
                    busy <= 1;
                    dout <= alu_dout[15:8];
                end
                if( wrq && ctl_cen ) we <= 1;
            end
            // interrupt vectors
            if( intvec!=0 && !busy ) begin
                busy   <= 1;
                is_op  <= 0;
                is_int <= 1;
                case( intvec )
                    1: addr <= IRQ;
                    2: addr <= FIRQ;
                    3: addr <= NMI;
                    4: addr <= RST;
                    // to do: fill in the rest
                    default:; // Leave code 0 free
                endcase
            end
            // Capture data
            data[ 7:0] <= din; // get the lower half/regular 1-byte access
        end
    end
end

endmodule