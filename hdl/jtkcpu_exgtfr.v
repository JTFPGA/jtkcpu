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

module jtkcpu_exgtfr(
	input      [ 7:0] op, 
    input      [ 7:0] opnd0,
    output reg [15:0] rslt
);

function [15:0] reg_sel(input [3:0] regid);
    begin
        case( regid )
            4'b0000: reg_sel = {a, b};
            4'b0001: reg_sel = x;
            4'b0010: reg_sel = y;
            4'b0011: reg_sel = u;
            4'b0100: reg_sel = s;
            4'b0101: reg_sel = pc;
            4'b1000: reg_sel = {8'hFF,  a};
            4'b1001: reg_sel = {8'hFF,  b};
            4'b1010: reg_sel = {8'hFF, cc};
            4'b1011: reg_sel = {8'hFF, dp};
            default: reg_sel = 0
        endcase
    end
endfunction

reg [15:0] reg_sel_A = reg_sel(opnd0[7:4]);
reg [15:0] reg_sel_B = reg_sel(opnd0[3:0]);

always @* begin

    if ( op == 8'h3E ) begin
        case ( opnd0[7:4] )
            4'b0000: rslt = reg_sel_B;
            4'b0001: rslt = reg_sel_B;
            4'b0010: rslt = reg_sel_B;
            4'b0011: rslt = reg_sel_B;
            4'b0100: rslt = reg_sel_B;
            4'b0101: rslt = reg_sel_B;
            4'b1000: rslt = reg_sel_B[7:0];
            4'b1001: rslt = reg_sel_B[7:0];
            4'b1010: rslt = reg_sel_B[7:0];
            4'b1011: rslt = reg_sel_B[7:0];
            default: rslt = 0
        endcase
        case ( opnd0[3:0] )
            4'b0000: rslt = reg_sel_A;
            4'b0001: rslt = reg_sel_A;
            4'b0010: rslt = reg_sel_A;
            4'b0011: rslt = reg_sel_A;
            4'b0100: rslt = reg_sel_A;
            4'b0101: rslt = reg_sel_A;
            4'b1000: rslt = reg_sel_A[7:0];
            4'b1001: rslt = reg_sel_A[7:0];
            4'b1010: rslt = reg_sel_A[7:0];
            4'b1011: rslt = reg_sel_A[7:0];
            default: rslt = 0
        endcase
    end
    else if ( op == 8'h3F ) begin
        case ( opnd0[3:0] )
            4'b0000: rslt = reg_sel_A;
            4'b0001: rslt = reg_sel_A;
            4'b0010: rslt = reg_sel_A;
            4'b0011: rslt = reg_sel_A;
            4'b0100: rslt = reg_sel_A;
            4'b0101: rslt = reg_sel_A;
            4'b1000: rslt = reg_sel_A[7:0];
            4'b1001: rslt = reg_sel_A[7:0];
            4'b1010: rslt = reg_sel_A[7:0];
            4'b1011: rslt = reg_sel_A[7:0];
            default: rslt = 0
        endcase           
    end

end
endmodule



/*

function [15:0] EXGTFRRegister(input [3:0] regid);
begin
        case (regid)
            EXGTFR_REG_D:
                EXGTFRRegister   =  {a, b};
            EXGTFR_REG_X:
                EXGTFRRegister   =  x;
            EXGTFR_REG_Y:
                EXGTFRRegister   =  y;
            EXGTFR_REG_U:
                EXGTFRRegister   =  u;
            EXGTFR_REG_S:
                EXGTFRRegister   =  s;
            EXGTFR_REG_PC:
                EXGTFRRegister   =  pc_p1; // For both EXG and TFR, this is used on the 2nd byte in the instruction's cycle.  The PC intended to transfer is actually the next byte.
            EXGTFR_REG_DP:
                EXGTFRRegister   =  {8'HFF, dp};
            EXGTFR_REG_A:
                EXGTFRRegister   =  {8'HFF, a};
            EXGTFR_REG_B:
                EXGTFRRegister   =  {8'HFF, b};
            EXGTFR_REG_CC:
                EXGTFRRegister   =  {8'HFF, cc};
            default:
                EXGTFRRegister   =  16'H0;
        endcase
end
endfunction
wire [15:0] EXGTFRRegA = EXGTFRRegister(D[7:4]);
wire [15:0] EXGTFRRegB = EXGTFRRegister(D[3:0]);

if (Inst1 == OPCODE_IMM_TFR)
                        begin
                            // The second byte lists the registers; Top nybble is reg #1, bottom is reg #2.

                            case (Inst2_nxt[3:0])
                                EXGTFR_REG_D:
                                    {a_nxt,b_nxt}  =  EXGTFRRegA;
                                EXGTFR_REG_X:
                                    x_nxt  =  EXGTFRRegA;
                                EXGTFR_REG_Y:
                                    y_nxt  =  EXGTFRRegA;
                                EXGTFR_REG_U:
                                    u_nxt  =  EXGTFRRegA;
                                EXGTFR_REG_S:
                                    s_nxt  =  EXGTFRRegA;
                                EXGTFR_REG_PC:
                                    pc_nxt =  EXGTFRRegA;
                                EXGTFR_REG_DP:
                                    dp_nxt =  EXGTFRRegA[7:0];
                                EXGTFR_REG_A:
                                    a_nxt  =  EXGTFRRegA[7:0];
                                EXGTFR_REG_B:
                                    b_nxt  =  EXGTFRRegA[7:0];
                                EXGTFR_REG_CC:
                                    cc_nxt =  EXGTFRRegA[7:0];
                                default:
                                begin
                                end
                            endcase
                            rAVMA = 1'b0;
                            CpuState_nxt   =  CPUSTATE_TFR_DONTCARE1;

                        end
                        else if (Inst1 == OPCODE_IMM_EXG)
                        begin
                            // The second byte lists the registers; Top nybble is reg #1, bottom is reg #2.

                            case (Inst2_nxt[7:4])
                                EXGTFR_REG_D:
                                    {a_nxt,b_nxt}  =  EXGTFRRegB;
                                EXGTFR_REG_X:
                                    x_nxt  =  EXGTFRRegB;
                                EXGTFR_REG_Y:
                                    y_nxt  =  EXGTFRRegB;
                                EXGTFR_REG_U:
                                    u_nxt  =  EXGTFRRegB;
                                EXGTFR_REG_S:
                                    s_nxt  =  EXGTFRRegB;
                                EXGTFR_REG_PC:
                                    pc_nxt =  EXGTFRRegB;
                                EXGTFR_REG_DP:
                                    dp_nxt =  EXGTFRRegB[7:0];
                                EXGTFR_REG_A:
                                    a_nxt  =  EXGTFRRegB[7:0];
                                EXGTFR_REG_B:
                                    b_nxt  =  EXGTFRRegB[7:0];
                                EXGTFR_REG_CC:
                                    cc_nxt =  EXGTFRRegB[7:0];
                                default:
                                begin
                                end
                            endcase
                            case (Inst2_nxt[3:0])
                                EXGTFR_REG_D:
                                    {a_nxt,b_nxt}  =  EXGTFRRegA;
                                EXGTFR_REG_X:
                                    x_nxt  =  EXGTFRRegA;
                                EXGTFR_REG_Y:
                                    y_nxt  =  EXGTFRRegA;
                                EXGTFR_REG_U:
                                    u_nxt  =  EXGTFRRegA;
                                EXGTFR_REG_S:
                                    s_nxt  =  EXGTFRRegA;
                                EXGTFR_REG_PC:
                                    pc_nxt =  EXGTFRRegA;
                                EXGTFR_REG_DP:
                                    dp_nxt =  EXGTFRRegA[7:0];
                                EXGTFR_REG_A:
                                    a_nxt  =  EXGTFRRegA[7:0];
                                EXGTFR_REG_B:
                                    b_nxt  =  EXGTFRRegA[7:0];
                                EXGTFR_REG_CC:
                                    cc_nxt =  EXGTFRRegA[7:0];
                                default:
                                begin
                                end
                            endcase
                            rAVMA = 1'b0;
                            CpuState_nxt   =  CPUSTATE_EXG_DONTCARE1;
                        end
                    end

*/