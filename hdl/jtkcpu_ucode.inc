localparam UCODE_DW = 58;
localparam OPCAT_AW = 6;
localparam UCODE_AW = OPCAT_AW+3;
localparam [OPCAT_AW-1:0] 
        PARSE_IDX        = 'o0,
        IDX_R            = 'o1,
        IDX_RINC         = 'o2,
        IDX_RINC2        = 'o3,
        IDX_RDEC         = 'o4,
        IDX_RDEC2        = 'o5,
        IDX_OFFSET8      = 'o6,
        IDX_OFFSET16     = 'o7,
        IDX_IND          = 'o10,
        IDX_EXT          = 'o11,
        IDX_DP           = 'o12,
        IDX_ACC          = 'o13,
        SINGLE_ALU       = 'o14,
        CMP8             = 'o15,
        CMP8_IDX         = 'o16,
        SINGLE_ALU_16    = 'o17,
        CMP16            = 'o20,
        CMP16_IDX        = 'o21,
        SINGLE_A_INH     = 'o22,
        SINGLE_B_INH     = 'o23,
        SINGLE_ALU_INH16 = 'o24,
        SINGLE_ABX       = 'o25,
        SINGLE_ALU_IDX   = 'o26,
        SINGLE_ALU_IDX16 = 'o27,
        MULTI_ALU        = 'o30,
        MEM_ALU_IDX      = 'o31,
        MULTI_ALU_INH    = 'o32,
        MULTI_ALU_IDX    = 'o33,
        WMEM_ALU         = 'o34,
        MULTIPLY         = 'o35,
        LMULTIPLY        = 'o36,
        LOOPX            = 'o37,
        LOOPB            = 'o40,
        MOVE             = 'o41,
        BMOVE            = 'o42,
        BSETA            = 'o43,
        BSETD            = 'o44,
        STORE8           = 'o45,
        STORE16          = 'o46,
        LEA              = 'o47,
        SETLNS           = 'o50,
        SETLNS_IDX       = 'o51,
        EXCHANGE         = 'o52,
        TRANSFER         = 'o53,
        NOPE             = 'o54,
        SBRANCH          = 'o55,
        SBSR             = 'o56,
        BSRL             = 'o57,
        LBRANCH          = 'o60,
        JUMP             = 'o61,
        JMSR             = 'o62,
        RTIT             = 'o63,
        RTSR             = 'o64,
        PSH              = 'o65,
        PUL              = 'o66,
        RESET            = 'o67,
        FIRQ             = 'o70,
        IRQ              = 'o71,
        NMI              = 'o72,
        BUSERROR         = 'o73;

assign { 
        we, 
        up_xb, 
        up_tfr, 
        up_move, 
        up_lmul, 
        up_lines, 
        up_lea, 
        up_ldb, 
        up_lda, 
        up_ld8, 
        up_ld16, 
        up_exg, 
        up_cc, 
        up_ab, 
        uc_loop, 
        rti_other, 
        rti_cc, 
        pul_go, 
        psh_pc, 
        psh_go, 
        psh_cc, 
        psh_all, 
        pc_jmp, 
        set_pc_branch8, 
        set_pc_branch16, 
        set_opn0_regs, 
        set_opn0_mem, 
        set_opn0_b, 
        opd, 
        niuz, 
        ni, 
        memhi, 
        int_en, 
        incx, 
        idx_ret, 
        idx_pre, 
        set_idx_post, 
        idx_jmp, 
        idx_ind, 
        idx_en, 
        idx_dp, 
        idx_adv, 
        set_idx_acc, 
        idx_8, 
        idx_16, 
        set_idxw, 
        set_i, 
        set_f, 
        set_e, 
        clr_e, 
        decx, 
        decu, 
        decb, 
        data2addr, 
        buserror, 
        branch_bnz, 
        addry, 
        addrx
    } = ucode;

