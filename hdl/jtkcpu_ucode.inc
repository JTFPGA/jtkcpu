localparam UCODE_DW = 59;
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
        SINGLE_ALUD      = 'o20,
        SINGLE_ALUD_IDX  = 'o21,
        CMP16            = 'o22,
        CMP16_IDX        = 'o23,
        SINGLE_A_INH     = 'o24,
        SINGLE_B_INH     = 'o25,
        SINGLE_ALU_INH16 = 'o26,
        SINGLE_ABX       = 'o27,
        SINGLE_ALU_IDX   = 'o30,
        SINGLE_ALU_IDX16 = 'o31,
        MULTI_ALU        = 'o32,
        MEM_ALU_IDX      = 'o33,
        MULTI_ALU_INH    = 'o34,
        MULTI_ALU_IDX    = 'o35,
        WMEM_ALU         = 'o36,
        MULTIPLY         = 'o37,
        LMULTIPLY        = 'o40,
        LOOPX            = 'o41,
        LOOPB            = 'o42,
        MOVE             = 'o43,
        BMOVE            = 'o44,
        BSETA            = 'o45,
        BSETD            = 'o46,
        STORE8           = 'o47,
        STORE16          = 'o50,
        LEA              = 'o51,
        SETLNS           = 'o52,
        SETLNS_IDX       = 'o53,
        EXCHANGE         = 'o54,
        TRANSFER         = 'o55,
        NOPE             = 'o56,
        SBRANCH          = 'o57,
        SBSR             = 'o60,
        BSRL             = 'o61,
        LBRANCH          = 'o62,
        JUMP             = 'o63,
        JMSR             = 'o64,
        RTIT             = 'o65,
        RTSR             = 'o66,
        PSH              = 'o67,
        PUL              = 'o70,
        RESET            = 'o71,
        FIRQ             = 'o72,
        IRQ              = 'o73,
        NMI              = 'o74,
        BUSERROR         = 'o75;

