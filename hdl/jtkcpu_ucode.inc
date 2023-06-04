localparam UCODE_DW = 59;
localparam OPCAT_AW = 6;
localparam UCODE_AW = OPCAT_AW+3;
localparam [OPCAT_AW-1:0] 
        RESET            = 'o0,
        FIRQ             = 'o1,
        IRQ              = 'o2,
        NMI              = 'o3,
        BUSERROR         = 'o4,
        PARSE_IDX        = 'o5,
        IDX_R            = 'o6,
        IDX_RINC         = 'o7,
        IDX_RINC2        = 'o10,
        IDX_RDEC         = 'o11,
        IDX_RDEC2        = 'o12,
        IDX_OFFSET8      = 'o13,
        IDX_OFFSET16     = 'o14,
        IDX_IND          = 'o15,
        IDX_EXT          = 'o16,
        IDX_DP           = 'o17,
        IDX_ACC          = 'o20,
        SINGLE_ALU       = 'o21,
        CMP8             = 'o22,
        CMP8_IDX         = 'o23,
        SINGLE_ALU_16    = 'o24,
        SINGLE_ALUD      = 'o25,
        SINGLE_ALUD_IDX  = 'o26,
        CMP16            = 'o27,
        CMP16_IDX        = 'o30,
        SINGLE_A_INH     = 'o31,
        SINGLE_B_INH     = 'o32,
        SINGLE_ALU_INH16 = 'o33,
        SINGLE_ABX       = 'o34,
        SINGLE_ALU_IDX   = 'o35,
        SINGLE_ALU_IDX16 = 'o36,
        SHIFTD           = 'o37,
        SHIFTD_IDX       = 'o40,
        NOPE             = 'o41,
        MEM_ALU_IDX      = 'o42,
        DIVIDE           = 'o43,
        WMEM_ALU         = 'o44,
        MULTIPLY         = 'o45,
        LMULTIPLY        = 'o46,
        LOOPX            = 'o47,
        LOOPB            = 'o50,
        MOVE             = 'o51,
        BMOVE            = 'o52,
        BSETA            = 'o53,
        BSETD            = 'o54,
        STORE8           = 'o55,
        STORE16          = 'o56,
        LEA              = 'o57,
        SETLNS           = 'o60,
        SETLNS_IDX       = 'o61,
        EXCHANGE         = 'o62,
        TRANSFER         = 'o63,
        SBRANCH          = 'o64,
        SBSR             = 'o65,
        BSRL             = 'o66,
        LBRANCH          = 'o67,
        JUMP             = 'o70,
        JMSR             = 'o71,
        RTIT             = 'o72,
        RTSR             = 'o73,
        PSH              = 'o74,
        PUL              = 'o75;

