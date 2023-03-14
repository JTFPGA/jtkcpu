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
    input             cen,

    // inputs to address mux
    input      [15:0] pc,
    input      [ 7:0] dp,
    input      [15:0] idx_addr,
    input      [15:0] psh_addr,

    // memory interface
    input      [ 7:0] din,
    output reg [15:0] addr
    
    // Data fetched can be 8 or 16 bits
    output reg [15:0] data,
    output reg        busy, // data not ready

    // select addressing mode
    input             halt,   // hold the current address
    input             idx_en,
    input             psh_en,
    input      [ 2:0] vector, // interrupt vectors

);

// To do: fill in the vectors for each interrupt type
localparam IRQ  = 16'hFFF8,
           FIRQ = 16'hFFF6,
           // SWI  = 16'hFFFA, // was this in a table too? The M6809 has, but Konami don't have this instructions
           NMI  = 16'hFFFC,
           RST  = 16'hFFFE;

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        addr <= 0;
    end else if( cen && !halt ) begin
        if( busy ) begin
            data[15:8] <= din; // get the MSB half and
            addr <= addr + 1;  // pick up the next byte
            busy <= 0;
        end else begin
            data[ 7:0] <= din; // get the lower half/regular 1-byte access
            addr <= pc;
            if( idx_en ) addr <= idx_addr;
            if( psh_en ) addr <= psh_addr;
            // interrupt vectors
            if( vector!=0 && !busy ) begin
                busy <= 1;
                case( vector )
                    1: addr <= IRQ;
                    2: addr <= FIRQ;
                    3: addr <= NMI;
                    4: addr <= RST;
                    // to do: fill in the rest
                    default:; // Leave code 0 free
                endcase
            end
        end

    end
end

endmodule