always @(posedge clk) if(cen) begin
    case( addr )
        9'o000: ucode <= 58'h20000000;    // PARSE_IDX
        9'o001: ucode <= 58'h100000;
        9'o011: ucode <= 58'h80000;
        9'o020: ucode <= 58'h200000;    // IDX_RINC
        9'o021: ucode <= 58'h80000;
        9'o030: ucode <= 58'h201000;    // IDX_RINC2
        9'o031: ucode <= 58'h80000;
        9'o040: ucode <= 58'h400000;    // IDX_RDEC
        9'o041: ucode <= 58'h80000;
        9'o050: ucode <= 58'h401000;    // IDX_RDEC2
        9'o051: ucode <= 58'h80000;
        9'o060: ucode <= 58'h20000000;    // IDX_OFFSET8
        9'o061: ucode <= 58'h84000;
        9'o070: ucode <= 58'h24000000;    // IDX_OFFSET16
        9'o071: ucode <= 58'h20000000;
        9'o072: ucode <= 58'h82000;
        9'o100: ucode <= 58'h4040000;    // IDX_IND
        9'o101: ucode <= 58'h50000;
        9'o102: ucode <= 58'h800010;
        9'o110: ucode <= 58'h24000000;    // IDX_EXT
        9'o111: ucode <= 58'h20000000;
        9'o112: ucode <= 58'h80010;
        9'o120: ucode <= 58'h20000000;    // IDX_DP
        9'o121: ucode <= 58'hA0000;
        9'o131: ucode <= 58'h88000;
        9'o140: ucode <= 58'h20000000;    // SINGLE_ALU
        9'o141: ucode <= 58'h1200100000000;
        9'o142: ucode <= 58'h8000000;
        9'o150: ucode <= 58'h20000000;    // CMP8
        9'o151: ucode <= 58'h200100000000;
        9'o152: ucode <= 58'h8000000;
        9'o160: ucode <= 58'h40000;    // CMP8_IDX
        9'o161: ucode <= 58'h200100000000;
        9'o162: ucode <= 58'h8000000;
        9'o170: ucode <= 58'h24000000;    // SINGLE_ALU_16
        9'o171: ucode <= 58'h20000000;
        9'o172: ucode <= 58'hA00100000000;
        9'o173: ucode <= 58'h8000000;
        9'o200: ucode <= 58'h24000000;    // CMP16
        9'o201: ucode <= 58'h20000000;
        9'o202: ucode <= 58'h200100000000;
        9'o203: ucode <= 58'h8000000;
        9'o210: ucode <= 58'h4040000;    // CMP16_IDX
        9'o211: ucode <= 58'h50000;
        9'o212: ucode <= 58'h200100000000;
        9'o213: ucode <= 58'h8000000;
        9'o220: ucode <= 58'h2200100000000;    // SINGLE_A_INH
        9'o221: ucode <= 58'h8000000;
        9'o230: ucode <= 58'h4200100000000;    // SINGLE_B_INH
        9'o231: ucode <= 58'h8000000;
        9'o240: ucode <= 58'h300100000000;    // SINGLE_ALU_INH16
        9'o241: ucode <= 58'h8000000;
        9'o250: ucode <= 58'h100200100000000;    // SINGLE_ABX
        9'o251: ucode <= 58'h8000000;
        9'o260: ucode <= 58'h40000;    // SINGLE_ALU_IDX
        9'o261: ucode <= 58'h1200100000000;
        9'o262: ucode <= 58'h8000000;
        9'o270: ucode <= 58'h4040000;    // SINGLE_ALU_IDX16
        9'o271: ucode <= 58'h50000;
        9'o272: ucode <= 58'hA00100000000;
        9'o273: ucode <= 58'h8000000;
        9'o300: ucode <= 58'h20000000;    // MULTI_ALU
        9'o301: ucode <= 58'h200100000000;
        9'o302: ucode <= 58'h8000000;
        9'o310: ucode <= 58'h40000;    // MEM_ALU_IDX
        9'o311: ucode <= 58'h200200080040000;
        9'o312: ucode <= 58'h8000000;
        9'o320: ucode <= 58'h24000000;    // MULTI_ALU_INH
        9'o321: ucode <= 58'h100200100000000;
        9'o322: ucode <= 58'h8000000;
        9'o330: ucode <= 58'h40000;    // MULTI_ALU_IDX
        9'o331: ucode <= 58'h200100000000;
        9'o332: ucode <= 58'h8000000;
        9'o340: ucode <= 58'h4040000;    // WMEM_ALU
        9'o341: ucode <= 58'h50000;
        9'o342: ucode <= 58'h200200084040000;
        9'o343: ucode <= 58'h200000080050000;
        9'o344: ucode <= 58'h8000000;
        9'o355: ucode <= 58'h300000000000;
        9'o356: ucode <= 58'h8000000;
        9'o365: ucode <= 58'h20000000000000;
        9'o366: ucode <= 58'h8000000;
        9'o370: ucode <= 58'h20000000;    // LOOPX
        9'o371: ucode <= 58'h200000000080;
        9'o372: ucode <= 58'h004;
        9'o373: ucode <= 58'h8000000;
        9'o400: ucode <= 58'h20000000;    // LOOPB
        9'o401: ucode <= 58'h200040000020;
        9'o402: ucode <= 58'h004;
        9'o403: ucode <= 58'h8000000;
        9'o410: ucode <= 58'h002;    // MOVE
        9'o411: ucode <= 58'h240000000000001;
        9'o412: ucode <= 58'h8000000;
        9'o420: ucode <= 58'h10000000;    // BMOVE
        9'o422: ucode <= 58'h002;
        9'o423: ucode <= 58'h240000000000001;
        9'o424: ucode <= 58'h80000000000;
        9'o430: ucode <= 58'h10000000;    // BSETA
        9'o432: ucode <= 58'h200000001000041;
        9'o433: ucode <= 58'h80000000000;
        9'o440: ucode <= 58'h10000000;    // BSETD
        9'o442: ucode <= 58'h200000001000041;
        9'o443: ucode <= 58'h200000001000001;
        9'o444: ucode <= 58'h80000000000;
        9'o450: ucode <= 58'h200000100040000;    // STORE8
        9'o451: ucode <= 58'h8000000;
        9'o460: ucode <= 58'h200000104040000;    // STORE16
        9'o461: ucode <= 58'h200000100050000;
        9'o462: ucode <= 58'h8000000;
        9'o470: ucode <= 58'h8200000000000;    // LEA
        9'o471: ucode <= 58'h8000000;
        9'o500: ucode <= 58'h20000000;    // SETLNS
        9'o501: ucode <= 58'h10000008000000;
        9'o510: ucode <= 58'h40000;    // SETLNS_IDX
        9'o511: ucode <= 58'h10000008000000;
        9'o520: ucode <= 58'h20000000;    // EXCHANGE
        9'o521: ucode <= 58'h400000000000;
        9'o522: ucode <= 58'h8000000;
        9'o530: ucode <= 58'h20000000;    // TRANSFER
        9'o531: ucode <= 58'h80000000000000;
        9'o532: ucode <= 58'h8000000;
        9'o540: ucode <= 58'h8000000;    // NOPE
        9'o550: ucode <= 58'h20000000;    // SBRANCH
        9'o551: ucode <= 58'h400000000;
        9'o552: ucode <= 58'h8000000;
        9'o560: ucode <= 58'h20000000;    // SBSR
        9'o561: ucode <= 58'hC000000000;
        9'o563: ucode <= 58'h400000000;
        9'o564: ucode <= 58'h8000000;
        9'o570: ucode <= 58'h24000000;    // BSRL
        9'o571: ucode <= 58'h20000000;
        9'o572: ucode <= 58'hC000000000;
        9'o574: ucode <= 58'h200000000;
        9'o575: ucode <= 58'h8000000;
        9'o600: ucode <= 58'h24000000;    // LBRANCH
        9'o601: ucode <= 58'h20000000;
        9'o602: ucode <= 58'h200000000;
        9'o603: ucode <= 58'h8000000;
        9'o610: ucode <= 58'h800000000;    // JUMP
        9'o611: ucode <= 58'h8000000;
        9'o620: ucode <= 58'hC000000000;    // JMSR
        9'o622: ucode <= 58'h800000000;
        9'o623: ucode <= 58'h8000000;
        9'o630: ucode <= 58'h30000000000;    // RTIT
        9'o632: ucode <= 58'h50000000000;
        9'o634: ucode <= 58'h8000000;
        9'o640: ucode <= 58'h18000000000;    // RTSR
        9'o643: ucode <= 58'h8000000;
        9'o650: ucode <= 58'h20000000;    // PSH
        9'o651: ucode <= 58'h4000000000;
        9'o654: ucode <= 58'h8000000;
        9'o660: ucode <= 58'h20000000;    // PUL
        9'o661: ucode <= 58'h10000000000;
        9'o664: ucode <= 58'h8000000;
        9'o670: ucode <= 58'h2000C00;    // RESET
        9'o674: ucode <= 58'h8000000;
        9'o700: ucode <= 58'h6000000000;    // FIRQ
        9'o701: ucode <= 58'hD00;
        9'o703: ucode <= 58'h2000000;
        9'o705: ucode <= 58'h8000000;
        9'o710: ucode <= 58'h5000000000;    // IRQ
        9'o711: ucode <= 58'hA00;
        9'o713: ucode <= 58'h2000000;
        9'o715: ucode <= 58'h8000000;
        9'o720: ucode <= 58'h5000000000;    // NMI
        9'o721: ucode <= 58'hE00;
        9'o723: ucode <= 58'h2000000;
        9'o725: ucode <= 58'h8000000;
        9'o730: ucode <= 58'h008;    // BUSERROR
        default: ucode <= 0;
    endcase
end

