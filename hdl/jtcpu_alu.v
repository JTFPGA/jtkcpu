module jtkcpu_alu(
	input      [4:0] op, 
	input      [7:0] opnd0, 
	input      [7:0] opnd1, 
	input      [7:0] cc_in,
	output reg [7:0] cc_out,
	output reg [7:0] rslt
);

always @* begin
    cc_out =  cc_in;
    case (op)
        ALUOP_NEG: begin
            rslt[7:0]             =  ~opnd0 + 1'b1;
            cc_out[CC_C_BIT]      =  (rslt[7:0] != 8'H00);
            cc_out[CC_V_BIT]      =  (opnd0 == 8'H80);
        end
        ALUOP_LSL: begin
            {cc_out[CC_C_BIT], rslt}  =  {opnd0, 1'b0};
            cc_out[CC_V_BIT]   =  opnd0[7] ^ opnd0[6];
        end
        ALUOP_LSR: begin
            {rslt, cc_out[CC_C_BIT]}  =  {1'b0, opnd0};
        end
        ALUOP_ASR: begin
            {rslt, cc_out[CC_C_BIT]}  =  {opnd0[7], opnd0};
        end
        ALUOP_ROL: begin
            {cc_out[CC_C_BIT], rslt}  =  {opnd0, cc_in[CC_C_BIT]};
            cc_out[CC_V_BIT]   =  opnd0[7] ^ opnd0[6];
        end
        ALUOP_ROR: begin
            {rslt, cc_out[CC_C_BIT]}  =  {cc_in[CC_C_BIT], opnd0};
        end
        ALUOP_OR: begin
            rslt[7:0] =  (opnd0 | opnd1);
            cc_out[CC_V_BIT]   =  1'b0;
        end
        ALUOP_ADD: begin
            {cc_out[CC_C_BIT], rslt[7:0]} =  {1'b0, opnd0} + {1'b0, opnd1};
            cc_out[CC_V_BIT]   =  (opnd0[7] & opnd1[7] & ~rslt[7]) | (~opnd0[7] & ~opnd1[7] & rslt[7]);
            cc_out[CC_H_BIT]   =  opnd0[4] ^ opnd1[4] ^ rslt[4];
        end
        ALUOP_SUB: begin
            {cc_out[CC_C_BIT], rslt[7:0]} = {1'b0, opnd0} - {1'b0, opnd1};
            cc_out[CC_V_BIT]   =   (opnd0[7] & ~opnd1[7] & ~rslt[7]) | (~opnd0[7] & opnd1[7] & rslt[7]);
        end
        ALUOP_AND: begin
            rslt[7:0] =  (opnd0 & opnd1);
            cc_out[CC_V_BIT]   =  1'b0;
        end
        ALUOP_BIT: begin
            rslt[7:0] =  (opnd0 & opnd1);
            cc_out[CC_V_BIT]   =  1'b0;
        end
        ALUOP_EOR: begin
            rslt[7:0] =  (opnd0 ^ opnd1);
            cc_out[CC_V_BIT]   =  1'b0;
        end
        ALUOP_CMP: begin
            {cc_out[CC_C_BIT], rslt[7:0]} = {1'b0, opnd0} - {1'b0, opnd1};
            cc_out[CC_V_BIT]   =   (opnd0[7] & ~opnd1[7] & ~rslt[7]) | (~opnd0[7] & opnd1[7] & rslt[7]);
        end
        ALUOP_COM: begin
            rslt[7:0] =  ~opnd0;
            cc_out[CC_V_BIT]   =  1'b0;
            cc_out[CC_C_BIT]   =  1'b1;
        end
        ALUOP_ADC: begin
            {cc_out[CC_C_BIT], rslt[7:0]} =  {1'b0, opnd0} + {1'b0, opnd1} + {8'd0,cc_in[CC_C_BIT]};
            cc_out[CC_V_BIT]   =  (opnd0[7] & opnd1[7] & ~rslt[7]) | (~opnd0[7] & ~opnd1[7] & rslt[7]);
            cc_out[CC_H_BIT]   =  opnd0[4] ^ opnd1[4] ^ rslt[4];
        end
        ALUOP_LD: begin
            rslt[7:0] =  opnd1;
            cc_out[CC_V_BIT] = 1'b0;
        end
        ALUOP_INC: begin
            rslt            =  opnd0 + 1'b1;
            cc_out[CC_V_BIT] =  (~opnd0[7] & rslt[7]);
        end
        ALUOP_DEC: begin
            rslt            = opnd0 - 1'b1;
            cc_out[CC_V_BIT] = (opnd0[7] & ~rslt[7]);
        end
        ALUOP_CLR: begin
            rslt[7:0] =  8'H00;
            cc_out[CC_V_BIT]   =  1'b0;
            cc_out[CC_C_BIT]   =  1'b0;
        end
        ALUOP_TST: begin
            rslt[7:0] =  opnd0;
            cc_out[CC_V_BIT]   =  1'b0;
        end
        ALUOP_SBC: begin
            {cc_out[CC_C_BIT], rslt[7:0]} = {1'b0, opnd0} - {1'b0, opnd1} - {8'd0,cc_in[CC_C_BIT]};
            cc_out[CC_V_BIT]   =   (opnd0[7] & ~opnd1[7] & ~rslt[7]) | (~opnd0[7] & opnd1[7] & rslt[7]);
        end
        default:
            rslt = 8'H00;

    endcase

    cc_out[CC_N_BIT]   =  rslt[7];
    cc_out[CC_Z_BIT]   =  (rslt == 8'H00);
end

endmodule