assign { 
        we, 
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
        up_div, 
        up_cc, 
        up_abx, 
        up_ab, 
        uc_loop, 
        shd_en, 
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
        set_opn0_mem, 
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
        div_en, 
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
        9'o000: ucode <= 59'h4001800;    // RESET
        9'o004: ucode <= 59'h10000000;
        9'o010: ucode <= 59'h3000000000;    // FIRQ
        9'o011: ucode <= 59'h1800;
        9'o013: ucode <= 59'h4001A00;
        9'o015: ucode <= 59'h10000000;
        9'o020: ucode <= 59'h2800000000;    // IRQ
        9'o021: ucode <= 59'h1000;
        9'o023: ucode <= 59'h4001400;
        9'o025: ucode <= 59'h10000000;
        9'o030: ucode <= 59'h2800000000;    // NMI
        9'o031: ucode <= 59'h1800;
        9'o033: ucode <= 59'h4001C00;
        9'o035: ucode <= 59'h10000000;
        9'o040: ucode <= 59'h008;    // BUSERROR
        9'o050: ucode <= 59'h40000000;    // PARSE_IDX
        9'o051: ucode <= 59'h200000;
        9'o061: ucode <= 59'h100000;
        9'o070: ucode <= 59'h400000;    // IDX_RINC
        9'o071: ucode <= 59'h100000;
        9'o100: ucode <= 59'h402000;    // IDX_RINC2
        9'o101: ucode <= 59'h100000;
        9'o110: ucode <= 59'h800000;    // IDX_RDEC
        9'o111: ucode <= 59'h100000;
        9'o120: ucode <= 59'h2000;    // IDX_RDEC2
        9'o121: ucode <= 59'h800000;
        9'o122: ucode <= 59'h100000;
        9'o130: ucode <= 59'h40000000;    // IDX_OFFSET8
        9'o131: ucode <= 59'h108000;
        9'o140: ucode <= 59'h48000000;    // IDX_OFFSET16
        9'o141: ucode <= 59'h40000000;
        9'o142: ucode <= 59'h104000;
        9'o150: ucode <= 59'h8080000;    // IDX_IND
        9'o151: ucode <= 59'hA0000;
        9'o152: ucode <= 59'h1000010;
        9'o160: ucode <= 59'h48000000;    // IDX_EXT
        9'o161: ucode <= 59'h40000000;
        9'o162: ucode <= 59'h100010;
        9'o170: ucode <= 59'h40000000;    // IDX_DP
        9'o171: ucode <= 59'h140000;
        9'o201: ucode <= 59'h110000;
        9'o210: ucode <= 59'h40000000;    // SINGLE_ALU
        9'o211: ucode <= 59'h4400000000000;
        9'o212: ucode <= 59'h10000000;
        9'o220: ucode <= 59'h40000000;    // CMP8
        9'o221: ucode <= 59'h400000000000;
        9'o222: ucode <= 59'h10000000;
        9'o230: ucode <= 59'h80000;    // CMP8_IDX
        9'o231: ucode <= 59'h400000000000;
        9'o232: ucode <= 59'h10000000;
        9'o240: ucode <= 59'h48000000;    // SINGLE_ALU_16
        9'o241: ucode <= 59'h40000000;
        9'o242: ucode <= 59'h2400000000000;
        9'o243: ucode <= 59'h10000000;
        9'o250: ucode <= 59'h48000000;    // SINGLE_ALUD
        9'o251: ucode <= 59'h40000000;
        9'o252: ucode <= 59'h500000000000;
        9'o253: ucode <= 59'h10000000;
        9'o260: ucode <= 59'h8080000;    // SINGLE_ALUD_IDX
        9'o261: ucode <= 59'hA0000;
        9'o262: ucode <= 59'h500000000000;
        9'o263: ucode <= 59'h10000000;
        9'o270: ucode <= 59'h48000000;    // CMP16
        9'o271: ucode <= 59'h40000000;
        9'o272: ucode <= 59'h400000000000;
        9'o273: ucode <= 59'h10000000;
        9'o300: ucode <= 59'h8080000;    // CMP16_IDX
        9'o301: ucode <= 59'hA0000;
        9'o302: ucode <= 59'h400000000000;
        9'o303: ucode <= 59'h10000000;
        9'o310: ucode <= 59'h8400000000000;    // SINGLE_A_INH
        9'o311: ucode <= 59'h10000000;
        9'o320: ucode <= 59'h10400000000000;    // SINGLE_B_INH
        9'o321: ucode <= 59'h10000000;
        9'o330: ucode <= 59'h500000000000;    // SINGLE_ALU_INH16
        9'o331: ucode <= 59'h10000000;
        9'o340: ucode <= 59'h200000000000;    // SINGLE_ABX
        9'o341: ucode <= 59'h10000000;
        9'o350: ucode <= 59'h80000;    // SINGLE_ALU_IDX
        9'o351: ucode <= 59'h4400000000000;
        9'o352: ucode <= 59'h10000000;
        9'o360: ucode <= 59'h8080000;    // SINGLE_ALU_IDX16
        9'o361: ucode <= 59'hA0000;
        9'o362: ucode <= 59'h2400000000000;
        9'o363: ucode <= 59'h10000000;
        9'o370: ucode <= 59'h40000000;    // SHIFTD
        9'o371: ucode <= 59'h40000000000;
        9'o373: ucode <= 59'h500000000000;
        9'o374: ucode <= 59'h10000000;
        9'o400: ucode <= 59'h8080000;    // SHIFTD_IDX
        9'o401: ucode <= 59'hA0000;
        9'o402: ucode <= 59'h400000A0000;
        9'o404: ucode <= 59'h400080000000;
        9'o405: ucode <= 59'h400000008080000;
        9'o406: ucode <= 59'h4000000000A0000;
        9'o410: ucode <= 59'h10000000;    // NOPE
        9'o420: ucode <= 59'h80000;    // MEM_ALU_IDX
        9'o421: ucode <= 59'h400400080080000;
        9'o422: ucode <= 59'h10000000;
        9'o430: ucode <= 59'h100;    // DIVIDE
        9'o433: ucode <= 59'hC00000000000;
        9'o434: ucode <= 59'h10000000;
        9'o440: ucode <= 59'h8080000;    // WMEM_ALU
        9'o441: ucode <= 59'hA0000;
        9'o442: ucode <= 59'h400000088080000;
        9'o443: ucode <= 59'h4004000800A0000;
        9'o444: ucode <= 59'h10000000;
        9'o454: ucode <= 59'h500000000000;
        9'o455: ucode <= 59'h10000000;
        9'o464: ucode <= 59'h80400000000000;
        9'o465: ucode <= 59'h10000000;
        9'o470: ucode <= 59'h40000000;    // LOOPX
        9'o471: ucode <= 59'h400000000080;
        9'o472: ucode <= 59'h004;
        9'o473: ucode <= 59'h10000000;
        9'o500: ucode <= 59'h40000000;    // LOOPB
        9'o501: ucode <= 59'h400000000020;
        9'o502: ucode <= 59'h004;
        9'o503: ucode <= 59'h10000000;
        9'o510: ucode <= 59'h002;    // MOVE
        9'o511: ucode <= 59'h500000000000001;
        9'o512: ucode <= 59'h10000000;
        9'o520: ucode <= 59'h20000000;    // BMOVE
        9'o522: ucode <= 59'h002;
        9'o523: ucode <= 59'h500000000000001;
        9'o524: ucode <= 59'h80000000000;
        9'o530: ucode <= 59'h20000000;    // BSETA
        9'o532: ucode <= 59'h400000002000041;
        9'o533: ucode <= 59'h80000000000;
        9'o540: ucode <= 59'h20000000;    // BSETD
        9'o542: ucode <= 59'h400000002000041;
        9'o543: ucode <= 59'h400000002000001;
        9'o544: ucode <= 59'h80000000000;
        9'o550: ucode <= 59'h400400000080000;    // STORE8
        9'o551: ucode <= 59'h10000000;
        9'o560: ucode <= 59'h400000008080000;    // STORE16
        9'o561: ucode <= 59'h4004000000A0000;
        9'o562: ucode <= 59'h10000000;
        9'o570: ucode <= 59'h20400000000000;    // LEA
        9'o571: ucode <= 59'h10000000;
        9'o600: ucode <= 59'h40000000;    // SETLNS
        9'o601: ucode <= 59'h40000010000000;
        9'o610: ucode <= 59'h80000;    // SETLNS_IDX
        9'o611: ucode <= 59'h40000010000000;
        9'o620: ucode <= 59'h40000000;    // EXCHANGE
        9'o621: ucode <= 59'h1000000000000;
        9'o622: ucode <= 59'h10000000;
        9'o630: ucode <= 59'h40000000;    // TRANSFER
        9'o631: ucode <= 59'h200000000000000;
        9'o632: ucode <= 59'h10000000;
        9'o640: ucode <= 59'h40000000;    // SBRANCH
        9'o641: ucode <= 59'h200000000;
        9'o642: ucode <= 59'h10000000;
        9'o650: ucode <= 59'h40000000;    // SBSR
        9'o651: ucode <= 59'h6000000000;
        9'o653: ucode <= 59'h200000000;
        9'o654: ucode <= 59'h10000000;
        9'o660: ucode <= 59'h48000000;    // BSRL
        9'o661: ucode <= 59'h40000000;
        9'o662: ucode <= 59'h6000000000;
        9'o664: ucode <= 59'h100000000;
        9'o665: ucode <= 59'h10000000;
        9'o670: ucode <= 59'h48000000;    // LBRANCH
        9'o671: ucode <= 59'h40000000;
        9'o672: ucode <= 59'h100000000;
        9'o673: ucode <= 59'h10000000;
        9'o700: ucode <= 59'h400000000;    // JUMP
        9'o701: ucode <= 59'h10000000;
        9'o710: ucode <= 59'h6000000000;    // JMSR
        9'o712: ucode <= 59'h400000000;
        9'o713: ucode <= 59'h10000000;
        9'o720: ucode <= 59'h18000000000;    // RTIT
        9'o722: ucode <= 59'h28000000000;
        9'o724: ucode <= 59'h10000000;
        9'o730: ucode <= 59'hC000000000;    // RTSR
        9'o733: ucode <= 59'h10000000;
        9'o740: ucode <= 59'h40000000;    // PSH
        9'o741: ucode <= 59'h2000000000;
        9'o744: ucode <= 59'h10000000;
        9'o750: ucode <= 59'h40000000;    // PUL
        9'o751: ucode <= 59'h8000000000;
        9'o754: ucode <= 59'h10000000;
        default: ucode <= 0;
    endcase
end

