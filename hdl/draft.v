
always @* begin

    addr = op[0] ? u : s;
    if ( op==8'h0C || op==8'h0D ) begin  // PUSH
        if ( postbyte[7] & ~( lo_hi )) begin  // PC LO
            addr = u_s-16'h1;
            if ( op==8'h0D)
                u = u-16'h1;
            else
                s = s-16'h1; 
            rslt  = pc[7:0];
            lo_hi = 1; 
        end else if ( postbyte[7] & ( lo_hi ))  begin  // PC HI
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt  = pc[15:8];
            lo_hi = 0;
            postbyte[7] = 0;
        end else if ( postbyte[6] & ~( lo_hi )) begin  // U/S LO
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt  = (op[0]) ? s[7:0] : u[7:0];
            lo_hi = 1; 
        end else if ( postbyte[6] & ( lo_hi ))  begin  // U/S HI
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt  = (op[0]) ? s[15:8] : u[15:8];
            lo_hi = 0;
            postbyte[6] = 0
        end else if ( postbyte[5] & ~( lo_hi )) begin  // Y LO
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt  = y[7:0];
            lo_hi = 1; 
        end else if ( postbyte[5] & ( lo_hi ))  begin  // Y HI
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt  = y[15:8];
            lo_hi = 0;
            postbyte[5] = 0
        end else if ( postbyte[4] & ~( lo_hi )) begin  // X LO 
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt  = x[7:0];
            lo_hi = 1; 
        end else if ( postbyte[4] & ( lo_hi ))  begin  // X HI
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt  = x[15:8];
            lo_hi = 0;
            postbyte[4] = 0
        end else if ( postbyte[3] ) begin  // DP
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt = dp;
            postbyte[3] = 0
        end else if ( postbyte[2] ) begin  // B
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt = b;
            postbyte[2] = 0
        end else if ( postbyte[1] ) begin  // A
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt = a;
            postbyte[1] = 0
        end else if ( postbyte[0] ) begin  // CC
            addr = u_s-1;
            if ( op==8'h0D)
                u = u-1;
            else
                s = s-1;
            rslt = cc;
            postbyte[0] = 0
        end
    end else if ( ( op == 8'h0E ) || ( op == 8'h0F )) begin  // PULL
        
        if ( postbyte[0] ) begin  // CC
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            cc = opnd0[7:0];
            postbyte[0] = 0
        end else if ( postbyte[1] ) begin  // A
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            a = opnd0[7:0];
            postbyte[1] = 0
        end else if ( postbyte[2] ) begin  // B
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            b = opnd0[7:0];
            postbyte[2] = 0
        end else if ( postbyte[3] ) begin  // DP
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            dp = opnd0[7:0];
            postbyte[3] = 0
        end else if ( postbyte[4] & ( lo_hi ))  begin  // X HI
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            x[15:8] = opnd0[7:0];
            lo_hi = 1;
        end else if ( postbyte[4] & ~( lo_hi )) begin  // X LO 
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            x[7:0] = opnd0[7:0];
            lo_hi = 0;
            postbyte[4] = 0;
        end else if ( postbyte[5] & ( lo_hi ))  begin  // Y HI
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            y[15:8] = opnd0[7:0];
            lo_hi = 1;
        end else if ( postbyte[5] & ~( lo_hi )) begin  // Y LO
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            y[7:0] = opnd0[7:0];
            lo_hi = 0;
            postbyte[5] = 0;
        end else if ( postbyte[6] & ( lo_hi ))  begin  // U/S HI
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            if (op==8'h0F)
                s[15:8] = opnd0[7:0];
            else
                u[15:8] = opnd0[7:0];
            lo_hi = 1;
        end else if ( postbyte[6] & ~( lo_hi )) begin  // U/S LO
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            if (op==8'h0F)
                s[7:0] = opnd0[7:0];
            else
                u[7:0] = opnd0[7:0];
            lo_hi = 0;
            postbyte[6] = 0;
        end else if ( postbyte[7] & ( lo_hi ))  begin  // PC HI
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            pc[15:8] = opnd0[7:0];
            lo_hi    = 1;
        end else if ( postbyte[7] & ~( lo_hi )) begin  // PC LO
            addr = u_s;
            if ( op==8'h0F)
                u = u+1;
            else
                s = s+1;
            pc[7:0] = opnd0[7:0];
            lo_hi   = 0;
            postbyte[7] = 0;
        end
    end
end




always @(posedge clk or posedge rst) begin 
    if(rst) begin
        us_sel  <= 0;
        pul_sel <= 0;
        hi_lon  <= 0;
    end else begin
        if( idle ) begin
            if( pul_go ) begin
                pul_sel <= postbyte;
                us_sel  <= op[0];
                hi_lon  <= 0;
            end
        end else begin
            if( us_sel == 0 ) begin
                pul_sel <= 
                hi_lon <= 1;
            end else begin
                hi_lon <= 0;
                pul_sel <= pul_sel & ~psh_bit;
            end
        end
    end
end


always @(posedge clk or posedge rst) begin 
    if(rst) begin
        psh_sel <= 0;
        pul_sel <=
        hi_lon  <= 0;
        us_sel  <= 0;
    end else begin
        if( idle ) begin
            if( psh_go ) begin
                psh_sel <= postbyte;
                us_sel  <= op[0];
                hi_lon  <= 1;
            end
        end else begin
            if( psh_bit[7:4]!=0 && hi_lon ) begin
                hi_lon <= 0;
            end else begin
                hi_lon <= 1;
                psh_sel <= psh_sel & ~psh_bit;
            end
        end
    end
end





// PUSH
always @* begin
    casez( pul_sel )
        8'b????_???1: begin end
        8'b????_??10: begin end
        8'b????_?100: begin end
        8'b????_1000: begin end
        8'b???1_0000: begin end
        8'b??10_0000: begin end
        8'b?100_0000: begin end
        default:      begin end
    endcase    
end


always @* begin
    if ( op==8'h0E ) begin
        casez( postbyte )
            8'b????_???1: begin pul_sel = up_cc; us_sel = op[0]; end
            8'b????_??10: begin pul_sel = up_a; us_sel  = op[0]; end
            8'b????_?100: begin pul_sel = up_b; us_sel  = op[0]; end
            8'b????_1000: begin pul_sel = up_dp; us_sel = op[0]; end
            8'b???1_0000: begin pul_sel = up_x; us_sel  = op[0]; end
            8'b??10_0000: begin pul_sel = up_y; us_sel  = op[0]; end
            8'b?100_0000: begin pul_sel = us_sel=op[0] ? up_s : up_u; end
            default:      begin pul_sel = up_pc; us_sel = op[0]; end
        endcase    
    end    
end


casez ( op )
    8'b0001???0: mux_reg = a;
    8'b0001???1: mux_reg = b;
    8'b0010???0: mux_reg = a;
    8'b0010???1: mux_reg = b;
    8'b00110??0: mux_reg = a;
    8'b00110??1: mux_reg = b;
    
    8'b0011110?: mux_reg = cc;

    mux_reg = x;
    mux_reg = y;
    mux_reg = u;
    mux_reg = s;

    default : mux_reg = 0;
endcase