assign { 
        we, 
        up_xb, 
        up_tfr, 
        up_move, 
        up_lmul, 
        up_lines, 
        up_lea, 
        up_ldx, 
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
        9'o000: ucode <= 59'h20000000;    // PARSE_IDX
        9'o001: ucode <= 59'h100000;
        9'o011: ucode <= 59'h80000;
        9'o020: ucode <= 59'h200000;    // IDX_RINC
        9'o021: ucode <= 59'h80000;
        9'o030: ucode <= 59'h201000;    // IDX_RINC2
        9'o031: ucode <= 59'h80000;
        9'o040: ucode <= 59'h400000;    // IDX_RDEC
        9'o041: ucode <= 59'h80000;
        9'o050: ucode <= 59'h401000;    // IDX_RDEC2
        9'o051: ucode <= 59'h80000;
        9'o060: ucode <= 59'h20000000;    // IDX_OFFSET8
        9'o061: ucode <= 59'h84000;
        9'o070: ucode <= 59'h24000000;    // IDX_OFFSET16
        9'o071: ucode <= 59'h20000000;
        9'o072: ucode <= 59'h82000;
        9'o100: ucode <= 59'h4040000;    // IDX_IND
        9'o101: ucode <= 59'h50000;
        9'o102: ucode <= 59'h800010;
        9'o110: ucode <= 59'h24000000;    // IDX_EXT
        9'o111: ucode <= 59'h20000000;
        9'o112: ucode <= 59'h80010;
        9'o120: ucode <= 59'h20000000;    // IDX_DP
        9'o121: ucode <= 59'hA0000;
        9'o131: ucode <= 59'h88000;
        9'o140: ucode <= 59'h20000000;    // SINGLE_ALU
        9'o141: ucode <= 59'h1200100000000;
        9'o142: ucode <= 59'h8000000;
        9'o150: ucode <= 59'h20000000;    // CMP8
        9'o151: ucode <= 59'h200100000000;
        9'o152: ucode <= 59'h8000000;
        9'o160: ucode <= 59'h40000;    // CMP8_IDX
        9'o161: ucode <= 59'h200100000000;
        9'o162: ucode <= 59'h8000000;
        9'o170: ucode <= 59'h24000000;    // SINGLE_ALU_16
        9'o171: ucode <= 59'h20000000;
        9'o172: ucode <= 59'hA00100000000;
        9'o173: ucode <= 59'h8000000;
        9'o200: ucode <= 59'h24000000;    // SINGLE_ALUD
        9'o201: ucode <= 59'h20000000;
        9'o202: ucode <= 59'h300100000000;
        9'o203: ucode <= 59'h8000000;
        9'o210: ucode <= 59'h4040000;    // SINGLE_ALUD_IDX
        9'o211: ucode <= 59'h50000;
        9'o212: ucode <= 59'h300100000000;
        9'o213: ucode <= 59'h8000000;
        9'o220: ucode <= 59'h24000000;    // CMP16
        9'o221: ucode <= 59'h20000000;
        9'o222: ucode <= 59'h200100000000;
        9'o223: ucode <= 59'h8000000;
        9'o230: ucode <= 59'h4040000;    // CMP16_IDX
        9'o231: ucode <= 59'h50000;
        9'o232: ucode <= 59'h200100000000;
        9'o233: ucode <= 59'h8000000;
        9'o240: ucode <= 59'h2200100000000;    // SINGLE_A_INH
        9'o241: ucode <= 59'h8000000;
        9'o250: ucode <= 59'h4200100000000;    // SINGLE_B_INH
        9'o251: ucode <= 59'h8000000;
        9'o260: ucode <= 59'h300100000000;    // SINGLE_ALU_INH16
        9'o261: ucode <= 59'h8000000;
        9'o270: ucode <= 59'h8000100000000;    // SINGLE_ABX
        9'o271: ucode <= 59'h8000000;
        9'o300: ucode <= 59'h40000;    // SINGLE_ALU_IDX
        9'o301: ucode <= 59'h1200100000000;
        9'o302: ucode <= 59'h8000000;
        9'o310: ucode <= 59'h4040000;    // SINGLE_ALU_IDX16
        9'o311: ucode <= 59'h50000;
        9'o312: ucode <= 59'hA00100000000;
        9'o313: ucode <= 59'h8000000;
        9'o320: ucode <= 59'h20000000;    // MULTI_ALU
        9'o321: ucode <= 59'h200100000000;
        9'o322: ucode <= 59'h8000000;
        9'o330: ucode <= 59'h40000;    // MEM_ALU_IDX
        9'o331: ucode <= 59'h400200080040000;
        9'o332: ucode <= 59'h8000000;
        9'o340: ucode <= 59'h24000000;    // MULTI_ALU_INH
        9'o341: ucode <= 59'h200200100000000;
        9'o342: ucode <= 59'h8000000;
        9'o350: ucode <= 59'h40000;    // MULTI_ALU_IDX
        9'o351: ucode <= 59'h200100000000;
        9'o352: ucode <= 59'h8000000;
        9'o360: ucode <= 59'h4040000;    // WMEM_ALU
        9'o361: ucode <= 59'h50000;
        9'o362: ucode <= 59'h400200084040000;
        9'o363: ucode <= 59'h400000080050000;
        9'o364: ucode <= 59'h8000000;
        9'o375: ucode <= 59'h300000000000;
        9'o376: ucode <= 59'h8000000;
        9'o405: ucode <= 59'h40200000000000;
        9'o406: ucode <= 59'h8000000;
        9'o410: ucode <= 59'h20000000;    // LOOPX
        9'o411: ucode <= 59'h200000000080;
        9'o412: ucode <= 59'h004;
        9'o413: ucode <= 59'h8000000;
        9'o420: ucode <= 59'h20000000;    // LOOPB
        9'o421: ucode <= 59'h200040000020;
        9'o422: ucode <= 59'h004;
        9'o423: ucode <= 59'h8000000;
        9'o430: ucode <= 59'h002;    // MOVE
        9'o431: ucode <= 59'h480000000000001;
        9'o432: ucode <= 59'h8000000;
        9'o440: ucode <= 59'h10000000;    // BMOVE
        9'o442: ucode <= 59'h002;
        9'o443: ucode <= 59'h480000000000001;
        9'o444: ucode <= 59'h80000000000;
        9'o450: ucode <= 59'h10000000;    // BSETA
        9'o452: ucode <= 59'h400000001000041;
        9'o453: ucode <= 59'h80000000000;
        9'o460: ucode <= 59'h10000000;    // BSETD
        9'o462: ucode <= 59'h400000001000041;
        9'o463: ucode <= 59'h400000001000001;
        9'o464: ucode <= 59'h80000000000;
        9'o470: ucode <= 59'h400000100040000;    // STORE8
        9'o471: ucode <= 59'h8000000;
        9'o500: ucode <= 59'h400000104040000;    // STORE16
        9'o501: ucode <= 59'h400000100050000;
        9'o502: ucode <= 59'h8000000;
        9'o510: ucode <= 59'h10200000000000;    // LEA
        9'o511: ucode <= 59'h8000000;
        9'o520: ucode <= 59'h20000000;    // SETLNS
        9'o521: ucode <= 59'h20000008000000;
        9'o530: ucode <= 59'h40000;    // SETLNS_IDX
        9'o531: ucode <= 59'h20000008000000;
        9'o540: ucode <= 59'h20000000;    // EXCHANGE
        9'o541: ucode <= 59'h400000000000;
        9'o542: ucode <= 59'h8000000;
        9'o550: ucode <= 59'h20000000;    // TRANSFER
        9'o551: ucode <= 59'h100000000000000;
        9'o552: ucode <= 59'h8000000;
        9'o560: ucode <= 59'h8000000;    // NOPE
        9'o570: ucode <= 59'h20000000;    // SBRANCH
        9'o571: ucode <= 59'h400000000;
        9'o572: ucode <= 59'h8000000;
        9'o600: ucode <= 59'h20000000;    // SBSR
        9'o601: ucode <= 59'hC000000000;
        9'o603: ucode <= 59'h400000000;
        9'o604: ucode <= 59'h8000000;
        9'o610: ucode <= 59'h24000000;    // BSRL
        9'o611: ucode <= 59'h20000000;
        9'o612: ucode <= 59'hC000000000;
        9'o614: ucode <= 59'h200000000;
        9'o615: ucode <= 59'h8000000;
        9'o620: ucode <= 59'h24000000;    // LBRANCH
        9'o621: ucode <= 59'h20000000;
        9'o622: ucode <= 59'h200000000;
        9'o623: ucode <= 59'h8000000;
        9'o630: ucode <= 59'h800000000;    // JUMP
        9'o631: ucode <= 59'h8000000;
        9'o640: ucode <= 59'hC000000000;    // JMSR
        9'o642: ucode <= 59'h800000000;
        9'o643: ucode <= 59'h8000000;
        9'o650: ucode <= 59'h30000000000;    // RTIT
        9'o652: ucode <= 59'h50000000000;
        9'o654: ucode <= 59'h8000000;
        9'o660: ucode <= 59'h18000000000;    // RTSR
        9'o663: ucode <= 59'h8000000;
        9'o670: ucode <= 59'h20000000;    // PSH
        9'o671: ucode <= 59'h4000000000;
        9'o674: ucode <= 59'h8000000;
        9'o700: ucode <= 59'h20000000;    // PUL
        9'o701: ucode <= 59'h10000000000;
        9'o704: ucode <= 59'h8000000;
        9'o710: ucode <= 59'h2000C00;    // RESET
        9'o714: ucode <= 59'h8000000;
        9'o720: ucode <= 59'h6000000000;    // FIRQ
        9'o721: ucode <= 59'hD00;
        9'o723: ucode <= 59'h2000000;
        9'o725: ucode <= 59'h8000000;
        9'o730: ucode <= 59'h5000000000;    // IRQ
        9'o731: ucode <= 59'hA00;
        9'o733: ucode <= 59'h2000000;
        9'o735: ucode <= 59'h8000000;
        9'o740: ucode <= 59'h5000000000;    // NMI
        9'o741: ucode <= 59'hE00;
        9'o743: ucode <= 59'h2000000;
        9'o745: ucode <= 59'h8000000;
        9'o750: ucode <= 59'h008;    // BUSERROR
        default: ucode <= 0;
    endcase
end

